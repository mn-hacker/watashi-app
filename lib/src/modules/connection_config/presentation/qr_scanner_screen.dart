import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:watashi/src/l10n/l10n.dart';
import 'package:watashi/src/modules/connection_config/presentation/widgets/connection_config_input_controller.dart';
import 'package:watashi/src/shared/constants/app_colors.dart';

class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.white,
      appBar: AppBar(
        title: Text(l10n.scanQRCode),
        backgroundColor: isDarkMode ? AppColors.darkSurface : AppColors.white,
        foregroundColor: isDarkMode ? AppColors.white : AppColors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) => _onDetect(capture, context),
          ),
          // Overlay with scanning frame
          _buildScanOverlay(context),
        ],
      ),
    );
  }

  Widget _buildScanOverlay(BuildContext context) {
    return CustomPaint(
      painter: _ScanOverlayPainter(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 250.w,
              height: 250.w,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.accent, width: 2),
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              context.l10n.scanQRCode,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDetect(BarcodeCapture capture, BuildContext context) {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final scannedValue = barcodes.first.rawValue;
    if (scannedValue == null || scannedValue.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    _processScannedData(scannedValue, context);
  }

  void _processScannedData(String data, BuildContext context) {
    final l10n = context.l10n;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final controller = ref.read(connectionConfigControllerProvider.notifier);
      controller.updateInput(data);

      navigator.pop();
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(l10n.configAddedSuccess)),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(l10n.invalidQRCode)),
      );
      setState(() {
        _isProcessing = false;
      });
    }
  }
}

class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final scanAreaSize = 250.0;
    final scanAreaRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: scanAreaSize,
        height: scanAreaSize,
      ),
      const Radius.circular(20),
    );

    final fullPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final scanPath = Path()..addRRect(scanAreaRect);
    final overlayPath =
        Path.combine(PathOperation.difference, fullPath, scanPath);

    canvas.drawPath(overlayPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
