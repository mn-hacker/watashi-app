import 'package:proxy_url_parser/src/protocol_config_base.dart';

/// Configuration for ShadowTLS protocol (sing-box only)
/// ShadowTLS disguises proxy traffic as normal TLS traffic
class ShadowTlsProtocolConfig extends ProtocolConfigBase {
  final String address;
  final int port;
  final String password;
  final String sni;
  final int version; // ShadowTLS version (1, 2, or 3)

  ShadowTlsProtocolConfig({
    required super.remark,
    required this.address,
    required this.port,
    required this.password,
    required this.sni,
    this.version = 3,
    required super.origLink,
  });

  factory ShadowTlsProtocolConfig.fromUrlComponents(
    Map<String, dynamic> components,
    String origLink,
  ) {
    return ShadowTlsProtocolConfig(
      remark: components['remark'] as String? ?? 'ShadowTLS',
      address: components['add'] as String,
      port: int.parse(components['port'] as String),
      password: components['password'] as String? ?? '',
      sni: components['sni'] as String? ?? '',
      version: int.tryParse(components['version']?.toString() ?? '3') ?? 3,
      origLink: origLink,
    );
  }

  @override
  Map<String, dynamic> toXrayJson({bool allowInsecure = false}) {
    // ShadowTLS is sing-box only
    return {
      'type': 'shadowtls',
      'tag': 'proxy',
      'server': address,
      'server_port': port,
      'version': version,
      'password': password,
      'tls': {'enabled': true, 'server_name': sni},
      'remark': remark,
    };
  }
}
