import 'package:flutter/foundation.dart';

class AppLogger {
  const AppLogger._();

  static void info(String message) {
    if (!kDebugMode) {
      return;
    }

    debugPrint(message);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (!kDebugMode) {
      return;
    }

    debugPrint(message);

    if (error != null) {
      debugPrint('Error: $error');
    }

    if (stackTrace != null) {
      debugPrint('$stackTrace');
    }
  }
}
