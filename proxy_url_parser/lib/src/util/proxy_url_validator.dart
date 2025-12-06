import 'package:proxy_url_parser/src/util/proxy_url_parser_exception.dart';

class ProxyUrlValidator {
  static void validateCommonComponents(
    Map<String, dynamic> components,
    String url,
  ) {
    if (components['add'] == null || (components['add'] as String).isEmpty) {
      throw InvalidUrlFormatException(
        'Missing or empty address (add) field',
        url,
        StackTrace.current,
      );
    }
    if (components['port'] == null) {
      throw InvalidUrlFormatException(
        'Missing port field',
        url,
        StackTrace.current,
      );
    }
    try {
      int.parse(components['port'].toString());
    } catch (e) {
      throw InvalidUrlFormatException(
        'Invalid port format: ${components['port']}',
        url,
        StackTrace.current,
      );
    }
  }

  static void validateShadowsocksComponents(
    Map<String, dynamic> components,
    String url,
  ) {
    validateCommonComponents(components, url);
    if (components['encryption'] == null ||
        (components['encryption'] as String).isEmpty) {
      throw InvalidUrlFormatException(
        'Missing or empty encryption field',
        url,
        StackTrace.current,
      );
    }
    if (components['password'] == null ||
        (components['password'] as String).isEmpty) {
      throw InvalidUrlFormatException(
        'Missing or empty password field',
        url,
        StackTrace.current,
      );
    }
    final network = components['type'] as String? ?? 'tcp';
    if (!['tcp', 'udp'].contains(network)) {
      throw InvalidUrlFormatException(
        'Invalid network type: $network (expected "tcp" or "udp")',
        url,
        StackTrace.current,
      );
    }
  }

  static void validateVmessComponents(
    Map<String, dynamic> components,
    String url,
  ) {
    validateCommonComponents(components, url);
    if (components['id'] == null || (components['id'] as String).isEmpty) {
      throw InvalidUrlFormatException(
        'Missing or empty id field',
        url,
        StackTrace.current,
      );
    }
    final security =
        components['scy'] as String? ??
        'auto'; // Use 'scy' instead of 'security'
    if (![
      'auto',
      'aes-128-gcm',
      'chacha20-poly1305',
      'none',
    ].contains(security)) {
      throw InvalidUrlFormatException(
        'Invalid security value: $security (expected "auto", "aes-128-gcm", "chacha20-poly1305", or "none")',
        url,
        StackTrace.current,
      );
    }
    final network = components['net'] as String? ?? 'tcp';

    final tls = components['tls'] as String? ?? '';
    if (!['', 'tls', 'none'].contains(tls)) {
      // Allow 'none' for VMess
      throw InvalidUrlFormatException(
        'Invalid tls value: $tls (expected "tls", "none", or empty)',
        url,
        StackTrace.current,
      );
    }
    final headerType = components['type'] as String? ?? '';
    if (network == 'kcp' &&
        headerType.isNotEmpty &&
        ![
          'none',
          'srtp',
          'utp',
          'wechat-video',
          'dtls',
          'wireguard',
        ].contains(headerType)) {
      throw InvalidUrlFormatException(
        'Invalid headerType value: $headerType (expected "none", "srtp", "utp", "wechat-video", "dtls", "wireguard", or empty)',
        url,
        StackTrace.current,
      );
    }
    if (network == 'tcp' &&
        headerType.isNotEmpty &&
        !['none', 'http'].contains(headerType)) {
      throw InvalidUrlFormatException(
        'Invalid headerType value: $headerType (expected "none", "http", or empty)',
        url,
        StackTrace.current,
      );
    }
    final quicSecurity = components['quicSecurity'] as String? ?? '';
    if (network == 'quic' &&
        quicSecurity.isNotEmpty &&
        !['none', 'aes-128-gcm', 'chacha20-poly1305'].contains(quicSecurity)) {
      throw InvalidUrlFormatException(
        'Invalid quicSecurity value: $quicSecurity (expected "none", "aes-128-gcm", "chacha20-poly1305", or empty)',
        url,
        StackTrace.current,
      );
    }
    if (network == 'grpc') {
      final authority = components['authority'] as String? ?? '';
      if (authority.isNotEmpty &&
          !RegExp(r'^[a-zA-Z0-9.-]+$').hasMatch(authority)) {
        throw InvalidUrlFormatException(
          'Invalid authority value: $authority (expected valid domain or empty)',
          url,
          StackTrace.current,
        );
      }
      // final mode = components['type'] as String? ?? '';
      // if (mode.isNotEmpty && !['gun', 'multi'].contains(mode)) {
      //   throw InvalidUrlFormatException('Invalid mode for grpc: $mode (expected "gun", "multi", or empty)', url, StackTrace.current);
      // }
    }
    if (network == 'xhttp') {
      final mode = components['mode'] as String? ?? '';
      if (mode.isNotEmpty && mode != 'auto') {
        throw InvalidUrlFormatException(
          'Invalid mode for xhttp: $mode (expected "auto" or empty)',
          url,
          StackTrace.current,
        );
      }
    }
    final muxEnabled = components['mux'] == '1' || components['mux'] == true;
    if (muxEnabled) {
      final concurrency = int.tryParse(
        components['muxConcurrency']?.toString() ?? '',
      );
      if (concurrency == null || concurrency < 1) {
        throw InvalidUrlFormatException(
          'Invalid muxConcurrency value: ${components['muxConcurrency']} (expected positive integer)',
          url,
          StackTrace.current,
        );
      }
    }
    // if (!['tcp', 'ws', 'httpupgrade', 'h2', 'kcp', 'quic', 'grpc', 'xhttp'].contains(network)) {
    //   throw InvalidUrlFormatException('Invalid network type: $network (expected "tcp", "ws", "httpupgrade", "h2", "kcp", "quic", "grpc", or "xhttp")', url, StackTrace.current);
    // }
    // final fingerprint = components['fp'] as String? ?? '';
    // if (fingerprint.isNotEmpty && !['chrome', 'firefox', 'safari', 'random', 'randomized'].contains(fingerprint)) { // Add 'randomized'
    //   throw InvalidUrlFormatException('Invalid fingerprint value: $fingerprint (expected "chrome", "firefox", "safari", "random", "randomized", or empty)', url, StackTrace.current);
    // }
    // final alpn = components['alpn'] as String? ?? '';
    // if (alpn.isNotEmpty) {
    //   final alpnValues = alpn.split(',');
    //   if (!alpnValues.every((val) => ['http/1.1', 'h2', 'spdy/3.1'].contains(val.trim()))) {
    //     throw InvalidUrlFormatException('Invalid alpn value: $alpn (expected comma-separated list of "http/1.1", "h2", "spdy/3.1", or empty)', url, StackTrace.current);
    //   }
    // }
  }

