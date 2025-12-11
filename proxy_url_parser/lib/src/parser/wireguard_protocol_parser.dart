import 'package:proxy_url_parser/src/parser/protocol_base_parser.dart';
import 'package:proxy_url_parser/src/util/proxy_url_parser_logger.dart';
import 'package:proxy_url_parser/src/xray/wireguard_protocol_config.dart';

/// Parser for Wireguard VPN URLs.
/// Format: wireguard://secretKey@host:port?publickey=xxx&address=xxx&reserved=x,x,x&mtu=xxx#remark
class WireguardProtocolParser extends ProtocolBaseParser {
  @override
  WireguardProtocolConfig parse(String url) {
    ProxyUrlParserLogger.debug('Parsing Wireguard URL: $url');

    // Fix illegal characters
    final fixedUrl = ProtocolBaseParser.fixIllegalUrl(url);
    final uri = Uri.parse(fixedUrl);

    // Check for query params
    if (uri.query.isEmpty) {
      ProxyUrlParserLogger.debug('Wireguard URL has no query parameters');
    }

    final components = <String, dynamic>{};
    final queryParams = uri.queryParameters;

    // Extract basic components
    components['add'] = uri.host;
    components['port'] = uri.port.toString();
    components['remark'] = extractFragment(uri);

    // secretKey is in userInfo
    components['secretKey'] = uri.userInfo;

    // Query parameters
    components['publicKey'] = queryParams['publickey'] ?? '';
    components['localAddress'] = queryParams['address'] ?? '172.16.0.2/32';
    components['reserved'] = queryParams['reserved'] ?? '0,0,0';
    components['mtu'] = queryParams['mtu'] ?? '1280';
    components['preSharedKey'] = queryParams['presharedkey'];

    return WireguardProtocolConfig.fromUrlComponents(components, url);
  }
}
