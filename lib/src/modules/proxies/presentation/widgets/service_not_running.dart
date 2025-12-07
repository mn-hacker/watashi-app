import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watashi/src/l10n/l10n.dart';
import 'package:watashi/src/shared/constants/app_colors.dart';

class ServiceNotRunningWidget extends StatelessWidget {
  const ServiceNotRunningWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.power_off,
            size: 80.sp,
            color:
                isDarkMode ? AppColors.grey.shade600 : AppColors.grey.shade400,
          ),
          SizedBox(height: 24.h),
          Text(
            context.l10n.serviceNotRunning,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: isDarkMode
                  ? AppColors.grey.shade400
                  : AppColors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Text(
            context.l10n.connectToViewProxies,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDarkMode
                  ? AppColors.grey.shade500
                  : AppColors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
