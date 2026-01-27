import 'package:flutter/material.dart';

class AppColors {
  // ==========================================
  // 1. Core Styles (Direct from Figma :root)
  // ==========================================

  // Base colors
  static const baseWhite = Color(0xFFFFFFFF);
  static const baseOffWhite = Color(0xFFFAFAFA);
  static const basePaleGrey = Color(0xFFF5F5F5);
  static const baseLightGrey = Color(0xFFE9EAEB);
  static const baseGrey = Color(0xFFA4A7AE);
  static const baseDarkGrey = Color(0xFF717680);
  static const baseBlack = Color(0xFF181D27);

  // Brand colors
  static const brandBlue = Color(0xFF1743C7);
  static const brandDarkBlue = Color(0xFF0028A2);
  static const brandGreen = Color(0xFF32A792);
  static const brandLightGreen = Color(0xFFEAFAF7);

  // Support colors
  static const supportRedDeep = Color(0xFFD61204);
  static const supportRedDark = Color(0xFFF04437);
  static const supportRedLight = Color(0xFFFFECEC);
  static const supportGreenDark = Color(0xFF3FBE59);
  static const supportGreenLight = Color(0xFFE8FCEC);
  static const supportOrangeDark = Color(0xFFFA7C2E);
  static const supportOrangeLight = Color(0xFFFFF6E8);
  static const supportBlueDeep = Color(0xFF175CD3);
  static const supportBlueDark = Color(0xFF2E90FA);
  static const supportBlueLight = Color(0xFFEFF8FF);

  // ==========================================
  // 2. Primary & Semantic Aliases (เรียกใช้ใน App)
  // ==========================================

  // Primary Mapping (ตามที่คุณต้องการ)
  static const primary = brandBlue; // #1743C7
  static const primaryHover = brandDarkBlue; // #0028A2
  static const primaryLight = supportBlueLight;

  // Secondary / Alternative
  static const secondary = brandGreen;
  static const secondaryLight = brandLightGreen;

  // Gray Aliases (เพื่อให้ Code เดิมไม่พัง) - All mapped to base colors
  // static const basePaleGrey = baseOffWhite;
  // static const basePaleGrey = basePaleGrey;
  // static const baseLightGrey = baseLightGrey;
  // static const baseLightGrey = baseLightGrey; // Map to baseLightGrey
  // static const baseGrey = baseGrey;
  // static const baseDarkGrey = baseDarkGrey;
  // static const gray600 = baseDarkGrey; // Map to baseDarkGrey
  // static const baseDarkGrey = baseDarkGrey; // Map to baseDarkGrey
  // static const gray800 = baseBlack; // Map to baseBlack
  // static const baseDarkGrey = baseBlack; // Map to baseBlack
  static const black = baseBlack;
  static const white = baseWhite;

  // Button aliases (for backward compatibility)
  static const buttonPrimary = primary;
  static const buttonSecondary = secondary;
  static const buttonLightGreen = brandLightGreen;
  static const buttonDisabledBg = basePaleGrey;
  static const buttonDisabledText = baseGrey;
  static const disabledBg = basePaleGrey;
  static const disabledText = baseGrey;
  static const jungleGreen = brandGreen;

  // Status Aliases
  static const success = supportGreenDark;
  static const error = supportRedDark;
  static const warning = supportOrangeDark;
  static const info = supportBlueDark;
}
