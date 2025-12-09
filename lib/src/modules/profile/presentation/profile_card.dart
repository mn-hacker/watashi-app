import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watashi/src/modules/profile/data/profile_repo.dart';
import 'package:watashi/src/modules/profile/domain/profile_entity.dart';
import 'package:watashi/src/modules/profile/presentation/profiles_overview_sheet.dart';
import 'package:watashi/src/shared/constants/app_colors.dart';

/// Card showing active profile with subscription info
/// Similar to Hiddify's ProfileTile
class ProfileCard extends ConsumerWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileRepo = ref.watch(profileRepoProvider);
    final activeProfile = profileRepo.activeProfile;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (activeProfile == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDarkMode
              ? AppColors.darkTextSecondary.withOpacity(0.2)
              : AppColors.lightGrey,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left side - Dropdown indicator or refresh
            _buildActionButton(context, ref, activeProfile, isDarkMode),
            // Divider
            VerticalDivider(
              width: 1,
              color: isDarkMode
                  ? AppColors.darkTextSecondary.withOpacity(0.2)
                  : AppColors.lightGrey,
            ),
            // Main content
            Expanded(
              child: InkWell(
                onTap: () => _showProfileSelector(context, ref),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Profile name with dropdown arrow
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              activeProfile.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode
                                    ? AppColors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20.sp,
                            color: isDarkMode
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ],
                      ),
                      // Subscription info if available
                      if (activeProfile.subInfo != null) ...[
                        SizedBox(height: 6.h),
                        _ProgressIndicator(
                          ratio: activeProfile.subInfo!.ratio,
                        ),
                        SizedBox(height: 6.h),
                        _SubscriptionInfoRow(subInfo: activeProfile.subInfo!),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    ProfileEntity profile,
    bool isDarkMode,
  ) {
    final isLoading = ref.watch(profileRepoProvider).isLoading;

    return SizedBox(
      width: 48.w,
      child: InkWell(
        onTap: isLoading
            ? null
            : () {
                ref.read(profileRepoProvider).updateProfile(profile.id);
              },
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          bottomLeft: Radius.circular(16.r),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent,
                  ),
                )
              : Icon(
                  Icons.refresh_rounded,
                  size: 22.sp,
                  color: isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
        ),
      ),
    );
  }

  void _showProfileSelector(BuildContext context, WidgetRef ref) {
    showProfilesOverview(context);
  }
}

/// Progress bar for data usage
class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({required this.ratio});

  final double ratio;

  @override
  Widget build(BuildContext context) {
    // Color based on usage
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
      height: 6.h,
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

/// Row showing data consumption and days remaining
class _SubscriptionInfoRow extends StatelessWidget {
  const _SubscriptionInfoRow({required this.subInfo});

  final SubscriptionInfo subInfo;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Data usage text
        Text(
          _formatTraffic(subInfo),
          style: TextStyle(fontSize: 12.sp, color: textColor),
        ),
        // Days remaining
        Text(
          _formatDaysRemaining(subInfo),
          style: TextStyle(
            fontSize: 12.sp,
            color: subInfo.isExpired ? Colors.red : textColor,
          ),
        ),
      ],
    );
  }

  String _formatTraffic(SubscriptionInfo info) {
    if (info.isUnlimitedTraffic) {
      return '∞';
    }

    final consumedGB = info.consumption / (1024 * 1024 * 1024);
    final totalGB = info.total / (1024 * 1024 * 1024);

    return '${consumedGB.toStringAsFixed(2)}GiB / ${totalGB.toStringAsFixed(0)}GiB';
  }

  String _formatDaysRemaining(SubscriptionInfo info) {
    if (info.isExpired) {
      return 'منقضی شده';
    }
    if (info.isUnlimitedTime) {
      return '∞ روز باقی مانده';
    }
    return '${info.daysRemaining} روز باقی مانده';
  }
}
