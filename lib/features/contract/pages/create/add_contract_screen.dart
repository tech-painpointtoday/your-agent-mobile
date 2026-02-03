import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_bloc.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_event.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_state.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
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

class AddContractScreen extends StatelessWidget {
  const AddContractScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ContractFormBloc(
        propertyApiService: DependencyInjection.propertyApiService,
        contractApiService: DependencyInjection.contractApiService,
      ),
      child: const _AddContractView(),
    );
  }
}

class _AddContractView extends StatelessWidget {
  const _AddContractView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/x.svg',
            height: 24,
            width: 24,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () {
            final step = context.read<ContractFormBloc>().state.step;
            if (step == 1) {
              Navigator.of(context).pop();
              return;
            }

            AppConfirmationBottomSheet.show(
              context: context,
              title: 'ยืนยันการยกเลิก',
              description:
                  'ข้อมูลที่คุณกรอกไว้จะหายไป คุณต้องการยกเลิกใช่หรือไม่?',
              confirmLabel: 'ยืนยันการยกเลิก',
              cancelLabel: 'กลับไปทำต่อ',
              style: ConfirmationStyle.destructive,
              onConfirm: () => Navigator.of(context).pop(),
            );
          },
        ),
        titleSpacing: 0,
        title: BlocBuilder<ContractFormBloc, ContractFormState>(
          builder: (context, state) {
            String title = 'สร้างสัญญา';
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
      body: Container(
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
            switch (state.step) {
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
          },
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
              child: BlocBuilder<ContractFormBloc, ContractFormState>(
                buildWhen: (prev, curr) => prev.step != curr.step,
                builder: (context, state) {
                  return AppButton(
                    text: 'ย้อนกลับ',
                    style: AppButtonStyle.outline,
                    onPressed: state.step > 1
                        ? () => context.read<ContractFormBloc>().add(
                            ContractFormStepChanged(state.step - 1),
                          )
                        : null,
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
                      state.status == ContractFormStatus.submmitting;

                  return AppButton(
                    text: isLastStep ? 'สร้างสัญญา' : 'ถัดไป',
                    style: AppButtonStyle.primary,
                    onPressed: (state.isValid && !isLoading)
                        ? () {
                            if (isLastStep) {
                              context.read<ContractFormBloc>().add(
                                const ContractFormSubmitted(),
                              );
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