  static void validateVlessComponents(
    Map<String, dynamic> components,
    String url,
  ) {
    validateCommonComponents(components, url);
    if (components['id'] == null || (components['id'] as String).isEmpty) {
      throw InvalidUrlFormatException(
        'Missing or empty id field',
        url,
        StackTrace.current,
      );
    }
    final securityValue = components['security'] as String? ?? 'none';
    if (!['none', 'tls', 'reality'].contains(securityValue)) {
      throw InvalidUrlFormatException(
        'Invalid security value: $securityValue (expected "none", "tls", or "reality")',
        url,
        StackTrace.current,
      );
    }
    if (securityValue == 'reality') {
      final publicKey = components['pbk'] as String?;
      if (publicKey == null || publicKey.isEmpty) {
        throw InvalidUrlFormatException(
          'Missing or empty publicKey (pbk) for reality security',
          url,
          StackTrace.current,
        );
      }
      final shortId = components['sid'] as String? ?? '';
      if (shortId.isNotEmpty && shortId.length > 16) {
        // Relaxed to allow any length up to 16
        throw InvalidUrlFormatException(
          'Invalid shortId (sid) length: $shortId (expected up to 16 characters or empty)',
          url,
          StackTrace.current,
        );
      }
    }
    final network = components['type'] as String? ?? 'tcp';
    if (network == 'grpc') {
      final mode = components['mode'] as String? ?? '';
      if (mode.isNotEmpty && !['gun', 'multi'].contains(mode)) {
        throw InvalidUrlFormatException(
          'Invalid mode for grpc: $mode (expected "gun", "multi", or empty)',
          url,
          StackTrace.current,
        );
      }
    } else if (network == 'tcp') {
      final headerType = components['headerType'] as String? ?? '';
      if (headerType.isNotEmpty && !['none', 'http'].contains(headerType)) {
        throw InvalidUrlFormatException(
          'Invalid headerType for tcp: $headerType (expected "none", "http", or empty)',
          url,
          StackTrace.current,
        );
      }
    }
    final encryption = components['encryption'] as String? ?? 'none';
    if (encryption.isEmpty) {
      throw InvalidUrlFormatException(
        'Invalid encryption value: $encryption (expected "value" or "none")',
        url,
        StackTrace.current,
      );
    }

    final allowInsecure = components['allowInsecure'] as String? ?? '0';
    if (!['0', '1', "false", "true"].contains(allowInsecure)) {
      throw InvalidUrlFormatException(
        'Invalid allowInsecure value: $allowInsecure (expected "0" or "1")',
        url,
        StackTrace.current,
      );
    }

    // if (!['tcp', 'ws', 'httpupgrade', 'h2', 'grpc', 'xhttp'].contains(network)) {
    //   throw InvalidUrlFormatException('Invalid network type: $network (expected "tcp", "ws", "httpupgrade", "h2", "grpc", or "xhttp")', url, StackTrace.current);
    // }
    // final flow = components['flow'] as String? ?? '';
    // if (flow.isNotEmpty && !['xtls-rprx-vision', 'xtls-rprx-direct'].contains(flow)) {
    //   throw InvalidUrlFormatException('Invalid flow value: $flow (expected "xtls-rprx-vision", "xtls-rprx-direct", or empty)', url, StackTrace.current);
    // }
    // final fingerprint = components['fp'] as String? ?? '';
    // if (fingerprint.isNotEmpty && !['chrome', 'firefox', 'safari', 'ios', 'android', 'edge', '360', 'qq', 'random', 'none', 'randomized'].contains(fingerprint)) { // Add 'randomized'
    //   throw InvalidUrlFormatException('Invalid fingerprint value: $fingerprint (expected "chrome", "firefox", "safari", "ios", "android", "edge", "360", "qq", "random", "none", "randomized", or empty)', url, StackTrace.current);
    // }
    // final alpn = components['alpn'] as String? ?? '';
    // if (alpn.isNotEmpty) {
    //   final alpnValues = alpn.split(',');
    //   if (!alpnValues.every((val) => ['http/1.1', 'h2', 'h3'].contains(val.trim()))) {
    //     throw InvalidUrlFormatException('Invalid alpn value: $alpn (expected comma-separated list of "http/1.1", "h2", or empty)', url, StackTrace.current);
    //   }
    // }
  }

