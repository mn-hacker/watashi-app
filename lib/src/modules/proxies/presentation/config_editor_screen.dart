import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:watashi/src/l10n/l10n.dart';
import 'package:watashi/src/modules/connection_config/domain/connection_config_model.dart';
import 'package:watashi/src/modules/connection_config/presentation/widgets/connection_config_input_controller.dart';
import 'package:watashi/src/shared/constants/app_colors.dart';

/// Shows the config editor screen as a full-screen modal
void showConfigEditor(BuildContext context, ConnectionConfigModel config) {
  Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => ConfigEditorScreen(config: config),
    ),
  );
}

class ConfigEditorScreen extends ConsumerStatefulWidget {
  final ConnectionConfigModel config;

  const ConfigEditorScreen({super.key, required this.config});

  @override
  ConsumerState<ConfigEditorScreen> createState() => _ConfigEditorScreenState();
}

class _ConfigEditorScreenState extends ConsumerState<ConfigEditorScreen> {
  late TextEditingController _remarkController;
  late TextEditingController _addressController;
  late TextEditingController _portController;
  late TextEditingController _uuidController;
  late TextEditingController _pathController;
  late TextEditingController _hostController;
  late TextEditingController _securityController;
  late TextEditingController _networkController;
  late TextEditingController _encryptionController;
  late TextEditingController _fingerprintController;
  late TextEditingController _alpnController;
  late TextEditingController _flowController;
  late TextEditingController _publicKeyController;
  late TextEditingController _shortIdController;
  late TextEditingController _sniController;

  @override
  void initState() {
    super.initState();
    _remarkController = TextEditingController(text: widget.config.configName);
    _addressController =
        TextEditingController(text: widget.config.serverAddress ?? '');
    _portController =
        TextEditingController(text: widget.config.serverPort?.toString() ?? '');
    _uuidController = TextEditingController(text: _extractUuid());
    _pathController = TextEditingController(text: _extractPath());
    _hostController = TextEditingController(text: _extractHost());
    _securityController = TextEditingController(text: _extractSecurity());
    _networkController = TextEditingController(text: _extractNetwork());
    _encryptionController = TextEditingController(text: _extractEncryption());
    _fingerprintController = TextEditingController(text: _extractFingerprint());
    _alpnController = TextEditingController(text: _extractAlpn());
    _flowController = TextEditingController(text: _extractFlow());
    _publicKeyController = TextEditingController(text: _extractPublicKey());
    _shortIdController = TextEditingController(text: _extractShortId());
    _sniController = TextEditingController(text: _extractSni());
  }

  String _extractUuid() {
    if (widget.config.configLink != null) {
      // Extract UUID from config link
      final link = widget.config.configLink!;
      final uriPart = link.split('@').first;
      if (uriPart.contains('://')) {
        return uriPart.split('://').last;
      }
    }
    return '';
  }

  String _extractPath() {
    if (widget.config.configLink != null) {
      try {
        final uri = Uri.parse(widget.config.configLink!
            .replaceFirst(RegExp(r'^\w+://'), 'https://'));
        final params = Uri.splitQueryString(uri.fragment);
        return params['path'] ?? uri.path;
      } catch (e) {
        return '';
      }
    }
    return '';
  }

  String _extractHost() {
    if (widget.config.configLink != null) {
      try {
        final uri = Uri.parse(widget.config.configLink!
            .replaceFirst(RegExp(r'^\w+://'), 'https://'));
        final params = Uri.splitQueryString(uri.fragment);
        return params['host'] ?? '';
      } catch (e) {
        return '';
      }
    }
    return '';
  }

  String _extractSecurity() {
    if (widget.config.configLink != null) {
      try {
        final uri = Uri.parse(widget.config.configLink!
            .replaceFirst(RegExp(r'^\w+://'), 'https://'));
        final params = Uri.splitQueryString(uri.fragment);
        return params['security'] ?? 'tls';
      } catch (e) {
        return 'tls';
      }
    }
    return 'tls';
  }

