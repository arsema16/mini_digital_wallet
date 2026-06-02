import 'package:flutter/foundation.dart' show kIsWeb;
import 'local_database.dart';
import 'sqlite_database.dart';
import 'web_database.dart';

class DatabaseFactory {
  static LocalDatabase create() {
    if (kIsWeb) {
      print('🌐 Running on WEB - Using SharedPreferences (SQLite not supported)');
      print('📱 For SQLite (challenge requirement), run on Android/Windows');
      return WebDatabase();
    } else {
      print('📱 Running on native platform - Using SQLite database');
      print('✅ This meets the internship requirement');
      return SQLiteDatabase();
    }
  }
}