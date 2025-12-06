# 🔄 Proxy URL Parser

Proxy URL Parser is a lightweight Dart package that parses proxy URLs into structured
configurations. It supports multiple proxy protocols and makes it easy to integrate proxy
functionality into your Dart and Flutter applications.

## ✨ Features

- 🧩 Parse multiple proxy protocol URLs into structured configurations
- 🔀 Support for VMess, VLESS, Shadowsocks, and Trojan protocols
- 🧰 Easy integration with [proxy_core](https://github.com/mahsanet/proxy_core) implementations
- 🛠️ Inject parsed configurations into existing config structures

## 🔌 Supported Protocols

- ✅ VMess (`vmess://`)
- ✅ VLESS (`vless://`)
- ✅ Shadowsocks (`ss://`)
- ✅ Trojan (`trojan://`)
- 🔜 WireGuard, SOCKS, Hysteria2 (Coming soon)

## 🛠️ Core Functionality

| Function                                       | Description                                                              |
|------------------------------------------------|--------------------------------------------------------------------------|
| `parse(String proxyUrl)`                       | Parse a proxy URL into a specific configuration type                     |
| `injectToConfig(Map baseConfig, Map outbound)` | Inject parsed outbound configuration into an existing base configuration |
| `toXrayJson(bool allowInsecure)`               | Convert a parsed configuration to Xray JSON format                       |

## 🧪 Testing

The package includes comprehensive test coverage for all supported protocols. Tests are organized into two main categories:

### Unit Tests
Located in `test/proxy_url_parser_test.dart`, these tests verify individual protocol parsing functionality with predefined test vectors.

### Vector Tests
Located in `test/proxy_url_parser_vector_test.dart`, these tests read proxy URLs from a vector bucket file (`test/vector_bucket`) and perform comprehensive validation of all fields for each protocol type.

#### Running Tests
```bash
# Run all tests
dart test

# Run specific test file
dart test test/proxy_url_parser_test.dart
dart test test/proxy_url_parser_vector_test.dart

# Run tests with coverage
dart test --coverage=coverage
```

#### Adding Test Vectors
To add new test vectors:
1. Add your proxy URLs to `test/vector_bucket`
2. Each URL should be on a new line
3. Lines starting with `#` are treated as comments
4. Empty lines are ignored

Example vector bucket format:
```
# VLESS URLs
vless://uuid@host:port?type=tcp&security=none#remark
vless://uuid@host:port?type=ws&path=/path&security=tls#remark

# VMess URLs
vmess://base64-encoded-json

# Shadowsocks URLs
ss://method:password@host:port#remark

# Trojan URLs
trojan://password@host:port?security=tls#remark
```

## 🚀 Getting Started

To use this package, add `proxy_url_parser` as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  proxy_url_parser: ^latest
```

### 📝 Usage

```dart
import 'package:proxy_url_parser/proxy_url_parser.dart';

void main() {
  // Parse a VMess URL
  try {
    final vmessConfig = ProxyUrlParser.parse("vmess://your-vmess-url-here");
    print("Parsed VMess config: ${vmessConfig.server}:${vmessConfig.port}");

    // Inject into a base configuration
    final baseConfig = <String, dynamic>{
      "log": {"loglevel": "info"},
      "dns": {},
      // Other base config elements
    };
    
    xrayJson = vmessConfig.toXrayJson();

    final fullConfig = ProxyUrlParser.injectToConfig(
      baseConfig,
      xrayJson,
    );

    // Use the full configuration with your proxy core
  } catch (e) {
    if (e is UnsupportedProxyTypeException) {
      print("Unsupported proxy protocol");
    } else if (e is InvalidUrlFormatException) {
      print("Invalid URL format: ${e.message}");
    } else {
      print("Error parsing URL: $e");
    }
  }
}
```

## 🔍 Exception Handling

The package provides custom exceptions for better error handling:

- `DecodingException` - Thrown when decoding fails (e.g., base64 or JSON)
- `UnsupportedProxyTypeException` - Thrown when an unsupported protocol is encountered
- `InvalidUrlFormatException` - Thrown when the URL format is invalid

## 🔧 Debugging

The package includes a logging utility (`ProxyUrlParserLogger`) that can be enabled for debugging:

```dart
// Enable debug logging
ProxyUrlParserLogger.enableDebugLogs = true;
```

## 📖 Example

For more detailed examples, check the example directory in the repository.

## 📄 License

This project is licensed under the MIT License.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