  String _extractNetwork() {
    if (widget.config.configLink != null) {
      try {
        final uri = Uri.parse(widget.config.configLink!
            .replaceFirst(RegExp(r'^\w+://'), 'https://'));
        final params = Uri.splitQueryString(uri.fragment);
        return params['type'] ?? params['net'] ?? 'tcp';
      } catch (e) {
        return 'tcp';
      }
    }
    return 'tcp';
  }

  String _extractEncryption() {
    if (widget.config.configLink != null) {
      try {
        final uri = Uri.parse(widget.config.configLink!
            .replaceFirst(RegExp(r'^\w+://'), 'https://'));
        final params = Uri.splitQueryString(uri.fragment);
        return params['encryption'] ?? params['method'] ?? 'auto';
      } catch (e) {
        return 'auto';
      }
    }
    return 'auto';
  }

  String _extractFingerprint() {
    if (widget.config.configLink != null) {
      try {
        final uri = Uri.parse(widget.config.configLink!
            .replaceFirst(RegExp(r'^\w+://'), 'https://'));
        final params = Uri.splitQueryString(uri.fragment);
        return params['fp'] ?? '';
      } catch (e) {
        return '';
      }
    }
    return '';
  }

  String _extractAlpn() {
    if (widget.config.configLink != null) {
      try {
        final uri = Uri.parse(widget.config.configLink!
            .replaceFirst(RegExp(r'^\w+://'), 'https://'));
        final params = Uri.splitQueryString(uri.fragment);
        return params['alpn'] ?? '';
      } catch (e) {
        return '';
      }
    }
    return '';
  }

  String _extractFlow() {
    if (widget.config.configLink != null) {
      try {
        final uri = Uri.parse(widget.config.configLink!
            .replaceFirst(RegExp(r'^\w+://'), 'https://'));
        final params = Uri.splitQueryString(uri.fragment);
        return params['flow'] ?? '';
      } catch (e) {
        return '';
      }
    }
    return '';
  }

  String _extractPublicKey() {
    if (widget.config.configLink != null) {
      try {
        final uri = Uri.parse(widget.config.configLink!
            .replaceFirst(RegExp(r'^\w+://'), 'https://'));
        final params = Uri.splitQueryString(uri.fragment);
        return params['pbk'] ?? '';
      } catch (e) {
        return '';
      }
    }
    return '';
  }

  String _extractShortId() {
    if (widget.config.configLink != null) {
      try {
        final uri = Uri.parse(widget.config.configLink!
            .replaceFirst(RegExp(r'^\w+://'), 'https://'));
        final params = Uri.splitQueryString(uri.fragment);
        return params['sid'] ?? '';
      } catch (e) {
        return '';
      }
    }
    return '';
  }

  String _extractSni() {
    if (widget.config.configLink != null) {
      try {
        final uri = Uri.parse(widget.config.configLink!
            .replaceFirst(RegExp(r'^\w+://'), 'https://'));
        final params = Uri.splitQueryString(uri.fragment);
        return params['sni'] ?? '';
      } catch (e) {
        return '';
      }
    }
    return '';
  }

