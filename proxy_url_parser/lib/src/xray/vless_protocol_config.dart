import 'package:proxy_url_parser/src/protocol_config_base.dart';

class VlessProtocolConfig extends ProtocolConfigBase {
  String id;
  String address;
  int port;
  String? encryption;
  String? flow;
  String? network;
  String? security;
  String? sni;
  String? fingerprint;
  List<String>? alpn;
  bool allowInsecure;
  String? path;
  String? host;
  String? serviceName;
  String? mode;
  String? headerType;
  String? publicKey;
  String? shortId;
  String? spiderX;
  String? authority;

  VlessProtocolConfig({
    required this.id,
    required this.address,
    required this.port,
    this.encryption = "none",
    this.flow,
    this.network = "tcp",
    this.security = "none",
    this.sni,
    this.fingerprint,
    this.alpn,
    this.allowInsecure = false,
    this.path,
    this.host,
    this.serviceName,
    this.mode,
    this.headerType,
    this.publicKey,
    this.shortId,
    this.spiderX,
    this.authority,
    required super.remark,
    required super.origLink,
  });

  // Factory constructor to create VlessConfig from URL components
  factory VlessProtocolConfig.fromUrlComponents(
    Map<String, dynamic> components,
    String originalUrl,
  ) {
    return VlessProtocolConfig(
      id: components['id'] as String,
      address: components['add'] as String,
      port: int.parse(components['port'] as String),
      encryption: components['encryption'] as String? ?? 'none',
      flow: components['flow'] as String? ?? '',
      network: components['type'] as String? ?? 'tcp',
      // VLESS typically uses 'type' for network
      security: components['security'] as String? ?? 'none',
      sni: components['sni'] as String? ?? '',
      fingerprint: components['fp'] as String?,
      alpn: components['alpn']?.toString().split(',') ?? [],
      allowInsecure: (components['allowInsecure'] as String? ?? '0') == '1',
      path: components['path'] as String?,
      host: components['host'] as String?,
      serviceName: components['serviceName'] as String?,
      mode: components['mode'] as String?,
      headerType: components['headerType'] as String?,
      publicKey: components['pbk'] as String?,
      shortId: components['sid'] as String? ?? '',
      spiderX: components['spx'] as String ? ?? '',
      authority: components['authority'] as String? ?? '',
      remark: components['remark'] as String,
      origLink: originalUrl,
    );
  }

  @override
  Map<String, dynamic> toXrayJson({bool allowInsecure = false}) {
    final json = {
      "protocol": "vless",
      "settings": {
        "vnext": [
          {
            "address": address,
            "port": port,
            "users": [
              {"id": id, "encryption": encryption, "flow": flow},
            ],
          },
        ],
      },
      "streamSettings": <String, dynamic>{"network": network},
      ...{'remark': remark},
    };

    final streamSettings = json["streamSettings"] as Map<String, dynamic>;

    if (network == "tcp") {
      if (headerType != null) {
        streamSettings["tcpSettings"] = {
          "header": {"type": headerType},
        };
      }
    } else if (network == "ws") {
      streamSettings["wsSettings"] = {
        if (path != null) "path": path,
        if (host != null) "headers": {"Host": host},
      };
    } else if (network == "httpupgrade") {
      streamSettings["httpupgradeSettings"] = {
        if (path != null) "path": path,
        if (host != null) "headers": {"Host": host},
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
        "spiderX": spiderX,
        if (fingerprint != null) "fingerprint": fingerprint,
      };
    }

    return json;
  }
}
