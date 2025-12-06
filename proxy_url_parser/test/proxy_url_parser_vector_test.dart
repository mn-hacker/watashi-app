import 'dart:io';
import 'package:proxy_url_parser/src/util/proxy_url_parser_logger.dart';
import 'package:proxy_url_parser/src/xray/trojan_protocol_config.dart';
import 'package:proxy_url_parser/src/xray/vless_protocol_config.dart';
import 'package:proxy_url_parser/src/xray/vmess_protocol_config.dart';
import 'package:test/test.dart';
import 'package:proxy_url_parser/proxy_url_parser.dart';
import 'package:proxy_url_parser/src/xray/shadowsocks_protocol_config.dart';

void main() {
  setUp(() {
    ProxyUrlParserLogger.enableDebugMode(); // Enable debug logging for all tests
  });

  group('ProxyUrlParser Vector Tests', () {
    // Read the vector bucket file
    final file = File('test/vector_bucket');
    if (!file.existsSync()) {
      fail('Vector bucket file not found at test/vector_bucket');
    }

    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final url = lines[i].trim();
      if (url.isEmpty || url.startsWith('#')) {
        continue; // Skip empty lines and comments
      }

      late dynamic config;

      print("\n\n==>\nTesting URL config at Line #${i + 1}:\n$url");

      test('Parsing Url at Line #${i + 1}', () {
        config = ProxyUrlParser.parse(url);
        if (config is VlessProtocolConfig) {
          assertVlessBasicFields(config);
          assertVlessNetworkFields(config);
          assertVlessSecurityFields(config);
        } else if (config is VmessProtocolConfig) {
          assertVmessBasicFields(config);
          assertVmessNetworkFields(config);
          assertVmessTlsFields(config);
        } else if (config is ShadowsocksProtocolConfig) {
          assertShadowsocksBasicFields(config);
        } else if (config is TrojanProtocolConfig) {
          assertTrojanBasicFields(config);
          assertTrojanNetworkFields(config);
          assertTrojanSecurityFields(config);
        } else {
          fail('Unknown protocol type');
        }
        print("<===");
      });
    }
  });
}

// Helper functions for protocol-specific assertions
void assertVlessBasicFields(VlessProtocolConfig config) {
  expect(config.address, isNotEmpty, reason: 'Address should not be empty');
  expect(config.port, isPositive, reason: 'Port should be positive');
  expect(config.remark, isNotEmpty, reason: 'Remark should not be empty');
  expect(config.id, isNotEmpty, reason: 'VLESS ID should not be empty');
  expect(config.network, isNotEmpty, reason: 'Network should not be empty');
  expect(config.security, isNotEmpty, reason: 'Security should not be empty');
  expect(
    config.encryption,
    isNotEmpty,
    reason: 'Encryption should not be empty',
  );
}

void assertVlessNetworkFields(VlessProtocolConfig config) {
  switch (config.network) {
    case 'ws':
    case 'httpupgrade':
    case 'xhttp':
      expect(
        config.path,
        isNotNull,
        reason: 'Path should not be empty for ${config.network}',
      );
      expect(
        config.host,
        isNotNull,
        reason: 'Host should be defined for ${config.network}',
      );
      break;
    case 'grpc':
      expect(
        config.serviceName,
        isNotNull,
        reason: 'Service name should not be empty for gRPC',
      );
      expect(
        config.mode,
        isNotNull,
        reason: 'Mode should not be empty for gRPC',
      );
      expect(
        config.authority,
        isNotNull,
        reason: 'Authority should be defined for gRPC',
      );
      break;
    case 'tcp':
      // TCP connections don't require header type in VLESS protocol
      break;
  }
}

void assertVlessSecurityFields(VlessProtocolConfig config) {
  switch (config.security) {
    case 'tls':
      expect(config.sni, isNotNull, reason: 'SNI should not be empty for TLS');
      expect(
        config.fingerprint,
        isNotNull,
        reason: 'Fingerprint should not be empty for TLS',
      );
      expect(
        config.alpn,
        isNotEmpty,
        reason: 'ALPN should not be empty for TLS',
      );
      expect(config.flow, isNotNull, reason: 'Flow should be defined for TLS');
      break;
    case 'reality':
      expect(
        config.sni,
        isNotNull,
        reason: 'SNI should not be empty for reality',
      );
      expect(
        config.fingerprint,
        isNotNull,
        reason: 'Fingerprint should not be empty for reality',
      );
      expect(
        config.publicKey,
        isNotEmpty,
        reason: 'Public key should not be empty for reality',
      );
      expect(
        config.shortId,
        isNotNull,
        reason: 'Short ID should not be empty for reality',
      );
      expect(
        config.spiderX,
        isNotNull,
        reason: 'SpiderX should not be empty for reality',
      );
      expect(
        config.flow,
        isNotNull,
        reason: 'Flow should be defined for reality',
      );
      break;
    case 'none':
      expect(
        config.flow,
        isNotNull,
        reason: 'Flow should be null for none security',
      );
      break;
  }
}

