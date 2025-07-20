# Billora

Billora là ứng dụng Flutter quản lý hóa đơn, sử dụng Clean Architecture và tích hợp Firebase.

## Kiến trúc
- Clean Architecture
- Firebase (Auth, Firestore, Storage)
- State management: flutter_bloc
- Dependency Injection: get_it, injectable

## Cấu trúc thư mục
```
lib/
└── src/
    ├── core/
    │   ├── constants/
    │   ├── network/
    │   ├── errors/
    │   ├── utils/
    │   └── di/
    └── features/
```

## Cài đặt
```bash
flutter pub get
flutterfire configure # Để tạo firebase_options.dart
```

## Phát triển
- Tuần 1: Setup project, core, Firebase, DI
- Tuần 2+: Xây dựng các tính năng theo plan

## Build iOS với flavor

### 1. Generate flavor (chạy 1 lần)
flutter pub run flutter_flavorizr

### 2. Mở project bằng Xcode
open ios/Runner.xcworkspace

### 3. Chọn scheme (Dev/Prod) và build
- Product > Scheme > Billora Dev hoặc Billora
- Product > Run

### 4. Đảm bảo file GoogleService-Info-Dev.plist và GoogleService-Info-Prod.plist đúng vị trí

## Sử dụng CustomCupertinoButton

```dart
import 'package:billora/src/core/widgets/custom_cupertino_button.dart';

CustomCupertinoButton(
  text: 'Đăng nhập',
  onPressed: () {},
)
```

## Chạy test

```bash
flutter test
```

## CI/CD
- Đã cấu hình GitHub Actions tự động build/test khi push code.

## Cloud Functions
- Đã có thư mục functions, có thể deploy function mẫu lên Firebase.

## Design System
- Đã có theme, custom widgets, ưu tiên style iOS.
