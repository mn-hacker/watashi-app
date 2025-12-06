import 'package:proxy_url_parser/src/protocol_config_base.dart';

class TrojanProtocolConfig extends ProtocolConfigBase {
  String password;
  String address;
  int port;
  String? network;
  String? security;
  String? fingerprint;
  List<String>? alpn;
  bool allowInsecure;
  String? publicKey;
  String? shortId;
  String? spiderX;
  String? path;
  String? host;
  String? serviceName;
  String? authority;
  String? mode;

  TrojanProtocolConfig({
    required this.password,
    required this.address,
    required this.port,
    this.network = "tcp",
    this.security = "tls",
    this.fingerprint,
    this.alpn,
    this.allowInsecure = false,
    this.publicKey,
    this.shortId,
    this.spiderX,
    this.path,
    this.host,
    this.serviceName,
    this.authority,
    this.mode,
    required super.remark,
    required super.origLink,
  });

  // Factory constructor to create TrojanConfig from URL components
  factory TrojanProtocolConfig.fromUrlComponents(
    Map<String, dynamic> components,
    String originalUrl,
  ) {
    return TrojanProtocolConfig(
      password: components['password'] as String,
      address: components['add'] as String,
      port: int.parse(components['port'] as String),
      network:
          components['type'] as String? ??
          'tcp', // Trojan typically uses 'type' for network
      security:
          components['security'] as String? ??
          'tls', // Default to 'tls' as per Trojan standard
      fingerprint: components['fp'] as String?,
      alpn: components['alpn']?.toString().split(',') ?? [],
      allowInsecure: (components['allowInsecure'] as String? ?? '0') == '1',
      publicKey:
          components['pbk']
              as String?, // Typically 'pbk' for publicKey in reality
      shortId:
          components['sid']
              as String?, // Typically 'sid' for shortId in reality
      spiderX:
          components['spx']
              as String?, // Typically 'spx' for spiderX in reality
      path: components['path'] as String? ?? '',
      host: components['host'] as String?,
      serviceName: components['serviceName'] as String?,
      authority: components['authority'] as String? ?? '',
      mode: components['mode'] as String?,
      remark: components['remark'] as String,
      origLink: originalUrl,
    ).._sni = components['sni'] as String?;
  }

  @override
  Map<String, dynamic> toXrayJson({bool allowInsecure = false}) {
    final json = {
      "protocol": "trojan",
      "settings": {
        "servers": [
          {"address": address, "port": port, "password": password},
        ],
      },
      "streamSettings": <String, dynamic>{"network": network},
      ...{'remark': remark},
    };

    final streamSettings = json["streamSettings"] as Map<String, dynamic>;

    if (network == "tcp") {
      // No additional settings needed for raw TCP
    } else if (network == "ws") {
      streamSettings["wsSettings"] = {
        if (path != null) "path": path,
        if (host != null) "headers": {"Host": host},
      };
    } else if (network == "httpupgrade") {
      streamSettings["httpupgradeSettings"] = {
        if (path != null) "path": path,
        "host": host,
      };
    } else if (network == "grpc") {
      streamSettings["grpcSettings"] = {
        if (serviceName != null) "serviceName": serviceName,
        if (mode == "multi") "multiMode": true,
        if (authority != null) "authority": authority,
      };
    } else if (network == "xhttp") {
      streamSettings["xhttpSettings"] = {
        if (path != null) "path": path,
        if (mode != null) "mode": mode,
        "host": host,
      };
    }

    if (security == "tls") {
      streamSettings["security"] = "tls";
      streamSettings["tlsSettings"] = {
        if (sni != null) "serverName": sni,
        "allowInsecure": allowInsecure,
        if (alpn != null) "alpn": alpn,
        if (fingerprint != null) "fingerprint": fingerprint,
      };
    } else if (security == "reality") {
      streamSettings["security"] = "reality";
      streamSettings["realitySettings"] = {
        if (sni != null) "serverName": sni,
        if (publicKey != null) "publicKey": publicKey,
        if (shortId != null) "shortId": shortId,
        if (spiderX != null) "spiderX": spiderX,
        if (fingerprint != null) "fingerprint": fingerprint,
      };
    }

    return json;
  }

  String? _sni;
  String? get sni => _sni;
}
