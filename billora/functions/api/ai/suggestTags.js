const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * Suggest tags for invoice using AI
 * Triggered by HTTP POST request
 */
exports.suggestTags = functions.https.onRequest(async (req, res) => {
  // Enable CORS
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  if (req.method !== 'POST') {
    res.status(405).send('Method Not Allowed');
    return;
  }

  try {
    const { invoiceData, userMessage } = req.body;

    if (!invoiceData) {
      res.status(400).json({ error: 'Invoice data is required' });
      return;
    }

    // Perform AI analysis
    const aiResult = await performAIAnalysis(invoiceData, userMessage);

    // Store analysis result
    const analysisId = admin.firestore().collection('ai_analyses').doc().id;
    await db.collection('ai_analyses').doc(analysisId).set({
      id: analysisId,
      invoice_data: invoiceData,
      user_message: userMessage || '',
      suggested_tags: aiResult.suggested_tags,
      summary: aiResult.summary,
      classification: aiResult.classification,
      confidence: aiResult.confidence,
      model_info: {
        provider: 'openai',
        model_id: 'gpt-3.5-turbo',
        version: '1.0',
        api_endpoint: 'https://api.openai.com/v1/chat/completions'
      },
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      raw_response: aiResult.raw_response
    });

    res.status(200).json({
      success: true,
      data: {
        suggested_tags: aiResult.suggested_tags,
        summary: aiResult.summary,
        classification: aiResult.classification,
        confidence: aiResult.confidence,
        analysis_id: analysisId
      }
    });

  } catch (error) {
    console.error('Error in suggestTags function:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Internal server error'
    });
  }
});

/**
 * Perform AI analysis using ChatGPT API
 */
async function performAIAnalysis(invoiceData, userMessage = '') {
  const OPENAI_API_KEY = process.env.OPENAI_API_KEY;
  const MODEL_ENDPOINT = 'https://api.openai.com/v1/chat/completions';
  
  if (!OPENAI_API_KEY) {
    throw new Error('OPENAI_API_KEY not configured');
  }

  // Prepare items text
  const itemsText = invoiceData.items?.map(item => 
    `${item.name} (${item.quantity}x)`
  ).join(', ') || '';

  // Create analysis prompt
  let prompt = `Analyze this invoice and suggest relevant tags for categorization.

Invoice details:
- Customer: ${invoiceData.customerName || 'Unknown'}
- Items: ${itemsText}
- Total: $${invoiceData.total || 0}
- Description: ${invoiceData.description || ''}

Please suggest 3-5 relevant tags separated by commas. Return only the tags, no additional text.
Example format: tag1, tag2, tag3, tag4`;

  if (userMessage) {
    prompt += `\n\nUser request: ${userMessage}\nProvide relevant analysis and suggestions.`;
  }

  try {
    const response = await fetch(MODEL_ENDPOINT, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${OPENAI_API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: 'gpt-3.5-turbo',
        messages: [
          {
            role: 'system',
            content: 'You are an AI assistant specialized in invoice analysis and business intelligence. Be concise and professional in your responses.'
          },
          {
            role: 'user',
            content: prompt
          }
        ],
        max_tokens: 200,
        temperature: 0.7,
      })
    });

    if (!response.ok) {
      throw new Error(`AI API error: ${response.status} - ${response.statusText}`);
    }

    const data = await response.json();
    const generatedText = data.choices[0]?.message?.content || '';

    // Parse tags from response
    const tags = parseTagsFromResponse(generatedText);
    
    return {
      suggested_tags: tags,
      summary: generatedText.trim() || 'Analysis completed successfully',
      classification: 'General',
      confidence: 0.8,
      raw_response: generatedText
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
    // Clean response and split by comma
    const cleanResponse = response.trim().replace(/\n/g, '');
    const tags = cleanResponse.split(',')
        .map(tag => tag.trim())
        .filter(tag => tag.length > 0)
        .slice(0, 5);
    
    return tags.length > 0 ? tags : ['General', 'Business', 'Invoice'];
  } catch (e) {
    console.error('Error parsing tags:', e);
    return ['General', 'Business', 'Invoice'];
  }
} 