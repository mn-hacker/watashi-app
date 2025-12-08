import 'dart:convert';

import 'package:proxy_core/constants/core_names.dart';
import 'package:proxy_url_parser/proxy_url_parser.dart';

class ConnectionConfigModel {
  ConnectionConfigModel._({
    required this.id,
    required this.configLink,
    required this.rawJsonConfig,
    this.ping,
  }) : assert(
          rawJsonConfig != null || configLink != null,
          'At least one of rawJsonConfig or configLink must be provided',
        ) {
    if (configLink != null) {
      _parsedConfig = ProxyUrlParser.parse(configLink!);
    }
  }

  /// Unique identifier for this config
  final String id;

  /// For raw user-entered json
  final Map<String, dynamic>? rawJsonConfig;

  /// For user-entered config link
  final String? configLink;

  /// Ping latency in milliseconds (null if not tested)
  int? ping;

  /// For parsed config from [configLink]
  late final ProtocolConfigBase? _parsedConfig;

  /// Get the parsed config if available
  ProtocolConfigBase? get parsedConfig => _parsedConfig;

  String get configName {
    if (_parsedConfig != null) return _parsedConfig.remark;
    try {
      return rawJsonConfig!['remark'] ??
          rawJsonConfig!['outbounds']?[0]?['remark'] ??
          'Config';
    } catch (e) {
      return 'Config';
    }
  }

  /// Get protocol type (VLESS, VMess, Trojan, Shadowsocks, etc.)
  String get protocolType {
    if (_parsedConfig != null) {
      return _parsedConfig.runtimeType.toString().replaceAll('Config', '');
    }
    try {
      final protocol = rawJsonConfig!['outbounds']?[0]?['protocol'];
      if (protocol != null) {
        return protocol.toString().toUpperCase();
      }
    } catch (e) {
      // Ignore
    }
    return 'Unknown';
  }

  /// Get server address
  String? get serverAddress {
    // Try to extract from config link
    if (configLink != null) {
      try {
        final uri =
            Uri.parse(configLink!.replaceFirst(RegExp(r'^\w+://'), 'https://'));
        return uri.host.isNotEmpty ? uri.host : null;
      } catch (e) {
        // Ignore parsing errors
      }
    }
    // Try to extract from raw JSON config
    try {
      return rawJsonConfig!['outbounds']?[0]?['settings']?['vnext']?[0]
              ?['address'] ??
          rawJsonConfig!['outbounds']?[0]?['settings']?['servers']?[0]
              ?['address'];
    } catch (e) {
      return null;
    }
  }

  /// Get server port
  int? get serverPort {
    // Try to extract from config link
    if (configLink != null) {
      try {
        final uri =
            Uri.parse(configLink!.replaceFirst(RegExp(r'^\w+://'), 'https://'));
        return uri.port != 0 ? uri.port : 443;
      } catch (e) {
        // Ignore parsing errors
      }
    }
    // Try to extract from raw JSON config
    try {
      return rawJsonConfig!['outbounds']?[0]?['settings']?['vnext']?[0]
              ?['port'] ??
          rawJsonConfig!['outbounds']?[0]?['settings']?['servers']?[0]?['port'];
    } catch (e) {
      return null;
    }
  }

  /// Returns full config for the given core to start the core.
  String getFullJsonConfig(CoreNames core) {
    final Map<String, dynamic> config;
    if (_parsedConfig != null) {
      switch (core) {
        case CoreNames.xray:
        case CoreNames.clashMeta:
        case CoreNames.singbox:
        case CoreNames.v2ray:
          config = ProxyUrlParser.injectToConfig(
              _baseConfig, _parsedConfig.toXrayJson(allowInsecure: true))
            ..['outbounds'][0]['tag'] = 'proxy';
        case CoreNames.outline:
          config = _parsedConfig.toOutlineJson();
      }
    } else {
      config = rawJsonConfig!;
    }

    return jsonEncode(config);
  }

  factory ConnectionConfigModel.fromJson(Map<String, dynamic> json) {
    return ConnectionConfigModel._(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      configLink: null,
      rawJsonConfig: json,
    );
  }

  factory ConnectionConfigModel.fromLink({
    required String configLink,
    String? id,
  }) =>
      ConnectionConfigModel._(
        id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        configLink: configLink,
        rawJsonConfig: null,
      );

  /// Create from storage JSON (for loading saved configs)
  factory ConnectionConfigModel.fromStorageJson(Map<String, dynamic> json) {
    final configLink = json['configLink'] as String?;
    final rawJsonConfig = json['rawJsonConfig'] as Map<String, dynamic>?;

    return ConnectionConfigModel._(
      id: json['id'] as String,
      configLink: configLink,
      rawJsonConfig: rawJsonConfig,
      ping: json['ping'] as int?,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toStorageJson() {
    return {
      'id': id,
      'configLink': configLink,
      'rawJsonConfig': rawJsonConfig,
      'ping': ping,
    };
  }

  /// Returns link if [configLink] is not null and raw config otherwise
  String get asStringValue => configLink ?? _parsedConfig.toString();

  /// Create a copy with updated fields
  ConnectionConfigModel copyWith({
    String? id,
    String? configLink,
    Map<String, dynamic>? rawJsonConfig,
    int? ping,
  }) {
    return ConnectionConfigModel._(
      id: id ?? this.id,
      configLink: configLink ?? this.configLink,
      rawJsonConfig: rawJsonConfig ?? this.rawJsonConfig,
      ping: ping ?? this.ping,
    );
  }

  static const _baseConfig = {
    "log": {"level": "debug"},
    "inbounds": [
      {
        "listen": "127.0.0.1",
        "port": 2080,
        "protocol": "socks",
        "settings": {"auth": "noauth", "udp": true},
        "sniffing": {
          "destOverride": ["http", "tls", "quic", "fakedns"],
          "enabled": false,
          "routeOnly": true
        },
        "tag": "socks"
      }
    ],
    "dns": {
      "servers": ["1.1.1.1", "8.8.8.8"]
    },
    "routing": {
      "rules": [
        {
          "type": "field",
          "inboundTag": ["socks"],
          "outboundTag": "proxy"
        }
      ]
    },
  };
}
