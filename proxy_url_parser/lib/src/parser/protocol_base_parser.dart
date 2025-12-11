import 'package:proxy_url_parser/src/protocol_config_base.dart';
import 'package:proxy_url_parser/src/util/proxy_url_parser_exception.dart';

/// Base class for proxy URL parsers, providing shared utility methods.
abstract class ProtocolBaseParser {
  static const String userInfoSeparator = ':';
  static const String queryParamSeparator = '&';
  static const String fragmentSeparator = '#';

  /// Parses a proxy URL and returns the appropriate [ProtocolConfigBase] instance.
  ///
  /// Throws a [InvalidUrlFormatException] if the URL is invalid or unsupported.
  ProtocolConfigBase parse(String url);

  /// Extracts user info (e.g., username:password) from the URL.
  ///
  /// Throws a [InvalidUrlFormatException] if the user info format is invalid.
  List<String> extractUserInfo(Uri uri) {
    final userInfo = uri.userInfo.split(userInfoSeparator);
    if (userInfo.isEmpty || userInfo.length > 2) {
      throw InvalidUrlFormatException(
        'Invalid user info format in URL: ${uri.toString()}',
        uri.toString(),
        StackTrace.current,
      );
    }
    return userInfo;
  }

  /// Extracts query parameters into a map.
  Map<String, String> extractQueryParameters(Uri uri) {
    return uri.queryParameters;
  }

  /// Extracts the fragment (remark) from the URL.
  String extractFragment(Uri uri) {
    // If the fragment is empty, return a default remark
    try {
      return Uri.decodeFull(
        uri.fragment.isNotEmpty
            ? uri.fragment
            : 'My%20Config', // Default url_encoded "My Config" remark
      );
    } on FormatException {
      return uri.fragment;
    }
  }

  /// Fixes illegal characters in URLs that could cause parsing failures.
  /// Based on MahsaNG/V2rayNG's Utils.fixIllegalUrl
  static String fixIllegalUrl(String url) {
    return url
        .replaceAll(' ', '%20')
        .replaceAll('|', '%7C')
        .replaceAll('[', '%5B')
        .replaceAll(']', '%5D');
  }
}
