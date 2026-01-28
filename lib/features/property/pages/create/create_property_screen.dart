import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/features/property/bloc/property_form/property_form_bloc.dart';
import 'package:youragent/features/property/bloc/property_metadata/property_metadata_bloc.dart';
import 'package:youragent/features/property/bloc/property_metadata/property_metadata_event.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'steps/additional_info_step.dart';
import 'steps/confirmation_step.dart';
import 'steps/general_info_step.dart';
import 'steps/property_detail_step.dart';
import 'steps/property_images_step.dart';
import 'steps/property_type_step.dart';

class CreatePropertyScreen extends StatelessWidget {
  const CreatePropertyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure metadata is loaded/loading
    final metadataBloc = context.read<PropertyMetadataBloc>();
    metadataBloc.add(const LoadPropertyMetadata());

    final metadataState = metadataBloc.state;
    final filters = metadataState.specificationFilters;

    return BlocProvider(
      create: (context) => PropertyFormBloc(
        initialFilters: filters,
        initialDevelopers: metadataState.developers,
        initialCondoProjects: metadataState.condoProjects,
      ),
      child: const _CreatePropertyView(),
    );
  }
}

class _CreatePropertyView extends StatelessWidget {
  const _CreatePropertyView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/x.svg',
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: BlocBuilder<PropertyFormBloc, PropertyFormState>(
          builder: (context, state) {
            return Text(
              state.step == 6 ? 'ยืนยันข้อมูล' : 'สร้างทรัพย์',
              style: GoogleFonts.anuphan(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.supportBlueDeep,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.description_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'บันทึกร่าง',
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
        ],
      ),
      body: BlocListener<PropertyFormBloc, PropertyFormState>(
        listenWhen: (prev, curr) =>
            prev.propertyFormStatus != curr.propertyFormStatus,
        listener: (context, state) {
          if (state.propertyFormStatus ==
              PropertyFormStatus.submissionSuccess) {
            // Show Success Dialog then pop
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
                content: Text(
                  'สร้างทรัพย์สำเร็จ',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.anuphan(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(); // Close dialog
                        Navigator.of(context).pop(); // Close create screen
                        // TODO: Navigate to Detail Screen
                      },
                      child: Text(
                        'ตกลง',
                        style: GoogleFonts.anuphan(color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (state.propertyFormStatus ==
              PropertyFormStatus.submissionFailure) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Icon(Icons.error, color: Colors.red, size: 48),
                content: Text(
                  'เกิดข้อผิดพลาด: ${state.errorMessage}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.anuphan(),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      'ตกลง',
                      style: GoogleFonts.anuphan(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            );
          }
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: BlocBuilder<PropertyFormBloc, PropertyFormState>(
              builder: (context, state) {
                switch (state.step) {
                  case 1:
                    return PropertyTypeStep(step: state.step);
                  case 2:
                    return GeneralInfoStep(step: state.step);
                  case 3:
                    return PropertyDetailStep(step: state.step);
                  case 4:
                    return AdditionalInfoStep(step: state.step);
                  case 5:
                    return PropertyImagesStep(step: state.step);
                  case 6:
                    return PropertyConfirmationStep();
                  default:
                    return Center(
                      child: Text('Step ${state.step} Coming Soon'),
                    );
                }
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
              child: BlocBuilder<PropertyFormBloc, PropertyFormState>(
                buildWhen: (previous, current) => previous.step != current.step,
                builder: (context, state) {
                  return AppButton(
                    text: 'ย้อนกลับ',
                    style: AppButtonStyle
                        .outline, // Assuming outline style exists, or use ghost
                    onPressed: state.step > 1
                        ? () {
                            context.read<PropertyFormBloc>().add(
                              PropertyFormStepChanged(state.step - 1),
                            );
                          }
                        : null, // Disable if on step 1
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: BlocBuilder<PropertyFormBloc, PropertyFormState>(
                buildWhen: (prev, curr) =>
                    prev.isValid != curr.isValid ||
                    prev.step != curr.step ||
                    prev.propertyFormStatus != curr.propertyFormStatus,
                builder: (context, state) {
                  final isLastStep = state.step == 6; // Confirmation step
                  return AppButton(
                    text: isLastStep ? 'สร้าง' : 'ถัดไป',
                    style: AppButtonStyle.primary,
                    // If creating, check validation AND not currently submitting
                    onPressed:
                        (state.isValid &&
                            state.propertyFormStatus !=
                                PropertyFormStatus.submissionInProgress)
                        ? () {
                            if (isLastStep) {
                              // Confirmation Dialog
                              // We need access to helper.
                              // Since we can't await inside build easily without callback,
                              // we can refactor this into a method.
                              _onNextPressed(context, state);
                            } else {
                              context.read<PropertyFormBloc>().add(
                                PropertyFormStepChanged(state.step + 1),
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

  void _onNextPressed(BuildContext context, PropertyFormState state) {
    if (state.step == 6) {
      // Show Confirm Dialog
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          // Using standard or custom dialog
          title: Text(
            'ยืนยันข้อมูล',
            style: GoogleFonts.anuphan(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'คุณต้องการสร้างประกาศทรัพย์นี้ใช่หรือไม่?',
            style: GoogleFonts.anuphan(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'ยกเลิก',
                style: GoogleFonts.anuphan(color: AppColors.baseGrey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Close dialog
                context.read<PropertyFormBloc>().add(
                  const PropertyFormSubmitted(),
                );
              },
              child: Text(
                'ยืนยัน',
                style: GoogleFonts.anuphan(color: AppColors.primary),
              ),
            ),
          ],
        ),
      );
    }
  }
}
