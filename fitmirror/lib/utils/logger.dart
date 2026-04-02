import 'dart:developer' as developer;

/// 日志工具
class Logger {
  static const String _tag = 'FitMirror';

  static bool _isEnabled = true;

  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  static void d(String message, [String? tag]) {
    if (_isEnabled) {
      developer.log(message, name: tag ?? _tag, level: 500);
    }
  }

  static void i(String message, [String? tag]) {
    if (_isEnabled) {
      developer.log(message, name: tag ?? _tag, level: 800);
    }
  }

  static void w(String message, [String? tag]) {
    if (_isEnabled) {
      developer.log(message, name: tag ?? _tag, level: 900);
    }
  }

  static void e(String message, [String? tag, Object? error]) {
    if (_isEnabled) {
      developer.log(
        message,
        name: tag ?? _tag,
        level: 1000,
        error: error,
      );
    }
  }
}
