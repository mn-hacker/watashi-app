import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:watashi/src/modules/connection_config/presentation/add_config_bottom_sheet.dart';
import 'package:watashi/src/modules/profile/data/profile_repo.dart';
import 'package:watashi/src/modules/profile/domain/profile_entity.dart';
import 'package:watashi/src/shared/constants/app_colors.dart';

/// Show profiles overview bottom sheet
void showProfilesOverview(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const ProfilesOverviewSheet(),
  );
}

class ProfilesOverviewSheet extends ConsumerWidget {
  const ProfilesOverviewSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileRepo = ref.watch(profileRepoProvider);
    final profiles = profileRepo.profiles;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(maxHeight: 0.75.sh),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 16.h),

          // Profile list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: profiles.length,
              itemBuilder: (context, index) {
                final profile = profiles[index];
                return _ProfileListItem(
                  profile: profile,
                  isDarkMode: isDarkMode,
                  onTap: () {
                    profileRepo.setActiveProfile(profile.id);
                    Navigator.pop(context);
                  },
                  onMenuTap: () =>
                      _showProfileMenu(context, ref, profile, isDarkMode),
                );
              },
            ),
          ),

          // Bottom action buttons
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Row with Add and Sort buttons
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.add_rounded,
                        label: 'پروفایل جدید',
                        isDarkMode: isDarkMode,
                        onTap: () {
                          Navigator.pop(context);
                          showAddConfigBottomSheet(context);
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.swap_vert_rounded,
                        label: 'مرتب‌سازی',
                        isDarkMode: isDarkMode,
                        onTap: () {
                          // TODO: Sort profiles
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                // Update all button
                SizedBox(
                  width: double.infinity,
                  child: _ActionButton(
                    icon: Icons.refresh_rounded,
                    label: 'بروزرسانی اشتراک‌ها',
                    isDarkMode: isDarkMode,
                    onTap: () => _updateAllProfiles(context, ref),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  void _showProfileMenu(BuildContext context, WidgetRef ref,
      ProfileEntity profile, bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? AppColors.darkCard : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // بروزرسانی
              _MenuItemTile(
                icon: Icons.refresh_rounded,
                title: 'بروزرسانی',
                isDarkMode: isDarkMode,
                onTap: () {
                  Navigator.pop(context);
                  ref.read(profileRepoProvider).updateProfile(profile.id);
                },
              ),
              // اشتراک‌گذاری (with submenu arrow)
              _MenuItemTile(
                icon: Icons.share_rounded,
                title: 'اشتراک‌گذاری',
                isDarkMode: isDarkMode,
                hasSubmenu: true,
                onTap: () {
                  Navigator.pop(context);
                  _showShareMenu(context, profile, isDarkMode);
                },
              ),
              // ویرایش
              _MenuItemTile(
                icon: Icons.edit_rounded,
                title: 'ویرایش',
                isDarkMode: isDarkMode,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Edit profile
                },
              ),
              // حذف
              _MenuItemTile(
                icon: Icons.delete_rounded,
                title: 'حذف',
                isDarkMode: isDarkMode,
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, ref, profile, isDarkMode);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showShareMenu(
      BuildContext context, ProfileEntity profile, bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? AppColors.darkCard : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // صادر کردن لینک اشتراک به کلیپ‌بورد
              _MenuItemTile(
                icon: Icons.copy_rounded,
                title: 'صادر کردن لینک اشتراک به کلیپ‌بورد',
                isDarkMode: isDarkMode,
                onTap: () {
                  Navigator.pop(ctx);
                  Clipboard.setData(ClipboardData(text: profile.url));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('لینک اشتراک کپی شد')),
                  );
                },
              ),
              // کد QR لینک اشتراک
              _MenuItemTile(
                icon: Icons.qr_code_rounded,
                title: 'کد QR لینک اشتراک',
                isDarkMode: isDarkMode,
                onTap: () {
                  Navigator.pop(ctx);
                  _showQRCodeDialog(context, profile, isDarkMode);
                },
              ),
              // افزودن پیکربندی به کلیپ‌بورد
              _MenuItemTile(
                icon: Icons.content_copy_rounded,
                title: 'افزودن پیکربندی به کلیپ‌بورد',
                isDarkMode: isDarkMode,
                onTap: () {
                  Navigator.pop(ctx);
                  // Copy profile URL (configs are fetched from this URL)
                  Clipboard.setData(ClipboardData(text: profile.url));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('پیکربندی کپی شد')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQRCodeDialog(
      BuildContext context, ProfileEntity profile, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.darkCard : AppColors.white,
        contentPadding: EdgeInsets.all(20.w),
        title: Text(
          profile.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDarkMode ? AppColors.white : AppColors.textPrimary,
            fontSize: 16.sp,
          ),
        ),
        content: SizedBox(
          width: 250.w,
          height: 250.w,
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: QrImageView(
              data: profile.url,
              version: QrVersions.auto,
              size: 220.w,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.black,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بستن'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Clipboard.setData(ClipboardData(text: profile.url));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('لینک کپی شد')),
              );
            },
            child: const Text('کپی لینک'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref,
      ProfileEntity profile, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.darkCard : AppColors.white,
        title: Text(
          'حذف پروفایل؟',
          style: TextStyle(
              color: isDarkMode ? AppColors.white : AppColors.textPrimary),
        ),
        content: Text(
          'آیا از حذف ${profile.name} مطمئن هستید؟',
          style: TextStyle(
              color: isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(profileRepoProvider).deleteProfile(profile.id);
            },
            child: Text('حذف', style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );
  }

  void _updateAllProfiles(BuildContext context, WidgetRef ref) {
    final profileRepo = ref.read(profileRepoProvider);
    for (final profile in profileRepo.profiles) {
      profileRepo.updateProfile(profile.id);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('در حال بروزرسانی...')),
    );
  }
}

/// Single profile item in list
class _ProfileListItem extends StatelessWidget {
  const _ProfileListItem({
    required this.profile,
    required this.isDarkMode,
    required this.onTap,
    required this.onMenuTap,
  });

  final ProfileEntity profile;
  final bool isDarkMode;
  final VoidCallback onTap;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isDarkMode
            ? (profile.active ? AppColors.darkSurface : Colors.transparent)
            : (profile.active ? AppColors.lightGrey : Colors.transparent),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: profile.active
              ? AppColors.accent.withOpacity(0.5)
              : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              // Profile info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode
                            ? AppColors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (profile.subInfo != null) ...[
                      SizedBox(height: 8.h),
                      // Progress bar
                      _ProgressBar(ratio: profile.subInfo!.ratio),
                      SizedBox(height: 6.h),
                      // Usage and days
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatTraffic(profile.subInfo!),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: isDarkMode
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            _formatDays(profile.subInfo!),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: profile.subInfo!.isExpired
                                  ? Colors.red
                                  : (isDarkMode
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Menu button
              IconButton(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
                onPressed: onMenuTap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTraffic(SubscriptionInfo info) {
    if (info.isUnlimitedTraffic) return '∞';
    final consumedGB = info.consumption / (1024 * 1024 * 1024);
    final totalGB = info.total / (1024 * 1024 * 1024);
    return '${consumedGB.toStringAsFixed(2)}GiB / ${totalGB.toStringAsFixed(0)}GiB';
  }

  String _formatDays(SubscriptionInfo info) {
    if (info.isExpired) return 'منقضی شده';
    if (info.isUnlimitedTime) return '∞ روز باقی مانده';
    return '${info.daysRemaining} روز باقی مانده';
  }
}

/// Progress bar widget
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.ratio});

  final double ratio;

  @override
  Widget build(BuildContext context) {
    Color startColor;
    Color endColor;

    if (ratio < 0.25) {
      startColor = const Color(0xFF5DCDFB);
      endColor = const Color(0xFF3192F8);
    } else if (ratio < 0.65) {
      startColor = const Color(0xFFCDC740);
      endColor = const Color(0xFF627320);
    } else {
      startColor = const Color(0xFFF15251);
      endColor = const Color(0xFF8B1E24);
    }

    return Container(
      height: 5.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(3.r),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: ratio.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [startColor, endColor]),
            borderRadius: BorderRadius.circular(3.r),
          ),
        ),
      ),
    );
  }
}

/// Action button at bottom
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isDarkMode,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isDarkMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDarkMode
          ? AppColors.darkSurface.withOpacity(0.5)
          : AppColors.lightGrey,
      borderRadius: BorderRadius.circular(30.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20.sp,
                color: isDarkMode ? AppColors.white : AppColors.textPrimary,
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Menu item tile for profile actions (RTL layout)
class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({
    required this.icon,
    required this.title,
    required this.isDarkMode,
    required this.onTap,
    this.hasSubmenu = false,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final bool isDarkMode;
  final VoidCallback onTap;
  final bool hasSubmenu;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final textColor = isDestructive
        ? Colors.red.shade400
        : (isDarkMode ? AppColors.white : AppColors.textPrimary);
    final iconColor = isDestructive
        ? Colors.red.shade400
        : (isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        child: Row(
          children: [
            // Submenu arrow (left side for RTL)
            if (hasSubmenu)
              Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 20.sp,
                  color: iconColor,
                ),
              ),
            // Spacer
            const Spacer(),
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            SizedBox(width: 12.w),
            // Icon (right side for RTL)
            Icon(
              icon,
              size: 22.sp,
              color: iconColor,
            ),
          ],
        ),
      ),
    );
  }
}
