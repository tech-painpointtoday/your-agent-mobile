import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import 'package:youragent/features/property/bloc/create_property/create_property_bloc.dart';
import '../../../../../widgets/form_fields/app_text_form_field.dart';

class PropertyDetailStep extends StatelessWidget {
  const PropertyDetailStep({super.key});

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
                      'รายละเอียดทรัพย์',
                      style: GoogleFonts.anuphan(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '3/5',
                    style: GoogleFonts.anuphan(
                      color: AppColors.baseGrey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Bedrooms
              AppTextFormField(
                label: 'จำนวนห้องนอน',
                controller: TextEditingController(
                  text: state.bedrooms?.toString() ?? '',
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) => context.read<CreatePropertyBloc>().add(
                  CreatePropertyDetailsUpdated(bedrooms: int.tryParse(val)),
                ),
              ),
              const SizedBox(height: 16),

              // Bathrooms
              AppTextFormField(
                label: 'จำนวนห้องน้ำ',
                controller: TextEditingController(
                  text: state.bathrooms?.toString() ?? '',
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) => context.read<CreatePropertyBloc>().add(
                  CreatePropertyDetailsUpdated(bathrooms: int.tryParse(val)),
                ),
              ),
              const SizedBox(height: 16),

              // Land Size
              AppTextFormField(
                label: 'ขนาดที่ดิน (ตร.ว.)',
                controller: TextEditingController(
                  text: state.landSize?.toString() ?? '',
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) => context.read<CreatePropertyBloc>().add(
                  CreatePropertyDetailsUpdated(landSize: double.tryParse(val)),
                ),
              ),
              const SizedBox(height: 16),

              // Building Size
              AppTextFormField(
                label: 'พื้นที่ใช้สอย (ตร.ม.)',
                controller: TextEditingController(
                  text: state.buildingSize?.toString() ?? '',
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) => context.read<CreatePropertyBloc>().add(
                  CreatePropertyDetailsUpdated(
                    buildingSize: double.tryParse(val),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
