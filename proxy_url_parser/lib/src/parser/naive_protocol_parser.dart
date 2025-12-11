import 'package:proxy_url_parser/src/parser/protocol_base_parser.dart';
import 'package:proxy_url_parser/src/util/proxy_url_parser_logger.dart';
import 'package:proxy_url_parser/src/xray/naive_protocol_config.dart';

/// Parser for NaiveProxy protocol URLs.
/// Format: naive+https://user:pass@host:port#remark
/// Also supports: naive+quic://
class NaiveProtocolParser extends ProtocolBaseParser {
  @override
  NaiveProtocolConfig parse(String url) {
    ProxyUrlParserLogger.debug('Parsing NaiveProxy URL: $url');

    // Determine protocol type (https or quic)
    String protocol = 'https';
    String cleanUrl = url;

    if (url.startsWith('naive+quic://')) {
      protocol = 'quic';
      cleanUrl = url.replaceFirst('naive+quic://', 'https://');
    } else if (url.startsWith('naive+https://')) {
      protocol = 'https';
      cleanUrl = url.replaceFirst('naive+https://', 'https://');
    } else if (url.startsWith('naive://')) {
      cleanUrl = url.replaceFirst('naive://', 'https://');
    }

    // Fix illegal characters
    final fixedUrl = ProtocolBaseParser.fixIllegalUrl(cleanUrl);
    final uri = Uri.parse(fixedUrl);

    final components = <String, dynamic>{};

    // Extract basic components
    components['add'] = uri.host;
    components['port'] = (uri.port != 0 ? uri.port : 443).toString();
    components['remark'] = extractFragment(uri);
    components['protocol'] = protocol;

    // Username and password from userInfo
    if (uri.userInfo.isNotEmpty) {
      final parts = Uri.decodeComponent(uri.userInfo).split(':');
      components['username'] = parts[0];
      if (parts.length > 1) {
        components['password'] = parts.sublist(1).join(':');
      }
    }

    return NaiveProtocolConfig.fromUrlComponents(components, url);
  }
}
