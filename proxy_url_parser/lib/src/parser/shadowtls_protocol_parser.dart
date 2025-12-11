import 'package:proxy_url_parser/src/parser/protocol_base_parser.dart';
import 'package:proxy_url_parser/src/util/proxy_url_parser_logger.dart';
import 'package:proxy_url_parser/src/xray/shadowtls_protocol_config.dart';

/// Parser for ShadowTLS protocol URLs.
/// Format: shadow-tls://password@host:port?sni=xxx&version=3#remark
class ShadowTlsProtocolParser extends ProtocolBaseParser {
  @override
  ShadowTlsProtocolConfig parse(String url) {
    ProxyUrlParserLogger.debug('Parsing ShadowTLS URL: $url');

    // Fix illegal characters
    final fixedUrl = ProtocolBaseParser.fixIllegalUrl(url);
    final uri = Uri.parse(fixedUrl);

    final components = <String, dynamic>{};
    final queryParams = uri.queryParameters;

    // Extract basic components
    components['add'] = uri.host;
    components['port'] = uri.port.toString();
    components['remark'] = extractFragment(uri);

    // Password from userInfo
    components['password'] = uri.userInfo;

    // Query parameters
    components['sni'] = queryParams['sni'] ?? queryParams['host'];
    components['version'] = queryParams['version'] ?? '3';

    return ShadowTlsProtocolConfig.fromUrlComponents(components, url);
  }
}
