import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watashi/src/modules/profile/domain/profile_entity.dart';
import 'package:watashi/src/modules/profile/data/profile_parser.dart';
import 'package:watashi/src/modules/connection_config/data/connection_config_repo.dart';
import 'package:watashi/src/shared/data/shared_prefs_repo.dart';

final profileRepoProvider =
    ChangeNotifierProvider<ProfileRepo>((_) => ProfileRepo());

/// Repository for managing subscription profiles
class ProfileRepo extends ChangeNotifier {
  static const _storageKey = 'profiles_v1';

  List<ProfileEntity> _profiles = [];
  bool _isLoading = false;

  /// Get all profiles
  List<ProfileEntity> get profiles => _profiles;

  /// Get active profile
  ProfileEntity? get activeProfile {
    try {
      return _profiles.firstWhere((p) => p.active);
    } catch (e) {
      return _profiles.isNotEmpty ? _profiles.first : null;
    }
  }

  /// Check if any profile exists
  bool get hasProfiles => _profiles.isNotEmpty;

  /// Loading state
  bool get isLoading => _isLoading;

  /// Load profiles from storage
  Future<void> loadProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);

      if (jsonStr != null) {
        final List<dynamic> jsonList = json.decode(jsonStr);
        _profiles = jsonList
            .map((j) => ProfileEntity.fromJson(j as Map<String, dynamic>))
            .toList();

        debugPrint('[ProfileRepo] Loaded ${_profiles.length} profiles');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[ProfileRepo] Error loading profiles: $e');
    }
  }

  /// Save profiles to storage
  Future<void> _saveProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _profiles.map((p) => p.toJson()).toList();
      await prefs.setString(_storageKey, json.encode(jsonList));
      debugPrint('[ProfileRepo] Saved ${_profiles.length} profiles');
    } catch (e) {
      debugPrint('[ProfileRepo] Error saving profiles: $e');
    }
  }

  /// Add a new profile from URL
  Future<ProfileEntity?> addProfile(String url) async {
    _isLoading = true;
    notifyListeners();

    try {
      final httpClient = HttpClient();
      httpClient.connectionTimeout = const Duration(seconds: 15);
      httpClient.badCertificateCallback = (cert, host, port) => true;

      final request = await httpClient.getUrl(Uri.parse(url));
      request.followRedirects = true;
      request.maxRedirects = 5;
      request.headers.add('User-Agent', 'WatashiVPN/1.0');

      final response = await request.close();

      if (response.statusCode != 200) {
        debugPrint('[ProfileRepo] Failed to fetch: ${response.statusCode}');
        _isLoading = false;
        notifyListeners();
        return null;
      }

      // Extract headers
      final headers = <String, String>{};
      response.headers.forEach((name, values) {
        headers[name.toLowerCase()] = values.join(', ');
      });

      // Parse profile from headers
      final profile = ProfileParser.parse(url, headers);

      // Consume response body (content will be processed by connection config controller)
      await response.transform(utf8.decoder).join();
      httpClient.close();

      // Check if profile with same URL exists
      final existingIndex = _profiles.indexWhere((p) => p.url == url);
      if (existingIndex != -1) {
        // Update existing profile
        _profiles[existingIndex] = profile.copyWith(
          name: profile.name,
          subInfo: profile.subInfo,
          lastUpdate: DateTime.now(),
          active: _profiles[existingIndex].active,
        );
        // Keep the same ID
        _profiles[existingIndex] = ProfileEntity(
          id: _profiles[existingIndex].id,
          name: profile.name,
          url: url,
          lastUpdate: DateTime.now(),
          active: _profiles[existingIndex].active,
          subInfo: profile.subInfo,
        );
      } else {
        // Add new profile
        // If first profile, make it active
        if (_profiles.isEmpty) {
          _profiles.add(profile.copyWith(active: true));
        } else {
          _profiles.add(profile);
        }
      }

      await _saveProfiles();
      _isLoading = false;
      notifyListeners();

      debugPrint('[ProfileRepo] Added/updated profile: ${profile.name}');
      return _profiles.last;
    } catch (e) {
      debugPrint('[ProfileRepo] Error adding profile: $e');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Update/refresh a profile by ID
  /// Also refreshes configs (deletes old ones, imports new ones)
  Future<bool> updateProfile(
    String id, {
    ConnectionConfigRepo? configRepo,
    SharedPrefsRepo? sharedPrefsRepo,
    dynamic subscriptionService,
  }) async {
    final index = _profiles.indexWhere((p) => p.id == id);
    if (index == -1) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final profile = _profiles[index];

      // Step 1: Delete old configs for this profile
      if (configRepo != null) {
        final deletedCount = configRepo.removeConfigsByProfileId(id);
        debugPrint(
            '[ProfileRepo] Deleted $deletedCount old configs for profile: ${profile.name}');
      }

      // Step 2: Re-fetch and update profile info
      final updated = await addProfile(profile.url);

      // Step 3: Re-import configs if subscriptionService provided
      if (subscriptionService != null && updated != null) {
        try {
          final result = await subscriptionService.importFromUrl(profile.url);
          debugPrint(
              '[ProfileRepo] Re-imported ${result.successfulConfigs} configs');

          // Save config changes
          if (sharedPrefsRepo != null && configRepo != null) {
            await sharedPrefsRepo.saveAllConfigs(configRepo.configs);
            await sharedPrefsRepo.saveActiveConfigIndex(configRepo.activeIndex);
          }
        } catch (e) {
          debugPrint('[ProfileRepo] Failed to re-import configs: $e');
        }
      }

      _isLoading = false;
      notifyListeners();
      return updated != null;
    } catch (e) {
      debugPrint('[ProfileRepo] Error updating profile: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Set active profile by ID
  void setActiveProfile(String id) {
    for (var i = 0; i < _profiles.length; i++) {
      _profiles[i] = _profiles[i].copyWith(
        active: _profiles[i].id == id,
      );
    }
    _saveProfiles();
    notifyListeners();
  }

  /// Delete profile by ID
  /// If configRepo is provided, also deletes associated configs
  Future<int> deleteProfile(
    String id, {
    ConnectionConfigRepo? configRepo,
    SharedPrefsRepo? sharedPrefsRepo,
  }) async {
    final wasActive = _profiles.any((p) => p.id == id && p.active);
    _profiles.removeWhere((p) => p.id == id);

    // If deleted profile was active, make first one active
    if (wasActive && _profiles.isNotEmpty) {
      _profiles[0] = _profiles[0].copyWith(active: true);
    }

    await _saveProfiles();

    // Delete associated configs if repo provided
    int deletedConfigs = 0;
    if (configRepo != null) {
      deletedConfigs = configRepo.removeConfigsByProfileId(id);
      debugPrint(
          '[ProfileRepo] Deleted $deletedConfigs configs for profile $id');

      // Save config changes
      if (sharedPrefsRepo != null && deletedConfigs > 0) {
        await sharedPrefsRepo.saveAllConfigs(configRepo.configs);
        await sharedPrefsRepo.saveActiveConfigIndex(configRepo.activeIndex);
      }
    }

    notifyListeners();
    return deletedConfigs;
  }

  /// Delete all profiles
  Future<void> deleteAllProfiles({
    ConnectionConfigRepo? configRepo,
    SharedPrefsRepo? sharedPrefsRepo,
  }) async {
    _profiles.clear();
    await _saveProfiles();

    // Delete all configs if repo provided
    if (configRepo != null) {
      configRepo.clearAllConfigs();
      if (sharedPrefsRepo != null) {
        await sharedPrefsRepo.saveAllConfigs([]);
        await sharedPrefsRepo.saveActiveConfigIndex(-1);
      }
    }

    notifyListeners();
  }
}
