import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watashi/src/l10n/l10n.dart';
import 'package:watashi/src/modules/connection_config/presentation/add_connection_config_modal_widget.dart';
import 'package:watashi/src/modules/connection_config/presentation/widgets/connection_config_input_controller.dart';
import 'package:watashi/src/modules/connection_config/presentation/qr_scanner_screen.dart';
import 'package:watashi/src/shared/constants/app_colors.dart';
import 'package:watashi/src/shared/widgets/app_toast.dart';

/// Shows the add config bottom sheet with options
Future<void> showAddConfigBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => const AddConfigBottomSheet(),
  );
}

class AddConfigBottomSheet extends ConsumerStatefulWidget {
  const AddConfigBottomSheet({super.key});

  @override
  ConsumerState<AddConfigBottomSheet> createState() =>
      _AddConfigBottomSheetState();
}

class _AddConfigBottomSheetState extends ConsumerState<AddConfigBottomSheet> {
  bool _isLoading = false;
  String _loadingMessage = '';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: SafeArea(
        child: AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState:
              _isLoading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: _buildLoadingState(isDarkMode, l10n),
          secondChild: _buildButtonsState(isDarkMode, l10n),
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDarkMode, dynamic l10n) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 64.w, vertical: 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Handle bar
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: (isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary)
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            _loadingMessage.isNotEmpty
                ? _loadingMessage
                : 'در حال افزودن پروفایل',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          LinearProgressIndicator(
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
          ),
          SizedBox(height: 12.h),
          TextButton(
            onPressed: () {
              setState(() => _isLoading = false);
            },
            child: Text(
              'لغو',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonsState(bool isDarkMode, dynamic l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle bar
        Container(
          margin: EdgeInsets.only(top: 12.h),
          width: 40.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.darkItemsBackground
                : AppColors.lightGrey,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(height: 20.h),
        // Top row with QR and Clipboard options
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Expanded(
                child: _OptionCard(
                  icon: Icons.qr_code_scanner,
                  label: l10n.scanQRCode,
                  isDarkMode: isDarkMode,
                  onTap: () => _onScanQRCode(context),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _OptionCard(
                  icon: Icons.content_paste,
                  label: l10n.addFromClipboard,
                  isDarkMode: isDarkMode,
                  onTap: () => _onAddFromClipboard(context),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        // Manual add option
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: _OptionButton(
            icon: Icons.add,
            label: l10n.manualAdd,
            isDarkMode: isDarkMode,
            onTap: () => _onManualAdd(context),
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  void _onScanQRCode(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );
  }

  Future<void> _onAddFromClipboard(BuildContext context) async {
    final l10n = context.l10n;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData == null ||
          clipboardData.text == null ||
          clipboardData.text!.isEmpty) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(l10n.clipboardEmpty)),
        );
        return;
      }

      final configText = clipboardData.text!.trim();

      // Show loading state
      setState(() {
        _isLoading = true;
        _loadingMessage = 'Parsing config...';
      });

      // Small delay to show the animation
      await Future.delayed(const Duration(milliseconds: 100));

      final controller = ref.read(connectionConfigControllerProvider.notifier);

      try {
        controller.updateInput(configText);

        if (mounted) {
          Navigator.of(context).pop();
          AppToast.showSuccess(context);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text(l10n.noConfigInClipboard)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(l10n.clipboardEmpty)),
        );
      }
    }
  }

  void _onManualAdd(BuildContext context) {
    Navigator.of(context).pop();
    showConnectionConfigModal(context);
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.label,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color:
              isDarkMode ? AppColors.darkItemsBackground : AppColors.lightGrey,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28.sp,
                color: AppColors.accent,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isDarkMode
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _OptionButton({
    required this.icon,
    required this.label,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color:
              isDarkMode ? AppColors.darkItemsBackground : AppColors.lightGrey,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20.sp,
                color: AppColors.accent,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: isDarkMode
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
