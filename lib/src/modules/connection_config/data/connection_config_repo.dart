import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watashi/src/modules/connection_config/domain/connection_config_model.dart';

final connectionConfigRepoProvider =
    Provider<ConnectionConfigRepo>((_) => ConnectionConfigRepo());

class ConnectionConfigRepo {
  /// List of all saved configs
  List<ConnectionConfigModel> configs = [];

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
    final existingIndex = configs.indexWhere((c) => c.id == config.id);
    if (existingIndex != -1) {
      configs[existingIndex] = config;
    } else {
      configs.add(config);
    }

    // If this is the first config, set it as active
    if (configs.length == 1) {
      activeConfig = config;
      activeIndex = 0;
    }
  }

  /// Remove a config from the list
  void removeConfig(String configId) {
    final index = configs.indexWhere((c) => c.id == configId);
    if (index == -1) return;

    configs.removeAt(index);

    // Update active config if needed
    if (activeConfig?.id == configId) {
      if (configs.isNotEmpty) {
        activeIndex = 0;
        activeConfig = configs[0];
      } else {
        activeIndex = -1;
        activeConfig = null;
      }
    } else if (activeIndex > index) {
      activeIndex--;
    }
  }

  /// Update an existing config
  void updateConfig(ConnectionConfigModel config) {
    final index = configs.indexWhere((c) => c.id == config.id);
    if (index != -1) {
      configs[index] = config;
      if (activeConfig?.id == config.id) {
        activeConfig = config;
      }
    }
  }

  /// Set the active config by index
  void setActiveConfig(int index) {
    if (index >= 0 && index < configs.length) {
      activeIndex = index;
      activeConfig = configs[index];
      autoSelectEnabled = false;
    }
  }

  /// Set auto-select mode
  void setAutoSelect() {
    autoSelectEnabled = true;
    activeIndex = -1;
    // Auto-select will pick the config with lowest ping
    _selectBestPingConfig();
  }

  /// Select the config with lowest ping
  void _selectBestPingConfig() {
    if (configs.isEmpty) {
      activeConfig = null;
      return;
    }

    // Find config with lowest ping (excluding null pings)
    ConnectionConfigModel? bestConfig;
    int lowestPing = 999999;

    for (final config in configs) {
      if (config.ping != null && config.ping! < lowestPing) {
        lowestPing = config.ping!;
        bestConfig = config;
      }
    }

    // If no config has ping data, use first config
    activeConfig = bestConfig ?? configs.first;
  }

  /// Sort configs by ping (lowest first)
  void sortByPing() {
    configs.sort((a, b) {
      if (a.ping == null && b.ping == null) return 0;
      if (a.ping == null) return 1;
      if (b.ping == null) return -1;
      return a.ping!.compareTo(b.ping!);
    });

    // Update active index after sorting
    if (activeConfig != null) {
      activeIndex = configs.indexWhere((c) => c.id == activeConfig!.id);
    }
  }

  /// Update ping for a specific config
  void updatePing(String configId, int ping) {
    final index = configs.indexWhere((c) => c.id == configId);
    if (index != -1) {
      configs[index].ping = ping;

      // If auto-select is enabled, re-evaluate best config
      if (autoSelectEnabled) {
        _selectBestPingConfig();
      }
    }
  }

  /// Clear all configs
  void clearAllConfigs() {
    configs.clear();
    activeConfig = null;
    activeIndex = -1;
  }

  /// Get config by ID
  ConnectionConfigModel? getConfigById(String id) {
    try {
      return configs.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
