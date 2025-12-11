import 'package:proxy_url_parser/src/protocol_config_base.dart';

/// Configuration for NaiveProxy protocol (sing-box only)
/// NaiveProxy uses Chrome's network stack to resist fingerprinting
class NaiveProtocolConfig extends ProtocolConfigBase {
  final String address;
  final int port;
  final String username;
  final String password;
  final String protocol; // https or quic

  NaiveProtocolConfig({
    required super.remark,
    required this.address,
    required this.port,
    required this.username,
    required this.password,
    this.protocol = 'https',
    required super.origLink,
  });

  factory NaiveProtocolConfig.fromUrlComponents(
    Map<String, dynamic> components,
    String origLink,
  ) {
    return NaiveProtocolConfig(
      remark: components['remark'] as String? ?? 'NaiveProxy',
      address: components['add'] as String,
      port: int.parse(components['port'] as String),
      username: components['username'] as String? ?? '',
      password: components['password'] as String? ?? '',
      protocol: components['protocol'] as String? ?? 'https',
      origLink: origLink,
    );
  }

  @override
  Map<String, dynamic> toXrayJson({bool allowInsecure = false}) {
    // NaiveProxy is sing-box only
    return {
      'type': 'naive',
      'tag': 'proxy',
      'server': address,
      'server_port': port,
      'username': username,
      'password': password,
      'network': protocol, // https or quic
      'remark': remark,
    };
  }
}
