import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Success toast notification service
/// Based on Hiddify's in_app_notification_controller
class AppToast {
  static OverlayEntry? _currentToast;

  /// Show success toast with green background and checkmark
  static void showSuccess(
    BuildContext context, {
    String message = 'پروفایل با موفقیت ذخیره شد',
    Duration duration = const Duration(seconds: 3),
  }) {
    _dismissCurrent();

    final overlay = Overlay.of(context);

    _currentToast = OverlayEntry(
      builder: (context) => _SuccessToast(
        message: message,
        onDismiss: _dismissCurrent,
        duration: duration,
      ),
    );

    overlay.insert(_currentToast!);
  }

  /// Show error toast with red background
  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    _dismissCurrent();

    final overlay = Overlay.of(context);

    _currentToast = OverlayEntry(
      builder: (context) => _ErrorToast(
        message: message,
        onDismiss: _dismissCurrent,
        duration: duration,
      ),
    );

    overlay.insert(_currentToast!);
  }

  static void _dismissCurrent() {
    _currentToast?.remove();
    _currentToast = null;
  }
}

class _SuccessToast extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;
  final Duration duration;

  const _SuccessToast({
    required this.message,
    required this.onDismiss,
    required this.duration,
  });

  @override
  State<_SuccessToast> createState() => _SuccessToastState();
}

class _SuccessToastState extends State<_SuccessToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_controller);

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80.h,
      left: 16.w,
      right: 16.w,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {
                _controller.reverse().then((_) => widget.onDismiss());
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50), // Green
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28.w,
                      height: 28.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: const Color(0xFF4CAF50),
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorToast extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;
  final Duration duration;

  const _ErrorToast({
    required this.message,
    required this.onDismiss,
    required this.duration,
  });

  @override
  State<_ErrorToast> createState() => _ErrorToastState();
}

class _ErrorToastState extends State<_ErrorToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_controller);

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80.h,
      left: 16.w,
      right: 16.w,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {
                _controller.reverse().then((_) => widget.onDismiss());
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935), // Red
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
