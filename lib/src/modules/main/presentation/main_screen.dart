import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watashi/gen/assets.gen.dart';
import 'package:watashi/src/l10n/l10n.dart';
import 'package:watashi/src/modules/connection_config/data/connection_config_repo.dart';
import 'package:watashi/src/modules/connection_config/presentation/add_config_bottom_sheet.dart';
import 'package:watashi/src/modules/connection_config/presentation/widgets/connection_config_input_controller.dart';
import 'package:watashi/src/modules/connection_meta/presentation/connection_meta_controller.dart';
import 'package:watashi/src/modules/connection_meta/presentation/connection_meta_widget.dart';
import 'package:watashi/src/modules/core/data/core_repo.dart';
import 'package:watashi/src/modules/main/presentation/main_controller.dart';
import 'package:watashi/src/modules/main/presentation/widgets/main_connect_button/main_connect_button.dart';
import 'package:watashi/src/modules/settings/presention/settings_modal_widget.dart';
import 'package:watashi/src/shared/constants/app_colors.dart';
import 'package:watashi/src/shared/constants/app_icons.dart';
import 'package:watashi/src/shared/constants/app_text_styles.dart';
import 'package:watashi/src/shared/presentation/routing/app_router.dart';
import 'package:watashi/src/shared/utils/async_value_extensions.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkBackground : AppColors.white,
        image: DecorationImage(
          image: Assets.images.bg.image(fit: BoxFit.cover).image,
          colorFilter: isDarkMode
              ? const ColorFilter.mode(
                  AppColors.darkBackground, BlendMode.darken)
              : null,
          opacity: isDarkMode ? 0.3 : 1.0,
        ),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.transparent,
        endDrawer: _MainDrawer(),
        appBar: AppBar(
          title: Padding(
            padding: EdgeInsets.only(left: 20.w),
            child: AppIcons.logo(),
          ),
          actions: [
            IconButton(
              iconSize: 28,
              icon: AppIcons.settings(width: 30.h, height: 30.h),
              tooltip: 'Quick Settings',
              onPressed: () => showSettingsModal(context),
            ),
            IconButton(
              iconSize: 28,
              icon: AppIcons.circlePlus(width: 30.h, height: 30.h),
              onPressed: () => showAddConfigBottomSheet(context),
            ),
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: IconButton(
                icon: Icon(
                  Icons.menu,
                  size: 28,
                  color: isDarkMode ? AppColors.white : AppColors.black,
                ),
                onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 0.075.sh),
        MainScreenHint(),
        const Spacer(),
        ConnectionButton(),
        SizedBox(height: 0.125.sh),
      ],
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
    final config = ref.read(connectionConfigRepoProvider).config;

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
              fontSize: 18.sp,
              fontFamily: AppTextStyles.fontFamily,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.white
                  : AppColors.black,
              fontWeight: FontWeight.w300,
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

class _MainDrawer extends ConsumerWidget {
  const _MainDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDarkMode ? AppColors.darkSurface : AppColors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.darkCard
                    : AppColors.lightGrey.withValues(alpha: 0.3),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppIcons.logo(height: 30),
                  SizedBox(height: 8.h),
                  Text(
                    'Main Settings',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDarkMode
                          ? AppColors.white.withValues(alpha: 0.7)
                          : AppColors.black54,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            // Menu Items
            _DrawerMenuItem(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);
                showSettingsModal(context);
              },
            ),
            _DrawerMenuItem(
              icon: Icons.bug_report,
              title: 'Logs',
              onTap: () {
                Navigator.pop(context);
                ref.read(goRouterProvider).goNamed(logsScreenName);
              },
            ),
            _DrawerMenuItem(
              icon: Icons.info_outline,
              title: 'About',
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'Watashi VPN',
                  applicationVersion: '1.0.0',
                );
              },
            ),
            const Spacer(),
            // Version info
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'Watashi VPN v1.0.0',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDarkMode
                      ? AppColors.white.withValues(alpha: 0.5)
                      : AppColors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color: isDarkMode
            ? AppColors.white.withValues(alpha: 0.8)
            : AppColors.black87,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          color: isDarkMode ? AppColors.white : AppColors.black,
        ),
      ),
      onTap: onTap,
    );
  }
}
