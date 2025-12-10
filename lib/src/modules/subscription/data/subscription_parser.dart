import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Parsed config result
class ParsedConfig {
  final String rawLink;
  final String protocol;
  final String? name;

  ParsedConfig({
    required this.rawLink,
    required this.protocol,
    this.name,
  });
}

/// Subscription info parsed from headers
class SubscriptionInfo {
  final String? profileTitle;
  final int? upload;
  final int? download;
  final int? total;
  final DateTime? expire;
  final String? supportUrl;
  final String? testUrl;
  final Duration? updateInterval;

  SubscriptionInfo({
    this.profileTitle,
    this.upload,
    this.download,
    this.total,
    this.expire,
    this.supportUrl,
    this.testUrl,
    this.updateInterval,
  });
}

/// Parses subscription content and headers
/// Based on Hiddify's link_parsers.dart and profile_parser.dart
class SubscriptionParser {
  // Known header names (same as Hiddify)
  static const _subInfoHeaders = [
    'profile-title',
    'content-disposition',
    'subscription-userinfo',
    'profile-update-interval',
    'support-url',
    'profile-web-page-url',
    'test-url',
  ];

  // Supported protocols
  static const _supportedProtocols = [
    'vless',
    'vmess',
    'trojan',
    'ss',
    'ssr',
    'ssconf',
    'hysteria',
    'hysteria2',
    'hy',
    'hy2',
    'tuic',
    'wireguard',
    'wg',
    'warp',
    'ssh',
    'socks',
    'socks5',
  ];

  /// Safely decode base64 content (never throws)
  /// Based on Hiddify's safeDecodeBase64
  static String safeDecodeBase64(String content) {
    // Check if already plain text (starts with protocol or comment)
    final trimmed = content.trim();
    final plainTextIndicators = [
      ...(_supportedProtocols.map((p) => '$p://')),
      '#',
      '//',
      '{', // JSON
    ];

    for (final indicator in plainTextIndicators) {
      if (trimmed.toLowerCase().startsWith(indicator.toLowerCase())) {
        debugPrint('[Parser] Content is already plain text');
        return content;
      }
    }

    // Try base64 decode
    try {
      // Clean content: remove whitespace
      String cleaned = content.replaceAll(RegExp(r'\s'), '');

      // Fix padding
      while (cleaned.length % 4 != 0) {
        cleaned += '=';
      }

      final decoded = utf8.decode(base64.decode(cleaned));
      debugPrint('[Parser] Base64 decoded successfully');
      return decoded;
    } catch (e) {
      debugPrint('[Parser] Base64 decode failed, using raw content: $e');
      return content;
    }
  }

  /// Parse subscription info from headers
  static SubscriptionInfo parseSubscriptionInfo(Map<String, String> headers) {
    String? profileTitle;
    int? upload, download, total;
    DateTime? expire;
    String? supportUrl, testUrl;
    Duration? updateInterval;

    // Parse profile-title
    final titleHeader = headers['profile-title'];
    if (titleHeader != null) {
      // May be base64 encoded
      profileTitle = safeDecodeBase64(titleHeader);
      if (profileTitle == titleHeader) {
        // Not base64, use as-is but decode URI if needed
        try {
          profileTitle = Uri.decodeComponent(titleHeader);
        } catch (_) {
          profileTitle = titleHeader;
        }
      }
    }

    // Parse content-disposition for filename
    if (profileTitle == null || profileTitle.isEmpty) {
      final disposition = headers['content-disposition'];
      if (disposition != null) {
        final match = RegExp(r"filename\*?=(?:UTF-8'')?([^;\s]+)")
            .firstMatch(disposition);
        if (match != null) {
          try {
            profileTitle = Uri.decodeComponent(match.group(1)!);
          } catch (_) {
            profileTitle = match.group(1);
          }
        }
      }
    }

    // Parse subscription-userinfo
    final userInfo = headers['subscription-userinfo'];
    if (userInfo != null) {
      final parts = userInfo.split(';').map((p) => p.trim());
      for (final part in parts) {
        final keyValue = part.split('=');
        if (keyValue.length == 2) {
          final key = keyValue[0].trim().toLowerCase();
          final value = int.tryParse(keyValue[1].trim());
          switch (key) {
            case 'upload':
              upload = value;
              break;
            case 'download':
              download = value;
              break;
            case 'total':
              total = value;
              break;
            case 'expire':
              if (value != null && value > 0) {
                expire = DateTime.fromMillisecondsSinceEpoch(value * 1000);
              }
              break;
          }
        }
      }
    }

    // Parse other headers
    supportUrl = headers['support-url'] ?? headers['profile-web-page-url'];
    testUrl = headers['test-url'];

    final intervalStr = headers['profile-update-interval'];
    if (intervalStr != null) {
      final hours = int.tryParse(intervalStr);
      if (hours != null) {
        updateInterval = Duration(hours: hours);
      }
    }

    return SubscriptionInfo(
      profileTitle: profileTitle,
      upload: upload,
      download: download,
      total: total,
      expire: expire,
      supportUrl: supportUrl,
      testUrl: testUrl,
      updateInterval: updateInterval,
    );
  }

