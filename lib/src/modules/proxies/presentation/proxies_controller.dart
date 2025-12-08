import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watashi/src/modules/connection_config/data/connection_config_repo.dart';
import 'package:watashi/src/shared/data/shared_prefs_repo.dart';

final proxiesControllerProvider =
    AsyncNotifierProvider<ProxiesController, bool>(ProxiesController.new);

class ProxiesController extends AsyncNotifier<bool> {
  @override
  FutureOr<bool> build() async {
    return false; // false = not testing, true = testing in progress
  }

  /// Test ping for all configs in parallel (much faster!)
  Future<void> testAllPings() async {
    state = const AsyncData(true); // Start loading
    debugPrint('[Ping] Starting ping test for all configs...');

    final configRepo = ref.read(connectionConfigRepoProvider);
    final sharedPrefs = ref.read(sharedPrefsRepoProvider);

    // Run all pings in parallel
    final futures = configRepo.configs.map((config) async {
      debugPrint(
          '[Ping] Testing ${config.configName}: ${config.serverAddress}:${config.serverPort}');
      final ping = await _testPing(config.serverAddress, config.serverPort);
      debugPrint('[Ping] Result for ${config.configName}: $ping ms');
      configRepo.updatePing(config.id, ping);
    }).toList();

    // Wait for all pings to complete
    await Future.wait(futures);

    // Save updated configs with ping values
    await sharedPrefs.saveAllConfigs(configRepo.configs);

    debugPrint('[Ping] All pings completed!');
    state = const AsyncData(false); // Done loading
  }

  /// Test ping for a specific server with shorter timeout
  Future<int> _testPing(String? address, int? port) async {
    if (address == null || address.isEmpty) return -1;

    try {
      final stopwatch = Stopwatch()..start();

      // TCP connection test with 3 second timeout (faster than 5s)
      final socket = await Socket.connect(
        address,
        port ?? 443,
        timeout: const Duration(seconds: 3),
      );

      stopwatch.stop();
      await socket.close();

      return stopwatch.elapsedMilliseconds;
    } catch (e) {
      debugPrint('[Ping] Error connecting to $address:$port - $e');
      // Connection failed or timeout
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
  }
}
