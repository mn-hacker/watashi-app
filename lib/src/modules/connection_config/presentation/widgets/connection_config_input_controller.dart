import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

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
  /// Based on Hiddify's link_parsers.dart
  bool _isValidConfigLine(String line) {
    final validPrefixes = [
      // Standard protocols
      'vless://',
      'vmess://',
      'trojan://',
      'ss://',
      'ssconf://', // Shadowsocks config
      'ssr://', // ShadowsocksR

      // Hysteria
      'hysteria://',
      'hysteria2://',
      'hy2://',
      'hy://',

      // TUIC
      'tuic://',

      // Wireguard
      'wireguard://',
      'wg://',

      // WARP
      'warp://',

      // SSH
      'ssh://',

      // SOCKS (not HTTP as it conflicts with subscription URL detection)
      'socks://',
      'socks5://',

      // JSON config
      '{',
    ];
    final lowerLine = line.toLowerCase();
    return validPrefixes.any((prefix) => lowerLine.startsWith(prefix));
  }

  /// Check if content contains multiple protocol prefixes
  bool _containsMultipleProtocols(String content) {
    final protocolPattern = RegExp(
      r'(vmess|vless|trojan|ss|ssr|hysteria2?|hy2?|tuic|wireguard|wg|warp|ssh|socks5?)://',
      caseSensitive: false,
    );
    final matches = protocolPattern.allMatches(content);
    return matches.length > 1;
  }

  /// Split content by protocol prefixes
  List<String> _splitByProtocols(String content) {
    final protocolPattern = RegExp(
      r'(?=vmess://|vless://|trojan://|ss://|ssr://|hysteria2://|hysteria://|hy2://|hy://|tuic://|wireguard://|wg://|warp://|ssh://|socks5?://)',
      caseSensitive: false,
    );
    return content
        .split(protocolPattern)
        .where((s) => s.trim().isNotEmpty)
        .map((s) => s.trim())
        .toList();
  }

  /// Fetch subscription URL and add all configs from it
  Future<void> _fetchSubscription(String url) async {
    state = state.copyWith(error: null);
    debugPrint('[Subscription] Fetching: $url');

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
      debugPrint('[Subscription] Response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        state = state.copyWith(
            error: 'Failed to fetch subscription: HTTP ${response.statusCode}');
        httpClient.close();
        return;
      }

      final content = await response.transform(utf8.decoder).join();
      httpClient.close();

      debugPrint('[Subscription] Content length: ${content.length}');
      debugPrint(
          '[Subscription] Content preview: ${content.substring(0, content.length > 200 ? 200 : content.length)}');

      // Determine if content is base64 encoded
      // If content starts with protocol prefixes or #, it's NOT base64
      String decodedContent;
      final trimmedContent = content.trim();

      final plainTextIndicators = [
        'vless://',
        'vmess://',
        'trojan://',
        'ss://',
        'ssr://',
        'hysteria://',
        'hysteria2://',
        'hy://',
        'hy2://',
        'tuic://',
        'wireguard://',
        'wg://',
        'warp://',
        'ssh://',
        'socks://',
        'socks5://',
        'http://',
        '#',
        '//'
      ];

      final isPlainText = plainTextIndicators.any((prefix) =>
          trimmedContent.toLowerCase().startsWith(prefix.toLowerCase()));

      if (isPlainText) {
        debugPrint(
            '[Subscription] Content is plain text (starts with protocol prefix)');
        decodedContent = content;
      } else {
        // Try to decode as base64
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
          debugPrint('[Subscription] Base64 decoded successfully');
          debugPrint(
              '[Subscription] Decoded preview: ${decodedContent.substring(0, decodedContent.length > 200 ? 200 : decodedContent.length)}');
        } catch (e) {
          // Not base64, use as-is
          debugPrint(
              '[Subscription] Base64 decode failed, using raw content: $e');
          decodedContent = content;
        }
      }

      // Normalize line endings and parse configs
      decodedContent =
          decodedContent.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

      debugPrint(
          '[Subscription] Calling _addMultipleConfigs with ${decodedContent.split('\n').length} potential lines');

      // Parse and add configs
      _addMultipleConfigs(decodedContent);
    } catch (e, stack) {
      debugPrint('[Subscription] Error: $e');
      debugPrint('[Subscription] Stack: $stack');
      state = state.copyWith(error: 'Failed to fetch subscription: $e');
    }
  }

  /// Add multiple configs from multi-line input
  void _addMultipleConfigs(String content) {
    // First, try splitting by newlines
    var lines = content.split('\n').where((l) => l.trim().isNotEmpty).toList();

    // If only one line but contains multiple protocols, split by protocol prefixes
    if (lines.length == 1 && _containsMultipleProtocols(content)) {
      lines = _splitByProtocols(content);
      debugPrint(
          '[AddConfigs] Split by protocols, found ${lines.length} configs');
    }

    final configRepo = ref.read(connectionConfigRepoProvider);
    int addedCount = 0;

    debugPrint('[AddConfigs] Found ${lines.length} lines to process');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      // Skip comment lines
      if (line.startsWith('#') || line.startsWith('//')) {
        debugPrint('[AddConfigs] Skipping comment line $i');
        continue;
      }

      // Only process valid protocol prefixes
      if (!_isValidConfigLine(line)) {
        debugPrint(
            '[AddConfigs] Skipping non-config line $i: ${line.substring(0, line.length > 30 ? 30 : line.length)}...');
        continue;
      }

      try {
        debugPrint(
            '[AddConfigs] Processing line $i: ${line.substring(0, line.length > 50 ? 50 : line.length)}...');
        final config = _buildConfig(line);
        configRepo.addConfig(config);
        addedCount++;
        debugPrint('[AddConfigs] Successfully added: ${config.configName}');
      } catch (e) {
        // Skip invalid lines
        debugPrint('[AddConfigs] Failed to parse line $i: $e');
        continue;
      }
    }

    debugPrint('[AddConfigs] Total configs added: $addedCount');

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
