library;

import 'package:proxy_url_parser/src/parser/protocol_parser_registry.dart';
import 'package:proxy_url_parser/src/protocol_config_base.dart';
import 'package:proxy_url_parser/src/proxy_protocols.dart';
import 'package:proxy_url_parser/src/util/proxy_url_parser_exception.dart';
import 'package:proxy_url_parser/src/util/proxy_url_parser_logger.dart';

export 'package:proxy_url_parser/src/protocol_config_base.dart';

class ProxyUrlParser {
  static ProtocolConfigBase _parseUrl(String proxyUrl) {
    final cleanedUrl = proxyUrl.trim();
    ProxyUrlParserLogger.debug(
      '_parseUrl called with URL length: ${cleanedUrl.length}',
    );

    final type = _determineProxyType(cleanedUrl);
    ProxyUrlParserLogger.debug(
      'Parsing URL with proxy type: $type',
    ); // Debug log

    try {
      final result = ProtocolParserRegistry.parse(type, cleanedUrl);
      ProxyUrlParserLogger.debug(
        'Successfully parsed URL, result type: ${result.runtimeType}',
      );
      return result;
    } catch (e, stack) {
      ProxyUrlParserLogger.debug('Parse failed with error: $e');
      ProxyUrlParserLogger.debug('Stack: $stack');
      throw InvalidUrlFormatException(
        'Failed to parse proxy URL: $e',
        cleanedUrl,
        StackTrace.current,
      );
    }
  }

  // Generic parse method to infer specific type
  static T parse<T extends ProtocolConfigBase>(String proxyUrl) {
    final config = _parseUrl(proxyUrl);
    if (config is T) {
      return config;
    }
    throw UnsupportedProxyTypeException(
      'Parsed config type ${config.runtimeType} does not match expected type $T for URL: $proxyUrl',
      StackTrace.current,
    );
  }

  static Map<String, dynamic> injectToConfig(
    Map<String, dynamic> baseConfig,
    Map<String, dynamic> outboundConfig,
  ) {
    return Map<String, dynamic>.from(baseConfig)
      ..['outbounds'] = [outboundConfig];
  }

  static ProxyProtocols _determineProxyType(String url) {
    const prefixes = {
      'vmess://': ProxyProtocols.vmess,
      'vless://': ProxyProtocols.vless,
      'ss://': ProxyProtocols.shadowsocks,
      'trojan://': ProxyProtocols.trojan,
      'wireguard://': ProxyProtocols.wireguard,
      'wg://': ProxyProtocols.wireguard,
      'socks://': ProxyProtocols.socks,
      'socks5://': ProxyProtocols.socks,
      'http://': ProxyProtocols.http,
      'hysteria2://': ProxyProtocols.hysteria2,
      'hy2://': ProxyProtocols.hysteria2,
      'tuic://': ProxyProtocols.tuic,
      'naive+https://': ProxyProtocols.naive,
      'naive+quic://': ProxyProtocols.naive,
      'naive://': ProxyProtocols.naive,
      'shadow-tls://': ProxyProtocols.shadowtls,
      'shadowtls://': ProxyProtocols.shadowtls,
    };

    for (final prefix in prefixes.keys) {
      if (url.startsWith(prefix)) {
        return prefixes[prefix]!;
      }
    }
    throw UnsupportedProxyTypeException(url, StackTrace.current);
  }
}
