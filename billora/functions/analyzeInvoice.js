const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * Analyze invoice using AI and store results
 * Triggered by Firestore onCreate/onUpdate or explicit POST
 */
exports.analyzeInvoice = functions.firestore
  .document('invoices/{invoiceId}')
  .onCreate(async (snap, context) => {
    const invoiceId = context.params.invoiceId;
    const invoiceData = snap.data();
    
    try {
      // Update status to pending
      await snap.ref.update({
        ai_status: 'pending',
        ai_updated_at: admin.firestore.FieldValue.serverTimestamp()
      });

      // Prepare invoice data for AI analysis
      const analysisData = {
        invoice_id: invoiceId,
        customer_name: invoiceData.customerName || '',
        items: invoiceData.items || [],
        total_amount: invoiceData.total || 0,
        created_date: invoiceData.createdAt,
        description: invoiceData.note || '',
        tags: invoiceData.tags || []
      };

      // Call AI analysis
      const aiResult = await performAIAnalysis(analysisData);
      
      // Store AI analysis results
      await db.collection('ai_analyses').doc(invoiceId).set({
        invoice_id: invoiceId,
        generated_at: admin.firestore.FieldValue.serverTimestamp(),
        summary: aiResult.summary,
        tags: aiResult.suggested_tags,
        classification: aiResult.classification,
        confidence: aiResult.confidence,
        model_info: {
          provider: 'hugging_face',
          model_id: 'mistralai/Mistral-7B-Instruct-v0.2',
          version: '1.0',
          metadata_json_url: 'https://huggingface.co/mistralai/Mistral-7B-Instruct-v0.2'
        },
        raw_response: aiResult.raw_response
      });

      // Update invoice with AI results
      await snap.ref.update({
        ai_status: 'done',
        ai_summary: aiResult.summary,
        ai_classification: aiResult.classification,
        ai_suggested_tags: aiResult.suggested_tags,
        ai_updated_at: admin.firestore.FieldValue.serverTimestamp()
      });

      console.log(`AI analysis completed for invoice ${invoiceId}`);
      
    } catch (error) {
      console.error(`Error analyzing invoice ${invoiceId}:`, error);
      
      // Update status to error
      await snap.ref.update({
        ai_status: 'error',
        ai_error_reason: error.message,
        ai_updated_at: admin.firestore.FieldValue.serverTimestamp()
      });
    }
  });

/**
 * Perform AI analysis using Hugging Face API
 */
async function performAIAnalysis(invoiceData) {
  const HUGGING_FACE_API_KEY = process.env.HUGGING_FACE_API_KEY;
  const MODEL_ENDPOINT = 'https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.2';
  
  if (!HUGGING_FACE_API_KEY) {
    throw new Error('HUGGING_FACE_API_KEY not configured');
  }

  // Prepare items text
  const itemsText = invoiceData.items.map(item => 
    `${item.name} (${item.quantity}x)`
  ).join(', ');

  // Create analysis prompt
  const prompt = `Analyze this invoice and provide:
1. A brief summary (max 100 characters)
2. Suggested tags (comma-separated, max 5 tags)
3. Classification (one of: Food & Beverage, Electronics, Services, Clothing, Software, Hardware, General)

Invoice details:
- Customer: ${invoiceData.customer_name}
- Items: ${itemsText}
- Total: $${invoiceData.total_amount}
- Description: ${invoiceData.description}

Format response as JSON:
{
  "summary": "brief summary here",
  "suggested_tags": ["tag1", "tag2", "tag3"],
  "classification": "category",
  "confidence": 0.85
}`;

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
          max_new_tokens: 500,
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

    // Parse AI response
    const aiResult = parseAIResponse(generatedText);
    
    return {
      summary: aiResult.summary || 'Invoice analysis completed',
      suggested_tags: aiResult.suggested_tags || [],
      classification: aiResult.classification || 'General',
      confidence: aiResult.confidence || 0.8,
      raw_response: generatedText
    };

  } catch (error) {
    console.error('AI API call failed:', error);
    throw new Error(`AI analysis failed: ${error.message}`);
  }
}

/**
 * Parse AI response to extract structured data
 */
function parseAIResponse(response) {
  try {
    // Try to extract JSON from response
    const jsonMatch = response.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      const jsonData = JSON.parse(jsonMatch[0]);
      return {
        summary: jsonData.summary,
        suggested_tags: Array.isArray(jsonData.suggested_tags) ? jsonData.suggested_tags : [],
        classification: jsonData.classification,
        confidence: jsonData.confidence || 0.8
      };
    }

    // Fallback parsing if JSON not found
    const lines = response.split('\n');
    const result = {
      summary: '',
      suggested_tags: [],
      classification: 'General',
      confidence: 0.8
    };

    for (const line of lines) {
      if (line.includes('summary:') || line.includes('Summary:')) {
        result.summary = line.split(':')[1]?.trim() || '';
      } else if (line.includes('tags:') || line.includes('Tags:')) {
        const tagsText = line.split(':')[1]?.trim() || '';
        result.suggested_tags = tagsText.split(',').map(tag => tag.trim()).filter(tag => tag);
      } else if (line.includes('classification:') || line.includes('Classification:')) {
        result.classification = line.split(':')[1]?.trim() || 'General';
      }
    }

    return result;

  } catch (error) {
    console.error('Error parsing AI response:', error);
    return {
      summary: 'Invoice analysis completed',
      suggested_tags: [],
      classification: 'General',
      confidence: 0.8
    };
  }
}

/**
 * Manual trigger for AI analysis
 */
exports.triggerAnalyzeInvoice = functions.https.onCall(async (data, context) => {
  // Check authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { invoiceId } = data;
  
  if (!invoiceId) {
    throw new functions.https.HttpsError('invalid-argument', 'invoiceId is required');
  }

  try {
    const invoiceRef = db.collection('invoices').doc(invoiceId);
    const invoiceDoc = await invoiceRef.get();
    
    if (!invoiceDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Invoice not found');
    }

    // Trigger analysis by updating the document
    await invoiceRef.update({
      ai_status: 'pending',
      ai_updated_at: admin.firestore.FieldValue.serverTimestamp()
    });

    return { success: true, message: 'AI analysis triggered' };
    
  } catch (error) {
    console.error('Error triggering AI analysis:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
}); 