import 'package:flutter/services.dart';
import 'package:proxy_core/constants/core_names.dart';
import 'package:proxy_core/models/proxy_core_config.dart';
import 'package:proxy_core/models/proxy_core_exception.dart';

/// Method channel for SingBox core communication with Kotlin
class SingBoxChannel {
  static const MethodChannel _channel = MethodChannel('proxy_core/singbox');

  /// Start SingBox with the given configuration
  ///
  /// [config] The proxy configuration
  /// [tunFd] The TUN file descriptor from VPN service
  static Future<bool> start(ProxyCoreConfig config, int tunFd) async {
    if (config.core != CoreNames.singbox) {
      throw ProxyCoreException.message(
          'SingBoxChannel only supports singbox core');
    }

    try {
      // Convert config to SingBox JSON format
      final singBoxConfig = _convertToSingBoxConfig(config.config);

      final result = await _channel.invokeMethod<bool>('start', {
        'config': singBoxConfig,
        'tunFd': tunFd,
      });

      return result ?? false;
    } on PlatformException catch (e) {
      throw ProxyCoreException.message('Failed to start SingBox: ${e.message}');
    }
  }

  /// Stop SingBox
  static Future<void> stop() async {
    try {
      await _channel.invokeMethod('stop');
    } on PlatformException catch (e) {
      throw ProxyCoreException.message('Failed to stop SingBox: ${e.message}');
    }
  }

  /// Check if SingBox is running
  static Future<bool> isRunning() async {
    try {
      final result = await _channel.invokeMethod<bool>('isRunning');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Convert Xray/internal config format to SingBox JSON format
  ///
  /// This is a basic conversion that creates a minimal SingBox config.
  /// For more complex setups, the config should already be in SingBox format.
  static String _convertToSingBoxConfig(String config) {
    // If config is already JSON (SingBox format), return as-is
    if (config.trim().startsWith('{')) {
      return config;
    }

    // For proxy URLs, create a basic SingBox outbound config
    // This is a simplified conversion - real implementation would parse the URL
    // and create proper SingBox outbound configuration

    // Basic SingBox config template
    return '''
{
  "log": {
    "level": "info"
  },
  "dns": {
    "servers": [
      {
        "tag": "cloudflare",
        "address": "https://1.1.1.1/dns-query",
        "detour": "proxy"
      },
      {
        "tag": "local",
        "address": "223.5.5.5",
        "detour": "direct"
      }
    ],
    "rules": [
      {
        "outbound": "any",
        "server": "local"
      }
    ]
  },
  "inbounds": [
    {
      "type": "tun",
      "tag": "tun-in",
      "interface_name": "tun0",
      "inet4_address": "172.19.0.1/30",
      "inet6_address": "fdfe:dcba:9876::1/126",
      "auto_route": true,
      "strict_route": true,
      "stack": "system"
    }
  ],
  "outbounds": [
    {
      "type": "direct",
      "tag": "direct"
    },
    {
      "type": "block",
      "tag": "block"
    }
  ],
  "route": {
    "auto_detect_interface": true,
    "final": "direct"
  }
}
''';
  }
}
