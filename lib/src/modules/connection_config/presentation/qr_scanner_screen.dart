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
    final l10n = context.l10n;
    // Calculate scan area size based on screen width
    final scanAreaSize = MediaQuery.of(context).size.width * 0.7;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.scanQRCode),
        backgroundColor: Colors.black,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Builder(
        builder: (context) {
          final topOffset = (MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight -
                  scanAreaSize) /
              2;

          return Stack(
            children: [
              // Camera preview - full screen
              Positioned.fill(
                child: MobileScanner(
                  controller: _scannerController,
                  onDetect: (capture) => _onDetect(capture, context),
                ),
              ),
              // Dark overlay with scan window
              Positioned.fill(
                child: CustomPaint(
                  painter: _ScanOverlayPainter(
                    scanAreaSize: scanAreaSize,
                    topOffset: topOffset,
                  ),
                ),
              ),
              // Scan frame border - exactly centered
              Positioned(
                left: (MediaQuery.of(context).size.width - scanAreaSize) / 2,
                top: topOffset,
                child: Container(
                  width: scanAreaSize,
                  height: scanAreaSize,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.accent, width: 3),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
              // Text below scan area
              Positioned(
                left: 0,
                right: 0,
                top: topOffset + scanAreaSize + 24.h,
                child: Text(
                  l10n.scanQRCode,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          );
        },
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
  final double scanAreaSize;
  final double topOffset;

  _ScanOverlayPainter({required this.scanAreaSize, required this.topOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final scanAreaRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        (size.width - scanAreaSize) / 2,
        topOffset,
        scanAreaSize,
        scanAreaSize,
      ),
      const Radius.circular(16),
    );

    final fullPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final scanPath = Path()..addRRect(scanAreaRect);
    final overlayPath =
        Path.combine(PathOperation.difference, fullPath, scanPath);

    canvas.drawPath(overlayPath, paint);
  }

  @override
  bool shouldRepaint(covariant _ScanOverlayPainter oldDelegate) =>
      oldDelegate.scanAreaSize != scanAreaSize ||
      oldDelegate.topOffset != topOffset;
}
