import 'dart:convert';
import 'package:proxy_url_parser/src/parser/protocol_base_parser.dart';
import 'package:proxy_url_parser/src/util/proxy_url_parser_logger.dart';
import 'package:proxy_url_parser/src/xray/socks_protocol_config.dart';

/// Parser for SOCKS proxy URLs.
/// Format: socks://[user:pass@]host:port#remark
class SocksProtocolParser extends ProtocolBaseParser {
  @override
  SocksProtocolConfig parse(String url) {
    ProxyUrlParserLogger.debug('Parsing SOCKS URL: $url');

    // Fix illegal characters
    final fixedUrl = ProtocolBaseParser.fixIllegalUrl(url);
    final uri = Uri.parse(fixedUrl);

    final components = <String, dynamic>{};

    // Extract basic components
    components['add'] = uri.host;
    components['port'] = uri.port.toString();
    components['remark'] = extractFragment(uri);

    // Extract username/password if present
    if (uri.userInfo.isNotEmpty) {
      try {
        // userInfo might be base64 encoded
        final decoded = _tryDecodeUserInfo(uri.userInfo);
        final parts = decoded.split(':');
        if (parts.length >= 2) {
          components['username'] = parts[0];
          components['password'] = parts.sublist(1).join(':');
        }
      } catch (e) {
        ProxyUrlParserLogger.debug('Failed to decode SOCKS userInfo: $e');
      }
    }

    return SocksProtocolConfig.fromUrlComponents(components, url);
  }

  String _tryDecodeUserInfo(String userInfo) {
    // Try base64 decode
    try {
      final decoded = utf8.decode(base64.decode(userInfo));
      return decoded;
    } catch (e) {
      // Not base64, use as-is
      return Uri.decodeComponent(userInfo);
    }
  }
}
