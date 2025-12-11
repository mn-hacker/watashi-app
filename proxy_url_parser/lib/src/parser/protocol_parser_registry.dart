import 'package:proxy_url_parser/src/parser/protocol_base_parser.dart';
import 'package:proxy_url_parser/src/parser/shadowsocks_protocol_parser.dart';
import 'package:proxy_url_parser/src/parser/trojan_protocol_parser.dart';
import 'package:proxy_url_parser/src/parser/vless_protocol_parser.dart';
import 'package:proxy_url_parser/src/parser/vmess_protocol_parser.dart';
import 'package:proxy_url_parser/src/parser/socks_protocol_parser.dart';
import 'package:proxy_url_parser/src/parser/http_protocol_parser.dart';
import 'package:proxy_url_parser/src/parser/wireguard_protocol_parser.dart';
import 'package:proxy_url_parser/src/parser/hysteria2_protocol_parser.dart';
import 'package:proxy_url_parser/src/parser/tuic_protocol_parser.dart';
import 'package:proxy_url_parser/src/parser/naive_protocol_parser.dart';
import 'package:proxy_url_parser/src/parser/shadowtls_protocol_parser.dart';
import 'package:proxy_url_parser/src/protocol_config_base.dart';
import 'package:proxy_url_parser/src/proxy_protocols.dart';
import 'package:proxy_url_parser/src/util/proxy_url_parser_exception.dart';

/// A registry for mapping proxy types to their respective parsers.
class ProtocolParserRegistry {
  static final Map<ProxyProtocols, ProtocolBaseParser> _parsers = {
    ProxyProtocols.vmess: VmessProtocolParser(),
    ProxyProtocols.vless: VlessProtocolParser(),
    ProxyProtocols.shadowsocks: ShadowsocksProtocolParser(),
    ProxyProtocols.trojan: TrojanProtocolParser(),
    ProxyProtocols.wireguard: WireguardProtocolParser(),
    ProxyProtocols.socks: SocksProtocolParser(),
    ProxyProtocols.http: HttpProtocolParser(),
    ProxyProtocols.hysteria2: Hysteria2ProtocolParser(),
    ProxyProtocols.tuic: TuicProtocolParser(),
    ProxyProtocols.naive: NaiveProtocolParser(),
    ProxyProtocols.shadowtls: ShadowTlsProtocolParser(),
  };

  /// Registers a new parser for a given proxy type.
  static void registerParser(ProxyProtocols type, ProtocolBaseParser parser) {
    _parsers[type] = parser;
  }

  /// Retrieves the parser for a given proxy type and parses the URL.
  ///
  /// Throws a [InvalidUrlFormatException] if no parser is registered for the type.
  static ProtocolConfigBase parse(ProxyProtocols type, String url) {
    final parser = _parsers[type];
    if (parser == null) {
      throw InvalidUrlFormatException(
        'No parser registered for proxy type: $type',
        url,
        StackTrace.current,
      );
    }
    return parser.parse(url);
  }
}
