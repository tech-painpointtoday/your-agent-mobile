import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.buttonPrimary, // #1743C7
        primary: AppColors.buttonPrimary, // #1743C7
        secondary: AppColors.alizarinCrimson,
        error: AppColors.alizarinCrimson,
        surface: AppColors.white,
        onSurface: AppColors.baseDarkGrey,
      ),
      scaffoldBackgroundColor: AppColors.wildSand,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: _NoTransitionPageTransitionsBuilder(),
          TargetPlatform.iOS: _NoTransitionPageTransitionsBuilder(),
          TargetPlatform.macOS: _NoTransitionPageTransitionsBuilder(),
          TargetPlatform.linux: _NoTransitionPageTransitionsBuilder(),
          TargetPlatform.windows: _NoTransitionPageTransitionsBuilder(),
        },
      ),
      // Make modal bottom sheets (like the voice assistant) use full screen width,
      // instead of the default 640px max constraint on large screens.
      bottomSheetTheme: const BottomSheetThemeData(
        constraints: BoxConstraints(maxWidth: double.infinity),
      ),
      textTheme: _textTheme,
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.buttonPrimary,
          backgroundColor: AppColors.buttonContainerOutlinedDefault,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          side: const BorderSide(
            color: AppColors.buttonStrokeOutlinedRdDefault,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        hintStyle: const TextStyle(color: AppColors.baseGrey),
        labelStyle: const TextStyle(color: AppColors.baseGrey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.baseGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.baseGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.baseGrey),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.buttonPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  static TextTheme get _textTheme {
    // Helper function to create TextStyle with Anuphan font
    TextStyle anuphan({
      required double fontSize,
      required double height,
      FontWeight fontWeight = FontWeight.w400,
      Color? color,
      double? letterSpacing,
    }) {
      return TextStyle(
        fontFamily: 'Anuphan',
        fontSize: fontSize,
        height: height,
        fontWeight: fontWeight,
        color: color ?? AppColors.baseDarkGrey,
        letterSpacing: letterSpacing,
      );
    }

    return TextTheme(
      // Display xl: 60px / 3.75rem | Line height: 72px / 4.5rem | Letter spacing: -2%
      displayLarge: anuphan(
        fontSize: 60,
        height: 72 / 60, // 1.2
        letterSpacing: -0.02 * 60, // -2% of fontSize = -1.2
        fontWeight: FontWeight.w400,
      ),
      // Display lg: 48px / 3rem | Line height: 60px / 3.75rem | Letter spacing: -2%
      displayMedium: anuphan(
        fontSize: 48,
        height: 60 / 48, // 1.25
        letterSpacing: -0.02 * 48, // -2% of fontSize = -0.96
        fontWeight: FontWeight.w400,
      ),
      // Display md: 36px / 2.25rem | Line height: 44px / 2.75rem | Letter spacing: -2%
      displaySmall: anuphan(
        fontSize: 36,
        height: 44 / 36, // 1.222
        letterSpacing: -0.02 * 36, // -2% of fontSize = -0.72
        fontWeight: FontWeight.w400,
      ),
      // Display sm: 30px / 1.875rem | Line height: 38px / 2.375rem
      headlineLarge: anuphan(
        fontSize: 30,
        height: 38 / 30, // 1.267
        fontWeight: FontWeight.w400,
      ),
      // Display xs: 24px / 1.5rem | Line height: 32px / 2rem | Medium weight
      headlineMedium: anuphan(
        fontSize: 24,
        height: 32 / 24, // 1.333
        fontWeight: FontWeight.w500, // Medium for Display xs
      ),
      // Body xl: 20px / 1.25rem | Line height: 30px / 1.875rem
      headlineSmall: anuphan(
        fontSize: 20,
        height: 30 / 20, // 1.5
        fontWeight: FontWeight.w400,
      ),
      // Body lg: 18px / 1.125rem | Line height: 28px / 1.75rem | Medium weight
      titleLarge: anuphan(
        fontSize: 18,
        height: 28 / 18, // 1.556 (155.556%)
        fontWeight: FontWeight.w500, // Medium
        letterSpacing: 0,
      ),
      // Body md: 16px / 1rem | Line height: 24px / 1.5rem
      titleMedium: anuphan(
        fontSize: 16,
        height: 24 / 16, // 1.5
        fontWeight: FontWeight.w500,
      ),
      // Body sm: 14px / 0.875rem | Line height: 20px / 1.25rem
      titleSmall: anuphan(
        fontSize: 14,
        height: 20 / 14, // 1.429
        fontWeight: FontWeight.w500,
      ),
      // Body md: 16px / 1rem | Line height: 24px / 1.5rem | Regular weight
      bodyLarge: anuphan(
        fontSize: 16,
        height: 24 / 16, // 1.5 (150%)
        fontWeight: FontWeight.w400, // Regular
        letterSpacing: 0,
      ),
      // Body sm: 14px / 0.875rem | Line height: 20px / 1.25rem
      bodyMedium: anuphan(
        fontSize: 14,
        height: 20 / 14, // 1.429
        fontWeight: FontWeight.w400,
      ),
      // Body xs: 12px / 0.75rem | Line height: 18px / 1.125rem | Regular weight
      bodySmall: anuphan(
        fontSize: 12,
        height: 18 / 12, // 1.5 (150%)
        fontWeight: FontWeight.w400, // Regular
        letterSpacing: 0,
      ),
      // Body sm: 14px / 0.875rem | Line height: 20px / 1.25rem
      labelLarge: anuphan(
        fontSize: 14,
        height: 20 / 14, // 1.429
        fontWeight: FontWeight.w500,
      ),
      // Body xs: 12px / 0.75rem | Line height: 18px / 1.125rem
      labelMedium: anuphan(
        fontSize: 12,
        height: 18 / 12, // 1.5
        fontWeight: FontWeight.w500,
      ),
      // Body xs: 12px / 0.75rem | Line height: 18px / 1.125rem
      labelSmall: anuphan(
        fontSize: 12,
        height: 18 / 12, // 1.5
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// Page transition builder that disables all animations (instant transition),
/// to make route changes feel like a normal website.
class _NoTransitionPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoTransitionPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
