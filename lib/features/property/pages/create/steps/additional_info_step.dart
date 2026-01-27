import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import 'package:youragent/features/property/bloc/create_property/create_property_bloc.dart';
import '../../../../../widgets/form_fields/app_text_form_field.dart';

class AdditionalInfoStep extends StatelessWidget {
  const AdditionalInfoStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreatePropertyBloc, CreatePropertyState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'ข้อมูลเพิ่มเติม',
                      style: GoogleFonts.anuphan(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '4/5',
                    style: GoogleFonts.anuphan(
                      color: AppColors.baseGrey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Description
              AppTextFormField(
                label: 'รายละเอียดเพิ่มเติม',
                controller: TextEditingController(
                  text: state.description ?? '',
                ),
                maxLines: 5,
                onChanged: (val) => context.read<CreatePropertyBloc>().add(
                  CreatePropertyGeneralInfoUpdated(description: val),
                ),
              ),
              const SizedBox(height: 16),

              // Direction
              AppTextFormField(
                label: 'ทิศทาง',
                controller: TextEditingController(text: state.direction ?? ''),
                onChanged: (val) => context.read<CreatePropertyBloc>().add(
                  CreatePropertyAdditionalInfoUpdated(direction: val),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
