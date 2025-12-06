/// Base class for all proxy parsing exceptions.
abstract class ProxyUrlParserException implements Exception {
  final String message;
  final String? url;
  final StackTrace? stackTrace;

  ProxyUrlParserException(this.message, this.url, [this.stackTrace]);

  @override
  String toString() =>
      "ProxyParseException: $message${url != null ? ' (URL: $url)' : ''}\n ${stackTrace.toString()}";
}

/// Exception thrown when the proxy type is unsupported.
class UnsupportedProxyTypeException extends ProxyUrlParserException {
  UnsupportedProxyTypeException(String url, stack)
    : super('Unsupported proxy type', url, stack ?? StackTrace.current);
}

/// Exception thrown when the URL format is invalid.
class InvalidUrlFormatException extends ProxyUrlParserException {
  InvalidUrlFormatException(message, url, StackTrace? stack)
    : super(message, url, stack ?? StackTrace.current);
}

/// Exception thrown when decoding fails (e.g., base64 or JSON).
class DecodingException extends ProxyUrlParserException {
  DecodingException(message, url, StackTrace? stack)
    : super(message, url, stack ?? StackTrace.current);
}
