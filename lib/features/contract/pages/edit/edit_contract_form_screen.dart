import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/contract.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_bloc.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_event.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_state.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:youragent/widgets/modals/app_confirmation_bottom_sheet.dart';

import '../create/steps/property_owner_step.dart';
import '../create/steps/buyer_info_step.dart';
import '../create/steps/appliance_step.dart';
import '../create/steps/furniture_step.dart';
import '../create/steps/payment_step.dart';
import '../create/steps/additional_conditions_step.dart';
import '../create/steps/attachment_step.dart';
import 'package:youragent/l10n/app_localizations.dart';

enum EditContractStepType {
  ownerInfo,
  buyerInfo,
  appliances,
  furniture,
  payment,
  additionalConditions,
  attachments,
}

class EditContractFormScreen extends StatefulWidget {
  final Contract contract;
  final EditContractStepType stepType;
  final String title;
  final ContractFormBloc? bloc;

  const EditContractFormScreen({
    super.key,
    required this.contract,
    required this.stepType,
    required this.title,
    this.bloc,
  });

  @override
  State<EditContractFormScreen> createState() => _EditContractFormScreenState();
}

class _EditContractFormScreenState extends State<EditContractFormScreen> {
  late ContractFormBloc _effectiveBloc;

  @override
  void initState() {
    super.initState();
    _effectiveBloc =
        widget.bloc ??
        ContractFormBloc(
          propertyApiService: DependencyInjection.propertyApiService,
          contractApiService: DependencyInjection.contractApiService,
        );

    // If it's a new bloc (not passed from menu), initialize it.
    // If it's the passed bloc, we assume it's already initialized.
    if (widget.bloc == null) {
      _effectiveBloc.add(ContractFormEditStarted(widget.contract.id!));
    }

    _effectiveBloc.add(ContractFormStepChanged(_getStepIndex(widget.stepType)));
  }

  int _getStepIndex(EditContractStepType type) {
    switch (type) {
      case EditContractStepType.ownerInfo:
        return 2;
      case EditContractStepType.buyerInfo:
        return 3;
      case EditContractStepType.appliances:
        return 4;
      case EditContractStepType.furniture:
        return 5;
      case EditContractStepType.payment:
        return 6;
      case EditContractStepType.additionalConditions:
        return 7;
      case EditContractStepType.attachments:
        return 8;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _effectiveBloc,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).editContract,
            style: GoogleFonts.anuphan(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: SvgPicture.asset(
              'assets/icons/chevron-left.svg',
              width: 18,
              height: 18,
              fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: Container(
            margin: const EdgeInsets.only(top: 16),
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: AppBadge(
                    label: widget.title,
                    color: BadgeColor.blue,
                    style: BadgeStyle.plain,
                  ),
                ),
                Expanded(child: _buildBody(context)),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomBar(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocConsumer<ContractFormBloc, ContractFormState>(
      listenWhen: (prev, curr) {
        // Only listen when transitioning TO success/failure FROM a different status
        // This prevents duplicate dialogs when widget rebuilds with same success state
        return prev.status != curr.status &&
            prev.status != ContractFormStatus.success &&
            prev.status != ContractFormStatus.failure &&
            (curr.status == ContractFormStatus.success ||
                curr.status == ContractFormStatus.failure);
      },
      listener: (context, state) {
        if (state.status == ContractFormStatus.success) {
          StatusDialog.showSuccess(
            context: context,
            title: AppLocalizations.of(context).successTitle,
            message: AppLocalizations.of(context).changesSavedMessage,
          );
          // Pop after a short delay to ensure dialog is shown
          Future.delayed(const Duration(milliseconds: 300), () {
            if (context.mounted) {
              context.pop(true);
            }
          });
        } else if (state.status == ContractFormStatus.failure) {
          AppConfirmationBottomSheet.show(
            context: context,
            title: AppLocalizations.of(context).errorLabel,
            description:
                state.errorMessage ??
                AppLocalizations.of(context).saveDataSuccess,
            confirmLabel: AppLocalizations.of(context).ok,
            cancelLabel: '',
            style: ConfirmationStyle.destructive,
            onConfirm: () {},
          );
        }
      },
      builder: (context, state) {
        // We render specific steps based on stepType.
        // The BLoC's 'step' might be set, but we enforce the widget matching the type.
        switch (widget.stepType) {
          case EditContractStepType.ownerInfo:
            return const PropertyOwnerStep(hideHeader: true);
          case EditContractStepType.buyerInfo:
            return const BuyerInfoStep(hideHeader: true);
          case EditContractStepType.appliances:
            return const ApplianceStep(hideHeader: true);
          case EditContractStepType.furniture:
            return const FurnitureStep(hideHeader: true);
          case EditContractStepType.payment:
            return const PaymentStep(hideHeader: true);
          case EditContractStepType.additionalConditions:
            return const AdditionalConditionsStep(hideHeader: true);
          case EditContractStepType.attachments:
            return const AttachmentStep(hideHeader: true);
        }
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.baseLightGrey)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                text: AppLocalizations.of(context).statusCancelled,
                style: AppButtonStyle.outline,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: BlocBuilder<ContractFormBloc, ContractFormState>(
                builder: (context, state) {
                  final isValid = state.isValid;
                  final isLoading =
                      state.status == ContractFormStatus.submitting;

                  return AppButton(
                    text: AppLocalizations.of(context).confirmSaveLabel,
                    style: AppButtonStyle.primary,
                    enabled: isValid && !isLoading,
                    onPressed: () {
                      AppConfirmationBottomSheet.show(
                        context: context,
                        title: AppLocalizations.of(context).saveChangesQuestion,
                        description: AppLocalizations.of(
                          context,
                        ).saveChangesConfirmation,
                        confirmLabel: AppLocalizations.of(
                          context,
                        ).confirmSaveLabel,
                        cancelLabel: AppLocalizations.of(
                          context,
                        ).statusCancelled,
                        style: ConfirmationStyle.normal,
                        onConfirm: () {
                          context.read<ContractFormBloc>().add(
                            const ContractFormSubmitted(), // Currently mocks API in BLoC
                          );
                        },
                      );
                    },
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
