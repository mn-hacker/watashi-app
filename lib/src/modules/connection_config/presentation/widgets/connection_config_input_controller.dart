import 'dart:convert';
import 'dart:io';

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

  void updateInput(String input) {
    if (state.isDisabled || input.trim().isEmpty) return;

    final trimmedInput = input.trim();

    // Check if it's a subscription URL (http/https)
    if (_isSubscriptionUrl(trimmedInput)) {
      _fetchSubscription(trimmedInput);
      return;
    }

    // Check if it's multiple configs (contains newlines or multiple protocol links)
    if (_isMultipleConfigs(trimmedInput)) {
      _addMultipleConfigs(trimmedInput);
      return;
    }

    // Single config
    try {
      final builtConfig = _buildConfig(trimmedInput);
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

  /// Check if input is a subscription URL
  bool _isSubscriptionUrl(String input) {
    return input.startsWith('http://') || input.startsWith('https://');
  }

  /// Check if input contains multiple configs
  bool _isMultipleConfigs(String input) {
    final lines = input.split('\n').where((l) => l.trim().isNotEmpty).toList();
    return lines.length > 1;
  }

  /// Check if line is a valid config (starts with known protocol)
  bool _isValidConfigLine(String line) {
    final validPrefixes = [
      'vless://',
      'vmess://',
      'trojan://',
      'ss://',
      'ssr://',
      'hysteria://',
      'hysteria2://',
      'hy2://',
      'tuic://',
      'wireguard://',
      'wg://',
      '{', // JSON config
    ];
    final lowerLine = line.toLowerCase();
    return validPrefixes.any((prefix) => lowerLine.startsWith(prefix));
  }

  /// Fetch subscription URL and add all configs from it
  Future<void> _fetchSubscription(String url) async {
    state = state.copyWith(error: null);
    print('[Subscription] Fetching: $url');

    try {
      final httpClient = HttpClient();
      httpClient.connectionTimeout = const Duration(seconds: 15);
      httpClient.badCertificateCallback =
          (cert, host, port) => true; // Allow self-signed certs

      final request = await httpClient.getUrl(Uri.parse(url));
      request.followRedirects = true;
      request.maxRedirects = 5;

      // Add common headers
      request.headers.add('User-Agent', 'WatashiVPN/1.0');
      request.headers.add('Accept', '*/*');

      final response = await request.close();
      print('[Subscription] Response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        state = state.copyWith(
            error: 'Failed to fetch subscription: HTTP ${response.statusCode}');
        httpClient.close();
        return;
      }

      final content = await response.transform(utf8.decoder).join();
      httpClient.close();

      print('[Subscription] Content length: ${content.length}');
      print(
          '[Subscription] Content preview: ${content.substring(0, content.length > 100 ? 100 : content.length)}...');

      // Try to decode as base64
      String decodedContent;
      try {
        // Fix base64 padding if needed
        String base64Content = content.trim();
        // Remove any whitespace/newlines within base64
        base64Content = base64Content.replaceAll(RegExp(r'\s'), '');
        // Add padding if necessary
        while (base64Content.length % 4 != 0) {
          base64Content += '=';
        }
        decodedContent = utf8.decode(base64.decode(base64Content));
        print('[Subscription] Base64 decoded successfully');
        print(
            '[Subscription] Decoded preview: ${decodedContent.substring(0, decodedContent.length > 200 ? 200 : decodedContent.length)}...');
      } catch (e) {
        // Not base64, use as-is
        print('[Subscription] Not base64, using raw content: $e');
        decodedContent = content;
      }

      // Parse and add configs
      _addMultipleConfigs(decodedContent);
    } catch (e, stack) {
      print('[Subscription] Error: $e');
      print('[Subscription] Stack: $stack');
      state = state.copyWith(error: 'Failed to fetch subscription: $e');
    }
  }

  /// Add multiple configs from multi-line input
  void _addMultipleConfigs(String content) {
    final lines =
        content.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final configRepo = ref.read(connectionConfigRepoProvider);
    int addedCount = 0;

    print('[AddConfigs] Found ${lines.length} lines to process');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      // Skip comment lines
      if (line.startsWith('#') || line.startsWith('//')) {
        print('[AddConfigs] Skipping comment line $i');
        continue;
      }

      // Only process valid protocol prefixes
      if (!_isValidConfigLine(line)) {
        print(
            '[AddConfigs] Skipping non-config line $i: ${line.substring(0, line.length > 30 ? 30 : line.length)}...');
        continue;
      }

      try {
        print(
            '[AddConfigs] Processing line $i: ${line.substring(0, line.length > 50 ? 50 : line.length)}...');
        final config = _buildConfig(line);
        configRepo.addConfig(config);
        addedCount++;
        print('[AddConfigs] Successfully added: ${config.configName}');
      } catch (e) {
        // Skip invalid lines
        print('[AddConfigs] Failed to parse line $i: $e');
        continue;
      }
    }

    print('[AddConfigs] Total configs added: $addedCount');

    if (addedCount > 0) {
      // Save all configs
      _sharedPrefsRepo.saveAllConfigs(configRepo.configs);
      _sharedPrefsRepo.saveActiveConfigIndex(configRepo.activeIndex);
      _sharedPrefsRepo.saveAutoSelectEnabled(configRepo.autoSelectEnabled);

      if (configRepo.activeConfig != null) {
        state = state.copyWith(
          input: configRepo.activeConfig!.asStringValue,
          error: null,
        );
      }
    } else {
      state = state.copyWith(error: 'No valid configs found in subscription');
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
