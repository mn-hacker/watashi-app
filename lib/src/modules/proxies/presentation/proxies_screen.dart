import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watashi/src/l10n/l10n.dart';
import 'package:watashi/src/modules/connection_config/data/connection_config_repo.dart';
import 'package:watashi/src/modules/connection_config/domain/connection_config_model.dart';
import 'package:watashi/src/modules/connection_config/presentation/widgets/connection_config_input_controller.dart';
import 'package:watashi/src/modules/proxies/presentation/config_editor_screen.dart';
import 'package:watashi/src/modules/proxies/presentation/widgets/auto_select_item.dart';
import 'package:watashi/src/modules/proxies/presentation/widgets/proxy_list_item.dart';
import 'package:watashi/src/modules/proxies/presentation/proxies_controller.dart';
import 'package:watashi/src/shared/constants/app_colors.dart';
import 'package:watashi/src/shared/widgets/full_screen_menu.dart';

class ProxiesScreen extends ConsumerWidget {
  const ProxiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final configRepo = ref.watch(connectionConfigRepoProvider);
    final configs = configRepo.configs;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightGrey,
      appBar: AppBar(
        title: Text(
          context.l10n.proxies,
          style: TextStyle(
            color:
                isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
        backgroundColor: isDarkMode ? AppColors.darkSurface : AppColors.white,
        elevation: 0,
        leadingWidth: 100.w,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 8.w),
            IconButton(
              icon: Icon(
                Icons.swap_vert_rounded,
                color: isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              tooltip: context.l10n.sortByPing,
              onPressed: () => _sortByPing(ref),
            ),
            IconButton(
              icon: Icon(
                Icons.delete_sweep_rounded,
                color: isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              tooltip: 'Delete All',
              onPressed: configs.isEmpty
                  ? null
                  : () => _showDeleteAllDialog(context, ref, isDarkMode),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.menu_rounded,
              color: isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
            onPressed: () => showFullScreenMenu(context),
          ),
        ],
      ),
      body: _buildConfigList(context, ref, isDarkMode, configs, configRepo),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.greenGlow,
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: AppColors.accent,
          elevation: 0,
          onPressed: () => _refreshPing(ref),
          child: Icon(Icons.bolt_rounded, color: AppColors.white, size: 26),
        ),
      ),
    );
  }

  Widget _buildConfigList(
    BuildContext context,
    WidgetRef ref,
    bool isDarkMode,
    List configs,
    ConnectionConfigRepo configRepo,
  ) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: configs.length + 1, // +1 for auto-select item
      itemBuilder: (context, index) {
        if (index == 0) {
          return AutoSelectItem(
            isSelected: configRepo.autoSelectEnabled,
            selectedConfigName: configRepo.activeConfig?.configName,
            onTap: () => _enableAutoSelect(ref),
          );
        }

        final configIndex = index - 1;
        final config = configs[configIndex];
        final isActive = !configRepo.autoSelectEnabled &&
            configRepo.activeIndex == configIndex;

        return ProxyListItem(
          config: config,
          isActive: isActive,
          onTap: () => _selectConfig(ref, configIndex),
          onDelete: () => _deleteConfig(ref, config.id),
          onEdit: () => _editConfig(context, ref, config),
        );
      },
    );
  }

  void _sortByPing(WidgetRef ref) {
    ref.read(connectionConfigControllerProvider.notifier).sortByPing();
  }

  void _refreshPing(WidgetRef ref) {
    ref.read(proxiesControllerProvider.notifier).testAllPings();
  }

  void _enableAutoSelect(WidgetRef ref) {
    ref.read(connectionConfigControllerProvider.notifier).enableAutoSelect();
  }

  void _selectConfig(WidgetRef ref, int index) {
    ref
        .read(connectionConfigControllerProvider.notifier)
        .setActiveConfig(index);
  }

  void _deleteConfig(WidgetRef ref, String configId) {
    ref
        .read(connectionConfigControllerProvider.notifier)
        .deleteConfig(configId);
  }

  void _editConfig(
      BuildContext context, WidgetRef ref, ConnectionConfigModel config) {
    showConfigEditor(context, config);
  }

  void _showDeleteAllDialog(
      BuildContext context, WidgetRef ref, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.darkCard : AppColors.white,
        title: Text(
          'Delete All Configs?',
          style: TextStyle(
            color: isDarkMode ? AppColors.white : AppColors.textPrimary,
          ),
        ),
        content: Text(
          'This will remove all your proxy configurations. This action cannot be undone.',
          style: TextStyle(
            color: isDarkMode
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(connectionConfigControllerProvider.notifier)
                  .deleteAllConfigs();
            },
            child: Text(
              'Delete All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
