import 'package:flutter/foundation.dart';

class AppLogger {
  static void log(String message) {
    if (kDebugMode) {
      print(message);
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      print('ℹ️ $message');
    }
  }

  static void success(String message) {
    if (kDebugMode) {
      print('✅ $message');
    }
  }

  static void error(String message) {
    if (kDebugMode) {
      print('❌ $message');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      print('⚠️ $message');
    }
  }

  static void debug(String message) {
    if (kDebugMode) {
      print('🔍 $message');
    }
  }

  static void process(String message) {
    if (kDebugMode) {
      print('🔄 $message');
    }
  }
}
