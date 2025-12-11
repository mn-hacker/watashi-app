import 'package:proxy_url_parser/src/parser/protocol_base_parser.dart';
import 'package:proxy_url_parser/src/util/proxy_url_parser_logger.dart';
import 'package:proxy_url_parser/src/util/proxy_url_validator.dart';
import 'package:proxy_url_parser/src/xray/vless_protocol_config.dart';

/// Parser for VLESS proxy URLs.
class VlessProtocolParser extends ProtocolBaseParser {
  @override
  VlessProtocolConfig parse(String url) {
    ProxyUrlParserLogger.debug('Parsing VLESS URL: $url');
    // Fix illegal characters in URL before parsing
    final fixedUrl = ProtocolBaseParser.fixIllegalUrl(url);
    ProxyUrlParserLogger.debug('Fixed URL: $fixedUrl');
    final uri = Uri.parse(fixedUrl);
    final components = <String, dynamic>{};

    // Extract basic components
    components['id'] = uri.userInfo;
    components['add'] = uri.host;
    components['port'] = uri.port.toString();
    components.addAll(extractQueryParameters(uri));
    components['remark'] = extractFragment(uri);

    // Check if 'security' is empty or null and set to 'none'
    if (components['security']?.isEmpty ?? true) {
      components['security'] = 'none';
    }

    // Normalize 'tls' query parameter to 'security'
    if (components.containsKey('tls')) {
      components['security'] = components['tls'] == '1' ? 'tls' : 'none';
      components.remove('tls'); // Clean up
    }

    // Handle 'security' for 'reality'
    if (components.containsKey('security') &&
        components['security'] == 'reality') {
      // Reality-specific fields might be present like pbk, sid, spx
      components['security'] = 'reality';
    }

    // Normalize 'sni' from 'peer' if present
    if (components.containsKey('peer') && !components.containsKey('sni')) {
      components['sni'] = components['peer'];
    }

    // Map 'type' to 'network' (standard for VLESS)
    if (components.containsKey('type')) {
      components['type'] =
          components['type']; // Already mapped as 'network' in VlessConfig
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
    components['encryption'] ??= 'none';
    components['type'] ??= 'tcp'; // Default network type
    components['path'] ??= '/';
    components['host'] ??= '';
    components['fp'] ??= ''; // Fingerprint default to empty
    components['alpn'] ??= ''; // Will be split into a list in fromUrlComponents
    components['serviceName'] ??= '';
    components['mode'] ??= '';
    components['allowInsecure'] ??= '0';

    // Validate the components before creating the config
    ProxyUrlValidator.validateVlessComponents(components, url);

    // Create and return the VlessConfig object
    return VlessProtocolConfig.fromUrlComponents(components, url);
  }
}
