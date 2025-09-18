// Sample file: copy to lib/firebase_options.dart and fill real values locally.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => throw UnimplementedError(
      'Provide real firebase_options.dart locally (ignored by VCS).');

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_FIREBASE_API_KEY',
    appId: '1:YOUR_SENDER_ID:web:YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'your-project-id',
    authDomain: 'your-project-id.firebaseapp.com',
    storageBucket: 'your-project-id.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_FIREBASE_API_KEY',
    appId: '1:YOUR_SENDER_ID:android:YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'your-project-id',
    storageBucket: 'your-project-id.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_FIREBASE_API_KEY',
    appId: '1:YOUR_SENDER_ID:ios:YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'your-project-id',
    storageBucket: 'your-project-id.firebasestorage.app',
    iosBundleId: 'your.bundle.id',
  );
}

