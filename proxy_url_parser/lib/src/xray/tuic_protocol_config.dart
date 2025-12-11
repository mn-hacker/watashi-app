import 'package:proxy_url_parser/src/protocol_config_base.dart';

/// Configuration for TUIC protocol (sing-box only)
/// TUIC is a UDP-based protocol designed for fast connections
class TuicProtocolConfig extends ProtocolConfigBase {
  final String address;
  final int port;
  final String uuid;
  final String? password;
  final String? sni;
  final String? alpn;
  final bool insecure;
  final String? congestionControl;
  final int? udpRelayMode;

  TuicProtocolConfig({
    required super.remark,
    required this.address,
    required this.port,
    required this.uuid,
    this.password,
    this.sni,
    this.alpn,
    this.insecure = false,
    this.congestionControl,
    this.udpRelayMode,
    required super.origLink,
  });

  factory TuicProtocolConfig.fromUrlComponents(
    Map<String, dynamic> components,
    String origLink,
  ) {
    return TuicProtocolConfig(
      remark: components['remark'] as String? ?? 'TUIC',
      address: components['add'] as String,
      port: int.parse(components['port'] as String),
      uuid: components['uuid'] as String? ?? '',
      password: components['password'] as String?,
      sni: components['sni'] as String?,
      alpn: components['alpn'] as String?,
      insecure:
          components['insecure'] == '1' || components['allowInsecure'] == '1',
      congestionControl: components['congestion_control'] as String?,
      udpRelayMode:
          components['udp_relay_mode'] != null
              ? int.tryParse(components['udp_relay_mode'].toString())
              : null,
      origLink: origLink,
    );
  }

  @override
  Map<String, dynamic> toXrayJson({bool allowInsecure = false}) {
    // TUIC is sing-box only, this generates sing-box format
    return {
      'type': 'tuic',
      'tag': 'proxy',
      'server': address,
      'server_port': port,
      'uuid': uuid,
      if (password != null) 'password': password,
      if (congestionControl != null) 'congestion_control': congestionControl,
      if (udpRelayMode != null)
        'udp_relay_mode': udpRelayMode == 1 ? 'native' : 'quic',
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