  /// Parse headers from content comments (first 10 lines)
  /// Based on Hiddify's parseHeadersFromContent
  static Map<String, String> parseHeadersFromContent(String content) {
    final headers = <String, String>{};
    final decoded = safeDecodeBase64(content);
    final lines = decoded.split('\n');
    final linesToProcess = lines.length < 10 ? lines.length : 10;

    for (var i = 0; i < linesToProcess; i++) {
      final line = lines[i].trim();
      if (line.startsWith('#') || line.startsWith('//')) {
        final colonIndex = line.indexOf(':');
        if (colonIndex == -1) continue;

        final key = line
            .substring(0, colonIndex)
            .replaceFirst(RegExp(r'^#|//'), '')
            .trim()
            .toLowerCase();
        final value = line.substring(colonIndex + 1).trim();

        if (!headers.containsKey(key) &&
            _subInfoHeaders.contains(key) &&
            value.isNotEmpty) {
          headers[key] = value;
        }
      }
    }

    return headers;
  }

  /// Merge HTTP headers with content-parsed headers
  static Map<String, String> mergeHeaders(
    Map<String, String> httpHeaders,
    String content,
  ) {
    final contentHeaders = parseHeadersFromContent(content);
    final merged = Map<String, String>.from(httpHeaders);

    for (final entry in contentHeaders.entries) {
      if (!merged.containsKey(entry.key)) {
        merged[entry.key] = entry.value;
      }
    }

    return merged;
  }

  /// Parse content into list of config lines
  static List<ParsedConfig> parseConfigs(String content) {
    final decoded = safeDecodeBase64(content);
    final normalized = decoded.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    // Split by newlines first
    var lines =
        normalized.split('\n').where((l) => l.trim().isNotEmpty).toList();

    // If single line with multiple protocols, split by protocol prefixes
    if (lines.length == 1 && _containsMultipleProtocols(normalized)) {
      lines = _splitByProtocols(normalized);
      debugPrint('[Parser] Split single line into ${lines.length} configs');
    }

    final configs = <ParsedConfig>[];

    for (final line in lines) {
      final trimmed = line.trim();

      // Skip comments
      if (trimmed.startsWith('#') || trimmed.startsWith('//')) {
        continue;
      }

      // Check if it's a valid protocol
      final protocol = _getProtocol(trimmed);
      if (protocol == null) {
        debugPrint(
            '[Parser] Skipping unknown protocol: ${trimmed.substring(0, trimmed.length > 30 ? 30 : trimmed.length)}...');
        continue;
      }

      // Extract name from fragment
      String? name;
      try {
        final uri = Uri.parse(trimmed);
        if (uri.hasFragment && uri.fragment.isNotEmpty) {
          name = Uri.decodeComponent(uri.fragment.split('&&detour')[0]);
        }
      } catch (_) {}

      configs.add(ParsedConfig(
        rawLink: trimmed,
        protocol: protocol,
        name: name,
      ));
    }

    debugPrint('[Parser] Parsed ${configs.length} valid configs');
    return configs;
  }

  /// Get protocol from line
  static String? _getProtocol(String line) {
    final lower = line.toLowerCase();
    for (final protocol in _supportedProtocols) {
      if (lower.startsWith('$protocol://')) {
        return protocol;
      }
    }
    // Check for JSON config
    if (lower.startsWith('{')) {
      return 'json';
    }
    return null;
  }

  /// Check if content contains multiple protocol prefixes
  static bool _containsMultipleProtocols(String content) {
    final pattern = RegExp(
      r'(vmess|vless|trojan|ss|ssr|hysteria2?|hy2?|tuic|wireguard|wg|warp|ssh|socks5?)://',
      caseSensitive: false,
    );
    return pattern.allMatches(content).length > 1;
  }

  /// Split content by protocol prefixes
  static List<String> _splitByProtocols(String content) {
    final pattern = RegExp(
      r'(?=vmess://|vless://|trojan://|ss://|ssr://|hysteria2://|hysteria://|hy2://|hy://|tuic://|wireguard://|wg://|warp://|ssh://|socks5?://)',
      caseSensitive: false,
    );
    return content
        .split(pattern)
        .where((s) => s.trim().isNotEmpty)
        .map((s) => s.trim())
        .toList();
  }
}
