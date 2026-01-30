import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/contract_type.dart';
import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_bloc.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_event.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_state.dart';
import 'package:youragent/utils/app_utils.dart';
import 'package:youragent/widgets/inputs/app_text_field.dart';
import 'package:youragent/widgets/inputs/app_chip_selection.dart';
import 'package:youragent/widgets/badges/app_badge.dart';

class BasicInfoStep extends StatefulWidget {
  const BasicInfoStep({super.key});

  @override
  State<BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends State<BasicInfoStep> {
  late final TextEditingController _propertyNameController;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<ContractFormBloc>();
    _propertyNameController = TextEditingController(
      text: bloc.state.propertyName,
    );

    // Initial fetch for properties to show suggestions on focus
    if (bloc.state.properties.isEmpty) {
      bloc.add(const ContractFormPropertiesFetched(''));
    }
  }

  @override
  void dispose() {
    _propertyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContractFormBloc, ContractFormState>(
      builder: (context, state) {
        return SizedBox(
          height: double.infinity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Badge & Step
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppBadge(label: 'ข้อมูลทั่วไป', color: BadgeColor.blue),
                    AppBadge(
                      color: BadgeColor.default_,
                      label: '${state.step}/7',
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Property Name Field with TypeAhead
                TypeAheadField<Property>(
                  controller: _propertyNameController,
                  hideOnEmpty: false,
                  builder: (context, controller, focusNode) => AppTextField(
                    label: 'ชื่ออสังหาฯ',
                    controller: controller,
                    focusNode: focusNode,
                    isRequired: true,
                    hintText: 'ค้นหาชื่ออสังหาฯ',
                    onChanged: (value) {
                      context.read<ContractFormBloc>().add(
                        ContractFormPropertyNameUpdated(value),
                      );
                    },
                    suffix: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 8,
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/search.svg',
                        width: 16,
                        height: 16,
                        colorFilter: const ColorFilter.mode(
                          AppColors.baseGrey,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  suggestionsCallback: (pattern) {
                    if (pattern.isEmpty) return state.properties;

                    final query = pattern.toLowerCase();
                    return state.properties.where((p) {
                      final nameMatch =
                          p.name?.toLowerCase().contains(query) ?? false;
                      final titleMatch = p.title.toLowerCase().contains(query);
                      final addressMatch =
                          p.address?.toLowerCase().contains(query) ?? false;
                      return nameMatch || titleMatch || addressMatch;
                    }).toList();
                  },
                  itemBuilder: (context, property) {
                    return ListTile(
                      title: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: property.name ?? property.title,
                              style: GoogleFonts.anuphan(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: AppColors.baseBlack,
                              ),
                            ),
                            const WidgetSpan(child: SizedBox(width: 8)),
                            TextSpan(
                              text:
                                  '(${AppUtils.generatePropertyCode(propertyId: property.id!, createdAt: property.createdAt)})',
                              style: GoogleFonts.anuphan(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: AppColors.supportBlueDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      subtitle: Text(
                        '${property.number ?? ''} ${property.address ?? ''}',
                        style: GoogleFonts.anuphan(
                          color: AppColors.baseGrey,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                  onSelected: (property) {
                    _propertyNameController.text =
                        '${property.name ?? property.title} (${AppUtils.generatePropertyCode(propertyId: property.id!, createdAt: property.createdAt)})';
                    context.read<ContractFormBloc>().add(
                      ContractFormPropertySelected(property),
                    );
                    FocusScope.of(context).unfocus();
                  },
                  emptyBuilder: (context) => Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'ไม่พบข้อมูลอสังหาฯ',
                      style: GoogleFonts.anuphan(color: AppColors.baseGrey),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ค้นหาชื่ออสังหาฯ ในระบบ เพื่อเชื่อมต่อข้อมูล',
                  style: GoogleFonts.anuphan(
                    color: AppColors.baseGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 24),

                // Contract Date Field
                AppTextField(
                  label: 'วันที่ทำสัญญา',
                  isRequired: true,
                  readOnly: true,
                  controller: TextEditingController(
                    text: state.contractDate != null
                        ? '${state.contractDate!.day}/${state.contractDate!.month}/${state.contractDate!.year + 543}'
                        : '',
                  ),
                  hintText: 'เลือกวันที่ทำสัญญา',
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: state.contractDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: AppColors.primary,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null && context.mounted) {
                      context.read<ContractFormBloc>().add(
                        ContractFormDateUpdated(date),
                      );
                    }
                  },
                  suffix: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 8,
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/calendar.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        AppColors.baseGrey,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Contract Type Selection
                AppChipSelection<ContractType>(
                  label: 'ประเภทสัญญา',
                  isRequired: true,
                  value: state.contractType,
                  options: const [
                    AppChipOption(label: 'สัญญาขาย', value: ContractType.buy),
                    AppChipOption(label: 'สัญญาเช่า', value: ContractType.rent),
                  ],
                  onChanged: (type) => context.read<ContractFormBloc>().add(
                    ContractFormTypeUpdated(type),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
