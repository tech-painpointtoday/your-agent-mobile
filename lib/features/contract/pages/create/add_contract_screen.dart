import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/domain/entities/contract.dart';
import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_bloc.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_event.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_state.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:youragent/widgets/modals/app_confirmation_bottom_sheet.dart';
import 'steps/basic_info_step.dart';
import 'steps/property_owner_step.dart';
import 'steps/buyer_info_step.dart';
import 'steps/appliance_step.dart';
import 'steps/furniture_step.dart';
import 'steps/additional_conditions_step.dart';
import 'steps/attachment_step.dart';

import 'package:youragent/core/di/dependency_injection.dart';

import 'package:youragent/features/contract/pages/create/steps/payment_step.dart';
import 'package:youragent/features/contract/pages/preview/contract_pdf_preview_page.dart';
import 'package:youragent/core/extensions/l10n_extensions.dart';

class AddContractScreen extends StatelessWidget {
  final Contract? contract;
  final Property? property;
  const AddContractScreen({super.key, this.contract, this.property});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = ContractFormBloc(
          propertyApiService: DependencyInjection.propertyApiService,
          contractApiService: DependencyInjection.contractApiService,
        );
        if (contract != null) {
          bloc.add(ContractFormEditStarted(contract!.id!));
        } else if (property != null) {
          bloc.add(ContractFormPropertySelected(property!));
        }
        return bloc;
      },
      child: const _AddContractView(),
    );
  }
}

class _AddContractView extends StatelessWidget {
  const _AddContractView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContractFormBloc, ContractFormState>(
      listenWhen: (prev, curr) {
        return prev.status != curr.status &&
            prev.status != ContractFormStatus.success &&
            prev.status != ContractFormStatus.draftSaveSuccess &&
            prev.status != ContractFormStatus.draftSaveFailure &&
            (curr.status == ContractFormStatus.success ||
                curr.status == ContractFormStatus.draftSaveSuccess ||
                curr.status == ContractFormStatus.draftSaveFailure);
      },
      listener: (context, state) {
        if (state.status == ContractFormStatus.success) {
          context.pop(true);
        } else if (state.status == ContractFormStatus.draftSaveSuccess) {
          StatusDialog.showSuccess(
            context: context,
            title: context.l10n.successTitle,
            message: context.l10n.draftSavedMessage,
          );
          if (context.mounted) {
            context.pop(true);
          }
        } else if (state.status == ContractFormStatus.draftSaveFailure) {
          StatusDialog.showError(
            context: context,
            title: context.l10n.errorLabel,
            message: state.errorMessage ?? context.l10n.draftSaveErrorMessage,
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
            onPressed: () {
              final step = context.read<ContractFormBloc>().state.step;
              if (step == 1) {
                Navigator.of(context).pop();
                return;
              }

              AppConfirmationBottomSheet.show(
                context: context,
                title: context.l10n.confirmCancelLabel,
                description: context.l10n.confirmCancelMessage,
                confirmLabel: context.l10n.confirmCancelLabel,
                cancelLabel: context.l10n.continueEditingLabel,
                style: ConfirmationStyle.destructive,
                onConfirm: () => Navigator.of(context).pop(),
              );
            },
          ),
          titleSpacing: 0,
          title: BlocBuilder<ContractFormBloc, ContractFormState>(
            builder: (context, state) {
              String title = context.l10n.createContractButton;
              return Text(
                title,
                style: GoogleFonts.anuphan(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
          actions: [
            BlocBuilder<ContractFormBloc, ContractFormState>(
              builder: (context, state) {
                final isPropertySelected = state.selectedProperty != null;

                if (!isPropertySelected) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  child: InkWell(
                    onTap: () {
                      AppConfirmationBottomSheet.show(
                        context: context,
                        title: context.l10n.saveDraftButton,
                        description: context.l10n.saveChangesConfirmation,
                        confirmLabel: context.l10n.confirm,
                        cancelLabel: context.l10n.cancel,
                        style: ConfirmationStyle.normal,
                        onConfirm: () {
                          context.read<ContractFormBloc>().add(
                            const ContractFormDraftSubmitted(),
                          );
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isPropertySelected
                            ? AppColors.supportBlueDeep
                            : AppColors.supportBlueDeep.withOpacity(0.5),
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
                            context.l10n.saveDraftButton,
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
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: BlocBuilder<ContractFormBloc, ContractFormState>(
              builder: (context, state) {
                return Stack(
                  children: [
                    _buildStepBody(state.step),
                    if (state.status == ContractFormStatus.loading)
                      const Center(child: CircularProgressIndicator()),
                  ],
                );
              },
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomBar(context),
      ),
    );
  }

  Widget _buildStepBody(int step) {
    switch (step) {
      case 1:
        return const BasicInfoStep();
      case 2:
        return const PropertyOwnerStep();
      case 3:
        return const BuyerInfoStep();
      case 4:
        return const ApplianceStep();
      case 5:
        return const FurnitureStep();
      case 6:
        return const PaymentStep();
      case 7:
        return const AdditionalConditionsStep();
      case 8:
        return const AttachmentStep();
      default:
        return const Center(child: Text('Unknown Step'));
    }
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: BlocBuilder<ContractFormBloc, ContractFormState>(
                buildWhen: (prev, curr) => prev.step != curr.step,
                builder: (context, state) {
                  return AppButton(
                    text: context.l10n.backButton,
                    style: AppButtonStyle.outline,
                    onPressed: state.step > 1
                        ? () => context.read<ContractFormBloc>().add(
                            ContractFormStepChanged(state.step - 1),
                          )
                        : () => context.pop(),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: BlocBuilder<ContractFormBloc, ContractFormState>(
                buildWhen: (prev, curr) =>
                    prev.isValid != curr.isValid ||
                    prev.step != curr.step ||
                    prev.status != curr.status,
                builder: (context, state) {
                  final isLastStep = state.step == 8;
                  final isLoading =
                      state.status == ContractFormStatus.submitting;

                  return AppButton(
                    text: context.l10n.nextButton,
                    style: AppButtonStyle.primary,
                    onPressed: (state.isValid && !isLoading)
                        ? () {
                            if (isLastStep) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<ContractFormBloc>(),
                                    child: ContractPdfPreviewPage(state: state),
                                  ),
                                ),
                              ).then((result) {
                                if (result == true && context.mounted) {
                                  context.pop(true);
                                }
                              });
                            } else {
                              context.read<ContractFormBloc>().add(
                                ContractFormStepChanged(state.step + 1),
                              );
                            }
                          }
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
