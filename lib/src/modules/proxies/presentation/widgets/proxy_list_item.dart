import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watashi/src/modules/connection_config/domain/connection_config_model.dart';
import 'package:watashi/src/shared/constants/app_colors.dart';

class ProxyListItem extends StatelessWidget {
  final ConnectionConfigModel config;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ProxyListItem({
    super.key,
    required this.config,
    required this.isActive,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final ping = config.ping;
    final pingColor = _getPingColor(ping);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onEdit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border:
              isActive ? Border.all(color: AppColors.accent, width: 2) : null,
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: AppColors.greenGlow,
                blurRadius: 12,
                spreadRadius: 0,
              )
            else
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.2)
                    : Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            // Ping indicator with background
            Container(
              width: 48.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: ping != null && ping > 0
                    ? pingColor.withOpacity(0.12)
                    : (isDarkMode
                        ? AppColors.darkItemsBackground
                        : AppColors.lightGrey),
                borderRadius: BorderRadius.circular(8.r),
              ),
              alignment: Alignment.center,
              child: ping != null && ping > 0
                  ? Text(
                      '$ping',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: pingColor,
                      ),
                    )
                  : Icon(
                      ping == -1 ? Icons.close_rounded : Icons.schedule_rounded,
                      size: 18.sp,
                      color: ping == -1 ? AppColors.red : AppColors.textMuted,
                    ),
            ),
            SizedBox(width: 14.w),
            // Selection indicator
            Container(
              width: 4.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: isActive ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    config.configName,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    config.protocolType.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPingColor(int? ping) {
    if (ping == null || ping <= 0) return AppColors.textMuted;
    if (ping < 150) return AppColors.green;
    if (ping < 300) return AppColors.orange;
    return AppColors.red;
  }

  void _showOptionsMenu(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? AppColors.darkSurface : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.grey.shade600
                    : AppColors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: Icon(Icons.edit, color: AppColors.accent),
              title: Text(
                'Edit',
                style: TextStyle(
                  color: isDarkMode ? AppColors.white : AppColors.black,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context);
              },
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Config'),
        content:
            Text('Are you sure you want to delete "${config.configName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
