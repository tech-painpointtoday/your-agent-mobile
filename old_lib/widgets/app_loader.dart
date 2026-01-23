import 'package:flutter/material.dart';

/// Global loading spinner that always uses the app's primary color.
///
/// Use this instead of raw `CircularProgressIndicator` for consistency.
class AppLoader extends StatelessWidget {
  final double strokeWidth;

  const AppLoader({super.key, this.strokeWidth = 4});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Center(
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
      ),
    );
  }
}
