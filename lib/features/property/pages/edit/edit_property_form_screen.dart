import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yourhome/core/theme/app_colors.dart';
import 'package:yourhome/domain/entities/property.dart';
import 'package:yourhome/features/property/bloc/property_form/property_form_bloc.dart';
import 'package:yourhome/features/property/bloc/property_metadata/property_metadata_bloc.dart';
import 'package:yourhome/features/property/bloc/property_metadata/property_metadata_event.dart';
import 'package:yourhome/widgets/buttons/app_button.dart';
import 'package:yourhome/widgets/dialogs/status_dialog.dart';
import 'package:yourhome/widgets/modals/app_confirmation_bottom_sheet.dart';

import '../create/steps/additional_info_step.dart';
import '../create/steps/general_info_step.dart';
import '../create/steps/property_detail_step.dart';
import '../create/steps/property_images_step.dart';
import 'package:yourhome/l10n/app_localizations.dart';

enum EditPropertyStepType {
  generalInfo,
  propertyDetail,
  additionalInfo,
  propertyImages,
}

class EditPropertyFormScreen extends StatelessWidget {
  final Property property;
  final EditPropertyStepType stepType;
  final String title;

  const EditPropertyFormScreen({
    super.key,
    required this.property,
    required this.stepType,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure metadata is loaded
    context.read<PropertyMetadataBloc>().add(const LoadPropertyMetadata());
    final metadataState = context.read<PropertyMetadataBloc>().state;

    return BlocProvider(
      create: (context) {
        int initialStep = 1;
        switch (stepType) {
          case EditPropertyStepType.generalInfo:
            initialStep = 2;
            break;
          case EditPropertyStepType.propertyDetail:
            initialStep = 3;
            break;
          case EditPropertyStepType.additionalInfo:
            initialStep = 4;
            break;
          case EditPropertyStepType.propertyImages:
            initialStep = 5;
            break;
        }

        final bloc = PropertyFormBloc(
          initialFilters: metadataState.specificationFilters,
          initialProperty: property,
          initialDevelopers: metadataState.developers,
          initialCondoProjects: metadataState.condoProjects,
          initialHouseProjects: metadataState.houseProjects,
        );

        // Set the correct step for this edit view.
        bloc.add(PropertyFormStepChanged(initialStep));

        // Always refresh developer list so IDs from the property can be matched.
        bloc.add(const PropertyFormDevelopersFetched(refresh: true));

        // If the property already has a developer, fetch its projects so
        // condo/house project IDs can be matched immediately.
        final selectedDevId = bloc.state.selectedDeveloperId;
        final type = property.propertyType;
        final isCondoOrApt =
            type == PropertyType.condo || type == PropertyType.apartment;
        final isHouseLike =
            type == PropertyType.house ||
            type == PropertyType.townhome ||
            type == PropertyType.homeOffice;

        if (selectedDevId != null) {
          if (isCondoOrApt) {
            bloc.add(
              PropertyFormCondoProjectsFetched(
                developerId: selectedDevId,
                refresh: true,
              ),
            );
          }
          if (isHouseLike) {
            bloc.add(
              PropertyFormHouseProjectsFetched(
                developerId: selectedDevId,
                refresh: true,
              ),
            );
          }
        }

        return bloc;
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).editDataTitle,
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
            margin: EdgeInsets.only(top: 16),
            height: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: _buildBody(context),
          ),
        ),
        bottomNavigationBar: _buildBottomBar(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocConsumer<PropertyFormBloc, PropertyFormState>(
      listener: (context, state) {
        if (state.propertyFormStatus == PropertyFormStatus.submissionSuccess) {
          StatusDialog.showSuccess(
            context: context,
            title: AppLocalizations.of(context).successTitle,
            message: AppLocalizations.of(context).changesSavedMessage,
          );
          context.pop(true);
        } else if (state.propertyFormStatus ==
            PropertyFormStatus.submissionFailure) {
          StatusDialog.showError(
            context: context,
            title: AppLocalizations.of(context).errorOccurredTitle,
            message: state.errorMessage ?? 'Update failed',
          );
        }
      },
      builder: (context, state) {
        // Reuse steps but pass a fixed 'step' index if the widget requires it.
        // Most widgets use step for validation or display, we can pass whatever matches the original flow or 1.
        // General: 2, Detail: 3, Additional: 4, Images: 5
        switch (stepType) {
          case EditPropertyStepType.generalInfo:
            return GeneralInfoStep();
          case EditPropertyStepType.propertyDetail:
            return PropertyDetailStep();
          case EditPropertyStepType.additionalInfo:
            return AdditionalInfoStep();
          case EditPropertyStepType.propertyImages:
            return PropertyImagesStep();
        }
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.baseLightGrey)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                text: AppLocalizations.of(context).cancel,
                style: AppButtonStyle.outline,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: BlocBuilder<PropertyFormBloc, PropertyFormState>(
                builder: (context, state) {
                  final isValid = state.isValid;

                  return AppButton(
                    text: AppLocalizations.of(context).confirmSaveLabel,
                    style: AppButtonStyle.primary,
                    onPressed: isValid
                        ? () {
                            AppConfirmationBottomSheet.show(
                              context: context,
                              title: AppLocalizations.of(
                                context,
                              ).saveChangesQuestion,
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
                                context.read<PropertyFormBloc>().add(
                                  PropertyFormSubmitted(
                                    validationErrorMessage: AppLocalizations.of(
                                      context,
                                    ).pleaseFillAllFields,
                                  ),
                                );
                              },
                            );
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
