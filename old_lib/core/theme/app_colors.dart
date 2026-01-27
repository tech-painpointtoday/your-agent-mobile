import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1743C7);
  static const primaryHover = Color(0xFF0F2E9E);
  static const primaryText = Color(0xFFFFFFFF);
  static const primaryTextHover = Color(0xFFFFFFFF);

  // Base
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);

  // Brand (emerald / ruby / gold)
  static const emerald400 = Color(0xFF70E1CF);
  static const emerald500 = Color(0xFF32A792);
  static const emerald600 = Color(0xFF2DA691);
  static const emerald700 = Color(0xFF058B72);

  static const ruby500 = Color(0xFFE03121);
  static const ruby600 = Color(0xFFBA2C17);

  static const gold500 = Color(0xFFFEC227);

  // Gray scale
  static const gray25 = Color(0xFFFDFDFD);
  static const basePaleGrey = Color(0xFFFAFAFA);
  static const basePaleGrey = Color(0xFFF5F5F5);
  static const baseLightGrey = Color(0xFFE9EAE8);
  static const baseLightGrey = Color(0xFFD5D7DA);
  static const baseGrey = Color(0xFFA4A7AE);
  static const baseDarkGrey = Color(0xFF717680);
  static const baseDarkGrey = Color(0xFF535862);
  static const baseDarkGrey = Color(0xFF414651);
  static const gray800 = Color(0xFF252B37);
  static const baseDarkGrey = Color(0xFF101828);

  static const baseGrey = Color(0xFFE9EAEB);

  // Error Red
  static const supportRedDeep = Color(0xFFD92D20);

  // Warning Orange
  static const warning = Color(0xFFDC6803);

  // Success Green
  static const success600 = Color(0xFF16B364);

  // Success
  static const success400 = Color(0xFF32D583);
  static const success500 = Color(0xFF12B76A);

  // Blue
  static const blue100 = Color(0xFFDBEAFE);
  static const blue600 = Color(0xFF2563EB);

  // Chart Colors - Bar Chart (Property Types)
  static const chartTeal = Color(0xFF00D2C3); // บ้าน (House)
  static const chartPurple = Color(0xFF7C60E0); // บ้านแฝด (Semi-detached)
  static const chartCyan = Color(0xFF1DC7E1); // คอนโด (Condo)
  static const chartOrange = Color(0xFFFFA601); // อื่น ๆ (Others)

  // Chart Colors - Pie Chart (Green scheme for Total Buyers/Renters)
  static const pieGreen1 = Color(0xFF3FA500);
  static const pieGreen2 = Color(0xFF82DD38);
  static const pieGreen3 = Color(0xFFA7E94B);
  static const pieGreen4 = Color(0xFF56C015);

  // Chart Colors - Pie Chart (Blue scheme for Total Buyers)
  static const pieBlue1 = Color(0xFF2A54A1);
  static const pieBlue2 = Color(0xFF34B3E7);
  static const pieBlue3 = Color(0xFF66C6DE);
  static const pieBlue4 = Color(0xFF438AC9);

  // Chart Colors - Pie Chart (Orange scheme for Total Renters)
  static const pieOrange1 = Color(0xFFDA5F4F);
  static const pieOrange2 = Color(0xFFFFA100);
  static const pieOrange3 = Color(0xFFF7C500);
  static const pieOrange4 = Color(0xFFF77231);

  // Button Colors
  static const buttonPrimary = Color(0xFF1743C7); // Blue (#1743C7)
  static const buttonPrimaryHover = Color(0xFF0F2E9E); // Darker blue for hover
  static const buttonSecondary = emerald500; // #32a792
  static const buttonSecondaryHover = Color(
    0xFF2A8B7A,
  ); // Darker green for hover
  static const buttonLightGreen = Color(
    0x297DE1CF,
  ); // #7de1cf29 (with transparency)
  static const buttonBorderGray = Color(0xFFE9E9EB);
  static const buttonDisabledBg = basePaleGrey; // #fafafa
  static const buttonDisabledText = Color(0xFFD5D6D9);
  static const buttonTextDark = Color(0xFF181D27);
  static const buttonGrayHover = Color(0xFFF5F5F5); // Light gray for hover

  // Button Outlined (from design system)
  static const buttonStrokeOutlinedRdDefault = Color(0xFFE9EAEB);
  static const buttonContainerOutlinedDefault = white; // #FFF

  // Divider Colors
  static const dividerLight = Color(0xFFE9EAEB);

  // Card Label Colors
  static const cardLabelPrimary = Color(0xFF181D27);
  static const cardLabelSecondary = baseGrey; // #A4A7AE

  // Avatar Label Colors
  static const avatarLabelPrimary = Color(0xFF181D27);
  static const avatarLabelSecondary = baseDarkGrey; // #717680

  // Base Label Colors
  static const baseLabelSecondary = baseDarkGrey; // #717680

  // Status Badge Colors
  // Pending
  static const statusPendingBg = Color(0xFFFFFAEB);
  static const statusPendingText = Color(0xFFB54708);
  // Confirmed
  static const statusConfirmedBg = Color(0xFFECFDF3);
  static const statusConfirmedText = Color(0xFF027A48);
  // Cancelled
  static const statusCancelledBg = Color(0xFFFEF3F2);
  static const statusCancelledText = Color(0xFFB42318);
  // Status card text colors
  static const statusCardTextActive = baseDarkGrey; // For confirmed status
  static const statusCardTextInactive = Color(
    0xFF717680,
  ); // For pending/cancelled

  // Existing aliases (kept for backward compatibility)
  static const alizarinCrimson = ruby500;
  static const bonJour = Color(0xFFE1E1E1);
  static const crowshead = Color(0xFF1A0F0A);
  static const baseDarkGrey = Color(0xFF1C1C1C);
  static const jungleGreen = emerald500;
  static const shadyLady = Color(0xFFA9A9A9);
  static const wildSand = Color(0xFFF3F3F3);
}
