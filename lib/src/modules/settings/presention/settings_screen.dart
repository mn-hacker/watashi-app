import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:watashi/src/l10n/l10n.dart';
import 'package:watashi/src/shared/constants/app_colors.dart';
import 'package:watashi/src/shared/presentation/routing/app_router.dart';

/// Full settings screen accessible from hamburger menu
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.goNamed(mainScreenName);
      },
      child: Scaffold(
        backgroundColor:
            isDarkMode ? AppColors.darkBackground : AppColors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: isDarkMode ? AppColors.white : AppColors.textPrimary,
            ),
            onPressed: () => context.goNamed(mainScreenName),
          ),
          title: Text(
            context.l10n.settings,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? AppColors.white : AppColors.textPrimary,
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Placeholder content
                _buildSectionTitle(context, 'General', isDarkMode),
                SizedBox(height: 16.h),
                _buildEmptyCard(context, isDarkMode),

                SizedBox(height: 32.h),
                _buildSectionTitle(context, 'Network', isDarkMode),
                SizedBox(height: 16.h),
                _buildEmptyCard(context, isDarkMode),

                SizedBox(height: 32.h),
                _buildSectionTitle(context, 'Advanced', isDarkMode),
                SizedBox(height: 16.h),
                _buildEmptyCard(context, isDarkMode),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
      BuildContext context, String title, bool isDarkMode) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color:
            isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.darkCard
            : AppColors.lightGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: Text(
          'Coming soon...',
          style: TextStyle(
            fontSize: 14.sp,
            color: isDarkMode
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
