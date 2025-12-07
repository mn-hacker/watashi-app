import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watashi/src/l10n/l10n.dart';
import 'package:watashi/src/modules/connection_config/presentation/add_connection_config_modal_widget.dart';
import 'package:watashi/src/modules/connection_config/presentation/widgets/connection_config_input_controller.dart';
import 'package:watashi/src/modules/connection_config/presentation/qr_scanner_screen.dart';
import 'package:watashi/src/shared/constants/app_colors.dart';

/// Shows the add config bottom sheet with options
Future<void> showAddConfigBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => const AddConfigBottomSheet(),
  );
}

class AddConfigBottomSheet extends ConsumerWidget {
  const AddConfigBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
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
                      onTap: () => _onAddFromClipboard(context, ref),
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
        ),
      ),
    );
  }

  void _onScanQRCode(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );
  }

  Future<void> _onAddFromClipboard(BuildContext context, WidgetRef ref) async {
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
      final controller = ref.read(connectionConfigControllerProvider.notifier);

      try {
        controller.updateInput(configText);
        Navigator.of(context).pop();
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(l10n.configAddedSuccess)),
        );
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(l10n.noConfigInClipboard)),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(l10n.clipboardEmpty)),
      );
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkCard : AppColors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color:
                isDarkMode ? AppColors.grey.shade700 : AppColors.grey.shade300,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 40.sp,
              color: isDarkMode ? AppColors.accent : AppColors.accent,
            ),
            SizedBox(height: 12.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? AppColors.white : AppColors.black,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkCard : AppColors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color:
                isDarkMode ? AppColors.grey.shade700 : AppColors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24.sp,
              color: isDarkMode ? AppColors.accent : AppColors.accent,
            ),
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? AppColors.white : AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
