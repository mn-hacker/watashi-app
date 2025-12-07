import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watashi/src/modules/connection_config/data/connection_config_repo.dart';
import 'package:watashi/src/modules/connection_config/domain/connection_config_model.dart';
import 'package:watashi/src/modules/connection_config/presentation/widgets/connection_config_input_state.dart';
import 'package:watashi/src/modules/core/data/core_repo.dart';
import 'package:watashi/src/shared/data/shared_prefs_repo.dart';

final connectionConfigControllerProvider = NotifierProvider<
    ConnectionConfigInputController,
    ConnectionConfigInputState>(ConnectionConfigInputController.new);

class ConnectionConfigInputController
    extends Notifier<ConnectionConfigInputState> {
  late SharedPrefsRepo _sharedPrefsRepo;

  @override
  ConnectionConfigInputState build() {
    final configRepo = ref.watch(connectionConfigRepoProvider);
    final currentConfig = configRepo.activeConfig?.asStringValue;
    _sharedPrefsRepo = ref.read(sharedPrefsRepoProvider);
    final coreStatus = ref.watch(isCoreRunningProvider).value ?? false;
    _loadSavedConfigs();
    return ConnectionConfigInputState(
        input: currentConfig ?? '', isDisabled: coreStatus);
  }

  Future<void> _loadSavedConfigs() async {
    final savedConfigs = await _sharedPrefsRepo.loadAllConfigs();
    if (savedConfigs.isNotEmpty) {
      final configRepo = ref.read(connectionConfigRepoProvider);

      // Load all configs
      for (final config in savedConfigs) {
        configRepo.addConfig(config);
      }

      // Load active config settings
      final activeIndex = await _sharedPrefsRepo.loadActiveConfigIndex();
      final autoSelect = await _sharedPrefsRepo.loadAutoSelectEnabled();

      if (autoSelect) {
        configRepo.setAutoSelect();
      } else if (activeIndex >= 0 && activeIndex < savedConfigs.length) {
        configRepo.setActiveConfig(activeIndex);
      }

      // Update state with active config
      if (configRepo.activeConfig != null) {
        state = state.copyWith(input: configRepo.activeConfig!.asStringValue);
      }
    }
  }

  void updateInput(String input) {
    if (state.isDisabled || input.trim().isEmpty) return;
    try {
      final builtConfig = _buildConfig(input);
      final configRepo = ref.read(connectionConfigRepoProvider);

      // Add to configs list
      configRepo.addConfig(builtConfig);

      // Save all configs
      _sharedPrefsRepo.saveAllConfigs(configRepo.configs);
      _sharedPrefsRepo.saveActiveConfigIndex(configRepo.activeIndex);
      _sharedPrefsRepo.saveAutoSelectEnabled(configRepo.autoSelectEnabled);

      state = state.copyWith(input: builtConfig.asStringValue, error: null);
    } catch (e) {
      state = state.copyWith(input: input, error: e.toString());
    }
  }

  ConnectionConfigModel _buildConfig(String input) {
    final trimmedInput = input.trim();
    late final ConnectionConfigModel config;

    // checking the first character of the input to determine if it's a link or a json
    if (!input.startsWith('{')) {
      config = ConnectionConfigModel.fromLink(configLink: trimmedInput);
    } else {
      // TODO: consider coreType here
      config = ConnectionConfigModel.fromJson(jsonDecode(trimmedInput));
    }

    return config;
  }

  void pasteInput(String input) {
    if (state.isDisabled) return;
    updateInput(input);
  }

  void clearInput() {
    if (state.isDisabled) return;
    state = state.copyWith(input: '', error: null);
    // Note: We don't clear configs from repo here, just the input field
  }

  /// Set the active config by index
  void setActiveConfig(int index) {
    final configRepo = ref.read(connectionConfigRepoProvider);
    configRepo.setActiveConfig(index);
    _sharedPrefsRepo.saveActiveConfigIndex(index);
    _sharedPrefsRepo.saveAutoSelectEnabled(false);

    if (configRepo.activeConfig != null) {
      state = state.copyWith(input: configRepo.activeConfig!.asStringValue);
    }
  }

  /// Enable auto-select mode
  void enableAutoSelect() {
    final configRepo = ref.read(connectionConfigRepoProvider);
    configRepo.setAutoSelect();
    _sharedPrefsRepo.saveActiveConfigIndex(-1);
    _sharedPrefsRepo.saveAutoSelectEnabled(true);
  }

  /// Delete a config by ID
  void deleteConfig(String configId) {
    final configRepo = ref.read(connectionConfigRepoProvider);
    configRepo.removeConfig(configId);
    _sharedPrefsRepo.saveAllConfigs(configRepo.configs);
    _sharedPrefsRepo.saveActiveConfigIndex(configRepo.activeIndex);

    if (configRepo.activeConfig != null) {
      state = state.copyWith(input: configRepo.activeConfig!.asStringValue);
    } else {
      state = state.copyWith(input: '');
    }
  }

  /// Update an existing config
  void updateConfig(ConnectionConfigModel config) {
    final configRepo = ref.read(connectionConfigRepoProvider);
    configRepo.updateConfig(config);
    _sharedPrefsRepo.saveAllConfigs(configRepo.configs);

    if (configRepo.activeConfig?.id == config.id) {
      state = state.copyWith(input: config.asStringValue);
    }
  }

  /// Sort configs by ping
  void sortByPing() {
    final configRepo = ref.read(connectionConfigRepoProvider);
    configRepo.sortByPing();
    _sharedPrefsRepo.saveAllConfigs(configRepo.configs);
    _sharedPrefsRepo.saveActiveConfigIndex(configRepo.activeIndex);
  }
}
