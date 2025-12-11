import 'package:proxy_url_parser/src/protocol_config_base.dart';

/// Configuration for SOCKS5 proxy
class SocksProtocolConfig extends ProtocolConfigBase {
  final String address;
  final int port;
  final String? username;
  final String? password;

  SocksProtocolConfig({
    required super.remark,
    required this.address,
    required this.port,
    this.username,
    this.password,
    required super.origLink,
  });

  factory SocksProtocolConfig.fromUrlComponents(
    Map<String, dynamic> components,
    String origLink,
  ) {
    return SocksProtocolConfig(
      remark: components['remark'] as String? ?? 'SOCKS Proxy',
      address: components['add'] as String,
      port: int.parse(components['port'] as String),
      username: components['username'] as String?,
      password: components['password'] as String?,
      origLink: origLink,
    );
  }

  @override
  Map<String, dynamic> toXrayJson({bool allowInsecure = false}) {
    final serversBean = <String, dynamic>{'address': address, 'port': port};

    if (username != null && username!.isNotEmpty) {
      serversBean['users'] = [
        {'user': username, 'pass': password ?? ''},
      ];
    }

    return {
      'protocol': 'socks',
      'settings': {
        'servers': [serversBean],
      },
      'remark': remark,
    };
  }
}
