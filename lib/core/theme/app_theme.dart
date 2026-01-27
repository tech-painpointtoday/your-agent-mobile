import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // ColorScheme
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.baseWhite,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        onSecondary: AppColors.baseWhite,
        error: AppColors.error,
        onError: AppColors.baseWhite,
        surface: AppColors.baseWhite,
        onSurface: AppColors.baseBlack,
        onSurfaceVariant: AppColors.baseDarkGrey,
        outline: AppColors.baseLightGrey,
        background: AppColors.baseWhite,
        onBackground: AppColors.baseBlack,
      ),
      
      scaffoldBackgroundColor: AppColors.baseWhite,
      
      // Typography
      textTheme: _buildTextTheme(),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.baseWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.baseLightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.baseLightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.baseLightGrey),
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.baseWhite,
          disabledBackgroundColor: AppColors.basePaleGrey,
          disabledForegroundColor: AppColors.baseGrey,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.baseBlack,
          disabledForegroundColor: AppColors.baseGrey,
          side: const BorderSide(color: AppColors.baseLightGrey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.baseGrey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      
      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return null;
          },
        ),
        checkColor: WidgetStateProperty.all(AppColors.baseWhite),
        side: const BorderSide(color: AppColors.baseLightGrey),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
      ),
      
      // Dropdown Menu Theme
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(AppColors.baseWhite),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.baseWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.baseWhite,
        foregroundColor: AppColors.baseBlack,
        elevation: 0,
        centerTitle: false,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.baseLightGrey,
        thickness: 1,
        space: 1,
      ),
    );
  }
  
  static TextTheme _buildTextTheme() {
    // Try to use GoogleFonts.anuphan, fallback to default if not available
    final baseTextStyle = _getAnuphanFont();
    
    return TextTheme(
      displayLarge: baseTextStyle.copyWith(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: AppColors.baseBlack,
      ),
      displayMedium: baseTextStyle.copyWith(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: AppColors.baseBlack,
      ),
      displaySmall: baseTextStyle.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: AppColors.baseBlack,
      ),
      headlineLarge: baseTextStyle.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: AppColors.baseBlack,
      ),
      headlineMedium: baseTextStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: AppColors.baseBlack,
      ),
      headlineSmall: baseTextStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: AppColors.baseBlack,
      ),
      titleLarge: baseTextStyle.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: AppColors.baseBlack,
      ),
      titleMedium: baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: AppColors.baseBlack,
      ),
      titleSmall: baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: AppColors.baseBlack,
      ),
      bodyLarge: baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: AppColors.baseBlack,
      ),
      bodyMedium: baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: AppColors.baseBlack,
      ),
      bodySmall: baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: AppColors.baseDarkGrey,
      ),
      labelLarge: baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: AppColors.baseBlack,
      ),
      labelMedium: baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: AppColors.baseDarkGrey,
      ),
      labelSmall: baseTextStyle.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: AppColors.baseDarkGrey,
      ),
    );
  }
  
  static TextStyle _getAnuphanFont() {
    try {
      return GoogleFonts.anuphan();
    } catch (e) {
      // Fallback to default sans-serif if GoogleFonts.anuphan is not available
      return const TextStyle(
        fontFamily: 'sans-serif',
      );
    }
  }
}

