import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/features/property/bloc/create_property/create_property_bloc.dart';
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
    return BlocProvider(
      create: (context) => CreatePropertyBloc(),
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
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: BlocBuilder<CreatePropertyBloc, CreatePropertyState>(
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
      body: BlocListener<CreatePropertyBloc, CreatePropertyState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == CreatePropertyStatus.submissionSuccess) {
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
          } else if (state.status == CreatePropertyStatus.submissionFailure) {
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
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: BlocBuilder<CreatePropertyBloc, CreatePropertyState>(
            builder: (context, state) {
              switch (state.step) {
                case 1:
                  return const PropertyTypeStep();
                case 2:
                  return const GeneralInfoStep();
                case 3:
                  return const PropertyDetailStep();
                case 4:
                  return const AdditionalInfoStep();
                case 5:
                  return const PropertyImagesStep();
                case 6:
                  return const PropertyConfirmationStep();
                default:
                  return Center(child: Text('Step ${state.step} Coming Soon'));
              }
            },
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
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: BlocBuilder<CreatePropertyBloc, CreatePropertyState>(
                buildWhen: (previous, current) => previous.step != current.step,
                builder: (context, state) {
                  return AppButton(
                    text: 'ย้อนกลับ',
                    style: AppButtonStyle
                        .outline, // Assuming outline style exists, or use ghost
                    onPressed: state.step > 1
                        ? () {
                            context.read<CreatePropertyBloc>().add(
                              CreatePropertyStepChanged(state.step - 1),
                            );
                          }
                        : null, // Disable if on step 1
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: BlocBuilder<CreatePropertyBloc, CreatePropertyState>(
                buildWhen: (prev, curr) =>
                    prev.isValid != curr.isValid ||
                    prev.step != curr.step ||
                    prev.status != curr.status,
                builder: (context, state) {
                  final isLastStep = state.step == 6; // Confirmation step
                  return AppButton(
                    text: isLastStep ? 'สร้าง' : 'ถัดไป',
                    style: AppButtonStyle.primary,
                    // If creating, check validation AND not currently submitting
                    onPressed:
                        (state.isValid &&
                            state.status !=
                                CreatePropertyStatus.submissionInProgress)
                        ? () {
                            if (isLastStep) {
                              // Confirmation Dialog
                              // We need access to helper.
                              // Since we can't await inside build easily without callback,
                              // we can refactor this into a method.
                              _onNextPressed(context, state);
                            } else {
                              context.read<CreatePropertyBloc>().add(
                                CreatePropertyStepChanged(state.step + 1),
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

  void _onNextPressed(BuildContext context, CreatePropertyState state) {
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
                context.read<CreatePropertyBloc>().add(
                  const CreatePropertySubmitted(),
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
