const functions = require('firebase-functions');
const admin = require('firebase-admin');
const cors = require('cors')({ 
  origin: true, // Allow all origins including localhost
  credentials: true 
});

// Initialize Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * AI Suggest Tags API endpoint
 * POST /api/ai/suggestTags
 */
exports.suggestTags = functions.https.onRequest(async (req, res) => {
  // Use CORS middleware
  return cors(req, res, async () => {
    if (req.method !== 'POST') {
      res.status(405).json({ error: 'Method not allowed' });
      return;
    }

    try {
      const { invoiceId, invoiceData, message } = req.body;

      if (!invoiceId && !invoiceData) {
        res.status(400).json({ error: 'invoiceId or invoiceData is required' });
        return;
      }

      let analysisData;

      if (invoiceId) {
        // Get invoice from Firestore
        const invoiceDoc = await db.collection('invoices').doc(invoiceId).get();
        
        if (!invoiceDoc.exists) {
          res.status(404).json({ error: 'Invoice not found' });
          return;
        }

        const invoice = invoiceDoc.data();
        analysisData = {
          invoice_id: invoiceId,
          customer_name: invoice.customerName || '',
          items: invoice.items || [],
          total_amount: invoice.total || 0,
          created_date: invoice.createdAt,
          description: invoice.note || '',
          tags: invoice.tags || []
        };
      } else {
        // Use provided invoice data
        analysisData = {
          invoice_id: invoiceData.id || 'temp',
          customer_name: invoiceData.customerName || '',
          items: invoiceData.items || [],
          total_amount: invoiceData.total || 0,
          created_date: invoiceData.createdAt,
          description: invoiceData.note || '',
          tags: invoiceData.tags || []
        };
      }

      // Perform AI analysis
      const aiResult = await performAIAnalysis(analysisData, message);

      res.status(200).json({
        success: true,
        response: aiResult.summary,
        data: {
          suggested_tags: aiResult.suggested_tags,
          summary: aiResult.summary,
          classification: aiResult.classification,
          confidence: aiResult.confidence
        }
      });

    } catch (error) {
      console.error('Error in suggestTags API:', error);
      res.status(500).json({ 
        error: 'Internal server error',
        message: error.message 
      });
    }
  });
});

/**
 * Perform AI analysis using Hugging Face API
 */
async function performAIAnalysis(invoiceData, userMessage = '') {
  const HUGGING_FACE_API_KEY = process.env.HUGGING_FACE_API_KEY;
  const MODEL_ENDPOINT = 'https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.2';
  
  if (!HUGGING_FACE_API_KEY) {
    throw new Error('HUGGING_FACE_API_KEY not configured');
  }

  // Prepare items text
  const itemsText = invoiceData.items.map(item => 
    `${item.name} (${item.quantity}x)`
  ).join(', ');

  // Create analysis prompt based on user message
  let prompt;
  if (userMessage.toLowerCase().includes('tag')) {
    prompt = `Analyze this invoice and suggest relevant tags for categorization. 
Invoice details: Customer: ${invoiceData.customer_name}, Items: ${itemsText}, Total: $${invoiceData.total_amount}, Note: ${invoiceData.description}. 
Suggest 3-5 relevant tags separated by commas.`;
  } else if (userMessage.toLowerCase().includes('summary')) {
    prompt = `Generate a brief summary of this invoice. 
Invoice details: Customer: ${invoiceData.customer_name}, Items: ${itemsText}, Total: $${invoiceData.total_amount}, Note: ${invoiceData.description}. 
Provide a concise summary in 1-2 sentences.`;
  } else if (userMessage.toLowerCase().includes('anomaly') || userMessage.toLowerCase().includes('insight')) {
    prompt = `Analyze this invoice for business insights and potential anomalies. 
Invoice details: Customer: ${invoiceData.customer_name}, Items: ${itemsText}, Total: $${invoiceData.total_amount}, Note: ${invoiceData.description}. 
Identify any unusual patterns or provide business insights.`;
  } else {
    // Default analysis
    prompt = `Analyze this invoice and provide insights. 
Invoice details: Customer: ${invoiceData.customer_name}, Items: ${itemsText}, Total: $${invoiceData.total_amount}, Note: ${invoiceData.description}. 
Provide relevant analysis and suggestions.`;
  }

  try {
    const response = await fetch(MODEL_ENDPOINT, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${HUGGING_FACE_API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        inputs: prompt,
        parameters: {
          max_new_tokens: 200,
          temperature: 0.7,
          return_full_text: false
        }
      })
    });

    if (!response.ok) {
      throw new Error(`AI API error: ${response.status} - ${response.statusText}`);
    }

    const data = await response.json();
    const generatedText = data[0]?.generated_text || '';

    // Parse tags from response
    const tags = parseTagsFromResponse(generatedText);
    
    return {
      suggested_tags: tags,
      summary: generatedText.trim() || 'Analysis completed successfully',
      classification: 'General',
      confidence: 0.8
    };

  } catch (error) {
    console.error('AI API call failed:', error);
    throw new Error(`AI analysis failed: ${error.message}`);
  }
}

/**
 * Parse tags from AI response
 */
function parseTagsFromResponse(response) {
  try {
    // Clean response and extract tags
    const cleanResponse = response.trim().toLowerCase();
    
    // Look for comma-separated tags
    const tagPattern = /[a-z0-9\s]+(?:,|$)/gi;
    const matches = cleanResponse.match(tagPattern);
    
    if (!matches) return [];

    const tags = [];
    for (const match of matches) {
      const tag = match.trim().replace(',', '').trim();
      if (tag && tag.length > 0 && tags.length < 5) {
        // Capitalize first letter of each word
        const capitalizedTag = tag.split(' ')
          .map(word => word.charAt(0).toUpperCase() + word.slice(1))
          .join(' ');
        tags.push(capitalizedTag);
      }
    }

    return tags;

  } catch (error) {
    console.error('Error parsing tags:', error);
    return [];
  }
} 