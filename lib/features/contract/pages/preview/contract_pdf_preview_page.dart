import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_bloc.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_event.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_state.dart';
import 'package:youragent/features/contract/services/contract_pdf_service.dart';
import 'package:flutter_svg/svg.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/domain/entities/contract_status.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:youragent/l10n/app_localizations.dart';

class ContractPdfPreviewPage extends StatelessWidget {
  final ContractFormState state;

  const ContractPdfPreviewPage({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<ContractFormBloc, ContractFormState>(
      listenWhen: (prev, curr) {
        // Only listen when transitioning TO success/failure/draftSave states FROM a different status
        // This prevents duplicate dialogs when widget rebuilds with same state
        return prev.status != curr.status &&
            prev.status != ContractFormStatus.success &&
            prev.status != ContractFormStatus.failure &&
            prev.status != ContractFormStatus.draftSaveSuccess &&
            prev.status != ContractFormStatus.draftSaveFailure &&
            (curr.status == ContractFormStatus.success ||
                curr.status == ContractFormStatus.failure ||
                curr.status == ContractFormStatus.draftSaveSuccess ||
                curr.status == ContractFormStatus.draftSaveFailure);
      },
      listener: (context, state) {
        if (state.status == ContractFormStatus.success) {
          StatusDialog.showSuccess(
            context: context,
            title: AppLocalizations.of(context).successTitle,
            message: state.contractStatus == ContractStatus.draft
                ? AppLocalizations.of(context).contractPublishedSuccess
                : AppLocalizations.of(context).contractCreatedSuccess,
          );
          Future.delayed(const Duration(seconds: 1), () {
            if (context.mounted) {
              context.pop(true);
            }
          });
        } else if (state.status == ContractFormStatus.failure) {
          StatusDialog.showError(
            context: context,
            title: AppLocalizations.of(context).errorLabel,
            message: state.errorMessage ?? 'Error',
          );
        } else if (state.status == ContractFormStatus.draftSaveSuccess) {
          StatusDialog.showSuccess(
            context: context,
            title: AppLocalizations.of(context).successTitle,
            message: AppLocalizations.of(context).draftSavedMessage,
          );
          Future.delayed(const Duration(seconds: 1), () {
            if (context.mounted) {
              context.pop(true);
            }
          });
        } else if (state.status == ContractFormStatus.draftSaveFailure) {
          StatusDialog.showError(
            context: context,
            title: AppLocalizations.of(context).errorLabel,
            message:
                state.errorMessage ??
                AppLocalizations.of(context).draftSaveErrorMessage,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: SvgPicture.asset(
              'assets/icons/x.svg',
              height: 18,
              width: 18,
              fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () => context.pop(),
          ),
          titleSpacing: 0,
          title: Text(
            l10n.confirmInfo,
            style: GoogleFonts.anuphan(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            BlocBuilder<ContractFormBloc, ContractFormState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  child: InkWell(
                    onTap: state.status == ContractFormStatus.submitting
                        ? null
                        : () {
                            context.read<ContractFormBloc>().add(
                              const ContractFormDraftSubmitted(),
                            );
                          },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.supportBlueDeep,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/file.svg',
                            height: 16,
                            width: 16,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.saveDraftButton,
                            style: GoogleFonts.anuphan(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // PDF Content Area
            Expanded(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  child: PdfPreview(
                    scrollViewDecoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.zero,
                    previewPageMargin: EdgeInsets.zero,
                    pdfPreviewPageDecoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    useActions: false,
                    build: (format) => ContractPdfService().generate(state),
                    allowPrinting: true,
                    allowSharing: true,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    initialPageFormat: null,
                    pdfFileName: 'Contract_${state.contractId ?? "Draft"}.pdf',
                    loadingWidget: const Center(
                      child: CircularProgressIndicator(),
                    ),
                    onError: (context, error) => Center(
                      child: Text('เกิดข้อผิดพลาดในการสร้าง PDF: $error'),
                    ),
                  ),
                ),
              ),
            ),

            // Fixed Footer
            _buildFooter(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              text: l10n.backButton,
              style: AppButtonStyle.outline,
              onPressed: () => context.pop(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: BlocBuilder<ContractFormBloc, ContractFormState>(
              builder: (context, state) {
                return AppButton(
                  text: 'สร้าง',
                  style: AppButtonStyle.primary,
                  isLoading: state.status == ContractFormStatus.submitting,
                  onPressed: () {
                    context.read<ContractFormBloc>().add(
                      const ContractFormSubmitted(),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
