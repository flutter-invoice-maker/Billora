const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * QR Resolve API endpoint
 * GET /api/qr/resolve?code=<payload>
 */
exports.resolve = functions.https.onRequest(async (req, res) => {
  // Enable CORS
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  if (req.method !== 'GET') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  try {
    const { code } = req.query;

    if (!code) {
      res.status(400).json({ error: 'QR code payload is required' });
      return;
    }

    // Parse QR code payload
    const qrData = parseQRPayload(code);
    
    if (!qrData || !qrData.invoice_id) {
      res.status(400).json({ error: 'Invalid QR code format' });
      return;
    }

    const invoiceId = qrData.invoice_id;

    // Get invoice from Firestore
    const invoiceDoc = await db.collection('invoices').doc(invoiceId).get();
    
    if (!invoiceDoc.exists) {
      res.status(404).json({ error: 'Invoice not found' });
      return;
    }

    const invoice = invoiceDoc.data();

    // Get AI analysis if available
    let aiAnalysis = null;
    try {
      const aiDoc = await db.collection('ai_analyses').doc(invoiceId).get();
      if (aiDoc.exists) {
        aiAnalysis = aiDoc.data();
      }
    } catch (error) {
      console.log('AI analysis not found for invoice:', invoiceId);
    }

    // Prepare public response (no sensitive data)
    const publicInvoiceData = {
      id: invoice.id,
      customer_name: invoice.customerName,
      total_amount: invoice.total,
      created_date: invoice.createdAt,
      due_date: invoice.dueDate,
      status: invoice.status,
      items_count: invoice.items?.length || 0,
      tags: invoice.tags || [],
      ai_summary: invoice.ai_summary,
      ai_classification: invoice.ai_classification,
      ai_status: invoice.ai_status
    };

    // Add AI analysis if available
    if (aiAnalysis) {
      publicInvoiceData.ai_analysis = {
        summary: aiAnalysis.summary,
        tags: aiAnalysis.tags,
        classification: aiAnalysis.classification,
        confidence: aiAnalysis.confidence,
        generated_at: aiAnalysis.generated_at
      };
    }

    res.status(200).json({
      success: true,
      data: {
        invoice: publicInvoiceData,
        qr_data: qrData
      }
    });

  } catch (error) {
    console.error('Error in QR resolve API:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      message: error.message 
    });
  }
});

/**
 * Parse QR code payload
 * Supports multiple formats:
 * 1. JSON: {"t":"inv","id":"HD00125","v":1}
 * 2. URL: https://billora.app/invoice/HD00125
 * 3. Simple ID: HD00125
 */
function parseQRPayload(payload) {
  try {
    // Try to parse as JSON first
    if (payload.startsWith('{')) {
      const jsonData = JSON.parse(payload);
      return {
        type: jsonData.t || 'invoice',
        invoice_id: jsonData.id,
        version: jsonData.v || 1
      };
    }

    // Try to parse as URL
    if (payload.startsWith('http')) {
      const url = new URL(payload);
      const pathParts = url.pathname.split('/');
      const invoiceId = pathParts[pathParts.length - 1];
      
      if (invoiceId) {
        return {
          type: 'invoice',
          invoice_id: invoiceId,
          version: 1
        };
      }
    }

    // Try to parse as simple invoice ID
    if (payload.length > 0) {
      return {
        type: 'invoice',
        invoice_id: payload,
        version: 1
      };
    }

    return null;

  } catch (error) {
    console.error('Error parsing QR payload:', error);
    return null;
  }
}

/**
 * Generate QR code data for invoice
 * POST /api/qr/generate
 */
exports.generate = functions.https.onRequest(async (req, res) => {
  // Enable CORS
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  try {
    const { invoiceId } = req.body;

    if (!invoiceId) {
      res.status(400).json({ error: 'invoiceId is required' });
      return;
    }

    // Verify invoice exists
    const invoiceDoc = await db.collection('invoices').doc(invoiceId).get();
    
    if (!invoiceDoc.exists) {
      res.status(404).json({ error: 'Invoice not found' });
      return;
    }

    // Generate QR data (minimal, no PII)
    const qrData = {
      t: 'inv',
      id: invoiceId,
      v: 1
    };

    // Store QR data in Firestore
    await db.collection('qr_codes').doc(invoiceId).set({
      invoice_id: invoiceId,
      data: JSON.stringify(qrData),
      generated_at: admin.firestore.FieldValue.serverTimestamp(),
      type: 'invoice_lookup'
    });

    res.status(200).json({
      success: true,
      data: {
        qr_data: qrData,
        qr_string: JSON.stringify(qrData),
        lookup_url: `https://billora.app/invoice/${invoiceId}`
      }
    });

  } catch (error) {
    console.error('Error in QR generate API:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      message: error.message 
    });
  }
}); 