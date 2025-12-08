import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watashi/src/l10n/l10n.dart';
import 'package:watashi/src/modules/settings/presention/settings_modal_widget.dart';
import 'package:watashi/src/shared/constants/app_colors.dart';
import 'package:watashi/src/shared/constants/app_icons.dart';
import 'package:watashi/src/shared/presentation/routing/app_router.dart';

/// Shows the full-screen hamburger menu that can be used from any screen
void showFullScreenMenu(BuildContext context) {
  Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      pageBuilder: (context, animation, secondaryAnimation) {
        return const _FullScreenMenu();
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
    ),
  );
}

class _FullScreenMenu extends ConsumerWidget {
  const _FullScreenMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Dark overlay
            Positioned.fill(
              child: Container(color: Colors.transparent),
            ),
            // Menu panel from right
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: MediaQuery.of(context).size.width * 0.75,
              child: GestureDetector(
                onTap: () {}, // Prevent closing when tapping menu
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.darkSurface : AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(-5, 0),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Header
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 20.h),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppColors.darkCard
                                : AppColors.lightGrey.withOpacity(0.3),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppIcons.logo(height: 30),
                              SizedBox(height: 8.h),
                              Text(
                                context.l10n.mainSettings,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: isDarkMode
                                      ? AppColors.white.withOpacity(0.7)
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
                          title: context.l10n.settings,
                          onTap: () {
                            Navigator.pop(context);
                            showSettingsModal(context);
                          },
                        ),
                        _DrawerMenuItem(
                          icon: Icons.bug_report,
                          title: context.l10n.logs,
                          onTap: () {
                            Navigator.pop(context);
                            ref.read(goRouterProvider).goNamed(logsScreenName);
                          },
                        ),
                        _DrawerMenuItem(
                          icon: Icons.info_outline,
                          title: context.l10n.about,
                          onTap: () {
                            Navigator.pop(context);
                            showAboutDialog(
                              context: context,
                              applicationName: 'Watashi VPN',
                              applicationVersion: '1.0.12',
                            );
                          },
                        ),
                        const Spacer(),
                        // Version info
                        Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Text(
                            'Watashi VPN v1.0.12',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isDarkMode
                                  ? AppColors.white.withOpacity(0.5)
                                  : AppColors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
        color:
            isDarkMode ? AppColors.white.withOpacity(0.8) : AppColors.black87,
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
