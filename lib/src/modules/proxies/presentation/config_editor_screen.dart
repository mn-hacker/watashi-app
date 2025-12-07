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
        return params['host'] ?? params['sni'] ?? '';
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
            SizedBox(height: 16.h),
            _buildSectionTitle('Path', isDarkMode),
            _buildTextField(_pathController, 'WebSocket Path', isDarkMode),
            SizedBox(height: 16.h),
            _buildSectionTitle('Host / SNI', isDarkMode),
            _buildTextField(_hostController, 'Host or SNI', isDarkMode),
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
    // TODO: Implement config update logic
    // This requires reconstructing the config link with updated values
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.configAddedSuccess)),
    );
    Navigator.pop(context);
  }
}
