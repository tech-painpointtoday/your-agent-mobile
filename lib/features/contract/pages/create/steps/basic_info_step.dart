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
import 'package:youragent/l10n/app_localizations.dart';

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
        final baseDate =
            state.contractDate ?? state.leaseStartDate ?? DateTime.now();

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
                    AppBadge(
                      label: AppLocalizations.of(context)!.general_information,
                      fontSize: 16,
                      color: BadgeColor.blue,
                    ),
                    AppBadge(
                      color: BadgeColor.default_,
                      label: '${state.step}/7',
                      fontSize: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Property Name Field with TypeAhead
                TypeAheadField<Property>(
                  controller: _propertyNameController,
                  hideOnEmpty: false,
                  builder: (context, controller, focusNode) => AppTextField(
                    label: AppLocalizations.of(context)!.propertyNameHint,
                    controller: controller,
                    focusNode: focusNode,
                    isRequired: true,
                    hintText: AppLocalizations.of(context)!.search_property_name,
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
                      AppLocalizations.of(context)!.propertyDataNotFound,
                      style: GoogleFonts.anuphan(color: AppColors.baseGrey),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.searchDataName,
                  style: GoogleFonts.anuphan(
                    color: AppColors.baseGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 24),

                // Contract Date Field
                AppTextField(
                  label: AppLocalizations.of(context)!.contract_date,
                  isRequired: true,
                  readOnly: false,
                  controller: TextEditingController(
                    text: state.contractDate != null
                        ? '${state.contractDate!.day}/${state.contractDate!.month}/${state.contractDate!.year + 543}'
                        : '',
                  ),
                  hintText: AppLocalizations.of(context)!.contractSelect,
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
                  label: AppLocalizations.of(context)!.contractTypeTitle,
                  isRequired: true,
                  value: state.contractType,
                  options: [
                    AppChipOption(label: AppLocalizations.of(context)!.saleContractType, value: ContractType.buy),
                    AppChipOption(label: AppLocalizations.of(context)!.rentContractType, value: ContractType.rent),
                  ],
                  onChanged: (type) => context.read<ContractFormBloc>().add(
                    ContractFormTypeUpdated(type),
                  ),
                ),

                if (state.contractType == ContractType.rent) ...[
                  const SizedBox(height: 24),
                  AppChipSelection<String>(
                    label: AppLocalizations.of(context)!.contractFormat,
                    value: state.leaseFormat.isEmpty ? null : state.leaseFormat,
                    options: [
                      AppChipOption(
                        label: AppLocalizations.of(context)!.sixMonthLeaseContract,
                        value: AppLocalizations.of(context)!.sixMonthLeaseContract,
                      ),
                      AppChipOption(
                        label: AppLocalizations.of(context)!.twelveMonthLeaseContract,
                        value: AppLocalizations.of(context)!.twelveMonthLeaseContract,
                      ),
                    ],
                    onChanged: (format) {
                      context.read<ContractFormBloc>().add(
                        ContractFormLeaseFormatUpdated(format),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: AppLocalizations.of(context)!.contract_start_date,
                    isRequired: true,
                    controller: TextEditingController(
                      text: state.leaseStartDate != null
                          ? '${state.leaseStartDate!.day}/${state.leaseStartDate!.month}/${state.leaseStartDate!.year + 543}'
                          : '',
                    ),
                    hintText: AppLocalizations.of(context)!.selectContractStartDate,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: baseDate,
                        firstDate: baseDate,
                        lastDate: DateTime(baseDate.year + 100),
                      );
                      if (date != null && context.mounted) {
                        context.read<ContractFormBloc>().add(
                          ContractFormLeaseStartDateUpdated(date),
                        );
                      }
                    },
                    suffix: _buildDateIcon(),
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: AppLocalizations.of(context)!.twelveMonthLeaseContract,
                    isRequired: true,
                    readOnly: state.leaseFormat.isNotEmpty,
                    controller: TextEditingController(
                      text: state.leaseEndDate != null
                          ? '${state.leaseEndDate!.day}/${state.leaseEndDate!.month}/${state.leaseEndDate!.year + 543}'
                          : '',
                    ),
                    hintText: AppLocalizations.of(context)!.selectContractEndDate,
                    onTap: state.leaseFormat.isNotEmpty
                        ? null
                        : () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate:
                                  state.leaseEndDate ??
                                  state.leaseStartDate?.add(
                                    const Duration(days: 180),
                                  ) ??
                                  DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null && context.mounted) {
                              context.read<ContractFormBloc>().add(
                                ContractFormLeaseEndDateUpdated(date),
                              );
                            }
                          },
                    suffix: _buildDateIcon(),
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: AppLocalizations.of(context)!.totalLeasePeriod,
                    readOnly: true,
                    controller: TextEditingController(
                      text: _formatDuration(state.leaseDuration),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(int days) {
    if (days == 0) return '';
    final months = days ~/ 30;
    final remainingDays = days % 30;
    if (remainingDays == 0) {
      return '$months เดือน';
    }
    return '$months เดือน $remainingDays วัน';
  }

  Widget _buildDateIcon() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
      child: SvgPicture.asset(
        'assets/icons/calendar.svg',
        width: 16,
        height: 16,
        colorFilter: const ColorFilter.mode(
          AppColors.baseGrey,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