void assertVmessBasicFields(VmessProtocolConfig config) {
  expect(config.address, isNotEmpty, reason: 'Address should not be empty');
  expect(config.port, isPositive, reason: 'Port should be positive');
  expect(config.remark, isNotEmpty, reason: 'Remark should not be empty');
  expect(config.id, isNotEmpty, reason: 'VMess ID should not be empty');
  expect(config.network, isNotEmpty, reason: 'Network should not be empty');
  expect(config.tls, isNotNull, reason: 'TLS should not be empty');
  expect(config.security, isNotEmpty, reason: 'Security should not be empty');
}

void assertVmessNetworkFields(VmessProtocolConfig config) {
  switch (config.network) {
    case 'ws':
    case 'httpupgrade':
    case 'xhttp':
      expect(
        config.path,
        isNotNull,
        reason: 'Path should not be empty for ${config.network}',
      );
      expect(
        config.host,
        isNotNull,
        reason: 'Host should be defined for ${config.network}',
      );
      break;
    case 'grpc':
      expect(
        config.path,
        isNotNull,
        reason: 'Service name should not be empty for gRPC',
      );
      expect(
        config.authority,
        isNotNull,
        reason: 'Authority should be defined for gRPC',
      );
      break;
    case 'tcp':
      expect(
        config.headerType,
        isNotNull,
        reason: 'Header type should be defined for TCP',
      );
      break;
  }
}

void assertVmessTlsFields(VmessProtocolConfig config) {
  if (config.tls == 'tls') {
    expect(config.sni, isNotNull, reason: 'SNI should not be empty for TLS');
    expect(
      config.fingerprint,
      isNotNull,
      reason: 'Fingerprint should not be empty for TLS',
    );
    expect(config.alpn, isNotNull, reason: 'ALPN should not be empty for TLS');
  }
}

void assertShadowsocksBasicFields(ShadowsocksProtocolConfig config) {
  expect(config.address, isNotEmpty, reason: 'Address should not be empty');
  expect(config.port, isPositive, reason: 'Port should be positive');
  expect(config.remark, isNotEmpty, reason: 'Remark should not be empty');
  expect(
    config.encryption,
    isNotEmpty,
    reason: 'Encryption should not be empty',
  );
  expect(config.password, isNotEmpty, reason: 'Password should not be empty');
  expect(config.network, isNotEmpty, reason: 'Network should not be empty');
}

void assertTrojanBasicFields(TrojanProtocolConfig config) {
  expect(config.address, isNotEmpty, reason: 'Address should not be empty');
  expect(config.port, isPositive, reason: 'Port should be positive');
  expect(config.remark, isNotEmpty, reason: 'Remark should not be empty');
  expect(config.password, isNotEmpty, reason: 'Password should not be empty');
  expect(config.network, isNotEmpty, reason: 'Network should not be empty');
  expect(config.security, isNotEmpty, reason: 'Security should not be empty');
}

void assertTrojanNetworkFields(TrojanProtocolConfig config) {
  switch (config.network) {
    case 'ws':
    case 'httpupgrade':
    case 'xhttp':
      expect(
        config.path,
        isNotNull,
        reason: 'Path should not be empty for ${config.network}',
      );
      expect(
        config.host,
        isNotNull,
        reason: 'Host should be defined for ${config.network}',
      );
      break;
    case 'grpc':
      expect(
        config.serviceName,
        isNotNull,
        reason: 'Service name should not be empty for gRPC',
      );
      expect(
        config.mode,
        isNotNull,
        reason: 'Mode should not be empty for gRPC',
      );
      expect(
        config.authority,
        isNotNull,
        reason: 'Authority should be defined for gRPC',
      );
      break;
  }
}

void assertTrojanSecurityFields(TrojanProtocolConfig config) {
  switch (config.security) {
    case 'tls':
      expect(config.sni, isNotNull, reason: 'SNI should not be empty for TLS');
      expect(
        config.fingerprint,
        isNotNull,
        reason: 'Fingerprint should not be empty for TLS',
      );
      expect(
        config.alpn,
        isNotEmpty,
        reason: 'ALPN should not be empty for TLS',
      );
      break;
    case 'reality':
      expect(
        config.sni,
        isNotEmpty,
        reason: 'SNI should not be empty for reality',
      );
      expect(
        config.fingerprint,
        isNotEmpty,
        reason: 'Fingerprint should not be empty for reality',
      );
      expect(
        config.publicKey,
        isNotEmpty,
        reason: 'Public key should not be empty for reality',
      );
      expect(
        config.shortId,
        isNotEmpty,
        reason: 'Short ID should not be empty for reality',
      );
      expect(
        config.spiderX,
        isNotEmpty,
        reason: 'SpiderX should not be empty for reality',
      );
      break;
  }
}
