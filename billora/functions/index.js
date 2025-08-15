const functions = require('firebase-functions');
const sgMail = require('@sendgrid/mail');
const cors = require('cors')({ origin: true });

// Import AI and QR functions
const aiFunctions = require('./analyzeInvoice');
const aiApiFunctions = require('./api/ai/suggestTags');
const qrApiFunctions = require('./api/qr/resolve');

// Initialize SendGrid with API key
sgMail.setApiKey(functions.config().sendgrid.key);

// Export AI and QR functions
exports.analyzeInvoice = aiFunctions.analyzeInvoice;
exports.triggerAnalyzeInvoice = aiFunctions.triggerAnalyzeInvoice;
exports.suggestTags = aiApiFunctions.suggestTags;
exports.qrResolve = qrApiFunctions.resolve;
exports.qrGenerate = qrApiFunctions.generate;

// Callable function (recommended for authenticated requests)
exports.sendInvoiceEmail = functions.https.onCall(async (data, context) => {
  // Check if user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  try {
    const { toEmail, subject, body, pdfData, fileName } = data;

    // Validate required fields
    if (!toEmail || !subject || !body || !pdfData || !fileName) {
      throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
    }

    // Create email message
    const msg = {
      to: toEmail,
      from: {
        email: functions.config().sendgrid.from_email || 'noreply@billora.com',
        name: functions.config().sendgrid.from_name || 'Billora Invoice System'
      },
      subject: subject,
      html: `
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Invoice</title>
            <style>
                body {
                    font-family: Arial, sans-serif;
                    line-height: 1.6;
                    color: #333;
                    max-width: 600px;
                    margin: 0 auto;
                    padding: 20px;
                }
                .header {
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    color: white;
                    padding: 30px;
                    text-align: center;
                    border-radius: 10px 10px 0 0;
                }
                .content {
                    background: #f9f9f9;
                    padding: 30px;
                    border-radius: 0 0 10px 10px;
                }
                .footer {
                    text-align: center;
                    margin-top: 20px;
                    color: #666;
                    font-size: 12px;
                }
            </style>
        </head>
        <body>
            <div class="header">
                <h1>📄 Invoice</h1>
                <p>Your invoice is ready!</p>
            </div>
            <div class="content">
                <p>Hello,</p>
                <p>${body}</p>
                <p>Please find your invoice attached to this email.</p>
                <p>If you have any questions, please don't hesitate to contact us.</p>
                <p>Best regards,<br>Billora Team</p>
            </div>
            <div class="footer">
                <p>This email was sent from Billora Invoice System</p>
                <p>© 2024 Billora. All rights reserved.</p>
            </div>
        </body>
        </html>
      `,
      attachments: [
        {
          content: pdfData,
          filename: fileName,
          type: 'application/pdf',
          disposition: 'attachment'
        }
      ]
    };

    // Send email
    await sgMail.send(msg);

    return { success: true, message: 'Email sent successfully' };
  } catch (error) {
    console.error('Error sending email:', error);
    throw new functions.https.HttpsError('internal', 'Failed to send email', error.message);
  }
});

// HTTP function with CORS (fallback for web)
exports.sendInvoiceEmailHttp = functions.https.onRequest((req, res) => {
  return cors(req, res, async () => {
    try {
      // Check if user is authenticated (you might want to add your own auth logic here)
      const authHeader = req.headers.authorization;
      if (!authHeader) {
        res.status(401).json({ error: 'Unauthorized' });
        return;
      }

      const { toEmail, subject, body, pdfData, fileName } = req.body;

      // Validate required fields
      if (!toEmail || !subject || !body || !pdfData || !fileName) {
        res.status(400).json({ error: 'Missing required fields' });
        return;
      }

      // Create email message
      const msg = {
        to: toEmail,
        from: {
          email: functions.config().sendgrid.from_email || 'noreply@billora.com',
          name: functions.config().sendgrid.from_name || 'Billora Invoice System'
        },
        subject: subject,
        html: `
          <!DOCTYPE html>
          <html>
          <head>
              <meta charset="utf-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <title>Invoice</title>
              <style>
                  body {
                      font-family: Arial, sans-serif;
                      line-height: 1.6;
                      color: #333;
                      max-width: 600px;
                      margin: 0 auto;
                      padding: 20px;
                  }
                  .header {
                      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                      color: white;
                      padding: 30px;
                      text-align: center;
                      border-radius: 10px 10px 0 0;
                  }
                  .content {
                      background: #f9f9f9;
                      padding: 30px;
                      border-radius: 0 0 10px 10px;
                  }
                  .footer {
                      text-align: center;
                      margin-top: 20px;
                      color: #666;
                      font-size: 12px;
                  }
              </style>
          </head>
          <body>
              <div class="header">
                  <h1>📄 Invoice</h1>
                  <p>Your invoice is ready!</p>
              </div>
              <div class="content">
                  <p>Hello,</p>
                  <p>${body}</p>
                  <p>Please find your invoice attached to this email.</p>
                  <p>If you have any questions, please don't hesitate to contact us.</p>
                  <p>Best regards,<br>Billora Team</p>
              </div>
              <div class="footer">
                  <p>This email was sent from Billora Invoice System</p>
                  <p>© 2024 Billora. All rights reserved.</p>
              </div>
          </body>
          </html>
        `,
        attachments: [
          {
            content: pdfData,
            filename: fileName,
            type: 'application/pdf',
            disposition: 'attachment'
          }
        ]
      };

      // Send email
      await sgMail.send(msg);

      res.status(200).json({ success: true, message: 'Email sent successfully' });
    } catch (error) {
      console.error('Error sending email:', error);
      res.status(500).json({ error: 'Failed to send email', details: error.message });
    }
  });
}); 