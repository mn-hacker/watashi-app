import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watashi/src/modules/connection_config/domain/connection_config_model.dart';

final connectionConfigRepoProvider =
    ChangeNotifierProvider<ConnectionConfigRepo>((_) => ConnectionConfigRepo());

class ConnectionConfigRepo extends ChangeNotifier {
  /// List of all saved configs
  List<ConnectionConfigModel> _configs = [];

  /// Get configs list
  List<ConnectionConfigModel> get configs => _configs;

  /// Currently active/selected config
  ConnectionConfigModel? activeConfig;

  /// Index of the active config in the list (-1 for auto mode)
  int activeIndex = -1;

  /// Whether auto-select mode is enabled
  bool autoSelectEnabled = true;

  /// Legacy single config getter for backward compatibility
  ConnectionConfigModel? get config => activeConfig;

  /// Add a new config to the list
  void addConfig(ConnectionConfigModel config) {
    // Check if config with same ID already exists
    final existingIndex = _configs.indexWhere((c) => c.id == config.id);
    if (existingIndex != -1) {
      _configs[existingIndex] = config;
    } else {
      _configs.add(config);
    }

    // If this is the first config, set it as active
    if (_configs.length == 1) {
      activeConfig = config;
      activeIndex = 0;
    }

    notifyListeners();
  }

  /// Remove a config from the list
  void removeConfig(String configId) {
    final index = _configs.indexWhere((c) => c.id == configId);
    if (index == -1) return;

    _configs.removeAt(index);

    // Update active config if needed
    if (activeConfig?.id == configId) {
      if (_configs.isNotEmpty) {
        activeIndex = 0;
        activeConfig = _configs[0];
      } else {
        activeIndex = -1;
        activeConfig = null;
      }
    } else if (activeIndex > index) {
      activeIndex--;
    }

    notifyListeners();
  }

  /// Update an existing config
  void updateConfig(ConnectionConfigModel config) {
    final index = _configs.indexWhere((c) => c.id == config.id);
    if (index != -1) {
      _configs[index] = config;
      if (activeConfig?.id == config.id) {
        activeConfig = config;
      }
      notifyListeners();
    }
  }

  /// Set the active config by index
  void setActiveConfig(int index) {
    if (index >= 0 && index < _configs.length) {
      activeIndex = index;
      activeConfig = _configs[index];
      autoSelectEnabled = false;
      notifyListeners();
    }
  }

  /// Set auto-select mode
  void setAutoSelect() {
    autoSelectEnabled = true;
    activeIndex = -1;
    // Auto-select will pick the config with lowest ping
    _selectBestPingConfig();
    notifyListeners();
  }

  /// Select the config with lowest ping
  void _selectBestPingConfig() {
    if (_configs.isEmpty) {
      activeConfig = null;
      return;
    }

    // Find config with lowest ping (excluding null and negative pings)
    ConnectionConfigModel? bestConfig;
    int lowestPing = 999999;

    for (final config in _configs) {
      if (config.ping != null &&
          config.ping! > 0 &&
          config.ping! < lowestPing) {
        lowestPing = config.ping!;
        bestConfig = config;
      }
    }

    // If no config has ping data, use first config
    activeConfig = bestConfig ?? _configs.first;
  }

  /// Sort configs by ping (lowest first)
  void sortByPing() {
    _configs.sort((a, b) {
      // Put negative/null pings at the end
      if (a.ping == null || a.ping! < 0) return 1;
      if (b.ping == null || b.ping! < 0) return -1;
      return a.ping!.compareTo(b.ping!);
    });

    // Update active index after sorting
    if (activeConfig != null) {
      activeIndex = _configs.indexWhere((c) => c.id == activeConfig!.id);
    }

    notifyListeners();
  }

  /// Update ping for a specific config
  void updatePing(String configId, int ping) {
    final index = _configs.indexWhere((c) => c.id == configId);
    if (index != -1) {
      _configs[index].ping = ping;

      // If auto-select is enabled, re-evaluate best config
      if (autoSelectEnabled) {
        _selectBestPingConfig();
      }

      notifyListeners();
    }
  }

  /// Clear all configs
  void clearAllConfigs() {
    _configs.clear();
    activeConfig = null;
    activeIndex = -1;
    notifyListeners();
  }

  /// Get config by ID
  ConnectionConfigModel? getConfigById(String id) {
    try {
      return _configs.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
