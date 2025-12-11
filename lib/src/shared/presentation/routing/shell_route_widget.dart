import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  DateTime? _lastBackPress;

  void _handleBackButton() {
    // If on Proxies tab, go back to Home tab
    if (_currentIndex == 0) {
      setState(() => _currentIndex = 1);
      return;
    }

    // If on Home tab, check for double press to exit
    final now = DateTime.now();
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Double press detected, exit app
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackButton();
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            widget.proxiesScreen, // Index 0
            widget.homeScreen, // Index 1
          ],
        ),
        bottomNavigationBar: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkCard : AppColors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Proxies tab
                  _NavItem(
                    icon: Icons.dns_rounded,
                    label: context.l10n.proxies,
                    isSelected: _currentIndex == 0,
                    onTap: () => setState(() => _currentIndex = 0),
                  ),
                  // Home tab
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: context.l10n.home,
                    isSelected: _currentIndex == 1,
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                ],
              ),
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
    final unselectedColor =
        isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        splashColor: AppColors.accent.withValues(alpha: 0.2),
        highlightColor: AppColors.accent.withValues(alpha: 0.1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.fastOutSlowIn,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: AppColors.connectedGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.greenGlow.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: Icon(
                  icon,
                  key: ValueKey(isSelected),
                  color: isSelected ? AppColors.white : unselectedColor,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 8.w),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                style: TextStyle(
                  color: isSelected ? AppColors.white : unselectedColor,
                  fontSize: 14.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
