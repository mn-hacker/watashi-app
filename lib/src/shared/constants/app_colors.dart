import 'package:flutter/material.dart';

final class AppColors {
  AppColors._();

  static const transparent = Color(0x00000000);

  // ========== Modern VPN Color Palette ==========

  // Primary gradient colors (Teal/Cyan inspired by Surfshark)
  static const accent = Color(0xFF00D4AA); // Modern teal
  static const accentLight = Color(0xFF00F5C4); // Lighter teal
  static const accentDark = Color(0xFF00B894); // Darker teal
  static const secondary = Color(0xFF6C5CE7); // Purple accent
  static const secondaryLight = Color(0xFFA29BFE); // Light purple

  // Gradient definitions
  static const List<Color> primaryGradient = [
    Color(0xFF00D4AA),
    Color(0xFF00B4D8),
  ];

  static const List<Color> connectedGradient = [
    Color(0xFF00D4AA),
    Color(0xFF00F5C4),
  ];

  static const List<Color> disconnectedGradient = [
    Color(0xFF636E72),
    Color(0xFF2D3436),
  ];

  // Status colors
  static const green = Color(0xFF00D4AA);
  static const greenGlow = Color(0x4000D4AA); // 25% opacity for glow
  static const greenShadow = Color(0x2000D4AA);
  static const red = Color(0xFFFF6B6B);
  static const redGlow = Color(0x40FF6B6B);
  static const yellow = Color(0xFFFFD93D);
  static const orange = Color(0xFFFFA502);

  // Neutral colors
  static const white = Colors.white;
  static const black = Color(0xFF1A1A2E); // Soft black
  static const black54 = Color(0x8A1A1A2E);
  static const black87 = Color(0xDE1A1A2E);
  static const grey = Colors.grey;
  static const lightGrey = Color(0xFFF1F3F4);
  static const itemsBackground = Color(0xFFF8F9FA);

  // Text colors
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFF9CA3AF);

  // Legacy support
  static const pink = Color(0xFFE84393);
  static const boltDefault = Color(0xFFB2BEC3);
  static const pingGreen = Color(0xFF00D4AA);
  static const activeTimeLabel = Color(0xFF6B7280);
  static const activeTimeValue = Color(0xFF374151);

  // Window button colors
  static const windowCloseHover = Color(0xFFFF6B6B);
  static const windowClosePress = Color(0xFFEE5A5A);
  static const backgroundDark = Color(0x80364155);

  // ========== Dark Theme Colors ==========
  static const darkBackground = Color(0xFF0D1117); // GitHub dark
  static const darkSurface = Color(0xFF161B22);
  static const darkCard = Color(0xFF21262D);
  static const darkItemsBackground = Color(0xFF30363D);
  static const darkGreenShadow = Color(0x2000D4AA);
  static const darkActiveTimeLabel = Color(0xFF8B949E);
  static const darkActiveTimeValue = Color(0xFFE6EDF3);
  static const darkTextPrimary = Color(0xFFE6EDF3);
  static const darkTextSecondary = Color(0xFF8B949E);
}
