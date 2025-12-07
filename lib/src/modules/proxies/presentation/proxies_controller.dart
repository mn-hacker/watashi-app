import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watashi/src/modules/connection_config/data/connection_config_repo.dart';
import 'package:watashi/src/shared/data/shared_prefs_repo.dart';

final proxiesControllerProvider =
    AsyncNotifierProvider<ProxiesController, void>(ProxiesController.new);

class ProxiesController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() async {
    // Initial state
  }

  /// Test ping for all configs
  Future<void> testAllPings() async {
    final configRepo = ref.read(connectionConfigRepoProvider);
    final sharedPrefs = ref.read(sharedPrefsRepoProvider);

    for (final config in configRepo.configs) {
      final ping = await _testPing(config.serverAddress, config.serverPort);
      configRepo.updatePing(config.id, ping);
    }

    // Save updated configs with ping values
    await sharedPrefs.saveAllConfigs(configRepo.configs);

    // Trigger UI refresh
    ref.invalidateSelf();
  }

  /// Test ping for a specific server
  Future<int> _testPing(String? address, int? port) async {
    if (address == null) return -1;

    try {
      final stopwatch = Stopwatch()..start();

      // Real ping test using TCP connection
      final socket = await Socket.connect(
        address,
        port ?? 443,
        timeout: const Duration(seconds: 5),
      );

      stopwatch.stop();
      await socket.close();

      return stopwatch.elapsedMilliseconds;
    } catch (e) {
      // Connection failed
      return -1;
    }
  }

  /// Test ping for a single config
  Future<void> testPingForConfig(String configId) async {
    final configRepo = ref.read(connectionConfigRepoProvider);
    final config = configRepo.getConfigById(configId);

    if (config == null) return;

    final ping = await _testPing(config.serverAddress, config.serverPort);
    configRepo.updatePing(configId, ping);

    // Save updated config
    await ref.read(sharedPrefsRepoProvider).saveAllConfigs(configRepo.configs);

    ref.invalidateSelf();
  }
}
