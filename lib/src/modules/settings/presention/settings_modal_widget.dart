import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proxy_core/constants/core_names.dart';
import 'package:watashi/src/l10n/l10n.dart';
import 'package:watashi/src/modules/connection/domain/connection_mode.dart';
import 'package:watashi/src/modules/settings/domain/settings_model.dart';
import 'package:watashi/src/modules/settings/presention/settings_modal_controller.dart';
import 'package:watashi/src/shared/constants/app_colors.dart';
import 'package:watashi/src/shared/constants/app_text_styles.dart';
import 'package:watashi/src/shared/presentation/theme_provider.dart';
import 'package:watashi/src/shared/presentation/widgets/custom_dialog.dart';
import 'package:watashi/src/shared/presentation/widgets/radio_button.dart';

// Shows the settings modal with custom animations
Future<void> showSettingsModal(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => DialogScaffold(
      child: const _SettingsModal(),
    ),
  );
}

// Settings modal widget that allows users to customize app settings
class _SettingsModal extends ConsumerWidget {
  const _SettingsModal();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsModalControllerProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: AppColors.transparent,
      child: Center(
        child: Container(
          width: 300.w,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkCard : AppColors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.08),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header (fixed at top)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.customization,
                      style: AppTextStyles.settingsModalTitle.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDarkMode
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 22.sp,
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                // Scrollable content
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Due to iOS limitations, the connection mode section is not shown (See ProxyCore Readme)
                        if (!Platform.isIOS)
                          _ConnectionModeSection(settings: settings),
                        if (!Platform.isIOS) SizedBox(height: 16.h),
                        _CoreTypeSection(settings: settings),
                        SizedBox(height: 20.h),
                        const _ThemeSection(),
                        SizedBox(height: 20.h),
                        const _LanguageSection(),
                        SizedBox(height: 24.h),
                        const _ActionButtons(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConnectionModeSection extends ConsumerWidget {
  final SettingsModel settings;

  const _ConnectionModeSection({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsController =
        ref.read(settingsModalControllerProvider.notifier);

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.connectionMode,
          style: AppTextStyles.settingsModalSectionTitle.copyWith(
            color: isDarkMode
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 12.h),
        RadioOption<ConnectionMode>(
          title: context.l10n.connectionModeProxy,
          groupValue: settings.connectionMode,
          value: ConnectionMode.proxy,
          onChanged: (value) => settingsController.updateConnectionMode(value!),
        ),
        RadioOption<ConnectionMode>(
          title: context.l10n.connectionModeVpn,
          groupValue: settings.connectionMode,
          value: ConnectionMode.vpn,
          onChanged: (value) => settingsController.updateConnectionMode(value!),
        ),
      ],
    );
  }
}

class _CoreTypeSection extends ConsumerWidget {
  final SettingsModel settings;

  const _CoreTypeSection({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsController =
        ref.read(settingsModalControllerProvider.notifier);

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.coreType,
          style: AppTextStyles.settingsModalSectionTitle.copyWith(
            color: isDarkMode
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 12.h),
        RadioOption<CoreNames>(
          title: 'Xray',
          subtitle: '(Custom)',
          groupValue: settings.coreType,
          value: CoreNames.xray,
          onChanged: (value) => settingsController.updateCoreType(value!),
        ),
        RadioOption<CoreNames>(
          title: 'Clash Meta',
          groupValue: settings.coreType,
          value: CoreNames.clashMeta,
          onChanged: (value) => settingsController.updateCoreType(value!),
        ),
        RadioOption<CoreNames>(
          title: 'SingBox',
          groupValue: settings.coreType,
          value: CoreNames.singbox,
          onChanged: (value) => settingsController.updateCoreType(value!),
        ),
        RadioOption<CoreNames>(
          title: 'Xray',
          subtitle: '(V2ray)',
          groupValue: settings.coreType,
          value: CoreNames.v2ray,
          onChanged: (value) => settingsController.updateCoreType(value!),
        ),
        RadioOption<CoreNames>(
          title: 'Outline',
          subtitle: '(Beta)',
          groupValue: settings.coreType,
          value: CoreNames.outline,
          onChanged: (value) => settingsController.updateCoreType(value!),
        ),
      ],
    );
  }
}

class _ConnectionLoadTypeSection extends ConsumerWidget {
  final SettingsModel settings;

  const _ConnectionLoadTypeSection({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final settingsController =
    //     ref.read(settingsModalControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Specify the connection type for the configurations:',
          style: AppTextStyles.settingsModalSectionTitle,
        ),
        SizedBox(height: 12.h),
        RadioOption<ConnectionLoadType>(
          title: 'Normal',
          groupValue: settings.connectionLoadType,
          value: ConnectionLoadType.normal,
          // onChanged: (value) => settingsController.updateConnectionType(value!),
        ),
        RadioOption<ConnectionLoadType>(
          title: 'Load Balance (Soon)',
          groupValue: settings.connectionLoadType,
          value: ConnectionLoadType.loadBalance,
          // onChanged: (value) => settingsController.updateConnectionType(value!),
        ),
      ],
    );
  }
}

class _ThemeSection extends ConsumerWidget {
  const _ThemeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.theme,
          style: AppTextStyles.settingsModalSectionTitle.copyWith(
            color: isDarkMode
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 12.h),
        RadioOption<ThemeMode>(
          title: context.l10n.themeLight,
          groupValue: themeMode,
          value: ThemeMode.light,
          onChanged: (value) =>
              ref.read(themeModeProvider.notifier).setThemeMode(value!),
        ),
        RadioOption<ThemeMode>(
          title: context.l10n.themeDark,
          groupValue: themeMode,
          value: ThemeMode.dark,
          onChanged: (value) =>
              ref.read(themeModeProvider.notifier).setThemeMode(value!),
        ),
        RadioOption<ThemeMode>(
          title: context.l10n.themeSystem,
          groupValue: themeMode,
          value: ThemeMode.system,
          onChanged: (value) =>
              ref.read(themeModeProvider.notifier).setThemeMode(value!),
        ),
      ],
    );
  }
}

class _LanguageSection extends ConsumerWidget {
  const _LanguageSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.language,
          style: AppTextStyles.settingsModalSectionTitle.copyWith(
            color: isDarkMode
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 12.h),
        ...SupportedLocales.all.map((locale) => RadioOption<Locale>(
              title: SupportedLocales.getDisplayName(locale),
              groupValue: currentLocale ?? SupportedLocales.en,
              value: locale,
              onChanged: (value) =>
                  ref.read(localeProvider.notifier).setLocale(value),
            )),
      ],
    );
  }
}

class _ActionButtons extends ConsumerWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsController =
        ref.read(settingsModalControllerProvider.notifier);

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: TextButton(
            onPressed: settingsController.restoreDefaults,
            child: Text(
              context.l10n.restoreDefaults,
              style: AppTextStyles.settingsModalRestoreButton.copyWith(
                color: isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        ElevatedButton(
          onPressed: () {
            settingsController.updateSettings();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
          ),
          child: Text(
            context.l10n.confirm,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
        ),
      ],
    );
  }
}