  @override
  void dispose() {
    _remarkController.dispose();
    _addressController.dispose();
    _portController.dispose();
    _uuidController.dispose();
    _pathController.dispose();
    _hostController.dispose();
    _securityController.dispose();
    _networkController.dispose();
    _encryptionController.dispose();
    _fingerprintController.dispose();
    _alpnController.dispose();
    _flowController.dispose();
    _publicKeyController.dispose();
    _shortIdController.dispose();
    _sniController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppColors.darkSurface : AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close,
              color: isDarkMode ? AppColors.white : AppColors.black),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Close',
        ),
        title: Text(
          context.l10n.editConfig,
          style: TextStyle(
            color: isDarkMode ? AppColors.white : AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteConfig,
            tooltip: context.l10n.deleteConfig,
          ),
          IconButton(
            icon: Icon(Icons.share,
                color: isDarkMode ? AppColors.white : AppColors.black),
            onPressed: _shareConfig,
            tooltip: 'Share',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(isDarkMode),
            SizedBox(height: 24.h),

            // Basic Settings Section
            _buildGroupTitle('Basic Settings', isDarkMode),
            _buildSectionTitle(context.l10n.configRemark, isDarkMode),
            _buildTextField(_remarkController, 'Config Name', isDarkMode),
            SizedBox(height: 16.h),
            _buildSectionTitle(context.l10n.configAddress, isDarkMode),
            _buildTextField(_addressController, 'Server Address', isDarkMode),
            SizedBox(height: 16.h),
            _buildSectionTitle(context.l10n.configPort, isDarkMode),
            _buildTextField(_portController, 'Port', isDarkMode,
                keyboardType: TextInputType.number),
            SizedBox(height: 16.h),
            _buildSectionTitle(context.l10n.configUuid, isDarkMode),
            _buildTextField(_uuidController, 'UUID / Password', isDarkMode),

            SizedBox(height: 24.h),

            // Network Settings Section
            _buildGroupTitle('Network Settings', isDarkMode),
            _buildSectionTitle('Network Type', isDarkMode),
            _buildTextField(
                _networkController, 'tcp, ws, grpc, etc.', isDarkMode),
            SizedBox(height: 16.h),
            _buildSectionTitle('Path', isDarkMode),
            _buildTextField(
                _pathController, 'WebSocket / HTTP Path', isDarkMode),
            SizedBox(height: 16.h),
            _buildSectionTitle('Host', isDarkMode),
            _buildTextField(_hostController, 'Request Host', isDarkMode),

            SizedBox(height: 24.h),

            // TLS Settings Section
            _buildGroupTitle('TLS Settings', isDarkMode),
            _buildSectionTitle('Security', isDarkMode),
            _buildTextField(
                _securityController, 'none, tls, reality', isDarkMode),
            SizedBox(height: 16.h),
            _buildSectionTitle('SNI', isDarkMode),
            _buildTextField(
                _sniController, 'Server Name Indication', isDarkMode),
            SizedBox(height: 16.h),
            _buildSectionTitle('Fingerprint', isDarkMode),
            _buildTextField(
                _fingerprintController, 'chrome, firefox, safari', isDarkMode),
            SizedBox(height: 16.h),
            _buildSectionTitle('ALPN', isDarkMode),
            _buildTextField(_alpnController, 'h2, http/1.1', isDarkMode),

            // Reality Settings (only show if security is reality)
            if (_securityController.text.toLowerCase() == 'reality') ...[
              SizedBox(height: 24.h),
              _buildGroupTitle('Reality Settings', isDarkMode),
              _buildSectionTitle('Public Key', isDarkMode),
              _buildTextField(
                  _publicKeyController, 'Reality Public Key', isDarkMode),
              SizedBox(height: 16.h),
              _buildSectionTitle('Short ID', isDarkMode),
              _buildTextField(
                  _shortIdController, 'Reality Short ID', isDarkMode),
            ],

            // VLESS Specific (flow)
            if (widget.config.protocolType.toUpperCase() == 'VLESS') ...[
              SizedBox(height: 24.h),
              _buildGroupTitle('VLESS Settings', isDarkMode),
              _buildSectionTitle('Flow', isDarkMode),
              _buildTextField(_flowController, 'xtls-rprx-vision', isDarkMode),
            ],

            // Shadowsocks Specific (encryption)
            if (widget.config.protocolType.toUpperCase() == 'SHADOWSOCKS') ...[
              SizedBox(height: 24.h),
              _buildGroupTitle('Shadowsocks Settings', isDarkMode),
              _buildSectionTitle('Encryption Method', isDarkMode),
              _buildTextField(_encryptionController,
                  'aes-256-gcm, chacha20-ietf-poly1305', isDarkMode),
            ],

            SizedBox(height: 32.h),
            _buildSaveButton(isDarkMode),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkCard : AppColors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.vpn_key,
              color: AppColors.accent,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.config.configName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppColors.white : AppColors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.config.protocolType,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          if (widget.config.ping != null && widget.config.ping! > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _getPingColor(widget.config.ping).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '${widget.config.ping}ms',
                style: TextStyle(
                  color: _getPingColor(widget.config.ping),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getPingColor(int? ping) {
    if (ping == null || ping <= 0) return AppColors.grey;
    if (ping < 200) return Colors.green;
    if (ping < 400) return Colors.orange;
    return Colors.red;
  }

  Widget _buildGroupTitle(String title, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h, top: 8.h),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.white : AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? AppColors.grey.shade400 : AppColors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    bool isDarkMode, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: isDarkMode ? AppColors.white : AppColors.black,
        fontSize: 16.sp,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDarkMode ? AppColors.grey.shade600 : AppColors.grey.shade400,
        ),
        filled: true,
        fillColor: isDarkMode ? AppColors.darkCard : AppColors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.copy, size: 20.sp),
                color: isDarkMode
                    ? AppColors.grey.shade400
                    : AppColors.grey.shade600,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: controller.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Copied to clipboard')),
                  );
                },
              )
            : null,
      ),
    );
  }

  Widget _buildSaveButton(bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          context.l10n.saveChanges,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _deleteConfig() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.deleteConfig),
        content: Text(
            'Are you sure you want to delete "${widget.config.configName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(connectionConfigControllerProvider.notifier)
                  .deleteConfig(widget.config.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _shareConfig() {
    final configString = widget.config.asStringValue;
    Share.share(configString, subject: widget.config.configName);
  }

  void _saveChanges() {
    // Reconstruct the config link with updated values
    final protocol = widget.config.protocolType.toLowerCase();
    final address = _addressController.text.trim();
    final port = _portController.text.trim();
    final uuid = _uuidController.text.trim();
    final remark = Uri.encodeComponent(_remarkController.text.trim());

    // Build query parameters
    final params = <String, String>{};

    if (_networkController.text.isNotEmpty) {
      params['type'] = _networkController.text.trim();
    }
    if (_securityController.text.isNotEmpty) {
      params['security'] = _securityController.text.trim();
    }
    if (_sniController.text.isNotEmpty) {
      params['sni'] = _sniController.text.trim();
    }
    if (_fingerprintController.text.isNotEmpty) {
      params['fp'] = _fingerprintController.text.trim();
    }
    if (_alpnController.text.isNotEmpty) {
      params['alpn'] = _alpnController.text.trim();
    }
    if (_pathController.text.isNotEmpty) {
      params['path'] = _pathController.text.trim();
    }
    if (_hostController.text.isNotEmpty) {
      params['host'] = _hostController.text.trim();
    }
    if (_flowController.text.isNotEmpty) {
      params['flow'] = _flowController.text.trim();
    }
    if (_publicKeyController.text.isNotEmpty) {
      params['pbk'] = _publicKeyController.text.trim();
    }
    if (_shortIdController.text.isNotEmpty) {
      params['sid'] = _shortIdController.text.trim();
    }

    // Build config link based on protocol
    String newLink;
    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    if (protocol == 'vless' || protocol == 'trojan') {
      // vless://uuid@address:port?params#remark
      newLink = '$protocol://$uuid@$address:$port?$queryString#$remark';
    } else if (protocol == 'vmess') {
      // vmess links are base64 encoded JSON - keep original for now
      // TODO: Implement vmess link reconstruction
      newLink = widget.config.configLink ?? '';
    } else if (protocol == 'shadowsocks' || protocol == 'ss') {
      // ss://base64(method:password)@address:port#remark
      final method = _encryptionController.text.trim();
      final encoded = base64Encode(utf8.encode('$method:$uuid'));
      newLink = 'ss://$encoded@$address:$port#$remark';
    } else {
      // Unknown protocol - keep original
      newLink = widget.config.configLink ?? '';
    }

    // Create updated config
    final updatedConfig = ConnectionConfigModel.fromLink(
      configLink: newLink,
      id: widget.config.id,
    );

    // Update in repository
    ref
        .read(connectionConfigControllerProvider.notifier)
        .updateConfig(updatedConfig);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.configAddedSuccess)),
    );
    Navigator.pop(context);
  }
}
