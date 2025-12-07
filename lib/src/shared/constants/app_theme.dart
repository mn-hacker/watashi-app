// app_theme.dart
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watashi/src/shared/constants/app_colors.dart';

final class AppTheme {
  AppTheme._();

  // Light Theme
  static final lightTheme = ThemeData.light(
    useMaterial3: true,
  ).copyWith(
    scaffoldBackgroundColor: AppColors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.black,
      elevation: 0,
    ),
    cardColor: AppColors.white,
    dialogBackgroundColor: AppColors.white,
  );

  // Dark Theme
  static final darkTheme = ThemeData.dark(
    useMaterial3: true,
  ).copyWith(
    scaffoldBackgroundColor: AppColors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.white,
      elevation: 0,
    ),
    cardColor: AppColors.darkCard,
    dialogBackgroundColor: AppColors.darkSurface,
  );

  // Deprecated - kept for backward compatibility, use lightTheme instead
  static final appTheme = lightTheme;

  static const lightSystemOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: AppColors.transparent,
    systemNavigationBarColor: AppColors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.dark,
  );

  static const darkSystemOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: AppColors.transparent,
    systemNavigationBarColor: AppColors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.light,
  );

  static final windowsWrapperButtonColors = WindowButtonColors(
    iconNormal: AppColors.white,
    mouseOver: AppColors.white.withValues(alpha: 0.1),
    mouseDown: AppColors.white.withValues(alpha: 0.54),
    iconMouseOver: AppColors.white.withValues(alpha: 0.5),
    iconMouseDown: AppColors.white.withValues(alpha: 0.5),
  );

  static final windowsWrapperCloseButtonColors = WindowButtonColors(
    mouseOver: AppColors.windowCloseHover,
    mouseDown: AppColors.windowClosePress,
    iconNormal: AppColors.white,
    iconMouseOver: AppColors.white,
  );
}
