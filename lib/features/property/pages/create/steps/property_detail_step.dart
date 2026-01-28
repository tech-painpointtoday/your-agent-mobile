import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import 'package:youragent/features/property/bloc/create_property/create_property_bloc.dart';
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
    final state = context.read<CreatePropertyBloc>().state;
    context.read<CreatePropertyBloc>().add(
      const CreatePropertyFiltersFetched(),
    );
    _builtController = TextEditingController(
      text: state.built != null
          ? DateFormat('dd/MM/yyyy').format(DateTime.parse(state.built!))
          : '',
    );
    _priceController = TextEditingController(
      text: state.price != null
          // If decimal is 0, show integer to avoid "1000.0"
          ? (state.price! % 1 == 0
                ? state.price!.toInt().toString()
                : state.price.toString())
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
    return BlocConsumer<CreatePropertyBloc, CreatePropertyState>(
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
                onChanged: (val) => context.read<CreatePropertyBloc>().add(
                  CreatePropertyListingTypeChanged(val),
                ),
              ),
              const SizedBox(height: 24),

              // Occupancy Status
              AppSelectionPills<String>(
                label: 'สถานะ',
                value: state.occupancyStatus,
                isRequired: true,
                options: const [
                  SelectionPillOption(label: 'ว่าง', value: 'ว่าง'),
                  SelectionPillOption(label: 'ไม่ว่าง', value: 'ไม่ว่าง'),
                ],
                onChanged: (val) => context.read<CreatePropertyBloc>().add(
                  CreatePropertyOccupancyStatusChanged(val),
                ),
              ),
              const SizedBox(height: 24),

              // Dynamic Filters or Fallback
              if (state.specificationFilters.singleSelect.isNotEmpty)
                ...state.specificationFilters.singleSelect.map((filter) {
                  return Column(
                    children: [
                      AppSelectionPills<String>(
                        label: filter.label,
                        value: state.dynamicValues[filter.key]?.toString(),
                        isRequired: true,
                        options: filter.options
                            .map(
                              (opt) =>
                                  SelectionPillOption(label: opt, value: opt),
                            )
                            .toList(),
                        onChanged: (val) =>
                            context.read<CreatePropertyBloc>().add(
                              CreatePropertyDynamicSingleSelectChanged(
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
                  onChanged: (val) => context.read<CreatePropertyBloc>().add(
                    CreatePropertyDetailsUpdated(totalFloors: val),
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
                  onChanged: (val) => context.read<CreatePropertyBloc>().add(
                    CreatePropertyDetailsUpdated(bedrooms: val),
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
                  onChanged: (val) => context.read<CreatePropertyBloc>().add(
                    CreatePropertyDetailsUpdated(bathrooms: val),
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
                  onChanged: (val) => context.read<CreatePropertyBloc>().add(
                    CreatePropertyDetailsUpdated(garage: val),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Construction Date (Built)
              AppTextFormField(
                label: 'วันที่สร้าง',
                controller: _builtController,
                isRequired: true,
                readOnly: true,
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
                    context.read<CreatePropertyBloc>().add(
                      CreatePropertyAdditionalInfoUpdated(
                        built: picked.toIso8601String(),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),

              // Property Color (Asset Color) - Updated to use AppDropdownFormField
              AppDropdownFormField<String>(
                label: 'สีทรัพย์',
                value: state.houseColor,
                isRequired: true,
                hint: 'เลือกสีทรัพย์',
                items: const [
                  'ขาว',
                  'ครีม',
                  'เทา',
                  'ดำ',
                  'น้ำตาล',
                  'แดง',
                  'เหลือง',
                  'เขียว',
                  'ฟ้า',
                  'ชมพู',
                  'ม่วง',
                  'ส้ม',
                ],
                onChanged: (val) => context.read<CreatePropertyBloc>().add(
                  CreatePropertyDetailsUpdated(houseColor: val),
                ),
              ),
              const SizedBox(height: 24),

              // Price
              AppTextFormField(
                label: 'ราคา',
                controller: _priceController,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                ],
                isRequired: true,
                hintText: '0',
                suffix: Text(
                  'บาท',
                  style: GoogleFonts.anuphan(color: AppColors.baseGrey),
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) => context.read<CreatePropertyBloc>().add(
                  CreatePropertyGeneralInfoUpdated(price: double.tryParse(val)),
                ),
              ),
              const SizedBox(height: 24),

              // Land Size & Building Size
              Row(
                children: [
                  Expanded(
                    child: AppTextFormField(
                      label: 'ขนาดที่ดิน',
                      controller: _landSizeController,
                      isRequired: true,
                      hintText: '0.00',
                      suffix: Text(
                        'ตร.ว.',
                        style: GoogleFonts.anuphan(color: AppColors.baseGrey),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (val) =>
                          context.read<CreatePropertyBloc>().add(
                            CreatePropertyDetailsUpdated(
                              landSize: double.tryParse(val),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextFormField(
                      label: 'พื้นที่ใช้สอย',
                      controller: _buildingSizeController,
                      isRequired: true,
                      hintText: '0.00',
                      suffix: Text(
                        'ตร.ม.',
                        style: GoogleFonts.anuphan(color: AppColors.baseGrey),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (val) =>
                          context.read<CreatePropertyBloc>().add(
                            CreatePropertyDetailsUpdated(
                              buildingSize: double.tryParse(val),
                            ),
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Direction - Updated to use AppDropdownFormField
              AppDropdownFormField<String>(
                label: 'ทิศหน้าบ้าน',
                value: state.direction,
                hint: 'เลือกทิศหน้าบ้าน',
                items: const [
                  'ทิศเหนือ',
                  'ทิศใต้',
                  'ทิศตะวันออก',
                  'ทิศตะวันตก',
                  'ทิศตะวันออกเฉียงเหนือ',
                  'ทิศตะวันออกเฉียงใต้',
                  'ทิศตะวันตกเฉียงเหนือ',
                  'ทิศตะวันตกเฉียงใต้',
                ],
                onChanged: (val) => context.read<CreatePropertyBloc>().add(
                  CreatePropertyAdditionalInfoUpdated(direction: val),
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
