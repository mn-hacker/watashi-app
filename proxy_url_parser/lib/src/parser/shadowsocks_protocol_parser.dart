import 'dart:convert';

import 'package:proxy_url_parser/src/parser/protocol_base_parser.dart';
import 'package:proxy_url_parser/src/util/proxy_url_parser_logger.dart';
import 'package:proxy_url_parser/src/util/proxy_url_validator.dart';
import 'package:proxy_url_parser/src/xray/shadowsocks_protocol_config.dart';
import 'package:proxy_url_parser/src/util/proxy_url_parser_exception.dart';

class ShadowsocksProtocolParser extends ProtocolBaseParser {
  @override
  ShadowsocksProtocolConfig parse(String url) {
    ProxyUrlParserLogger.debug('Parsing Shadowsocks URL: $url');
    final uri = Uri.parse(url);
    final components = <String, dynamic>{};

    // Remove fragment part if exists and then split on @
    final urlWithoutFragment = url.split('#')[0];
    final secondPart = urlWithoutFragment.substring(5).split('@');
    if (secondPart.length < 2) {
      throw InvalidUrlFormatException(
        'Invalid Shadowsocks URL format: $url',
        url,
        StackTrace.current,
      );
    }

    String decoded;
    try {
      // Ensure base64 string is padded correctly
      String base64String = secondPart[0];
      while (base64String.length % 4 != 0) {
        base64String += '=';
      }
      decoded = String.fromCharCodes(base64Decode(base64String));
    } catch (e) {
      ProxyUrlParserLogger.error('Failed to decode Shadowsocks URL: $e');
      throw DecodingException(
        'Invalid base64 encoding in Shadowsocks URL: $e',
        url,
        StackTrace.current,
      );
    }

    final creds = decoded.split(':');
    if (creds.length < 2) {
      throw InvalidUrlFormatException(
        'Invalid Shadowsocks credentials format: $decoded',
        url,
        StackTrace.current,
      );
    }

    components['encryption'] = creds[0];
    components['password'] = creds.sublist(1).join(':');
    components['add'] = uri.host;
    components['port'] = uri.port.toString();
    components['remark'] = extractFragment(uri);
    components.addAll(extractQueryParameters(uri));
    components['type'] ??= 'tcp';

    ProxyUrlValidator.validateShadowsocksComponents(components, url);
    return ShadowsocksProtocolConfig.fromUrlComponents(components, url);
  }
}
