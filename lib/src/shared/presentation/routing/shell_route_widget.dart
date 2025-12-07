import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watashi/src/l10n/l10n.dart';
import 'package:watashi/src/shared/constants/app_colors.dart';

/// This widget is used as a container for all routed screens
/// It provides bottom navigation between Home and Proxies screens
class ShellRouteWidget extends StatelessWidget {
  const ShellRouteWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// Bottom navigation shell for Home and Proxies screens
class BottomNavShell extends StatefulWidget {
  final Widget homeScreen;
  final Widget proxiesScreen;

  const BottomNavShell({
    super.key,
    required this.homeScreen,
    required this.proxiesScreen,
  });

  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  int _currentIndex = 1; // Start on Home tab (index 1)

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          widget.proxiesScreen, // Index 0
          widget.homeScreen, // Index 1
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkSurface : AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Proxies tab
                _NavItem(
                  icon: Icons.list_alt,
                  label: context.l10n.proxies,
                  isSelected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                // Home tab with power icon
                _NavItemWithCircle(
                  isSelected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final color = isSelected
        ? AppColors.accent
        : (isDarkMode ? AppColors.grey.shade400 : AppColors.grey.shade600);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: isSelected
            ? BoxDecoration(
                color: isDarkMode
                    ? AppColors.accent.withOpacity(0.1)
                    : AppColors.accent.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItemWithCircle extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItemWithCircle({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accent
                  : (isDarkMode
                      ? AppColors.grey.shade700
                      : AppColors.grey.shade300),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.power_settings_new,
              color: isSelected ? AppColors.white : AppColors.grey,
              size: 24.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            context.l10n.home,
            style: TextStyle(
              color: isSelected
                  ? AppColors.accent
                  : (isDarkMode
                      ? AppColors.grey.shade400
                      : AppColors.grey.shade600),
              fontSize: 12.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
