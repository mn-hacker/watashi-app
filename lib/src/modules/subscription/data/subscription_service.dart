import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watashi/src/modules/subscription/data/subscription_fetcher.dart';
import 'package:watashi/src/modules/subscription/data/subscription_parser.dart';
import 'package:watashi/src/modules/connection_config/domain/connection_config_model.dart';
import 'package:watashi/src/modules/connection_config/data/connection_config_repo.dart';
import 'package:watashi/src/modules/profile/data/profile_repo.dart';
import 'package:watashi/src/shared/data/shared_prefs_repo.dart';

/// Provider for SubscriptionService
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService(ref);
});

/// Result of subscription import
class SubscriptionImportResult {
  final int totalConfigs;
  final int successfulConfigs;
  final List<String> errors;
  final SubscriptionInfo? subscriptionInfo;

  SubscriptionImportResult({
    required this.totalConfigs,
    required this.successfulConfigs,
    this.errors = const [],
    this.subscriptionInfo,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get isSuccess => successfulConfigs > 0;
}

/// Service for importing subscriptions
/// Based on Hiddify's architecture but adapted for Watashi
class SubscriptionService {
  final Ref _ref;

  SubscriptionService(this._ref);

  /// Import subscription from URL
  Future<SubscriptionImportResult> importFromUrl(String url) async {
    debugPrint('[SubscriptionService] Starting import from: $url');

    final errors = <String>[];

    try {
      // Step 1: Fetch content
      final response = await SubscriptionFetcher.fetch(url);

      // Step 2: Merge headers (HTTP headers + content headers)
      final mergedHeaders = SubscriptionParser.mergeHeaders(
        response.headers,
        response.content,
      );

      // Step 3: Parse subscription info
      final subInfo = SubscriptionParser.parseSubscriptionInfo(mergedHeaders);
      debugPrint(
          '[SubscriptionService] Profile title: ${subInfo.profileTitle}');

      // Step 4: Create/update profile and get profileId
      final profileId = await _createProfile(url, subInfo);

      // Step 5: Parse configs
      final parsedConfigs = SubscriptionParser.parseConfigs(response.content);
      debugPrint('[SubscriptionService] Found ${parsedConfigs.length} configs');

      if (parsedConfigs.isEmpty) {
        return SubscriptionImportResult(
          totalConfigs: 0,
          successfulConfigs: 0,
          errors: ['هیچ کانفیگ معتبری در این ساب پیدا نشد'],
          subscriptionInfo: subInfo,
        );
      }

      // Step 6: Build and add configs with profileId
      int successCount = 0;
      final configRepo = _ref.read(connectionConfigRepoProvider);

      for (final parsed in parsedConfigs) {
        try {
          final config = _buildConfig(parsed, profileId: profileId);
          configRepo.addConfig(config);
          successCount++;
          debugPrint('[SubscriptionService] Added: ${config.configName}');
        } catch (e) {
          errors.add('Failed to parse ${parsed.name ?? parsed.protocol}: $e');
          debugPrint('[SubscriptionService] Failed to build config: $e');
        }
      }

      // Step 7: Save to persistent storage
      if (successCount > 0) {
        final sharedPrefs = _ref.read(sharedPrefsRepoProvider);
        await sharedPrefs.saveAllConfigs(configRepo.configs);
        await sharedPrefs.saveActiveConfigIndex(configRepo.activeIndex);
        await sharedPrefs.saveAutoSelectEnabled(configRepo.autoSelectEnabled);
      }

      return SubscriptionImportResult(
        totalConfigs: parsedConfigs.length,
        successfulConfigs: successCount,
        errors: errors,
        subscriptionInfo: subInfo,
      );
    } on SubscriptionException catch (e) {
      return SubscriptionImportResult(
        totalConfigs: 0,
        successfulConfigs: 0,
        errors: [e.message],
      );
    } catch (e) {
      debugPrint('[SubscriptionService] Unexpected error: $e');
      return SubscriptionImportResult(
        totalConfigs: 0,
        successfulConfigs: 0,
        errors: ['خطا در دریافت ساب: $e'],
      );
    }
  }

  /// Import from raw content (pasted or from file)
  Future<SubscriptionImportResult> importFromContent(String content) async {
    debugPrint('[SubscriptionService] Importing from content');

    final errors = <String>[];

    try {
      // Parse configs directly
      final parsedConfigs = SubscriptionParser.parseConfigs(content);

      if (parsedConfigs.isEmpty) {
        return SubscriptionImportResult(
          totalConfigs: 0,
          successfulConfigs: 0,
          errors: ['هیچ کانفیگ معتبری پیدا نشد'],
        );
      }

      // Create or get local profile for these configs
      final profileRepo = _ref.read(profileRepoProvider);
      final firstConfigName = parsedConfigs.first.name;
      final profileId = await profileRepo.addLocalProfile(
        configName: firstConfigName,
      );

      // Build and add configs with profileId
      int successCount = 0;
      final configRepo = _ref.read(connectionConfigRepoProvider);

      for (final parsed in parsedConfigs) {
        try {
          final config = _buildConfig(parsed, profileId: profileId);
          configRepo.addConfig(config);
          successCount++;
        } catch (e) {
          errors.add('Failed to parse ${parsed.name ?? parsed.protocol}: $e');
        }
      }

      // Save
      if (successCount > 0) {
        final sharedPrefs = _ref.read(sharedPrefsRepoProvider);
        await sharedPrefs.saveAllConfigs(configRepo.configs);
        await sharedPrefs.saveActiveConfigIndex(configRepo.activeIndex);
        await sharedPrefs.saveAutoSelectEnabled(configRepo.autoSelectEnabled);
      }

      return SubscriptionImportResult(
        totalConfigs: parsedConfigs.length,
        successfulConfigs: successCount,
        errors: errors,
      );
    } catch (e) {
      return SubscriptionImportResult(
        totalConfigs: 0,
        successfulConfigs: 0,
        errors: ['خطا در پردازش محتوا: $e'],
      );
    }
  }

  /// Import single config
  Future<bool> importSingleConfig(String configLink) async {
    try {
      final parsed = SubscriptionParser.parseConfigs(configLink);
      if (parsed.isEmpty) return false;

      // Create or get local profile
      final profileRepo = _ref.read(profileRepoProvider);
      final profileId = await profileRepo.addLocalProfile(
        configName: parsed.first.name,
      );

      final config = _buildConfig(parsed.first, profileId: profileId);
      final configRepo = _ref.read(connectionConfigRepoProvider);
      configRepo.addConfig(config);

      final sharedPrefs = _ref.read(sharedPrefsRepoProvider);
      await sharedPrefs.saveAllConfigs(configRepo.configs);
      await sharedPrefs.saveActiveConfigIndex(configRepo.activeIndex);

      return true;
    } catch (e) {
      debugPrint('[SubscriptionService] Failed to import single config: $e');
      return false;
    }
  }

  /// Create or update profile from subscription info
  /// Returns the profileId for linking configs
  Future<String?> _createProfile(String url, SubscriptionInfo info) async {
    try {
      final profileRepo = _ref.read(profileRepoProvider);
      final profile = await profileRepo.addProfile(url);
      return profile?.id;
    } catch (e) {
      debugPrint('[SubscriptionService] Failed to create profile: $e');
      return null;
    }
  }

  /// Build ConnectionConfigModel from ParsedConfig
  ConnectionConfigModel _buildConfig(ParsedConfig parsed, {String? profileId}) {
    debugPrint(
        '[SubscriptionService] Building config: protocol=${parsed.protocol}, link=${parsed.rawLink.substring(0, parsed.rawLink.length > 50 ? 50 : parsed.rawLink.length)}...');

    if (parsed.protocol == 'json') {
      // For JSON protocol, the rawLink contains the full JSON string
      try {
        final jsonContent = jsonDecode(parsed.rawLink) as Map<String, dynamic>;
        debugPrint('[SubscriptionService] Parsed JSON config successfully');
        return ConnectionConfigModel.fromJson(jsonContent);
      } catch (e) {
        debugPrint('[SubscriptionService] Failed to parse JSON config: $e');
        // Fallback: treat as link
        return ConnectionConfigModel.fromLink(
          configLink: parsed.rawLink,
          profileId: profileId,
        );
      }
    }

    debugPrint('[SubscriptionService] Creating config from link');
    return ConnectionConfigModel.fromLink(
      configLink: parsed.rawLink,
      profileId: profileId,
    );
  }
}
