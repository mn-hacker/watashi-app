import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watashi/src/modules/connection/domain/connection_mode.dart';
import 'package:watashi/src/modules/connection_config/domain/connection_config_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPrefsRepoProvider =
    Provider.autoDispose((ref) => SharedPrefsRepo());

// TODO: Use SharedPreferencesException here
class SharedPrefsRepo {
  static const _firstRun = 'first_run';
  static const _selectedConnectionMode = 'selected_connection_mode';
  static const _connectionStartTime = 'connection_start_time';
  static const _connectionConfig = 'connection_config'; // Legacy single config
  static const _connectionConfigs = 'connection_configs'; // Multiple configs
  static const _activeConfigIndex = 'active_config_index';
  static const _autoSelectEnabled = 'auto_select_enabled';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<bool> isFirstRun() async => (await _prefs).getBool(_firstRun) ?? true;

  Future<bool> setFirstRunToFalse() async =>
      (await _prefs).setBool(_firstRun, false);

  Future<ConnectionMode> selectedConnectionMode() async {
    // 1 = proxy, 2 = vpn
    // See [ConnectionMode.fromValue()]
    final value = (await _prefs).getInt(_selectedConnectionMode) ?? 2;
    return ConnectionMode.fromValue(value);
  }

  Future<void> saveConnectionStartTime(DateTime timestamp) async {
    await (await _prefs)
        .setString(_connectionStartTime, timestamp.toIso8601String());
  }

  // ==================== LEGACY SINGLE CONFIG (for backward compatibility) ====================

  Future<void> saveConnectionConfig(String config) async {
    await (await _prefs).setString(_connectionConfig, config);
  }

  Future<String?> getConnectionConfig() async {
    return (await _prefs).getString(_connectionConfig);
  }

  Future<void> clearConnectionConfig() async {
    await (await _prefs).remove(_connectionConfig);
  }

  // ==================== MULTI-CONFIG STORAGE ====================

  /// Save all configs to storage
  Future<void> saveAllConfigs(List<ConnectionConfigModel> configs) async {
    final prefs = await _prefs;
    final configsJson = configs.map((c) => c.toStorageJson()).toList();
    await prefs.setString(_connectionConfigs, jsonEncode(configsJson));
  }

  /// Load all configs from storage
  Future<List<ConnectionConfigModel>> loadAllConfigs() async {
    final prefs = await _prefs;
    final configsString = prefs.getString(_connectionConfigs);

    if (configsString == null || configsString.isEmpty) {
      // Try to migrate from legacy single config
      final legacyConfig = prefs.getString(_connectionConfig);
      if (legacyConfig != null && legacyConfig.isNotEmpty) {
        try {
          final config =
              ConnectionConfigModel.fromLink(configLink: legacyConfig);
          return [config];
        } catch (e) {
          return [];
        }
      }
      return [];
    }

    try {
      final List<dynamic> configsJson = jsonDecode(configsString);
      return configsJson
          .map((json) => ConnectionConfigModel.fromStorageJson(
              json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Save active config index
  Future<void> saveActiveConfigIndex(int index) async {
    await (await _prefs).setInt(_activeConfigIndex, index);
  }

  /// Load active config index
  Future<int> loadActiveConfigIndex() async {
    return (await _prefs).getInt(_activeConfigIndex) ?? -1;
  }

  /// Save auto-select setting
  Future<void> saveAutoSelectEnabled(bool enabled) async {
    await (await _prefs).setBool(_autoSelectEnabled, enabled);
  }

  /// Load auto-select setting
  Future<bool> loadAutoSelectEnabled() async {
    return (await _prefs).getBool(_autoSelectEnabled) ?? true;
  }

  /// Clear all configs
  Future<void> clearAllConfigs() async {
    final prefs = await _prefs;
    await prefs.remove(_connectionConfigs);
    await prefs.remove(_activeConfigIndex);
    await prefs.remove(_connectionConfig);
  }

  // ==================== CONNECTION TIME ====================

  Future<DateTime?> getConnectionStartTime() async {
    final timestamp = (await _prefs).getString(_connectionStartTime);
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  Future<void> clearConnectionStartTime() async {
    await (await _prefs).remove(_connectionStartTime);
  }
}
