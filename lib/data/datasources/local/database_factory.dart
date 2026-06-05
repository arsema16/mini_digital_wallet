import 'package:flutter/foundation.dart' show kIsWeb;
import 'local_database.dart';
import 'sqlite_database.dart';
import 'web_database.dart';

class DatabaseFactory {
  static LocalDatabase create() {
    if (kIsWeb) {
      return WebDatabase();
    }
    return SQLiteDatabase();
  }
}
