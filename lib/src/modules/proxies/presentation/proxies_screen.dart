import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watashi/src/l10n/l10n.dart';
import 'package:watashi/src/modules/connection_config/data/connection_config_repo.dart';
import 'package:watashi/src/modules/connection_config/domain/connection_config_model.dart';
import 'package:watashi/src/modules/connection_config/presentation/add_config_bottom_sheet.dart';
import 'package:watashi/src/modules/connection_config/presentation/widgets/connection_config_input_controller.dart';
import 'package:watashi/src/modules/core/data/core_repo.dart';
import 'package:watashi/src/modules/proxies/presentation/config_editor_screen.dart';
import 'package:watashi/src/modules/proxies/presentation/widgets/auto_select_item.dart';
import 'package:watashi/src/modules/proxies/presentation/widgets/proxy_list_item.dart';
import 'package:watashi/src/modules/proxies/presentation/widgets/service_not_running.dart';
import 'package:watashi/src/modules/proxies/presentation/proxies_controller.dart';
import 'package:watashi/src/shared/constants/app_colors.dart';

class ProxiesScreen extends ConsumerWidget {
  const ProxiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isConnected = ref.watch(isCoreRunningProvider).value ?? false;
    final configRepo = ref.watch(connectionConfigRepoProvider);
    final configs = configRepo.configs;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.white,
      appBar: AppBar(
        title: Text(
          context.l10n.proxies,
          style: TextStyle(
            color: isDarkMode ? AppColors.white : AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? AppColors.darkSurface : AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.swap_vert,
            color: isDarkMode ? AppColors.white : AppColors.black,
          ),
          tooltip: context.l10n.sortByPing,
          onPressed: isConnected ? () => _sortByPing(ref) : null,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.menu,
              color: isDarkMode ? AppColors.white : AppColors.black,
            ),
            onPressed: () {
              // Open drawer or menu
            },
          ),
        ],
      ),
      body: !isConnected
          ? const ServiceNotRunningWidget()
          : configs.isEmpty
              ? _buildEmptyState(context, isDarkMode)
              : _buildConfigList(context, ref, isDarkMode, configs, configRepo),
      floatingActionButton: isConnected
          ? FloatingActionButton(
              backgroundColor: AppColors.accent,
              onPressed: () => _refreshPing(ref),
              child: Icon(Icons.bolt, color: AppColors.white),
            )
          : null,
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dns_outlined,
            size: 80.sp,
            color:
                isDarkMode ? AppColors.grey.shade600 : AppColors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            context.l10n.addYourConfig,
            style: TextStyle(
              fontSize: 18.sp,
              color: isDarkMode
                  ? AppColors.grey.shade400
                  : AppColors.grey.shade600,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => showAddConfigBottomSheet(context),
            icon: const Icon(Icons.add),
            label: Text(context.l10n.addConfig),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
          ),
        ],
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
}
