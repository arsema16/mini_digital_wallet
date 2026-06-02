import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // For Android/Windows
    return android;
  }

  static const FirebaseOptions web = FirebaseOptions(
   apiKey: "AIzaSyDiy68cdStmD9F6xpSnN29c61JUwQ5zBhE",
  authDomain: "mini-digital-wallet.firebaseapp.com",
  projectId: "mini-digital-wallet",
  storageBucket: "mini-digital-wallet.firebasestorage.app",
  messagingSenderId: "932446762055",
  appId: "1:932446762055:web:25199fe42260676a45ed62",
  measurementId: "G-5Y0TBCG8RW"
  );

  static const FirebaseOptions android = FirebaseOptions(
  apiKey: "AIzaSyA_mzrcJ-chYJWuqQS1bIbWGBadpLf5yIo",  // ← Get from google-services.json
  appId: "1:932446762055:android:0fb06540e29973fb45ed62",  // ← From screenshot
  messagingSenderId: "932446762055",  // Same as web
  projectId: "mini-digital-wallet",  // Your project ID
  storageBucket: "mini-digital-wallet.firebasestorage.app",  // Same as web
);
}