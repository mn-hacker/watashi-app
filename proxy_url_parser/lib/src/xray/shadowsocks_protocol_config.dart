import 'package:proxy_url_parser/src/protocol_config_base.dart';

class ShadowsocksProtocolConfig extends ProtocolConfigBase {
  final String address;
  final int port;
  final String encryption;
  final String password;
  final String network;

  ShadowsocksProtocolConfig({
    required super.remark,
    required this.address,
    required this.port,
    required this.encryption,
    required this.password,
    required this.network,
    required super.origLink,
  });

  factory ShadowsocksProtocolConfig.fromUrlComponents(
    Map<String, dynamic> components,
    String origLink,
  ) {
    return ShadowsocksProtocolConfig(
      remark: components['remark'] as String? ?? '',
      address: components['add'] as String,
      port: int.parse(components['port'].toString()),
      encryption: components['encryption'] as String,
      password: components['password'] as String,
      network: components['type'] as String? ?? 'tcp',
      origLink: origLink,
    );
  }

  @override
  Map<String, dynamic> toXrayJson({bool allowInsecure = false}) {
    return {
      'protocol': 'shadowsocks',
      'settings': {
        'servers': [
          {
            'address': address,
            'port': port,
            'method': encryption,
            'password': password,
          },
        ],
      },
      'streamSettings': {'network': network},
      ...{'remark': remark},
    };
  }
}
