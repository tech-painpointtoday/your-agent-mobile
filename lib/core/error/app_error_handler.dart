import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/widgets/buttons/app_button.dart';

import '../theme/app_colors.dart';
import '../di/dependency_injection.dart';
import '../../widgets/dialogs/status_dialog.dart';
import 'package:youragent/l10n/app_localizations.dart';

class AppErrorHandler {
  static void initialize() {
    // Handle Flutter errors (rendering, etc.)
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      // Example: Log to Crashlytics here
      debugPrint('FlutterError caught: ${details.exception}');
    };

    // Handle asynchronous errors (Streams, Futures)
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('PlatformDispatcher error caught: $error');

      final context = navigatorKey.currentContext;
      if (context != null) {
        final message = error.toString();
        StatusDialog.showErrorDialog(
          context: context,
          title: AppLocalizations.of(context).errorOccurredTitle,
          message: message.isNotEmpty
              ? message
              : AppLocalizations.of(context).unexpectedErrorTryAgain,
        );
      }

      return true; // Return true to indicate duplication is handled.
    };

    // Customize the "Red Screen of Death"
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return _FriendlyErrorWidget(details: details);
    };
  }
}

class _FriendlyErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;

  const _FriendlyErrorWidget({required this.details});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.supportBlueLight, // Friendly blue background
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sentiment_dissatisfied_rounded,
                    size: 80,
                    color: AppColors.brandBlue,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Oops! Something went wrong.',
                    style: GoogleFonts.anuphan(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandDarkBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'We encountered an unexpected error. Please try restarting the app or contact support if the issue persists.',
                    style: GoogleFonts.anuphan(
                      fontSize: 16,
                      color: AppColors.brandBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Expandable details for developers
                  ExpansionTile(
                    title: Text(
                      'Technical Details',
                      style: GoogleFonts.anuphan(
                        fontSize: 14,
                        color: AppColors.brandDarkBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.baseWhite,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.baseLightGrey),
                        ),
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: SingleChildScrollView(
                          child: Text(
                            details.toString(),
                            style: GoogleFonts.robotoMono(
                              fontSize: 12,
                              color: AppColors.baseDarkGrey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      text: 'Back',
                      style: AppButtonStyle.outline,
                      onPressed: () {
                        context.pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
