import 'package:proxy_url_parser/src/parser/protocol_base_parser.dart';
import 'package:proxy_url_parser/src/util/proxy_url_parser_logger.dart';
import 'package:proxy_url_parser/src/xray/hysteria2_protocol_config.dart';

/// Parser for Hysteria2 protocol URLs.
/// Format: hysteria2://password@host:port?sni=xxx&insecure=1&obfs-password=xxx#remark
/// Also supports: hy2://
class Hysteria2ProtocolParser extends ProtocolBaseParser {
  @override
  Hysteria2ProtocolConfig parse(String url) {
    ProxyUrlParserLogger.debug('Parsing Hysteria2 URL: $url');

    // Fix illegal characters
    final fixedUrl = ProtocolBaseParser.fixIllegalUrl(url);
    final uri = Uri.parse(fixedUrl);

    final components = <String, dynamic>{};
    final queryParams = uri.queryParameters;

    // Extract basic components
    components['add'] = uri.host;
    components['port'] = uri.port.toString();
    components['remark'] = extractFragment(uri);

    // Password is in userInfo
    components['password'] = uri.userInfo;

    // Query parameters
    components['sni'] = queryParams['sni'];
    components['alpn'] = queryParams['alpn'];
    components['insecure'] = queryParams['insecure'];
    components['obfs-password'] = queryParams['obfs-password'];
    components['mport'] = queryParams['mport'];
    components['mportHopInt'] = queryParams['mportHopInt'];
    components['pinSHA256'] = queryParams['pinSHA256'];

    return Hysteria2ProtocolConfig.fromUrlComponents(components, url);
  }
}
