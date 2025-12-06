import 'dart:convert';

import 'package:proxy_url_parser/proxy_url_parser.dart';

//TODO: Check Users Sec for 18-vmess
//TODO: Check OTA 28-trojan
//TODO: Check Level for all configs
//TODO: Check show for tls

void main() {
  const testUrl =
      'trojan://34-trojan-xhttp-reality-password@pa1.khastehnabashi.com:10034?type=xhttp&path=%2Ftrojan-xhttp-reality-path&host=&mode=auto&security=reality&pbk=FwIqWGUoZFB-mswlWO7oLMrXKtkjHHRetYHEuHkCIUw&fp=randomized&sni=www.speedtest.net&sid=22dc&spx=%2Flogin#34-trojan-xhttp-reality';

  final config = ProxyUrlParser.parse(testUrl);

  final xrayJson = config.toXrayJson(allowInsecure: false);

  final fullConfig = ProxyUrlParser.injectToConfig({}, xrayJson);

  print(_getPrettyJSONString(fullConfig));
}

String _getPrettyJSONString(jsonObject) {
  var encoder = JsonEncoder.withIndent("  ");
  return encoder.convert(jsonObject);
}
