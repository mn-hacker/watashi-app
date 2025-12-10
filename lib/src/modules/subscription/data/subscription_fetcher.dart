import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Response from subscription fetcher
class SubscriptionResponse {
  final String content;
  final Map<String, String> headers;
  final int statusCode;

  SubscriptionResponse({
    required this.content,
    required this.headers,
    required this.statusCode,
  });
}

/// Fetches subscription content from URL with retry logic and User-Agent rotation
/// Based on Hiddify's http client approach
class SubscriptionFetcher {
  static const List<String> _userAgents = [
    'v2rayNG/1.8.23',
    'Clash/1.18.0',
    'sing-box/1.8.0',
    'Hiddify/2.5.7',
    'WatashiVPN/1.0',
  ];

  static const Duration _timeout = Duration(seconds: 30);
  static const int _maxRetries = 3;

  /// Fetch subscription with retry logic
  static Future<SubscriptionResponse> fetch(
    String url, {
    int retries = 0,
    String? userAgent,
  }) async {
    final effectiveUserAgent = userAgent ?? _userAgents[retries % _userAgents.length];

    debugPrint('[SubscriptionFetcher] Fetching: $url');
    debugPrint('[SubscriptionFetcher] User-Agent: $effectiveUserAgent (attempt ${retries + 1})');

    try {
      final httpClient = HttpClient();
      httpClient.connectionTimeout = _timeout;
      httpClient.badCertificateCallback = (cert, host, port) => true;

      final request = await httpClient.getUrl(Uri.parse(url.trim()));
      request.followRedirects = true;
      request.maxRedirects = 5;

      // Set headers
      request.headers.add('User-Agent', effectiveUserAgent);
      request.headers.add('Accept', '*/*');
      request.headers.add('Accept-Encoding', 'gzip, deflate');

      final response = await request.close();
      debugPrint('[SubscriptionFetcher] Response status: ${response.statusCode}');

      // Extract headers
      final headers = <String, String>{};
      response.headers.forEach((name, values) {
        headers[name.toLowerCase()] = values.join(', ');
      });

      // Read content
      final content = await response.transform(utf8.decoder).join();
      httpClient.close();

      if (response.statusCode != 200) {
        throw SubscriptionException(
          'HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      if (content.isEmpty) {
        throw SubscriptionException('Empty response from server');
      }

      debugPrint('[SubscriptionFetcher] Content length: ${content.length}');

      return SubscriptionResponse(
        content: content,
        headers: headers,
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('[SubscriptionFetcher] Error: $e');

      // Retry with different User-Agent
      if (retries < _maxRetries - 1) {
        debugPrint('[SubscriptionFetcher] Retrying with different User-Agent...');
        await Future.delayed(Duration(milliseconds: 500 * (retries + 1)));
        return fetch(url, retries: retries + 1);
      }

      if (e is SubscriptionException) rethrow;
      throw SubscriptionException('Failed to fetch: $e');
    }
  }

  /// Fetch with specific User-Agent (for testing)
  static Future<SubscriptionResponse> fetchWithAgent(
    String url,
    String userAgent,
  ) {
    return fetch(url, userAgent: userAgent);
  }
}

class SubscriptionException implements Exception {
  final String message;
  final int? statusCode;

  SubscriptionException(this.message, {this.statusCode});

  @override
  String toString() => 'SubscriptionException: $message';
}
