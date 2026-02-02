import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/features/property/bloc/property_form/property_form_bloc.dart';
import 'package:youragent/features/property/bloc/property_metadata/property_metadata_bloc.dart';
import 'package:youragent/features/property/bloc/property_metadata/property_metadata_event.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:youragent/widgets/modals/app_confirmation_bottom_sheet.dart';

import '../create/steps/additional_info_step.dart';
import '../create/steps/general_info_step.dart';
import '../create/steps/property_detail_step.dart';
import '../create/steps/property_images_step.dart';

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

        return PropertyFormBloc(
          initialFilters: metadataState.specificationFilters,
          initialProperty: property,
          initialDevelopers: metadataState.developers,
          initialCondoProjects: metadataState.condoProjects,
        )..add(PropertyFormStepChanged(initialStep));
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(
          title: Text(
            'แก้ไขข้อมูล',
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
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Container(
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
            title: 'สำเร็จ',
            message: 'บันทึกการเปลี่ยนแปลงเรียบร้อยแล้ว',
          );
          context.pop();
        } else if (state.propertyFormStatus ==
            PropertyFormStatus.submissionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Update failed')),
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
                text: 'ยกเลิก',
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
                    text: 'บันทึก',
                    style: AppButtonStyle.primary,
                    onPressed: isValid
                        ? () {
                            AppConfirmationBottomSheet.show(
                              context: context,
                              title: 'บันทึกการเปลี่ยนแปลง?',
                              description:
                                  'คุณต้องการบันทึกการเปลี่ยนแปลงนี้ใช่หรือไม่',
                              confirmLabel: 'บันทึก',
                              cancelLabel: 'ยกเลิก',
                              style: ConfirmationStyle.normal,
                              onConfirm: () {
                                context.read<PropertyFormBloc>().add(
                                  const PropertyFormSubmitted(),
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
