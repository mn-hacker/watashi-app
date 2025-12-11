import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watashi/gen/assets.gen.dart';
import 'package:watashi/src/l10n/l10n.dart';
import 'package:watashi/src/modules/connection_config/presentation/add_config_bottom_sheet.dart';
import 'package:watashi/src/modules/connection_config/presentation/widgets/connection_config_input_controller.dart';
import 'package:watashi/src/modules/connection_meta/presentation/connection_meta_controller.dart';
import 'package:watashi/src/modules/connection_meta/presentation/connection_meta_widget.dart';
import 'package:watashi/src/modules/core/data/core_repo.dart';
import 'package:watashi/src/modules/main/presentation/main_controller.dart';
import 'package:watashi/src/modules/main/presentation/widgets/main_connect_button/main_connect_button.dart';
import 'package:watashi/src/modules/profile/data/profile_repo.dart';
import 'package:watashi/src/modules/profile/presentation/profile_card.dart';
import 'package:watashi/src/modules/settings/presention/settings_modal_widget.dart';
import 'package:watashi/src/shared/constants/app_colors.dart';
import 'package:watashi/src/shared/constants/app_icons.dart';
import 'package:watashi/src/shared/constants/app_text_styles.dart';
import 'package:watashi/src/shared/utils/async_value_extensions.dart';
import 'package:watashi/src/shared/widgets/full_screen_menu.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkBackground : AppColors.white,
        // Only show background pattern in light mode
        image: isDarkMode
            ? null
            : DecorationImage(
                image: Assets.images.bg.image(fit: BoxFit.cover).image,
                opacity: 1.0,
              ),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leadingWidth: 100.w,
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 8.w),
              IconButton(
                iconSize: 26,
                icon: Icon(
                  Icons.add_circle_outline_rounded,
                  color: isDarkMode ? AppColors.white : AppColors.textPrimary,
                ),
                onPressed: () => showAddConfigBottomSheet(context),
              ),
              IconButton(
                iconSize: 26,
                icon: Icon(
                  Icons.tune_rounded,
                  color: isDarkMode ? AppColors.white : AppColors.textPrimary,
                ),
                tooltip: 'Quick Settings',
                onPressed: () => showSettingsModal(context),
              ),
            ],
          ),
          title: AppIcons.logo(isDarkMode: isDarkMode),
          centerTitle: true,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: IconButton(
                icon: Icon(
                  Icons.menu_rounded,
                  size: 26,
                  color: isDarkMode ? AppColors.white : AppColors.textPrimary,
                ),
                onPressed: () => showFullScreenMenu(context),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0.w),
          child: _MainScreenContent(),
        ),
      ),
    );
  }
}

class _MainScreenContent extends ConsumerWidget {
  const _MainScreenContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Rebuilds when connection config changes
    ref.watch(connectionConfigControllerProvider);
    final profileRepo = ref.watch(profileRepoProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Show empty state when no profiles exist
    // (configs without profiles are orphaned and should prompt adding a profile)
    if (!profileRepo.hasProfiles) {
      return _buildEmptyState(context, isDarkMode);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Profile card at top when profiles exist
        if (profileRepo.hasProfiles) ...[
          SizedBox(height: 8.h),
          const ProfileCard(),
        ],
        SizedBox(height: 0.05.sh),
        MainScreenHint(),
        const Spacer(),
        ConnectionButton(),
        SizedBox(height: 0.125.sh),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.l10n.startWithProfile,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              color: isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 24.h),
          OutlinedButton.icon(
            onPressed: () => showAddConfigBottomSheet(context),
            icon: const Icon(Icons.add_rounded),
            label: Text(context.l10n.addNewProfile),
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  isDarkMode ? AppColors.white : AppColors.textPrimary,
              side: BorderSide(
                color: isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MainScreenHint extends ConsumerWidget {
  const MainScreenHint({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mainState = ref.watch(mainControllerProvider);
    // Rebuilds when core status changes
    final coreStatus = ref.watch(isCoreRunningProvider).value ?? false;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppIcons.cloudCheck(width: 150.w, height: 150.h),
          SizedBox(height: 30.h),
          Text(
            context.l10n.hasActiveSub_MainScreen,
            textAlign: TextAlign.center,
            // TODO: This text style should be here as defining it it in the [AppTextStyles] causes the text to not show
            // Equivalent in the [AppTextStyles] is mainScreenHint
            style: TextStyle(
              fontSize: 17.sp,
              fontFamily: AppTextStyles.fontFamily,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          SizedBox(height: 30.h),
          mainState.when(
            data: (state) {
              if (state == MainState.connected && coreStatus) {
                return ConnectionMetaWidget();
              } else {
                return SizedBox.shrink();
              }
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class ConnectionButton extends ConsumerWidget {
  const ConnectionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mainState = ref.watch(mainControllerProvider);
    final mainController = ref.read(mainControllerProvider.notifier);
    final isCoreRunning = ref.watch(isCoreRunningProvider).value ?? false;
    final connectionMetaController =
        ref.read(connectionMetaControllerProvider.notifier);

    return MainConnectButton(
        width: 0.725.sw,
        height: 0.175.sw,
        isConnected: mainState.maybeWhen(
          data: (state) => state == MainState.connected && isCoreRunning,
          orElse: () => false,
        ),
        onSlideComplete: () async {
          final connectResult = await mainController.connect();
          connectResult.showSnackBarOnError(context);
          debugPrint(connectResult.toString());
          if (connectResult is AsyncData) {
            final testResult = await mainController.testAfterConnected();
            testResult.showSnackBar(context);
            if (testResult is AsyncData) {
              connectionMetaController.fetchConnectionMeta();
            }
          }
        },
        onToggle: () {
          // Clear connection metadata when disconnecting
          connectionMetaController.clear();
          mainController.disconnect();
        });
  }
}
