import 'package:proxy_url_parser/src/parser/protocol_base_parser.dart';
import 'package:proxy_url_parser/src/util/proxy_url_parser_logger.dart';
import 'package:proxy_url_parser/src/xray/tuic_protocol_config.dart';

/// Parser for TUIC protocol URLs.
/// Format: tuic://uuid:password@host:port?sni=xxx&alpn=xxx&congestion_control=bbr#remark
class TuicProtocolParser extends ProtocolBaseParser {
  @override
  TuicProtocolConfig parse(String url) {
    ProxyUrlParserLogger.debug('Parsing TUIC URL: $url');

    // Fix illegal characters
    final fixedUrl = ProtocolBaseParser.fixIllegalUrl(url);
    final uri = Uri.parse(fixedUrl);

    final components = <String, dynamic>{};
    final queryParams = uri.queryParameters;

    // Extract basic components
    components['add'] = uri.host;
    components['port'] = uri.port.toString();
    components['remark'] = extractFragment(uri);

    // UUID and password from userInfo (uuid:password format)
    if (uri.userInfo.isNotEmpty) {
      final parts = uri.userInfo.split(':');
      components['uuid'] = parts[0];
      if (parts.length > 1) {
        components['password'] = parts.sublist(1).join(':');
      }
    }

    // Query parameters
    components['sni'] = queryParams['sni'];
    components['alpn'] = queryParams['alpn'];
    components['insecure'] =
        queryParams['insecure'] ?? queryParams['allowInsecure'];
    components['congestion_control'] = queryParams['congestion_control'];
    components['udp_relay_mode'] = queryParams['udp_relay_mode'];

    return TuicProtocolConfig.fromUrlComponents(components, url);
  }
}
