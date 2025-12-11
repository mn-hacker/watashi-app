import 'dart:convert';

import 'package:proxy_url_parser/src/parser/protocol_base_parser.dart';
import 'package:proxy_url_parser/src/util/proxy_url_parser_exception.dart';
import 'package:proxy_url_parser/src/util/proxy_url_parser_logger.dart';
import 'package:proxy_url_parser/src/util/proxy_url_validator.dart';
import 'package:proxy_url_parser/src/xray/vmess_protocol_config.dart';

/// Parser for VMess proxy URLs.
class VmessProtocolParser extends ProtocolBaseParser {
  @override
  VmessProtocolConfig parse(String url) {
    ProxyUrlParserLogger.debug('Parsing VMess URL: $url');
    // Fix illegal characters in URL before parsing
    final fixedUrl = ProtocolBaseParser.fixIllegalUrl(url);
    final uri = Uri.parse(fixedUrl);
    final components = <String, dynamic>{};

    // Extract the part after the scheme
    final urlPart = url.split('://')[1];
    final basePart =
        urlPart.split('?')[0]; // Remove query parameters if present

    // Check if the URL is in base64-encoded JSON format (no '@' in the base part)
    if (!basePart.contains('@')) {
      // Handle base64-encoded JSON (common VMess URL format)
      try {
        final decodedString = String.fromCharCodes(base64Decode(basePart));
        final jsonData = jsonDecode(decodedString) as Map<String, dynamic>;
        components.addAll(jsonData);

        // Map 'ps' to 'remark' explicitly
        if (jsonData.containsKey('ps')) {
          components['remark'] = jsonData['ps'];
        }

        // Map 'type' to 'headerType' explicitly for TCP or gRPC
        if (jsonData.containsKey('type')) {
          components['headerType'] = jsonData['type'];
        }
      } catch (e) {
        throw InvalidUrlFormatException(
          'Failed to decode base64 JSON: $e',
          url,
          StackTrace.current,
        );
      }
    } else {
      // Handle standard format: vmess://user@host:port?query#remark
      components['id'] = uri.userInfo;
      components['add'] = uri.host;
      components['port'] = uri.port.toString();
    }

    components['remark'] = extractFragment(uri);

    // Add query parameters (if any) only if they don’t override JSON values
    components.addAll({
      for (var entry in extractQueryParameters(uri).entries)
        if (!components.containsKey(entry.key)) entry.key: entry.value,
    });

    // Normalize TLS
    if (components.containsKey('tls') && components['tls'] == '1') {
      components['tls'] = 'tls';
    } else if (!components.containsKey('tls') || components['tls'] == "none") {
      components['tls'] = 'none';
    }

    // Set defaults for additional fields
    components['alpn'] ??= '';
    components['fp'] ??= '';
    components['allowInsecure'] ??= '0';
    components['serviceName'] ??= '';
    components['mode'] ??= '';
    components['headerType'] ??= 'none';
    components['seed'] ??= '';
    components['quicSecurity'] ??= 'none';
    components['quicKey'] ??= '';
    components['mux'] ??= '0';
    components['muxConcurrency'] ??= '8';
    components['security'] ??= 'none';
    components['net'] ??= 'tcp';
    components['aid'] ??= '0';
    components['authority'] ??= '';
    components['path'] ??= '/';
    components['host'] ??= '';
    components['sni'] ??= '';

    ProxyUrlValidator.validateVmessComponents(components, url);
    return VmessProtocolConfig.fromUrlComponents(components, url);
  }
}
