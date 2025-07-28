import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmailService {
  static const String _sendGridUrl = 'https://api.sendgrid.com/v3/mail/send';
  
  String get _sendGridApiKey => dotenv.env['SENDGRID_API_KEY'] ?? '';
  String get _fromEmail => dotenv.env['SENDGRID_FROM_EMAIL'] ?? 'noreply@billora.com';
  String get _fromName => dotenv.env['SENDGRID_FROM_NAME'] ?? 'Billora Invoice System';

  Future<void> sendInvoiceEmail({
    required String toEmail,
    required String subject,
    required String body,
    required Uint8List pdfData,
    required String fileName,
  }) async {
    try {
      // Encode PDF data to base64
      final base64Pdf = base64Encode(pdfData);
      
      // Prepare SendGrid API request body
      final requestBody = {
        'personalizations': [
          {
            'to': [
              {
                'email': toEmail,
                'name': 'Customer'
              }
            ],
            'subject': subject
          }
        ],
        'from': {
          'email': _fromEmail,
          'name': _fromName
        },
        'content': [
          {
            'type': 'text/html',
            'value': _buildHtmlEmail(body)
          }
        ],
        'attachments': [
          {
            'content': base64Pdf,
            'filename': fileName,
            'type': 'application/pdf',
            'disposition': 'attachment'
          }
        ]
      };

      // Make API request to SendGrid
      final response = await http.post(
        Uri.parse(_sendGridUrl),
        headers: {
          'Authorization': 'Bearer $_sendGridApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 202) {
        throw Exception('Failed to send email: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending email: $e');
    }
  }

  String _buildHtmlEmail(String body) {
    return '''
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
            .button {
                display: inline-block;
                background: #667eea;
                color: white;
                padding: 12px 24px;
                text-decoration: none;
                border-radius: 5px;
                margin: 20px 0;
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
            <p>$body</p>
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
    ''';
  }
} 