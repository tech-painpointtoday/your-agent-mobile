import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../features/property/bloc/property_form/property_form_bloc.dart';
import '../../../../../widgets/form_fields/app_text_form_field.dart';
import '../../../../../widgets/inputs/app_selectable_grid.dart';
import '../../../../../widgets/inputs/app_multi_select_chips.dart';

class AdditionalInfoStep extends StatefulWidget {
  final int? step;
  const AdditionalInfoStep({super.key, this.step});

  @override
  State<AdditionalInfoStep> createState() => _AdditionalInfoStepState();
}

class _AdditionalInfoStepState extends State<AdditionalInfoStep> {
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final state = context.read<PropertyFormBloc>().state;
    _descriptionController = TextEditingController(
      text: state.description ?? '',
    );

    if (state.specificationFilters.multiSelect.isEmpty) {
      context.read<PropertyFormBloc>().add(PropertyFormFiltersFetched());
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PropertyFormBloc, PropertyFormState>(
      listenWhen: (previous, current) =>
          previous.description != current.description,
      listener: (context, state) {
        if (state.description != _descriptionController.text) {
          _descriptionController.text = state.description ?? '';
        }
      },
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
                  if (widget.step != null)
                    AppBadge(
                      color: BadgeColor.default_,
                      label: '${widget.step}/5',
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Property Style
              AppSelectableGrid<String>(
                label: 'สไตล์ทรัพย์',
                value: state.propertyStyle,
                isRequired: true,
                items: const [
                  GridItem(
                    label: 'โคโลเนียล',
                    value: 'colonial',
                    imagePath: 'assets/images/property_styles/colonial.jpg',
                  ),
                  GridItem(
                    label: 'ร่วมสมัย',
                    value: 'contemporary',
                    imagePath: 'assets/images/property_styles/contemporary.jpg',
                  ),
                  GridItem(
                    label: 'ลอฟท์',
                    value: 'loft',
                    imagePath: 'assets/images/property_styles/loft.jpg',
                  ),
                  GridItem(
                    label: 'มินิมอล',
                    value: 'minimal',
                    imagePath: 'assets/images/property_styles/minimal.jpg',
                  ),
                  GridItem(
                    label: 'เนเชอรัล',
                    value: 'natural',
                    imagePath: 'assets/images/property_styles/natural.jpg',
                  ),
                  GridItem(
                    label: 'นอร์ดิก',
                    value: 'nordic',
                    imagePath: 'assets/images/property_styles/nodic.jpg',
                  ),
                  GridItem(
                    label: 'ไทยร่วมสมัย',
                    value: 'thai_contemporary',
                    imagePath:
                        'assets/images/property_styles/thai_contemporary.jpg',
                  ),
                  GridItem(
                    label: 'วินเทจ',
                    value: 'vintage',
                    imagePath: 'assets/images/property_styles/vintage.jpg',
                  ),
                  GridItem(
                    label: 'อื่นๆ',
                    value: 'other',
                    imagePath: 'assets/images/property_styles/other.jpg',
                  ),
                ],
                onChanged: (val) => context.read<PropertyFormBloc>().add(
                  PropertyFormStyleChanged(val),
                ),
              ),
              const SizedBox(height: 24),

              // Dynamic Multi-Select Filters or Fallback
              if (state.specificationFilters.multiSelect.isNotEmpty)
                ...state.specificationFilters.multiSelect.map((filter) {
                  return Column(
                    children: [
                      AppMultiSelectChips<String>(
                        label: filter.label,
                        values:
                            (state.dynamicValues[filter.key] as List<dynamic>?)
                                ?.cast<String>() ??
                            [],
                        options: filter.options,
                        onSelected: (val) =>
                            context.read<PropertyFormBloc>().add(
                              PropertyFormDynamicMultiSelectToggled(
                                filter.key,
                                val,
                              ),
                            ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                })
              else ...[
                // Fallback: Highlights
                AppMultiSelectChips<String>(
                  label: 'จุดเด่นทรัพย์',
                  values: state.highlights,
                  options: const [
                    'Pet-friendly',
                    'Elderly-Friendly',
                    'ใกล้ทางด่วน',
                    'ใกล้รถไฟฟ้า',
                    'ใกล้โรงพยาบาล',
                    'โครงการใหม่',
                  ],
                  onSelected: (val) => context.read<PropertyFormBloc>().add(
                    PropertyFormHighlightToggled(val),
                  ),
                ),
                const SizedBox(height: 24),

                // Fallback: Facilities
                AppMultiSelectChips<String>(
                  label: 'ส่วนกลาง',
                  values: state.facilities,
                  options: const [
                    'Co-working space',
                    'สระว่ายน้ำ',
                    'ฟิตเนส',
                    'สนามหญ้า',
                    'สนามเด็กเล่น',
                    'สนามกีฬา',
                    'เจ้าหน้าที่ รปภ.',
                  ],
                  onSelected: (val) => context.read<PropertyFormBloc>().add(
                    PropertyFormFacilityToggled(val),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Description
              AppTextFormField(
                label: 'รายละเอียดเพิ่มเติม',
                controller: _descriptionController,
                maxLines: 5,
                onChanged: (val) => context.read<PropertyFormBloc>().add(
                  PropertyFormGeneralInfoUpdated(description: val),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }
}
