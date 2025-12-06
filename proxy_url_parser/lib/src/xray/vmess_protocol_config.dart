import 'package:proxy_url_parser/src/protocol_config_base.dart';

class VmessProtocolConfig extends ProtocolConfigBase {
  final String address;
  final int port;
  final String id;
  final int aid;
  final String network;
  final String tls;
  final String security;
  final String path;
  final String host;
  final String sni;
  final String alpn;
  final String fingerprint;
  final bool allowInsecure;
  final String serviceName;
  final String mode;
  final String headerType;
  final String seed;
  final String quicSecurity;
  final String quicKey;
  final bool muxEnabled;
  final int muxConcurrency;
  final String authority;

  VmessProtocolConfig({
    required super.remark,
    required this.address,
    required this.port,
    required this.id,
    required this.aid,
    required this.network,
    required this.tls,
    required this.security,
    required this.path,
    required this.host,
    required this.sni,
    required this.alpn,
    required this.fingerprint,
    required this.allowInsecure,
    required this.serviceName,
    required this.mode,
    required this.headerType,
    required this.seed,
    required this.quicSecurity,
    required this.quicKey,
    required this.muxEnabled,
    required this.muxConcurrency,
    required this.authority, // Added to constructor
    required super.origLink,
  });

  factory VmessProtocolConfig.fromUrlComponents(
    Map<String, dynamic> components,
    String origLink,
  ) {
    return VmessProtocolConfig(
      remark: components['remark'] as String? ?? '',
      address: components['add'] as String,
      port: int.parse(components['port'].toString()),
      id: components['id'] as String,
      aid: int.parse(components['aid']?.toString() ?? '0'),
      network: components['net'] as String? ?? 'tcp',
      tls: components['tls'] as String? ?? '',
      security: components['security'] as String? ?? 'none',
      path: components['path'] as String? ?? '/',
      host: components['host'] as String? ?? '',
      sni: components['sni'] as String? ?? '',
      alpn: components['alpn'] as String? ?? '',
      fingerprint: components['fp'] as String? ?? '',
      allowInsecure:
          components['allowInsecure'] == '1' ||
          components['allowInsecure'] == true,
      serviceName: components['serviceName'] as String? ?? '',
      mode: components['mode'] as String? ?? '',
      headerType: components['headerType'] as String? ?? 'none',
      seed: components['seed'] as String? ?? '',
      quicSecurity: components['quicSecurity'] as String? ?? 'none',
      quicKey: components['quicKey'] as String? ?? '',
      muxEnabled: components['mux'] == '1' || components['mux'] == true,
      muxConcurrency: int.parse(
        components['muxConcurrency']?.toString() ?? '8',
      ),
      authority: components['authority'] as String? ?? '',
      // Added authority
      origLink: origLink,
    );
  }

  @override
  Map<String, dynamic> toXrayJson({bool allowInsecure = false}) {
    final config = <String, dynamic>{
      'protocol': 'vmess',
      'settings': {
        'vnext': [
          {
            'address': address,
            'port': port,
            'users': [
              {'id': id, 'alterId': aid, 'security': security},
            ],
          },
        ],
      },
      'streamSettings': {
        'network': network,
        'security': security,
        if (network == 'ws') ...{
          'wsSettings': {
            'path': path,
            'headers': {'Host': host},
          },
        },
        if (network == 'kcp') ...{
          'kcpSettings': {
            'header': {'type': headerType},
            if (seed.isNotEmpty) 'seed': seed,
          },
        },
        if (network == 'quic') ...{
          'quicSettings': {
            'security': quicSecurity,
            'key': quicKey,
            'header': {'type': headerType},
          },
        },
        if (network == 'grpc') ...{
          'grpcSettings': {
            'serviceName': serviceName.isEmpty ? path : '',
            'multiMode': headerType == 'multi',
            'authority': authority,
          },
        },
        if (network == 'httpupgrade') ...{
          'httpupgradeSettings': {'path': path, 'host': host},
        },
        if (network == 'xhttp') ...{
          'xhttpSettings': {'path': path, 'host': host, 'mode': mode},
        },
        if (network == 'tcp') ...{
          'tcpSettings': {
            'header': {'type': headerType},
          },
        },
        if (tls.isNotEmpty && tls != 'none') ...{
          'security': 'tls',
          'tlsSettings': {
            'serverName': sni.isEmpty ? null : sni,
            'allowInsecure': this.allowInsecure || allowInsecure,
            if (alpn.isNotEmpty) 'alpn': [alpn],
            if (fingerprint.isNotEmpty) 'fingerprint': fingerprint,
          },
        },
      },
      if (muxEnabled) ...{
        'mux': {'enabled': true, 'concurrency': muxConcurrency},
      },
      ...{'remark': remark},
    };
    return Map<String, dynamic>.from(config)
      ..removeWhere((key, value) => value == null);
  }
}
