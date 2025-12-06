/// A simple logger for proxy parsing operations.
class ProxyUrlParserLogger {
  static bool _isDebugMode = false;

  /// Enables debug logging.
  static void enableDebugMode() => _isDebugMode = true;

  /// Logs a debug message if debug mode is enabled.
  static void debug(String message) {
    if (_isDebugMode) {
      print('\n\n[DEBUG] $message');
    }
  }

  /// Logs an error message.
  static void error(String message) {
    print('[ERROR] $message');
  }
}