import 'package:proxy_url_parser/src/protocol_config_base.dart';

/// Configuration for Wireguard VPN
class WireguardProtocolConfig extends ProtocolConfigBase {
  final String address;
  final int port;
  final String secretKey;
  final String publicKey;
  final String? localAddress;
  final String? reserved;
  final int? mtu;
  final String? preSharedKey;

  WireguardProtocolConfig({
    required super.remark,
    required this.address,
    required this.port,
    required this.secretKey,
    required this.publicKey,
    this.localAddress,
    this.reserved,
    this.mtu,
    this.preSharedKey,
    required super.origLink,
  });

  factory WireguardProtocolConfig.fromUrlComponents(
    Map<String, dynamic> components,
    String origLink,
  ) {
    return WireguardProtocolConfig(
      remark: components['remark'] as String? ?? 'Wireguard',
      address: components['add'] as String,
      port: int.parse(components['port'] as String),
      secretKey: components['secretKey'] as String? ?? '',
      publicKey: components['publicKey'] as String? ?? '',
      localAddress: components['localAddress'] as String?,
      reserved: components['reserved'] as String?,
      mtu:
          components['mtu'] != null
              ? int.tryParse(components['mtu'].toString())
              : null,
      preSharedKey: components['preSharedKey'] as String?,
      origLink: origLink,
    );
  }

  @override
  Map<String, dynamic> toXrayJson({bool allowInsecure = false}) {
    final reservedList =
        reserved?.split(',').map((e) => int.tryParse(e.trim()) ?? 0).toList();

    return {
      'protocol': 'wireguard',
      'settings': {
        'secretKey': secretKey,
        'address': localAddress?.split(',') ?? ['172.16.0.2/32'],
        if (mtu != null) 'mtu': mtu,
        if (reservedList != null) 'reserved': reservedList,
        'peers': [
          {
            'publicKey': publicKey,
            'endpoint': '$address:$port',
            if (preSharedKey != null && preSharedKey!.isNotEmpty)
              'preSharedKey': preSharedKey,
          },
        ],
      },
      'remark': remark,
    };
  }
}
