import 'package:proxy_url_parser/src/parser/protocol_base_parser.dart';
import 'package:proxy_url_parser/src/util/proxy_url_parser_logger.dart';
import 'package:proxy_url_parser/src/util/proxy_url_validator.dart';
import 'package:proxy_url_parser/src/xray/trojan_protocol_config.dart';

/// Parser for Trojan proxy URLs.
class TrojanProtocolParser extends ProtocolBaseParser {
  @override
  TrojanProtocolConfig parse(String url) {
    ProxyUrlParserLogger.debug('Parsing Trojan URL: $url');
    final uri = Uri.parse(url);
    final components = <String, dynamic>{};

    // Extract basic components
    components['password'] = uri.userInfo;
    components['add'] = uri.host;
    components['port'] = uri.port.toString();
    components.addAll(extractQueryParameters(uri));
    components['remark'] = extractFragment(uri);

    // Normalize 'peer' query parameter to 'sni' if sni is not explicitly set
    if (components.containsKey('peer') && !components.containsKey('sni')) {
      components['sni'] = components['peer'];
    } if (components["sni"] == null) {
      components['sni'] = '';
    }

    // Normalize 'tls' query parameter to 'security'
    if (components.containsKey('tls')) {
      components['security'] = components['tls'] == '1' ? 'tls' : 'none';
      components.remove('tls'); // Clean up
    }

    // Handle 'security' for 'reality'
    if (components.containsKey('security') && components['security'] == 'reality') {
      components['security'] = 'reality';
    }

    // Map 'type' to 'network' (standard for Trojan)
    if (components.containsKey('type')) {
      components['type'] = components['type'];
    }

    // Map fingerprint (fp) and other fields
    if (components.containsKey('fp')) {
      components['fp'] = components['fp'];
    }

    // Map reality-specific fields if present
    if (components.containsKey('pbk')) {
      components['pbk'] = components['pbk'];
    }
    if (components.containsKey('sid')) {
      components['sid'] = components['sid'];
    }
    if (components.containsKey('spx')) {
      components['spx'] = components['spx'];
    }

    // Ensure defaults for additional fields if not present
    components['type'] ??= 'tcp'; // Default network type
    components['security'] ??= 'tls'; // Default to 'tls' for Trojan
    components['host'] ??= '';
    components['fp'] ??= ''; // Fingerprint default to empty
    components['alpn'] ??= ''; // Will be split into a list in fromUrlComponents
    components['serviceName'] ??= '';
    components['mode'] ??= '';
    components['allowInsecure'] ??= '0';

    ProxyUrlValidator.validateTrojanComponents(components, url);
    return TrojanProtocolConfig.fromUrlComponents(components, url);
  }
}