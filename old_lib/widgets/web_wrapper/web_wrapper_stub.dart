import 'package:flutter/material.dart';

/// Stub for the web-only renderButton method.
Widget renderButton({dynamic configuration}) {
  throw StateError('This should only be called on web');
}

/// Stubs for GSI classes/enums to allow compilation on mobile.
class GSIButtonConfiguration {
  final GSIButtonType? type;
  final GSIButtonTheme? theme;
  final GSIButtonSize? size;
  final GSIButtonText? text;
  final GSIButtonShape? shape;
  final GSIButtonLogoAlignment? logoAlignment;

  GSIButtonConfiguration({this.type, this.theme, this.size, this.text, this.shape, this.logoAlignment});
}

enum GSIButtonType { standard, icon }

enum GSIButtonTheme { outline, filledBlue, filledBlack }

enum GSIButtonSize { large, medium, small }

enum GSIButtonText { signinWith, signupWith, continueWith, signin }

enum GSIButtonShape { rectangular, pill, circle, square }

enum GSIButtonLogoAlignment { left, center }