  static void validateTrojanComponents(
    Map<String, dynamic> components,
    String url,
  ) {
    validateCommonComponents(components, url);
    if (components['password'] == null ||
        (components['password'] as String).isEmpty) {
      throw InvalidUrlFormatException(
        'Missing or empty password field',
        url,
        StackTrace.current,
      );
    }
    final securityValue = components['security'] as String? ?? 'tls';

    if (securityValue == 'reality') {
      final publicKey = components['pbk'] as String?;
      if (publicKey == null || publicKey.isEmpty) {
        throw InvalidUrlFormatException(
          'Missing or empty publicKey (pbk) for reality security',
          url,
          StackTrace.current,
        );
      }
      final shortId = components['sid'] as String? ?? '';
      if (shortId.isNotEmpty && shortId.length > 16) {
        // Relaxed to allow any length up to 16
        throw InvalidUrlFormatException(
          'Invalid shortId (sid) length: $shortId (expected up to 16 characters or empty)',
          url,
          StackTrace.current,
        );
      }
    }
    final network = components['type'] as String? ?? 'tcp';
    if (network == 'grpc') {
      final mode = components['mode'] as String? ?? '';
      if (mode.isNotEmpty && !['gun', 'multi'].contains(mode)) {
        throw InvalidUrlFormatException(
          'Invalid mode for grpc: $mode (expected "gun", "multi", or empty)',
          url,
          StackTrace.current,
        );
      }
    }
    final fingerprint = components['fp'] as String? ?? '';
    if (fingerprint.isNotEmpty &&
        ![
          'chrome',
          'firefox',
          'safari',
          'ios',
          'android',
          'edge',
          '360',
          'qq',
          'random',
          'none',
          'randomized',
        ].contains(fingerprint)) {
      // Add 'randomized'
      throw InvalidUrlFormatException(
        'Invalid fingerprint value: $fingerprint (expected "chrome", "firefox", "safari", "ios", "android", "edge", "360", "qq", "random", "none", "randomized", or empty)',
        url,
        StackTrace.current,
      );
    }
    final allowInsecure = components['allowInsecure'] as String? ?? 'false';
    if (!['0', '1', 'true', 'false'].contains(allowInsecure)) {
      throw InvalidUrlFormatException(
        'Invalid allowInsecure value: $allowInsecure (expected "0" or "1" or "false", "true")',
        url,
        StackTrace.current,
      );
    }
    // final sniValue = components['sni'] as String? ?? '';
    // if (sniValue.isNotEmpty && !isValidDomain(sniValue)) {
    //   throw InvalidUrlFormatException('Invalid sni value: $sniValue (expected valid domain)', url, StackTrace.current);
    // }
    // if (!['tls', 'reality'].contains(securityValue)) {
    //   throw InvalidUrlFormatException('Invalid security value: $securityValue (expected "tls" or "reality")', url, StackTrace.current);
    // }
    // final network = components['type'] as String? ?? 'tcp';
    // if (!['tcp', 'ws', 'httpupgrade', 'h2', 'grpc', 'xhttp'].contains(network)) {
    //   throw InvalidUrlFormatException('Invalid network type: $network (expected "tcp", "ws", "httpupgrade", "h2", "grpc", or "xhttp")', url, StackTrace.current);
    // }
    // final alpn = components['alpn'] as String? ?? '';
    // if (alpn.isNotEmpty) {
    //   final alpnValues = alpn.split(',');
    //   if (!alpnValues.every((val) => ['http/1.1', 'h2'].contains(val.trim()))) {
    //     throw InvalidUrlFormatException('Invalid alpn value: $alpn (expected comma-separated list of "http/1.1", "h2", or empty)', url, StackTrace.current);
    //   }
    // }
  }

  static bool isValidDomain(String sni) {
    final domainRegex = RegExp(
      r'^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?:\.[a-zA-Z]{2,})+$',
    );
    return domainRegex.hasMatch(sni);
  }
}
