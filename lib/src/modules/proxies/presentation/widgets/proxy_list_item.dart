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

    return InkWell(
      onTap: onTap,
      onLongPress: onEdit, // Open config editor on long-press
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkCard : AppColors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isActive
                ? AppColors.accent
                : (isDarkMode
                    ? AppColors.grey.shade700
                    : AppColors.grey.shade300),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Ping indicator
            SizedBox(
              width: 50.w,
              child: ping != null && ping > 0
                  ? Text(
                      '$ping',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: pingColor,
                      ),
                    )
                  : Icon(
                      ping == -1 ? Icons.close : Icons.hourglass_empty,
                      size: 16.sp,
                      color: ping == -1 ? Colors.red : AppColors.grey,
                    ),
            ),
            // Selection indicator
            Container(
              width: 4.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: isActive ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    config.configName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? AppColors.white : AppColors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    config.protocolType,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDarkMode
                          ? AppColors.grey.shade400
                          : AppColors.grey.shade600,
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
    if (ping == null || ping <= 0) return AppColors.grey;
    if (ping < 200) return Colors.green;
    if (ping < 400) return Colors.orange;
    return Colors.red;
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
