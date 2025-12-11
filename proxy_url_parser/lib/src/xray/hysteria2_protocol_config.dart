import 'package:proxy_url_parser/src/protocol_config_base.dart';

/// Configuration for Hysteria2 protocol
class Hysteria2ProtocolConfig extends ProtocolConfigBase {
  final String address;
  final int port;
  final String password;
  final String? sni;
  final String? alpn;
  final bool insecure;
  final String? obfsPassword;
  final String? portHopping;
  final String? portHoppingInterval;
  final String? pinSHA256;

  Hysteria2ProtocolConfig({
    required super.remark,
    required this.address,
    required this.port,
    required this.password,
    this.sni,
    this.alpn,
    this.insecure = false,
    this.obfsPassword,
    this.portHopping,
    this.portHoppingInterval,
    this.pinSHA256,
    required super.origLink,
  });

  factory Hysteria2ProtocolConfig.fromUrlComponents(
    Map<String, dynamic> components,
    String origLink,
  ) {
    return Hysteria2ProtocolConfig(
      remark: components['remark'] as String? ?? 'Hysteria2',
      address: components['add'] as String,
      port: int.parse(components['port'] as String),
      password: components['password'] as String? ?? '',
      sni: components['sni'] as String?,
      alpn: components['alpn'] as String?,
      insecure: components['insecure'] == '1' || components['insecure'] == true,
      obfsPassword: components['obfs-password'] as String?,
      portHopping: components['mport'] as String?,
      portHoppingInterval: components['mportHopInt'] as String?,
      pinSHA256: components['pinSHA256'] as String?,
      origLink: origLink,
    );
  }

  @override
  Map<String, dynamic> toXrayJson({bool allowInsecure = false}) {
    // Hysteria2 is not natively supported by xray-core
    // It needs to be run as a separate plugin
    // This JSON is for sing-box compatibility
    return {
      'type': 'hysteria2',
      'tag': 'proxy',
      'server': address,
      'server_port': port,
      'password': password,
      if (obfsPassword != null)
        'obfs': {'type': 'salamander', 'password': obfsPassword},
      'tls': {
        'enabled': true,
        if (sni != null) 'server_name': sni,
        'insecure': insecure || allowInsecure,
        if (alpn != null && alpn!.isNotEmpty) 'alpn': alpn!.split(','),
      },
      'remark': remark,
    };
  }
}
