import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/l10n/app_localizations.dart';

class CallOption {
  final String label;
  final String phone;

  CallOption({required this.label, required this.phone});
}

class AppCallBottomSheet extends StatelessWidget {
  final List<CallOption> options;

  const AppCallBottomSheet({super.key, required this.options});

  static Future<void> show({
    required BuildContext context,
    required List<CallOption> options,
  }) {
    if (options.isEmpty) return Future.value();

    // If only one option, maybe just call directly?
    // Re-reading user request: "change ContractCallBottomSheet to be app component widgets"
    // So we keep the bottom sheet behavior.

    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => AppCallBottomSheet(options: options),
    );
  }

  void _makeCall(String phone) {
    if (phone.isEmpty) return;
    final url = Uri.parse(
      'tel:${phone.replaceAll(' ', '').replaceAll('-', '')}',
    );
    launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9EAEB),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...options.map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppButton(
                  width: double.infinity,
                  height: 48,
                  text: option.label.isNotEmpty
                      ? 'โทร ${option.phone} (${option.label})'
                      : 'โทร ${option.phone}',
                  style: AppButtonStyle.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  onPressed: () {
                    Navigator.pop(context);
                    _makeCall(option.phone);
                  },
                ),
              ),
            ),
            AppButton(
              width: double.infinity,
              height: 44,
              text: AppLocalizations.of(context).statusCancelled,
              style: AppButtonStyle.outline,
              textColor: AppColors.supportRedDeep,
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
