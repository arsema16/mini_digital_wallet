import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformHelper {
  // Check if running on web
  static bool get isWeb => kIsWeb;
  
  // Check if running on mobile (Android or iOS)
  static bool get isMobile => !isWeb && (isAndroid || isIOS);
  
  // Check if running on desktop
  static bool get isDesktop => !isWeb && (isWindows || isMacOS || isLinux);
  
  // Platform-specific checks (only works on non-web)
  static bool get isAndroid => !isWeb && Platform.isAndroid;
  
  static bool get isIOS => !isWeb && Platform.isIOS;
  
  static bool get isWindows => !isWeb && Platform.isWindows;
  
  static bool get isMacOS => !isWeb && Platform.isMacOS;
  
  static bool get isLinux => !isWeb && Platform.isLinux;
  
  // Get current platform name
  static String get platformName {
    if (isWeb) return 'Web';
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (isWindows) return 'Windows';
    if (isMacOS) return 'macOS';
    if (isLinux) return 'Linux';
    return 'Unknown';
  }
  
  // Check if SQLite is supported (not on web)
  static bool get isSQLiteSupported => !isWeb;
}