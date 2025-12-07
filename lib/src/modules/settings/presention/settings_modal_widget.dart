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

    return Material(
      color: AppColors.transparent,
      child: Center(
        child: Container(
          width: 300.w,
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Customization',
                      style: AppTextStyles.settingsModalTitle,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 24.sp,
                      color: AppColors.grey,
                    ),
                  ],
                ),
                // Due to iOS limitations, the connection mode section is not shown (See ProxyCore Readme)
                if (!Platform.isIOS) _ConnectionModeSection(settings: settings),
                SizedBox(height: 16.h),
                _CoreTypeSection(settings: settings),
                SizedBox(height: 20.h),
                _ConnectionLoadTypeSection(settings: settings),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Specify which connection mode the app should connect in:',
          style: AppTextStyles.settingsModalSectionTitle,
        ),
        SizedBox(height: 12.h),
        RadioOption<ConnectionMode>(
          title: 'Proxy',
          groupValue: settings.connectionMode,
          value: ConnectionMode.proxy,
          onChanged: (value) => settingsController.updateConnectionMode(value!),
        ),
        RadioOption<ConnectionMode>(
          title: 'VPN',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Specify which core the app should use:',
          style: AppTextStyles.settingsModalSectionTitle,
        ),
        SizedBox(height: 12.h),
        RadioOption<CoreNames>(
          title: 'Xray',
          subtitle: '(Mahsa Edition)',
          groupValue: settings.coreType,
          value: CoreNames.xray,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Theme',
          style: AppTextStyles.settingsModalSectionTitle,
        ),
        SizedBox(height: 12.h),
        RadioOption<ThemeMode>(
          title: 'Light',
          groupValue: themeMode,
          value: ThemeMode.light,
          onChanged: (value) =>
              ref.read(themeModeProvider.notifier).setThemeMode(value!),
        ),
        RadioOption<ThemeMode>(
          title: 'Dark',
          groupValue: themeMode,
          value: ThemeMode.dark,
          onChanged: (value) =>
              ref.read(themeModeProvider.notifier).setThemeMode(value!),
        ),
        RadioOption<ThemeMode>(
          title: 'System',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Language',
          style: AppTextStyles.settingsModalSectionTitle,
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: settingsController.restoreDefaults,
          child: Text(
            'Restore to default',
            style: AppTextStyles.settingsModalRestoreButton,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            settingsController.updateSettings();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          ),
          child: Text(
            'Confirm',
            style: AppTextStyles.settingsModalConfirmButton,
          ),
        ),
      ],
    );
  }
}
