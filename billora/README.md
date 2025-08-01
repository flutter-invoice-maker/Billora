# Billora - Flutter Invoice Maker

A professional invoice management application built with Flutter, Firebase, and SendGrid.

## 🚀 Features

### Week 7 - Smart Suggestions & Tags System ✅
- **Smart Product Suggestions**: AI-powered product recommendations based on usage history
- **Intelligent Scoring Algorithm**: Weighted scoring using frequency, recency, relevance, and similarity
- **Fuzzy Search**: Find products even with typos using Levenshtein distance
- **Tags Management**: Create, manage, and organize invoices with colorful tags
- **Usage Analytics**: Track product and customer usage patterns
- **TypeAhead Autocomplete**: Real-time suggestions with flutter_typeahead
- **Colorful Tag System**: Custom colors for better visual organization
- **Offline Support**: Local caching with SQLite for better performance

### Week 6 - Advanced Invoice Features ✅
- **PDF Generation**: Generate professional PDF invoices with multiple templates
- **Email Integration**: Send invoices via SendGrid API with beautiful HTML templates
- **Cloud Storage**: Upload PDFs to Firebase Storage with shareable links
- **Template System**: Multiple invoice templates (Template A, B, C)
- **Real-time Notifications**: Loading indicators and success/error feedback
- **Bill Scanner**: Professional OCR scanning with ML Kit and free APIs
- **Smart Data Extraction**: Vietnamese currency, date, phone number recognition
- **Camera Integration**: Real-time document detection and capture
- **Image Processing**: Automatic optimization for better OCR results

### Core Features
- **Authentication**: Firebase Auth with Google/Apple Sign-in
- **Customer Management**: CRUD operations for customers
- **Product Catalog**: Product and service management
- **Invoice Management**: Create, edit, delete invoices
- **Multi-language Support**: English and Vietnamese
- **Clean Architecture**: Domain-driven design with BLoC pattern

## 🛠️ Setup Instructions

### 1. Prerequisites
- Flutter SDK (^3.7.2)
- Firebase project
- SendGrid account
- Camera permissions (for bill scanning)

### 2. Environment Configuration

1. Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```

2. Update `.env` with your credentials:
```env
# SendGrid Configuration
SENDGRID_API_KEY=your_sendgrid_api_key_here
SENDGRID_FROM_EMAIL=noreply@yourdomain.com
SENDGRID_FROM_NAME=Your App Name
```

### 3. Firebase Setup
1. Create a Firebase project
2. Enable Authentication, Firestore, and Storage
3. Download and add configuration files:
   - `google-services.json` (Android)
   - `GoogleService-Info.plist` (iOS)

### 4. SendGrid Setup
1. Create a SendGrid account
2. Generate an API key
3. Verify your sender email domain
4. Update the `.env` file with your API key

### 5. Install Dependencies
```bash
flutter pub get
```

### 6. Run the Application
```bash
flutter run
```

### 7. Test Smart Suggestions & Tags
Navigate to the demo page to test the new features:
```bash
# In the app, navigate to:
/suggestions-demo
```

Or add this route to your navigation:
```dart
Navigator.pushNamed(context, '/suggestions-demo');
```

## 📁 Project Structure

```
lib/
├── src/
│   ├── core/
│   │   ├── constants/
│   │   ├── di/
│   │   ├── services/
│   │   │   ├── email_service.dart      # SendGrid integration
│   │   │   ├── pdf_service.dart        # PDF generation
│   │   │   └── storage_service.dart    # Firebase Storage
│   │   └── widgets/
│   ├── features/
│   │   ├── auth/                       # Authentication
│   │   ├── bill_scanner/               # Bill scanning & OCR
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── ocr_datasource.dart
│   │   │   │   │   ├── free_ocr_api_datasource.dart
│   │   │   │   │   └── image_processing_datasource.dart
│   │   │   │   └── repositories/
│   │   │   └── presentation/
│   │   │       ├── cubit/
│   │   │       ├── pages/
│   │   │       └── widgets/
│   │   ├── customer/                   # Customer management
│   │   ├── invoice/                    # Invoice management
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   │       ├── generate_pdf_usecase.dart
│   │   │   │       ├── send_invoice_email_usecase.dart
│   │   │   │       └── upload_invoice_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── cubit/
│   │   │       ├── pages/
│   │   │       └── widgets/
│   │   └── product/                    # Product management
│   └── widgets/
└── main.dart
```

## 🔧 Week 6 Implementation Details

### PDF Generation
- Uses `pdf` package for professional PDF creation
- Multiple template support (Template A, B, C)
- Includes invoice details, items, totals, and notes

### Email Integration
- SendGrid API integration with HTTP requests
- Beautiful HTML email templates
- PDF attachment support
- Error handling and user feedback

### Cloud Storage
- Firebase Storage integration
- Automatic file naming and organization
- Shareable download links
- Clipboard integration for easy sharing

### Bill Scanner & OCR
- **ML Kit Integration**: On-device text recognition with Google ML Kit
- **Free OCR APIs**: Fallback to OCR.Space API (500 requests/month free)
- **Smart Data Extraction**: Vietnamese currency, date, phone patterns
- **Image Processing**: Automatic optimization for better OCR results
- **Camera Integration**: Real-time document detection and capture
- **Confidence Scoring**: Quality assessment for extracted data

### UI/UX Improvements
- Loading indicators for all async operations
- Success/error notifications with icons
- Professional color-coded feedback
- Responsive design considerations
- Animated camera overlay with scanning guide

## 🧪 Testing

Run tests with coverage:
```bash
flutter test --coverage
```

## 📱 Supported Platforms

- Android
- iOS
- Web
- macOS
- Linux
- Windows

## 🔒 Security

- API keys stored in `.env` file (not committed to git)
- Firebase security rules configured
- Input validation and sanitization
- Error handling for all external services

## 📄 License

This project is licensed under the MIT License.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📞 Support

For support and questions, please open an issue on GitHub.
