import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watashi/src/modules/connection_config/data/connection_config_repo.dart';
import 'package:watashi/src/modules/connection_config/domain/connection_config_model.dart';
import 'package:watashi/src/modules/connection_config/presentation/widgets/connection_config_input_state.dart';
import 'package:watashi/src/modules/core/data/core_repo.dart';
import 'package:watashi/src/modules/subscription/data/subscription_service.dart';
import 'package:watashi/src/shared/data/shared_prefs_repo.dart';

final connectionConfigControllerProvider = NotifierProvider<
    ConnectionConfigInputController,
    ConnectionConfigInputState>(ConnectionConfigInputController.new);

class ConnectionConfigInputController
    extends Notifier<ConnectionConfigInputState> {
  late SharedPrefsRepo _sharedPrefsRepo;
  bool _hasLoadedConfigs = false;

  @override
  ConnectionConfigInputState build() {
    // Use ref.read instead of ref.watch to avoid infinite rebuild loop
    final configRepo = ref.read(connectionConfigRepoProvider);
    final currentConfig = configRepo.activeConfig?.asStringValue;
    _sharedPrefsRepo = ref.read(sharedPrefsRepoProvider);
    final coreStatus = ref.watch(isCoreRunningProvider).value ?? false;

    // Only load saved configs once on initial build
    if (!_hasLoadedConfigs) {
      _hasLoadedConfigs = true;
      _loadSavedConfigs();
    }

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

  /// Main entry point for input processing
  Future<void> updateInput(String input) async {
    if (state.isDisabled || input.trim().isEmpty) return;

    final trimmedInput = input.trim();
    state = state.copyWith(error: null, isLoading: true);

    try {
      final subscriptionService = ref.read(subscriptionServiceProvider);

      // Check if it's a subscription URL (http/https)
      if (_isSubscriptionUrl(trimmedInput)) {
        debugPrint('[Controller] Processing subscription URL');
        final result = await subscriptionService.importFromUrl(trimmedInput);

        if (result.isSuccess) {
          final configRepo = ref.read(connectionConfigRepoProvider);
          state = state.copyWith(
            input: configRepo.activeConfig?.asStringValue ?? '',
            error: null,
            isLoading: false,
          );
          debugPrint(
              '[Controller] Imported ${result.successfulConfigs}/${result.totalConfigs} configs');
        } else {
          state = state.copyWith(
            error: result.errors.isNotEmpty
                ? result.errors.first
                : 'خطا در import',
            isLoading: false,
          );
        }
        return;
      }

      // Check if it's multiple configs or single config
      final result = await subscriptionService.importFromContent(trimmedInput);

      if (result.isSuccess) {
        final configRepo = ref.read(connectionConfigRepoProvider);
        state = state.copyWith(
          input: configRepo.activeConfig?.asStringValue ?? '',
          error: null,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error:
              result.errors.isNotEmpty ? result.errors.first : 'کانفیگ نامعتبر',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        input: input,
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Check if input is a subscription URL
  bool _isSubscriptionUrl(String input) {
    return input.startsWith('http://') || input.startsWith('https://');
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

  /// Delete all configs
  void deleteAllConfigs() {
    final configRepo = ref.read(connectionConfigRepoProvider);
    configRepo.clearAllConfigs();
    _sharedPrefsRepo.saveAllConfigs([]);
    _sharedPrefsRepo.saveActiveConfigIndex(-1);
    _sharedPrefsRepo.saveAutoSelectEnabled(false);
    state = state.copyWith(input: '');
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
