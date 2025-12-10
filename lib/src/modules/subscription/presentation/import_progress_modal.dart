import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watashi/src/shared/constants/app_colors.dart';

/// Modal that shows during subscription import
/// Based on Hiddify's add_profile_modal.dart loading state
class ImportProgressModal extends StatelessWidget {
  final String message;
  final VoidCallback? onCancel;
  final bool isDarkMode;

  const ImportProgressModal({
    super.key,
    this.message = 'در حال افزودن پروفایل',
    this.onCancel,
    this.isDarkMode = true,
  });

  /// Show the modal as a bottom sheet
  static Future<void> show(
    BuildContext context, {
    String message = 'در حال افزودن پروفایل',
    VoidCallback? onCancel,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => ImportProgressModal(
        message: message,
        onCancel: onCancel ?? () => Navigator.of(context).pop(),
        isDarkMode: isDark,
      ),
    );
  }

  /// Dismiss the modal
  static void dismiss(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isDarkMode ? AppColors.darkSurface : AppColors.white;
    final textColor =
        isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: textColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 24.h),

              // Message
              Text(
                message,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),

              // Progress indicator
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: LinearProgressIndicator(
                  backgroundColor: textColor.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ),
              SizedBox(height: 16.h),

              // Cancel button
              TextButton(
                onPressed: onCancel,
                child: Text(
                  'لغو',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.accent,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }
}
