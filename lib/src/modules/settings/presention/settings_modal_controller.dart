import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proxy_core/constants/core_names.dart';
import 'package:watashi/src/modules/connection/application/connection_service.dart';
import 'package:watashi/src/modules/connection/domain/connection_mode.dart';
import 'package:watashi/src/modules/core/data/core_repo.dart';
import 'package:watashi/src/modules/settings/data/settings_repo.dart';
import 'package:watashi/src/modules/settings/domain/settings_model.dart';

final settingsModalControllerProvider =
    NotifierProvider<SettingsModalController, SettingsModel>(
        SettingsModalController.new);

class SettingsModalController extends Notifier<SettingsModel> {
  SettingsModalController();

  @override
  SettingsModel build() {
    final settings = ref.watch(settingsRepoProvider).settings;
    return settings;
  }

  void updateCoreType(CoreNames coreType) {
    state = state.copyWith(coreType: coreType);
  }

  void updateConnectionType(ConnectionLoadType connectionType) {
    state = state.copyWith(connectionLoadType: connectionType);
  }

  void updateConnectionMode(ConnectionMode connectionMode) {
    state = state.copyWith(connectionMode: connectionMode);
  }

  Future<void> updateSettings() async {
    final previousMode = ref.read(connectionModeProvider);
    final newMode = state.connectionMode;
    final isConnected = await ref.read(isCoreRunningProvider.future);

    debugPrint(
        'SettingsModalController.updateSettings: connectionMode = ${state.connectionMode.name}');

    // Persist settings
    ref.read(settingsRepoProvider).settings = state;
    ref.read(connectionModeProvider.notifier).state = state.connectionMode;

    debugPrint(
        'SettingsModalController.updateSettings: connectionModeProvider updated');

    // If mode changed while connected, disconnect and reconnect with new mode
    if (previousMode != newMode && isConnected) {
      debugPrint(
          'SettingsModalController.updateSettings: Mode changed, reconnecting...');
      final connectionService = ref.read(connectionServiceProvider);
      await connectionService.disconnect();
      await connectionService.connect();
    }
  }

  void restoreDefaults() {
    state = ref.read(settingsRepoProvider).defaultSettings;
  }
}
