import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/contract.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class ContractCallBottomSheet extends StatelessWidget {
  final Contract contract;

  const ContractCallBottomSheet({super.key, required this.contract});

  static Future<void> show({
    required BuildContext context,
    required Contract contract,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ContractCallBottomSheet(contract: contract),
    );
  }

  void _makeCall(String? phone) {
    if (phone == null || phone.isEmpty) return;
    final url = Uri.parse('tel:$phone');
    launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final ownerPhone = contract.owner?.phone;
    final buyerPhone = contract.buyer?.phone;

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
            if (ownerPhone != null && ownerPhone.isNotEmpty) ...[
              _buildCallAction(
                context: context,
                label: 'เจ้าของทรัพย์',
                phone: ownerPhone,
              ),
              const SizedBox(height: 12),
            ],
            if (buyerPhone != null && buyerPhone.isNotEmpty) ...[
              _buildCallAction(
                context: context,
                label: 'ผู้ซื้อ',
                phone: buyerPhone,
              ),
              const SizedBox(height: 12),
            ],
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

  Widget _buildCallAction({
    required BuildContext context,
    required String label,
    required String? phone,
  }) {
    final bool phoneExists = phone != null && phone.isNotEmpty;

    return AppButton(
      width: double.infinity,
      height: 44,
      text: 'โทร $phone ($label)',
      style: AppButtonStyle.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      onPressed: !phoneExists
          ? null
          : () {
              Navigator.pop(context);
              _makeCall(phone);
            },
    );
  }
}
