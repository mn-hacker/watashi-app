import 'package:proxy_url_parser/src/util/proxy_url_parser_logger.dart';
import 'package:proxy_url_parser/src/xray/trojan_protocol_config.dart';
import 'package:proxy_url_parser/src/xray/vless_protocol_config.dart';
import 'package:proxy_url_parser/src/xray/vmess_protocol_config.dart';
import 'package:test/test.dart';
import 'package:proxy_url_parser/proxy_url_parser.dart';
import 'package:proxy_url_parser/src/xray/shadowsocks_protocol_config.dart';

void main() {
  setUp(() {
    ProxyUrlParserLogger.enableDebugMode(); // Enable debug logging for all tests
  });

  // New Test Vectors for VLESS
  const testVlessRawUrl =
      'vless://1-vless-raw-uuid@pa1.khastehnabashi.com:10001?type=tcp&security=none#';
  const testVlessRawHttpUrl =
      'vless://2-vless-raw-http-uuid@pa1.khastehnabashi.com:10002?type=tcp&path=%2F&headerType=http&security=none#2-vless-raw-http';
  const testVlessRawTlsUrl =
      'vless://3-vless-raw-tls-uuid@pa1.khastehnabashi.com:10003?type=tcp&security=tls&fp=randomized&alpn=h2%2Chttp%2F1.1&sni=pa1.khastehnabashi.com&flow=xtls-rprx-vision#3-vless-raw-tls';
  const testVlessRawRealityUrl =
      'vless://4-vless-raw-reality-uuid@pa1.khastehnabashi.com:10004?type=tcp&security=reality&pbk=UpT7iRSw39AXIiRXvgewDttQ_SIYawR670ItDmHnm1A&fp=randomized&sni=www.speedtest.net&sid=3efe&spx=%2Flogin&flow=xtls-rprx-vision#4-vless-raw-reality';
  const testVlessWsUrl =
      'vless://5-vless-ws-uuid@pa1.khastehnabashi.com:10005?type=ws&path=%2Fvless-ws-path&host=&security=none#5-vless-ws';
  const testVlessWsTlsUrl =
      'vless://6-vless-ws-tls-uuid@pa1.khastehnabashi.com:10006?type=ws&path=%2Fvless-ws-tls-path&host=&security=tls&fp=randomized&alpn=h2%2Chttp%2F1.1&sni=pa1.khastehnabashi.com#6-vless-ws-tls';
  const testVlessHuUrl =
      'vless://7-vless-hu-uuid@pa1.khastehnabashi.com:10007?type=httpupgrade&path=%2Fvless-hu-path&host=&security=none#7-vless-hu';
  const testVlessHuTlsUrl =
      'vless://8-vless-hu-tls-uuid@pa1.khastehnabashi.com:10008?type=httpupgrade&path=%2Fvless-hu-tls-path&host=&security=tls&fp=randomized&alpn=h2%2Chttp%2F1.1&sni=pa1.khastehnabashi.com#8-vless-hu-tls';
  const testVlessGrpcUrl =
      'vless://9-vless-grpc-uuid@pa1.khastehnabashi.com:10009?type=grpc&serviceName=vless-grpc-servicename&authority=&mode=multi&security=none#9-vless-grpc';
  const testVlessGrpcTlsUrl =
      'vless://10-vless-grpc-tls-uuid@pa1.khastehnabashi.com:10010?type=grpc&serviceName=vless-grpc-tls-servicename&authority=&mode=multi&security=tls&fp=randomized&alpn=h2%2Chttp%2F1.1&sni=pa1.khastehnabashi.com#10-vless-grpc-tls';
  const testVlessGrpcRealityUrl =
      'vless://11-vless-grpc-reality-uuid@pa1.khastehnabashi.com:10011?type=grpc&serviceName=11-vless-grpc-reality-servicename&authority=&mode=multi&security=reality&pbk=j7s5HLse-lSLDWqKtZZe64umYwwYhN3d_u5JESOXj0U&fp=randomized&sni=www.speedtest.net&sid=7f&spx=%2Flogin#11-vless-grpc-reality';
  const testVlessXhttpUrl =
      'vless://12-vless-xhttp-uuid@pa1.khastehnabashi.com:10012?type=xhttp&path=%2Fvless-xhttp-path&host=&mode=auto&security=none#12-vless-xhttp';
  const testVlessXhttpTlsUrl =
      'vless://13-vless-xhttp-tls-uuid@pa1.khastehnabashi.com:10013?type=xhttp&path=%2Fvless-xhttp-tls-path&host=&mode=auto&security=tls&fp=randomized&alpn=h2%2Chttp%2F1.1&sni=pa1.khastehnabashi.com#13-vless-xhttp-tls';
  const testVlessXhttpRealityUrl =
      'vless://14-vless-xhttp-reality-uuid@pa1.khastehnabashi.com:10014?type=xhttp&path=%2Fvless-xhttp-reality-path&host=&mode=auto&security=reality&pbk=3dbvtOlu-RnnicTKhGcrbBZMnJ3dSJmBnGlPE_kUmBU&fp=randomized&sni=www.speedtest.net&sid=16c2&spx=%2Flogin#14-vless-xhttp-reality';

  // New Test Vectors for VMess
  const testVmessRawUrl =
      'vmess://ewogICJ2IjogIjIiLAogICJwcyI6ICIxNS12bWVzcy1yYXciLAogICJhZGQiOiAicGExLmtoYXN0ZWhuYWJhc2hpLmNvbSIsCiAgInBvcnQiOiAxMDAxNSwKICAiaWQiOiAiMTUtdm1lc3MtcmF3LXV1aWQiLAogICJzY3kiOiAiYXV0byIsCiAgIm5ldCI6ICJ0Y3AiLAogICJ0eXBlIjogIm5vbmUiLAogICJ0bHMiOiAibm9uZSIKfQ==';
  const testVmessRawHttpUrl =
      'vmess://ewogICJ2IjogIjIiLAogICJwcyI6ICIxNi12bWVzcy1yYXctaHR0cCIsCiAgImFkZCI6ICJwYTEua2hhc3RlaG5hYmFzaGkuY29tIiwKICAicG9ydCI6IDEwMDE2LAogICJpZCI6ICIxNi12bWVzcy1yYXctaHR0cC11dWlkIiwKICAic2N5IjogImF1dG8iLAogICJuZXQiOiAidGNwIiwKICAidHlwZSI6ICJodHRwIiwKICAidGxzIjogIm5vbmUiLAogICJwYXRoIjogIi8iCn0=';
  const testVmessRawTlsUrl =
      'vmess://ewogICJ2IjogIjIiLAogICJwcyI6ICIxNy12bWVzcy1yYXctdGxzIiwKICAiYWRkIjogInBhMS5raGFzdGVobmFiYXNoaS5jb20iLAogICJwb3J0IjogMTAwMTcsCiAgImlkIjogIjE3LXZtZXNzLXJhdy10bHMtdXVpZCIsCiAgInNjeSI6ICJhdXRvIiwKICAibmV0IjogInRjcCIsCiAgInR5cGUiOiAibm9uZSIsCiAgInRscyI6ICJ0bHMiLAogICJzbmkiOiAicGExLmtoYXN0ZWhuYWJhc2hpLmNvbSIsCiAgImZwIjogInJhbmRvbWl6ZWQiLAogICJhbHBuIjogImgyLGh0dHAvMS4xIgp9';
  const testVmessWsUrl =
      'vmess://ewogICJ2IjogIjIiLAogICJwcyI6ICIxOC12bWVzcy13cyIsCiAgImFkZCI6ICJwYTEua2hhc3RlaG5hYmFzaGkuY29tIiwKICAicG9ydCI6IDEwMDE4LAogICJpZCI6ICIxOC12bWVzcy13cy11dWlkIiwKICAic2N5IjogImF1dG8iLAogICJuZXQiOiAid3MiLAogICJ0eXBlIjogIm5vbmUiLAogICJ0bHMiOiAibm9uZSIsCiAgInBhdGgiOiAiL3ZtZXNzLXdzLXBhdGgiLAogICJob3N0IjogIiIKfQ==';
  const testVmessWsTlsUrl =
      'vmess://ewogICJ2IjogIjIiLAogICJwcyI6ICIxOS12bWVzcy13cy10bHMiLAogICJhZGQiOiAicGExLmtoYXN0ZWhuYWJhc2hpLmNvbSIsCiAgInBvcnQiOiAxMDAxOSwKICAiaWQiOiAiMTktdm1lc3Mtd3MtdGxzLXV1aWQiLAogICJzY3kiOiAiYXV0byIsCiAgIm5ldCI6ICJ3cyIsCiAgInR5cGUiOiAibm9uZSIsCiAgInRscyI6ICJ0bHMiLAogICJwYXRoIjogIi92bWVzcy13cy10bHMtcGF0aCIsCiAgImhvc3QiOiAiIiwKICAic25pIjogInBhMS5raGFzdGVobmFiYXNoaS5jb20iLAogICJmcCI6ICJyYW5kb21pemVkIiwKICAiYWxwbiI6ICJoMixodHRwLzEuMSIKfQ==';
  const testVmessHuUrl =
      'vmess://ewogICJ2IjogIjIiLAogICJwcyI6ICIyMC12bWVzcy1odSIsCiAgImFkZCI6ICJwYTEua2hhc3RlaG5hYmFzaGkuY29tIiwKICAicG9ydCI6IDEwMDIwLAogICJpZCI6ICIyMC12bWVzcy1odS11dWlkIiwKICAic2N5IjogImF1dG8iLAogICJuZXQiOiAiaHR0cHVwZ3JhZGUiLAogICJ0eXBlIjogIm5vbmUiLAogICJ0bHMiOiAibm9uZSIsCiAgInBhdGgiOiAiL3ZtZXNzLWh1LXBhdGgiLAogICJob3N0IjogIiIKfQ==';
  const testVmessHuTlsUrl =
      'vmess://ewogICJ2IjogIjIiLAogICJwcyI6ICIyMS12bWVzcy1odS10bHMiLAogICJhZGQiOiAicGExLmtoYXN0ZWhuYWJhc2hpLmNvbSIsCiAgInBvcnQiOiAxMDAyMSwKICAiaWQiOiAiMjEtdm1lc3MtaHUtdGxzLXV1aWQiLAogICJzY3kiOiAiYXV0byIsCiAgIm5ldCI6ICJodHRwdXBncmFkZSIsCiAgInR5cGUiOiAibm9uZSIsCiAgInRscyI6ICJ0bHMiLAogICJwYXRoIjogIi92bWVzcy1odS10bHMtcGF0aCIsCiAgImhvc3QiOiAiIiwKICAic25pIjogInBhMS5raGFzdGVobmFiYXNoaS5jb20iLAogICJmcCI6ICJyYW5kb21pemVkIiwKICAiYWxwbiI6ICJoMixodHRwLzEuMSIKfQ==';
  const testVmessGrpcUrl =
      'vmess://ewogICJ2IjogIjIiLAogICJwcyI6ICIyMi12bWVzcy1ncnBjIiwKICAiYWRkIjogInBhMS5raGFzdGVobmFiYXNoaS5jb20iLAogICJwb3J0IjogMTAwMjIsCiAgImlkIjogIjIyLXZtZXNzLWdycGMtdXVpZCIsCiAgInNjeSI6ICJhdXRvIiwKICAibmV0IjogImdycGMiLAogICJ0eXBlIjogIm11bHRpIiwKICAidGxzIjogIm5vbmUiLAogICJwYXRoIjogInZtZXNzLWdycGMtc2VydmljZW5hbWUiLAogICJhdXRob3JpdHkiOiAiIgp9';
  const testVmessGrpcTlsUrl =
      'vmess://ewogICJ2IjogIjIiLAogICJwcyI6ICIyMy12bWVzcy1ncnBjLXRscyIsCiAgImFkZCI6ICJwYTEua2hhc3RlaG5hYmFzaGkuY29tIiwKICAicG9ydCI6IDEwMDIzLAogICJpZCI6ICIyMy12bWVzcy1ncnBjLXRscy11dWlkIiwKICAic2N5IjogImF1dG8iLAogICJuZXQiOiAiZ3JwYyIsCiAgInR5cGUiOiAibXVsdGkiLAogICJ0bHMiOiAidGxzIiwKICAicGF0aCI6ICJ2bWVzcy1ncnBjLXRscy1zZXJ2aWNlbmFtZSIsCiAgImF1dGhvcml0eSI6ICIiLAogICJzbmkiOiAicGExLmtoYXN0ZWhuYWJhc2hpLmNvbSIsCiAgImZwIjogInJhbmRvbWl6ZWQiLAogICJhbHBuIjogImgyLGh0dHAvMS4xIgp9';
  const testVmessXhttpUrl =
      'vmess://ewogICJ2IjogIjIiLAogICJwcyI6ICIyNC12bWVzcy14aHR0cCIsCiAgImFkZCI6ICJwYTEua2hhc3RlaG5hYmFzaGkuY29tIiwKICAicG9ydCI6IDEwMDI0LAogICJpZCI6ICIyNC12bWVzcy14aHR0cC11dWlkIiwKICAic2N5IjogImF1dG8iLAogICJuZXQiOiAieGh0dHAiLAogICJ0eXBlIjogIm5vbmUiLAogICJ0bHMiOiAibm9uZSIsCiAgInBhdGgiOiAiL3ZtZXNzLXhodHRwLXBhdGgiLAogICJob3N0IjogIiIsCiAgIm1vZGUiOiAiYXV0byIKfQ==';
  const testVmessXhttpTlsUrl =
      'vmess://ewogICJ2IjogIjIiLAogICJwcyI6ICIyNS12bWVzcy14aHR0cC10bHMiLAogICJhZGQiOiAicGExLmtoYXN0ZWhuYWJhc2hpLmNvbSIsCiAgInBvcnQiOiAxMDAyNSwKICAiaWQiOiAiMjUtdm1lc3MteGh0dHAtdGxzLXV1aWQiLAogICJzY3kiOiAiYXV0byIsCiAgIm5ldCI6ICJ4aHR0cCIsCiAgInR5cGUiOiAibm9uZSIsCiAgInRscyI6ICJ0bHMiLAogICJwYXRoIjogIi92bWVzcy14aHR0cC10bHMtcGF0aCIsCiAgImhvc3QiOiAiIiwKICAibW9kZSI6ICJhdXRvIiwKICAic25pIjogInBhMS5raGFzdGVobmFiYXNoaS5jb20iLAogICJmcCI6ICJyYW5kb21pemVkIiwKICAiYWxwbiI6ICJoMixodHRwLzEuMSIKfQ==';

  // New Test Vectors for Shadowsocks
  const testShadowsocksRawUrl =
      'ss://MjAyMi1ibGFrZTMtY2hhY2hhMjAtcG9seTEzMDU6d29MRG5TbkN1TU95d3J3T3dxVi9XQlhEc2NLOEc4T1N3N2dsYk1PWWZTN0NtaG5DaU1LZUNRRnh3cnpDaUVYRHVRPT0@pa1.khastehnabashi.com:10026?type=tcp#26-ss-raw';

  // New Test Vectors for Trojan
  const testTrojanRawTlsUrl =
      'trojan://27-trojan-raw-tls-password@pa1.khastehnabashi.com:10027?type=tcp&security=tls&fp=randomized&alpn=h2%2Chttp%2F1.1&sni=pa1.khastehnabashi.com#27-trojan-raw-tls';
  const testTrojanRawRealityUrl =
      'trojan://28-trojan-raw-reality-password@pa1.khastehnabashi.com:10028?type=tcp&security=reality&pbk=4cbNTxmayYA5ElxZcDCTzJ1vXYE4AUXDwsRWwYutmDI&fp=randomized&sni=www.speedtest.net&sid=7e85a4&spx=%2Flogin#28-trojan-raw-reality';
  const testTrojanWsTlsUrl =
      'trojan://29-trojan-ws-tls-password@pa1.khastehnabashi.com:10029?type=ws&path=%2Ftrojan-ws-tls-path&host=&security=tls&fp=randomized&alpn=h2%2Chttp%2F1.1&sni=pa1.khastehnabashi.com#29-trojan-ws-tls';
  const testTrojanHuTlsUrl =
      'trojan://30-trojan-hu-tls-password@pa1.khastehnabashi.com:10030?type=httpupgrade&path=%2Ftrojan-hu-tls-path&host=&security=tls&fp=randomized&alpn=h2%2Chttp%2F1.1&sni=pa1.khastehnabashi.com#30-trojan-hu-tls';
  const testTrojanGrpcTlsUrl =
      'trojan://31-trojan-grpc-tls-password@pa1.khastehnabashi.com:10031?type=grpc&serviceName=trojan-grpc-tls-servicename&authority=&mode=multi&security=tls&fp=randomized&alpn=h2%2Chttp%2F1.1&sni=pa1.khastehnabashi.com#31-trojan-grpc-tls';
  const testTrojanGrpcRealityUrl =
      'trojan://32-trojan-grpc-reality-password@pa1.khastehnabashi.com:10032?type=grpc&serviceName=trojan-grpc-reality-servicename&authority=&mode=multi&security=reality&pbk=RARYHt-zT1oosWf86xXGGR7qk5ERNMburkrGm7lfajs&fp=randomized&sni=www.speedtest.net&sid=245e&spx=%2Flogin#32-trojan-grpc-reality';
  const testTrojanXhttpTlsUrl =
      'trojan://33-trojan-xhttp-tls-password@pa1.khastehnabashi.com:10033?type=xhttp&path=%2Ftrojan-xhttp-tls-path&host=&mode=auto&security=tls&fp=randomized&alpn=h2%2Chttp%2F1.1&sni=pa1.khastehnabashi.com#33-trojan-xhttp-tls';
  const testTrojanXhttpRealityUrl =
      'trojan://34-trojan-xhttp-reality-password@pa1.khastehnabashi.com:10034?type=xhttp&path=%2Ftrojan-xhttp-reality-path&host=&mode=auto&security=reality&pbk=FwIqWGUoZFB-mswlWO7oLMrXKtkjHHRetYHEuHkCIUw&fp=randomized&sni=www.speedtest.net&sid=22dc&spx=%2Flogin#34-trojan-xhttp-reality';

  group('ProxyUrlParser', () {
    // New VLESS Tests
    test('parses VLESS raw URL correctly', () {
      final config =
          ProxyUrlParser.parse(testVlessRawUrl) as VlessProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10001);
      expect(config.id, '1-vless-raw-uuid');
      expect(config.network, 'tcp');
      expect(config.security, 'none');
      expect(config.encryption, 'none');
      expect(config.path, '/');
      expect(config.host, '');
      expect(config.fingerprint, '');
      expect(config.alpn, ['']);
      expect(config.allowInsecure, false);
      // As the remark is not provided, it should be 'My Config'
      expect(config.remark, 'My Config');
    });

    test('parses VLESS raw HTTP URL correctly', () {
      final config =
          ProxyUrlParser.parse(testVlessRawHttpUrl) as VlessProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10002);
      expect(config.id, '2-vless-raw-http-uuid');
      expect(config.network, 'tcp');
      expect(config.security, 'none');
      expect(config.headerType, 'http');
      expect(config.path, '/');
      expect(config.remark, '2-vless-raw-http');
    });

    test('parses VLESS raw TLS URL correctly', () {
      final config =
          ProxyUrlParser.parse(testVlessRawTlsUrl) as VlessProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10003);
      expect(config.id, '3-vless-raw-tls-uuid');
      expect(config.network, 'tcp');
      expect(config.security, 'tls');
      expect(config.sni, 'pa1.khastehnabashi.com');
      expect(config.fingerprint, 'randomized');
      expect(config.alpn, ['h2', 'http/1.1']);
      expect(config.flow, 'xtls-rprx-vision');
      expect(config.remark, '3-vless-raw-tls');
    });

    test('parses VLESS raw reality URL correctly', () {
      final config =
          ProxyUrlParser.parse(testVlessRawRealityUrl) as VlessProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10004);
      expect(config.id, '4-vless-raw-reality-uuid');
      expect(config.network, 'tcp');
      expect(config.security, 'reality');
      expect(config.sni, 'www.speedtest.net');
      expect(config.publicKey, 'UpT7iRSw39AXIiRXvgewDttQ_SIYawR670ItDmHnm1A');
      expect(config.shortId, '3efe');
      expect(config.spiderX, '/login');
      expect(config.fingerprint, 'randomized');
      expect(config.flow, 'xtls-rprx-vision');
      expect(config.remark, '4-vless-raw-reality');
    });

    test('parses VLESS ws URL correctly', () {
      final config =
          ProxyUrlParser.parse(testVlessWsUrl) as VlessProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10005);
      expect(config.id, '5-vless-ws-uuid');
      expect(config.network, 'ws');
      expect(config.security, 'none');
      expect(config.path, '/vless-ws-path');
      expect(config.host, '');
      expect(config.remark, '5-vless-ws');
    });

    test('parses VLESS ws TLS URL correctly', () {
      final config =
          ProxyUrlParser.parse(testVlessWsTlsUrl) as VlessProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10006);
      expect(config.id, '6-vless-ws-tls-uuid');
      expect(config.network, 'ws');
      expect(config.security, 'tls');
      expect(config.sni, 'pa1.khastehnabashi.com');
      expect(config.path, '/vless-ws-tls-path');
      expect(config.host, '');
      expect(config.fingerprint, 'randomized');
      expect(config.alpn, ['h2', 'http/1.1']);
      expect(config.remark, '6-vless-ws-tls');
    });

    test('parses VLESS httpupgrade URL correctly', () {
      final config =
          ProxyUrlParser.parse(testVlessHuUrl) as VlessProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10007);
      expect(config.id, '7-vless-hu-uuid');
      expect(config.network, 'httpupgrade');
      expect(config.security, 'none');
      expect(config.path, '/vless-hu-path');
      expect(config.host, '');
      expect(config.remark, '7-vless-hu');
    });

    test('parses VLESS httpupgrade TLS URL correctly', () {
      final config =
          ProxyUrlParser.parse(testVlessHuTlsUrl) as VlessProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10008);
      expect(config.id, '8-vless-hu-tls-uuid');
      expect(config.network, 'httpupgrade');
      expect(config.security, 'tls');
      expect(config.sni, 'pa1.khastehnabashi.com');
      expect(config.path, '/vless-hu-tls-path');
      expect(config.host, '');
      expect(config.fingerprint, 'randomized');
      expect(config.alpn, ['h2', 'http/1.1']);
      expect(config.remark, '8-vless-hu-tls');
    });

    test('parses VLESS gRPC URL correctly', () {
      final config =
          ProxyUrlParser.parse(testVlessGrpcUrl) as VlessProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10009);
      expect(config.id, '9-vless-grpc-uuid');
      expect(config.network, 'grpc');
      expect(config.security, 'none');
      expect(config.serviceName, 'vless-grpc-servicename');
      expect(config.mode, 'multi');
      expect(config.authority, '');
      expect(config.remark, '9-vless-grpc');
    });

    test('parses VLESS gRPC TLS URL correctly', () {
      final config =
          ProxyUrlParser.parse(testVlessGrpcTlsUrl) as VlessProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10010);
      expect(config.id, '10-vless-grpc-tls-uuid');
      expect(config.network, 'grpc');
      expect(config.security, 'tls');
      expect(config.sni, 'pa1.khastehnabashi.com');
      expect(config.serviceName, 'vless-grpc-tls-servicename');
      expect(config.mode, 'multi');
      expect(config.authority, '');
      expect(config.fingerprint, 'randomized');
      expect(config.alpn, ['h2', 'http/1.1']);
      expect(config.remark, '10-vless-grpc-tls');
    });

    test('parses VLESS gRPC reality URL correctly', () {
      final config =
          ProxyUrlParser.parse(testVlessGrpcRealityUrl) as VlessProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10011);
      expect(config.id, '11-vless-grpc-reality-uuid');
      expect(config.network, 'grpc');
      expect(config.security, 'reality');
      expect(config.sni, 'www.speedtest.net');
      expect(config.publicKey, 'j7s5HLse-lSLDWqKtZZe64umYwwYhN3d_u5JESOXj0U');
      expect(config.shortId, '7f');
      expect(config.spiderX, '/login');
      expect(config.serviceName, '11-vless-grpc-reality-servicename');
      expect(config.mode, 'multi');
      expect(config.fingerprint, 'randomized');
      expect(config.remark, '11-vless-grpc-reality');
    });

    test('parses VLESS xhttp URL correctly', () {
      final config =
          ProxyUrlParser.parse(testVlessXhttpUrl) as VlessProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10012);
      expect(config.id, '12-vless-xhttp-uuid');
      expect(config.network, 'xhttp');
      expect(config.security, 'none');
      expect(config.path, '/vless-xhttp-path');
      expect(config.mode, 'auto');
      expect(config.remark, '12-vless-xhttp');
    });

    test('parses VLESS xhttp TLS URL correctly', () {
      final config =
          ProxyUrlParser.parse(testVlessXhttpTlsUrl) as VlessProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10013);
      expect(config.id, '13-vless-xhttp-tls-uuid');
      expect(config.network, 'xhttp');
      expect(config.security, 'tls');
      expect(config.sni, 'pa1.khastehnabashi.com');
      expect(config.path, '/vless-xhttp-tls-path');
      expect(config.mode, 'auto');
      expect(config.fingerprint, 'randomized');
      expect(config.alpn, ['h2', 'http/1.1']);
      expect(config.remark, '13-vless-xhttp-tls');
    });

    test('parses VLESS xhttp reality URL correctly', () {
      final config =
          ProxyUrlParser.parse(testVlessXhttpRealityUrl) as VlessProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10014);
      expect(config.id, '14-vless-xhttp-reality-uuid');
      expect(config.network, 'xhttp');
      expect(config.security, 'reality');
      expect(config.sni, 'www.speedtest.net');
      expect(config.publicKey, '3dbvtOlu-RnnicTKhGcrbBZMnJ3dSJmBnGlPE_kUmBU');
      expect(config.shortId, '16c2');
      expect(config.spiderX, '/login');
      expect(config.path, '/vless-xhttp-reality-path');
      expect(config.mode, 'auto');
      expect(config.fingerprint, 'randomized');
      expect(config.remark, '14-vless-xhttp-reality');
    });

    // New VMess Tests
    test('parses VMess raw URL correctly', () {
      final config =
          ProxyUrlParser.parse(testVmessRawUrl) as VmessProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10015);
      expect(config.id, '15-vmess-raw-uuid');
      expect(config.network, 'tcp');
      expect(config.tls, 'none');
      expect(config.security, 'none');
      expect(config.headerType, 'none');
      expect(config.remark, '15-vmess-raw');
    });

    test('parses VMess raw HTTP URL correctly', () {
      final config =
          ProxyUrlParser.parse(testVmessRawHttpUrl) as VmessProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10016);
      expect(config.id, '16-vmess-raw-http-uuid');
      expect(config.network, 'tcp');
      expect(config.tls, 'none');
      expect(config.security, 'none');
      expect(config.headerType, 'http');
      expect(config.path, '/');
      expect(config.remark, '16-vmess-raw-http');
    });

    test('parses VMess raw TLS URL correctly', () {
      final config =
          ProxyUrlParser.parse(testVmessRawTlsUrl) as VmessProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10017);
      expect(config.id, '17-vmess-raw-tls-uuid');
      expect(config.network, 'tcp');
      expect(config.tls, 'tls');
      expect(config.security, 'none');
      expect(config.headerType, 'none');
      expect(config.sni, 'pa1.khastehnabashi.com');
      expect(config.fingerprint, 'randomized');
      expect(config.alpn, 'h2,http/1.1');
      expect(config.remark, '17-vmess-raw-tls');
    });

    test('parses VMess ws URL correctly', () {
      final config =
          ProxyUrlParser.parse(testVmessWsUrl) as VmessProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10018);
      expect(config.id, '18-vmess-ws-uuid');
      expect(config.network, 'ws');
      expect(config.tls, 'none');
      expect(config.security, 'none');
      expect(config.path, '/vmess-ws-path');
      expect(config.host, '');
      expect(config.remark, '18-vmess-ws');
    });

    test('parses VMess ws TLS URL correctly', () {
      final config =
          ProxyUrlParser.parse(testVmessWsTlsUrl) as VmessProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10019);
      expect(config.id, '19-vmess-ws-tls-uuid');
      expect(config.network, 'ws');
      expect(config.tls, 'tls');
      expect(config.security, 'none');
      expect(config.path, '/vmess-ws-tls-path');
      expect(config.host, '');
      expect(config.sni, 'pa1.khastehnabashi.com');
      expect(config.fingerprint, 'randomized');
      expect(config.alpn, 'h2,http/1.1');
      expect(config.remark, '19-vmess-ws-tls');
    });

    test('parses VMess httpupgrade URL correctly', () {
      final config =
          ProxyUrlParser.parse(testVmessHuUrl) as VmessProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10020);
      expect(config.id, '20-vmess-hu-uuid');
      expect(config.network, 'httpupgrade');
      expect(config.tls, 'none');
      expect(config.security, 'none');
      expect(config.path, '/vmess-hu-path');
      expect(config.host, '');
      expect(config.remark, '20-vmess-hu');
    });

    test('parses VMess httpupgrade TLS URL correctly', () {
      final config =
          ProxyUrlParser.parse(testVmessHuTlsUrl) as VmessProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10021);
      expect(config.id, '21-vmess-hu-tls-uuid');
      expect(config.network, 'httpupgrade');
      expect(config.tls, 'tls');
      expect(config.security, 'none');
      expect(config.path, '/vmess-hu-tls-path');
      expect(config.host, '');
      expect(config.sni, 'pa1.khastehnabashi.com');
      expect(config.fingerprint, 'randomized');
      expect(config.alpn, 'h2,http/1.1');
      expect(config.remark, '21-vmess-hu-tls');
    });

    test('parses VMess gRPC URL correctly', () {
      final config =
          ProxyUrlParser.parse(testVmessGrpcUrl) as VmessProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10022);
      expect(config.id, '22-vmess-grpc-uuid');
      expect(config.network, 'grpc');
      expect(config.tls, 'none');
      expect(config.security, 'none');
      expect(config.path, 'vmess-grpc-servicename');
      expect(config.authority, '');
      expect(config.headerType, 'multi');
      expect(config.remark, '22-vmess-grpc');
    });

    test('parses VMess gRPC TLS URL correctly', () {
      final config =
          ProxyUrlParser.parse(testVmessGrpcTlsUrl) as VmessProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10023);
      expect(config.id, '23-vmess-grpc-tls-uuid');
      expect(config.network, 'grpc');
      expect(config.tls, 'tls');
      expect(config.security, 'none');
      expect(config.path, 'vmess-grpc-tls-servicename');
      expect(config.authority, '');
      expect(config.headerType, 'multi');
      expect(config.sni, 'pa1.khastehnabashi.com');
      expect(config.fingerprint, 'randomized');
      expect(config.alpn, 'h2,http/1.1');
      expect(config.remark, '23-vmess-grpc-tls');
    });

    test('parses VMess xhttp URL correctly', () {
      final config =
          ProxyUrlParser.parse(testVmessXhttpUrl) as VmessProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10024);
      expect(config.id, '24-vmess-xhttp-uuid');
      expect(config.network, 'xhttp');
      expect(config.tls, 'none');
      expect(config.security, 'none');
      expect(config.path, '/vmess-xhttp-path');
      expect(config.host, '');
      expect(config.mode, 'auto');
      expect(config.remark, '24-vmess-xhttp');
    });

    test('parses VMess xhttp TLS URL correctly', () {
      final config =
          ProxyUrlParser.parse(testVmessXhttpTlsUrl) as VmessProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10025);
      expect(config.id, '25-vmess-xhttp-tls-uuid');
      expect(config.network, 'xhttp');
      expect(config.tls, 'tls');
      expect(config.security, 'none');
      expect(config.path, '/vmess-xhttp-tls-path');
      expect(config.host, '');
      expect(config.mode, 'auto');
      expect(config.sni, 'pa1.khastehnabashi.com');
      expect(config.fingerprint, 'randomized');
      expect(config.alpn, 'h2,http/1.1');
      expect(config.remark, '25-vmess-xhttp-tls');
    });

    // New Shadowsocks Test
    test('parses Shadowsocks raw URL correctly', () {
      final config =
          ProxyUrlParser.parse(testShadowsocksRawUrl)
              as ShadowsocksProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10026);
      expect(config.encryption, '2022-blake3-chacha20-poly1305');
      expect(
        config.password,
        'woLDnSnCuMOywrwOwqV/WBXDscK8G8OSw7glbMOYfS7CmhnCiMKeCQFxwrzCiEXDuQ==',
      );
      expect(config.network, 'tcp');
      expect(config.remark, '26-ss-raw');
    });

    // New Trojan Tests
    test('parses Trojan raw TLS URL correctly', () {
      final config =
          ProxyUrlParser.parse(testTrojanRawTlsUrl) as TrojanProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10027);
      expect(config.password, '27-trojan-raw-tls-password');
      expect(config.network, 'tcp');
      expect(config.security, 'tls');
      expect(config.sni, 'pa1.khastehnabashi.com');
      expect(config.fingerprint, 'randomized');
      expect(config.alpn, ['h2', 'http/1.1']);
      expect(config.remark, '27-trojan-raw-tls');
    });

    test('parses Trojan raw reality URL correctly', () {
      final config =
          ProxyUrlParser.parse(testTrojanRawRealityUrl) as TrojanProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10028);
      expect(config.password, '28-trojan-raw-reality-password');
      expect(config.network, 'tcp');
      expect(config.security, 'reality');
      expect(config.sni, 'www.speedtest.net');
      expect(config.publicKey, '4cbNTxmayYA5ElxZcDCTzJ1vXYE4AUXDwsRWwYutmDI');
      expect(config.shortId, '7e85a4');
      expect(config.spiderX, '/login');
      expect(config.fingerprint, 'randomized');
      expect(config.remark, '28-trojan-raw-reality');
    });

    test('parses Trojan ws TLS URL correctly', () {
      final config =
          ProxyUrlParser.parse(testTrojanWsTlsUrl) as TrojanProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10029);
      expect(config.password, '29-trojan-ws-tls-password');
      expect(config.network, 'ws');
      expect(config.security, 'tls');
      expect(config.sni, 'pa1.khastehnabashi.com');
      expect(config.path, '/trojan-ws-tls-path');
      expect(config.host, '');
      expect(config.fingerprint, 'randomized');
      expect(config.alpn, ['h2', 'http/1.1']);
      expect(config.remark, '29-trojan-ws-tls');
    });

    test('parses Trojan httpupgrade TLS URL correctly', () {
      final config =
          ProxyUrlParser.parse(testTrojanHuTlsUrl) as TrojanProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10030);
      expect(config.password, '30-trojan-hu-tls-password');
      expect(config.network, 'httpupgrade');
      expect(config.security, 'tls');
      expect(config.sni, 'pa1.khastehnabashi.com');
      expect(config.path, '/trojan-hu-tls-path');
      expect(config.host, '');
      expect(config.fingerprint, 'randomized');
      expect(config.alpn, ['h2', 'http/1.1']);
      expect(config.remark, '30-trojan-hu-tls');
    });

    test('parses Trojan gRPC TLS URL correctly', () {
      final config =
          ProxyUrlParser.parse(testTrojanGrpcTlsUrl) as TrojanProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10031);
      expect(config.password, '31-trojan-grpc-tls-password');
      expect(config.network, 'grpc');
      expect(config.security, 'tls');
      expect(config.sni, 'pa1.khastehnabashi.com');
      expect(config.serviceName, 'trojan-grpc-tls-servicename');
      expect(config.mode, 'multi');
      expect(config.authority, '');
      expect(config.fingerprint, 'randomized');
      expect(config.alpn, ['h2', 'http/1.1']);
      expect(config.remark, '31-trojan-grpc-tls');
    });

    test('parses Trojan gRPC reality URL correctly', () {
      final config =
          ProxyUrlParser.parse(testTrojanGrpcRealityUrl)
              as TrojanProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10032);
      expect(config.password, '32-trojan-grpc-reality-password');
      expect(config.network, 'grpc');
      expect(config.security, 'reality');
      expect(config.sni, 'www.speedtest.net');
      expect(config.publicKey, 'RARYHt-zT1oosWf86xXGGR7qk5ERNMburkrGm7lfajs');
      expect(config.shortId, '245e');
      expect(config.spiderX, '/login');
      expect(config.serviceName, 'trojan-grpc-reality-servicename');
      expect(config.mode, 'multi');
      expect(config.fingerprint, 'randomized');
      expect(config.remark, '32-trojan-grpc-reality');
    });

    test('parses Trojan xhttp TLS URL correctly', () {
      final config =
          ProxyUrlParser.parse(testTrojanXhttpTlsUrl) as TrojanProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10033);
      expect(config.password, '33-trojan-xhttp-tls-password');
      expect(config.network, 'xhttp');
      expect(config.security, 'tls');
      expect(config.sni, 'pa1.khastehnabashi.com');
      expect(config.path, '/trojan-xhttp-tls-path');
      expect(config.mode, 'auto');
      expect(config.fingerprint, 'randomized');
      expect(config.alpn, ['h2', 'http/1.1']);
      expect(config.remark, '33-trojan-xhttp-tls');
    });

    test('parses Trojan xhttp reality URL correctly', () {
      final config =
          ProxyUrlParser.parse(testTrojanXhttpRealityUrl)
              as TrojanProtocolConfig;
      expect(config.address, 'pa1.khastehnabashi.com');
      expect(config.port, 10034);
      expect(config.password, '34-trojan-xhttp-reality-password');
      expect(config.network, 'xhttp');
      expect(config.security, 'reality');
      expect(config.sni, 'www.speedtest.net');
      expect(config.publicKey, 'FwIqWGUoZFB-mswlWO7oLMrXKtkjHHRetYHEuHkCIUw');
      expect(config.shortId, '22dc');
      expect(config.spiderX, '/login');
      expect(config.path, '/trojan-xhttp-reality-path');
      expect(config.mode, 'auto');
      expect(config.fingerprint, 'randomized');
      expect(config.remark, '34-trojan-xhttp-reality');
    });
  });
}
