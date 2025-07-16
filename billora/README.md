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
