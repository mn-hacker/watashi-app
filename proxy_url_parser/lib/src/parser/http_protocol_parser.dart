import 'package:proxy_url_parser/src/parser/protocol_base_parser.dart';
import 'package:proxy_url_parser/src/util/proxy_url_parser_logger.dart';
import 'package:proxy_url_parser/src/xray/http_protocol_config.dart';

/// Parser for HTTP proxy URLs.
/// Format: http://[user:pass@]host:port#remark
class HttpProtocolParser extends ProtocolBaseParser {
  @override
  HttpProtocolConfig parse(String url) {
    ProxyUrlParserLogger.debug('Parsing HTTP URL: $url');

    // Fix illegal characters
    final fixedUrl = ProtocolBaseParser.fixIllegalUrl(url);
    final uri = Uri.parse(fixedUrl);

    final components = <String, dynamic>{};

    // Extract basic components
    components['add'] = uri.host;
    components['port'] = (uri.port != 0 ? uri.port : 80).toString();
    components['remark'] = extractFragment(uri);

    // Extract username/password if present
    if (uri.userInfo.isNotEmpty) {
      final parts = Uri.decodeComponent(uri.userInfo).split(':');
      if (parts.length >= 2) {
        components['username'] = parts[0];
        components['password'] = parts.sublist(1).join(':');
      } else if (parts.length == 1) {
        components['username'] = parts[0];
      }
    }

    return HttpProtocolConfig.fromUrlComponents(components, url);
  }
}
