import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/utils/currency_input_formatter.dart';
import '../../../../../core/theme/app_colors.dart';
import 'package:youragent/features/property/bloc/property_form/property_form_bloc.dart';
import '../../../../../widgets/form_fields/app_text_form_field.dart';
import '../../../../../widgets/inputs/app_selection_pills.dart';
import '../../../../../widgets/form_fields/app_dropdown_form_field.dart';
import '../../../../../widgets/badges/app_badge.dart';

class PropertyDetailStep extends StatefulWidget {
  final int? step;
  const PropertyDetailStep({super.key, this.step});

  @override
  State<PropertyDetailStep> createState() => _PropertyDetailStepState();
}

class _PropertyDetailStepState extends State<PropertyDetailStep> {
  late final TextEditingController _builtController;
  late final TextEditingController _priceController;
  late final TextEditingController _landSizeController;
  late final TextEditingController _buildingSizeController;

  @override
  void initState() {
    super.initState();
    final state = context.read<PropertyFormBloc>().state;
    context.read<PropertyFormBloc>().add(const PropertyFormFiltersFetched());
    _builtController = TextEditingController(
      text: state.built != null
          ? DateFormat('dd/MM/yyyy').format(DateTime.parse(state.built!))
          : '',
    );
    _priceController = TextEditingController(
      text: state.price != null
          ? NumberFormat.decimalPattern('en_US').format(state.price)
          : '',
    );
    _landSizeController = TextEditingController(
      text: state.landSize?.toString() ?? '',
    );
    _buildingSizeController = TextEditingController(
      text: state.buildingSize?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _builtController.dispose();
    _priceController.dispose();
    _landSizeController.dispose();
    _buildingSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PropertyFormBloc, PropertyFormState>(
      listenWhen: (previous, current) => previous.built != current.built,
      listener: (context, state) {
        if (state.built != null) {
          final formatted = DateFormat(
            'dd/MM/yyyy',
          ).format(DateTime.parse(state.built!));
          if (_builtController.text != formatted) {
            _builtController.text = formatted;
          }
        }
      },
      builder: (context, state) {
        final isCondoOrApt = state.isCondoOrApt;

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
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
                  if (widget.step != null)
                    AppBadge(
                      color: BadgeColor.default_,
                      label: '${widget.step}/5',
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Listing Type
              AppSelectionPills<String>(
                label: 'ประเภทประกาศ',
                value: state.listingType,
                isRequired: true,
                options: const [
                  SelectionPillOption(label: 'ขาย', value: 'ขาย'),
                  SelectionPillOption(label: 'เช่า', value: 'เช่า'),
                  SelectionPillOption(label: 'ขายและเช่า', value: 'ขายและเช่า'),
                ],
                onChanged: (val) => context.read<PropertyFormBloc>().add(
                  PropertyFormListingTypeChanged(val),
                ),
              ),
              const SizedBox(height: 24),

              // Occupancy Status
              AppSelectionPills<String>(
                label: 'สถานะ',
                value: state.status,
                isRequired: true,
                options: const [
                  SelectionPillOption(label: 'ว่าง', value: 'ว่าง'),
                  SelectionPillOption(label: 'ไม่ว่าง', value: 'ไม่ว่าง'),
                ],
                onChanged: (val) => context.read<PropertyFormBloc>().add(
                  PropertyFormStatusChanged(val),
                ),
              ),
              const SizedBox(height: 24),

              // Dynamic Filters or Fallback
              if (state.specificationFilters.singleSelect.isNotEmpty)
                ...state.specificationFilters.singleSelect.map((filter) {
                  if (filter.key == 'style') {
                    return SizedBox.shrink();
                  }

                  return Column(
                    children: [
                      AppSelectionPills<String>(
                        label: filter.label,
                        value: state.specifications[filter.key],
                        isRequired: true,
                        options: filter.options
                            .map(
                              (opt) =>
                                  SelectionPillOption(label: opt, value: opt),
                            )
                            .toList(),
                        onChanged: (val) =>
                            context.read<PropertyFormBloc>().add(
                              PropertyFormDynamicSingleSelectChanged(
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
                // Fallback: Total Floors
                AppSelectionPills<int>(
                  label: 'จำนวนชั้น',
                  value: state.totalFloors,
                  isRequired: true,
                  options: List.generate(
                    5,
                    (i) => SelectionPillOption(label: '${i + 1}', value: i + 1),
                  ),
                  onChanged: (val) => context.read<PropertyFormBloc>().add(
                    PropertyFormDetailsUpdated(totalFloors: val),
                  ),
                ),
                const SizedBox(height: 24),

                // Fallback: Bedrooms
                AppSelectionPills<int>(
                  label: 'จำนวนห้องนอน',
                  value: state.bedrooms,
                  isRequired: true,
                  options: [
                    ...List.generate(
                      8,
                      (i) =>
                          SelectionPillOption(label: '${i + 1}', value: i + 1),
                    ),
                    const SelectionPillOption(label: 'Studio', value: 0),
                  ],
                  onChanged: (val) => context.read<PropertyFormBloc>().add(
                    PropertyFormDetailsUpdated(bedrooms: val),
                  ),
                ),
                const SizedBox(height: 24),

                // Fallback: Bathrooms
                AppSelectionPills<int>(
                  label: 'จำนวนห้องน้ำ',
                  value: state.bathrooms,
                  isRequired: true,
                  options: List.generate(
                    8,
                    (i) => SelectionPillOption(label: '${i + 1}', value: i + 1),
                  ),
                  onChanged: (val) => context.read<PropertyFormBloc>().add(
                    PropertyFormDetailsUpdated(bathrooms: val),
                  ),
                ),
                const SizedBox(height: 24),

                // Fallback: Parking
                AppSelectionPills<int>(
                  label: 'จำนวนที่จอดรถ',
                  value: state.garage,
                  isRequired: true,
                  options: List.generate(
                    8,
                    (i) => SelectionPillOption(label: '${i + 1}', value: i + 1),
                  ),
                  onChanged: (val) => context.read<PropertyFormBloc>().add(
                    PropertyFormDetailsUpdated(garage: val),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Construction Date (Built)
              AppTextFormField(
                label: 'วันที่สร้าง',
                controller: _builtController,
                isRequired: true,
                readOnly: false,
                showCursor: false,
                hintText: 'เลือกวันที่สร้าง',
                suffix: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SvgPicture.asset(
                    'assets/icons/calendar.svg',
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                      AppColors.baseGrey,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1980),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    if (!context.mounted) return;
                    context.read<PropertyFormBloc>().add(
                      PropertyFormAdditionalInfoUpdated(
                        built: picked.toIso8601String(),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),

              // Property Color (Asset Color) - Updated to use AppDropdownFormField
              AppDropdownFormField<PropertyColor>(
                label: 'สีทรัพย์',
                value: state.houseColor,
                isRequired: true,
                hint: 'เลือกสีทรัพย์',
                items: PropertyColor.values,
                itemLabel: (color) => color.label,
                onChanged: (val) => context.read<PropertyFormBloc>().add(
                  PropertyFormDetailsUpdated(houseColor: val),
                ),
              ),
              const SizedBox(height: 24),

              // Price
              AppTextFormField(
                label: 'ราคา',
                controller: _priceController,
                inputFormatters: [CurrencyInputFormatter()],
                isRequired: true,
                hintText: '0',
                suffix: Text(
                  'บาท',
                  style: GoogleFonts.anuphan(color: AppColors.baseGrey),
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) => context.read<PropertyFormBloc>().add(
                  PropertyFormGeneralInfoUpdated(
                    price: double.tryParse(val.replaceAll(',', '')),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Land Size & Building Size
              Row(
                children: [
                  if (!isCondoOrApt) ...[
                    Expanded(
                      child: AppTextFormField(
                        label: 'ขนาดที่ดิน',
                        controller: _landSizeController,
                        maxLength: 6,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        ],
                        isRequired: true,
                        hintText: '0.00',
                        suffix: Text(
                          'ตร.ว.',
                          style: GoogleFonts.anuphan(color: AppColors.baseGrey),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: true,
                          decimal: true,
                        ),
                        onChanged: (val) =>
                            context.read<PropertyFormBloc>().add(
                              PropertyFormDetailsUpdated(
                                landSize: double.tryParse(val),
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: AppTextFormField(
                      label: 'พื้นที่ใช้สอย',
                      controller: _buildingSizeController,
                      maxLength: 6,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      ],
                      isRequired: true,
                      hintText: '0.00',
                      suffix: Text(
                        'ตร.ม.',
                        style: GoogleFonts.anuphan(color: AppColors.baseGrey),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                      onChanged: (val) => context.read<PropertyFormBloc>().add(
                        PropertyFormDetailsUpdated(
                          buildingSize: double.tryParse(val),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Direction - Updated to use AppDropdownFormField
              AppDropdownFormField<PropertyDirection>(
                label: 'ทิศหน้าบ้าน',
                value: state.direction,
                hint: 'เลือกทิศหน้าบ้าน',
                items: PropertyDirection.values,
                itemLabel: (dir) => dir.label,
                onChanged: (val) => context.read<PropertyFormBloc>().add(
                  PropertyFormAdditionalInfoUpdated(direction: val),
                ),
              ),
              const SizedBox(height: 100), // Bottom padding
            ],
          ),
        );
      },
    );
  }
}
