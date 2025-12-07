import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watashi/src/l10n/l10n.dart';
import 'package:watashi/src/shared/constants/app_colors.dart';

class AutoSelectItem extends StatelessWidget {
  final bool isSelected;
  final String? selectedConfigName;
  final VoidCallback onTap;

  const AutoSelectItem({
    super.key,
    required this.isSelected,
    required this.selectedConfigName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkCard : AppColors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.accent
                : (isDarkMode
                    ? AppColors.grey.shade700
                    : AppColors.grey.shade300),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Selection indicator
            Container(
              width: 4.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    context.l10n.autoSelect,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? AppColors.white : AppColors.black,
                    ),
                  ),
                  if (isSelected && selectedConfigName != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      'URLTest ($selectedConfigName)',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDarkMode
                            ? AppColors.grey.shade400
                            : AppColors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
