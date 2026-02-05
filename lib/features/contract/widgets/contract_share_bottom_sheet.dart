import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/contract.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/widgets/modals/app_confirmation_bottom_sheet.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';

class ContractShareBottomSheet extends StatelessWidget {
  final Contract contract;
  final String? pdfPath;
  final VoidCallback? onDownloadPdf;
  final VoidCallback? onSendToSeller;
  final VoidCallback? onSendToBuyer;

  const ContractShareBottomSheet({
    super.key,
    required this.contract,
    this.pdfPath,
    this.onDownloadPdf,
    this.onSendToSeller,
    this.onSendToBuyer,
  });

  static Future<void> show({
    required BuildContext context,
    required Contract contract,
    String? pdfPath,
    VoidCallback? onDownloadPdf,
    VoidCallback? onSendToSeller,
    VoidCallback? onSendToBuyer,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ContractShareBottomSheet(
        contract: contract,
        pdfPath: pdfPath,
        onDownloadPdf: onDownloadPdf,
        onSendToSeller: onSendToSeller,
        onSendToBuyer: onSendToBuyer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sellerEmail = contract.owner?.email;
    final buyerEmail = contract.buyer?.email;

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
            const SizedBox(height: 32),
            _buildResendOrSendAction(
              context: context,
              label: AppLocalizations.of(context).property,
              email: sellerEmail,
              isSigned: contract.sellerSignedAt != null,
              onSend: onSendToSeller ?? () => _handleSendToSeller(context),
            ),
            const SizedBox(height: 12),
            _buildResendOrSendAction(
              context: context,
              label: AppLocalizations.of(context).lessee,
              email: buyerEmail,
              isSigned: contract.buyerSignedAt != null,
              onSend: onSendToBuyer ?? () => _handleSendToBuyer(context),
            ),
            // if (pdfPath != null || onDownloadPdf != null) ...[
            //   const SizedBox(height: 12),
            //   AppButton(
            //     text: AppLocalizations.of(context).file,
            //     style: AppButtonStyle.outline,
            //     onPressed: () {
            //       Navigator.pop(context);
            //       onDownloadPdf?.call();
            //     },
            //   ),
            // ],
            const SizedBox(height: 12),
            AppButton(
              text: AppLocalizations.of(context).statusCancelled,
              style: AppButtonStyle.ghost,
              textColor: AppColors.supportRedDeep,
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildResendOrSendAction({
    required BuildContext context,
    required String label,
    required String? email,
    required bool isSigned,
    required VoidCallback onSend,
  }) {
    final bool emailExists = email != null && email.isNotEmpty;

    if (isSigned) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.supportGreenLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.supportGreenDark.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/plus.svg',
                        width: 16,
                        height: 16,
                        fit: BoxFit.scaleDown,
                        colorFilter: ColorFilter.mode(
                          AppColors.supportGreenDark,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$labelลงนามแล้ว',
                        style: GoogleFonts.anuphan(
                          color: AppColors.supportGreenDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (emailExists)
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: Text(
                        email,
                        style: GoogleFonts.anuphan(
                          color: AppColors.baseGrey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            AppButton(
              text: AppLocalizations.of(context).submit,
              style: AppButtonStyle.outline,
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              onPressed: !emailExists
                  ? null
                  : () {
                      Navigator.pop(context);
                      AppConfirmationBottomSheet.show(
                        context: context,
                        title: AppLocalizations.of(context).submitDocument,
                        description:
                            'คุณต้องการส่งเอกสารไปยัง$label ($email) อีกครั้งใช่หรือไม่?',
                        confirmLabel: AppLocalizations.of(context).submit,
                        cancelLabel: AppLocalizations.of(
                          context,
                        ).statusCancelled,
                        style: ConfirmationStyle.normal,
                        onConfirm: onSend,
                      );
                    },
            ),
          ],
        ),
      );
    }

    return AppButton(
      text: 'ส่งเอกสารไปยัง $label',
      style: AppButtonStyle.primary,
      onPressed: !emailExists
          ? null
          : () {
              Navigator.pop(context);
              AppConfirmationBottomSheet.show(
                context: context,
                title: AppLocalizations.of(context).submitDocumentQuestion,
                description:
                    'คุณต้องการส่งเอกสารไปยัง$label ($email) ใช่หรือไม่?',
                confirmLabel: AppLocalizations.of(context).submit,
                cancelLabel: AppLocalizations.of(context).statusCancelled,
                style: ConfirmationStyle.normal,
                onConfirm: onSend,
              );
            },
    );
  }

  Future<void> _handleSendToSeller(BuildContext context) async {
    try {
      if (context.mounted) {
        StatusDialog.showLoading(context: context);
      }

      await DependencyInjection.contractApiService.sendToSeller(
        contractId: contract.id!,
      );

      if (context.mounted) {
        Navigator.pop(context); // Pop loading
        StatusDialog.showSuccess(
          context: context,
          title: AppLocalizations.of(context).successTitle,
          message: 'ส่งเอกสารไปยังผู้ให้เช่าสำเร็จ',
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Pop loading
        StatusDialog.showError(
          context: context,
          title: AppLocalizations.of(context).errorOccurredTitle,
          message: e.toString(),
        );
      }
    }
  }

  Future<void> _handleSendToBuyer(BuildContext context) async {
    try {
      if (context.mounted) {
        StatusDialog.showLoading(context: context);
      }

      await DependencyInjection.contractApiService.sendToBuyer(
        contractId: contract.id!,
      );

      if (context.mounted) {
        Navigator.pop(context); // Pop loading
        StatusDialog.showSuccess(
          context: context,
          title: AppLocalizations.of(context).successTitle,
          message: 'ส่งเอกสารไปยังผู้เช่าสำเร็จ',
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Pop loading
        StatusDialog.showError(
          context: context,
          title: AppLocalizations.of(context).errorOccurredTitle,
          message: e.toString(),
        );
      }
    }
  }
}
