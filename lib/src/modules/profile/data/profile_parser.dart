import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:watashi/src/modules/profile/domain/profile_entity.dart';

/// Parses HTTP response headers for subscription profile information
/// Based on Hiddify's profile_parser.dart
abstract class ProfileParser {
  static const int _infiniteTrafficThreshold = 9223372036854775807; // ~8 EB
  static const int _infiniteTimeThreshold = 92233720368; // ~2900 years

  /// Parse profile from URL and response headers
  static ProfileEntity parse(String url, Map<String, String> headers) {
    // Extract profile name
    String name = '';

    // Try profile-title header (may be base64 encoded)
    if (headers['profile-title'] != null) {
      final titleHeader = headers['profile-title']!;
      if (titleHeader.startsWith('base64:')) {
        try {
          name = utf8.decode(base64.decode(titleHeader.substring(7)));
        } catch (e) {
          name = titleHeader.substring(7);
        }
      } else {
        name = titleHeader.trim();
      }
    }

    // Try content-disposition header
    if (name.isEmpty && headers['content-disposition'] != null) {
      final regExp = RegExp('filename="([^"]*)"');
      final match = regExp.firstMatch(headers['content-disposition']!);
      if (match != null && match.groupCount >= 1) {
        name = match.group(1) ?? '';
      }
    }

    // Try URL fragment (#name)
    if (name.isEmpty) {
      final uri = Uri.parse(url);
      if (uri.fragment.isNotEmpty) {
        name = Uri.decodeComponent(uri.fragment);
      }
    }

    // Try filename from URL path
    if (name.isEmpty) {
      final parts = url.split('/');
      if (parts.isNotEmpty) {
        final lastPart = parts.last.split('?').first;
        final pattern = RegExp(r'\.(json|yaml|yml|txt)[\s\S]*');
        name = lastPart.replaceFirst(pattern, '');
      }
    }

    // Fallback name
    if (name.isEmpty) {
      name = 'Remote Profile';
    }

    // Parse subscription info
    SubscriptionInfo? subInfo;
    if (headers['subscription-userinfo'] != null) {
      subInfo = parseSubscriptionInfo(headers['subscription-userinfo']!);
    }

    // Parse support URLs
    if (subInfo != null) {
      String? webPageUrl;
      String? supportUrl;

      if (headers['profile-web-page-url'] != null) {
        webPageUrl = headers['profile-web-page-url'];
      }
      if (headers['support-url'] != null) {
        supportUrl = headers['support-url'];
      }

      if (webPageUrl != null || supportUrl != null) {
        subInfo = subInfo.copyWith(
          webPageUrl: webPageUrl,
          supportUrl: supportUrl,
        );
      }
    }

    debugPrint('[ProfileParser] Parsed profile: $name');
    debugPrint('[ProfileParser] SubInfo: $subInfo');

    return ProfileEntity(
      name: name,
      url: url,
      subInfo: subInfo,
    );
  }

  /// Parse subscription-userinfo header
  /// Format: upload=X; download=Y; total=Z; expire=T
  static SubscriptionInfo? parseSubscriptionInfo(String subInfoStr) {
    try {
      final values = subInfoStr.split(';');
      final map = <String, int>{};

      for (final v in values) {
        final parts = v.split('=');
        if (parts.length == 2) {
          final key = parts[0].trim();
          final value = int.tryParse(parts[1].trim());
          if (value != null) {
            map[key] = value;
          }
        }
      }

      if (map.containsKey('upload') && map.containsKey('download')) {
        var total = map['total'] ?? _infiniteTrafficThreshold;
        var expire = map['expire'] ?? _infiniteTimeThreshold;

        // Treat 0 as infinite
        if (total == 0) total = _infiniteTrafficThreshold;
        if (expire == 0) expire = _infiniteTimeThreshold;

        return SubscriptionInfo(
          upload: map['upload']!,
          download: map['download']!,
          total: total,
          expire: DateTime.fromMillisecondsSinceEpoch(expire * 1000),
        );
      }
    } catch (e) {
      debugPrint('[ProfileParser] Error parsing subInfo: $e');
    }

    return null;
  }
}
