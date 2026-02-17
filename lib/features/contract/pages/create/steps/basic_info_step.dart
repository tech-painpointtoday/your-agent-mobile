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
import 'package:youragent/core/extensions/l10n_extensions.dart';
import 'package:youragent/widgets/modals/app_status_bottom_sheet.dart';

class BasicInfoStep extends StatefulWidget {
  const BasicInfoStep({super.key});

  @override
  State<BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends State<BasicInfoStep> {
  late final TextEditingController _propertyNameController;
  late final TextEditingController _signingPlaceController;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<ContractFormBloc>();
    _propertyNameController = TextEditingController(
      text: bloc.state.propertyName,
    );
    _signingPlaceController = TextEditingController(
      text: bloc.state.signingPlace,
    );

    // Initial fetch for properties to show suggestions on focus
    if (bloc.state.properties.isEmpty) {
      bloc.add(const ContractFormPropertiesFetched(''));
    }
  }

  @override
  void dispose() {
    _propertyNameController.dispose();
    _signingPlaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContractFormBloc, ContractFormState>(
      listenWhen: (prev, curr) =>
          prev.propertyName != curr.propertyName ||
          prev.signingPlace != curr.signingPlace ||
          prev.status != curr.status ||
          prev.errorMessage != curr.errorMessage,
      listener: (context, state) {
        if (state.status == ContractFormStatus.failure &&
            state.errorMessage == 'no_approved_properties') {
          AppStatusBottomSheet.showWarning(
            context: context,
            iconPath: 'assets/images/YA_Illustration_ConfirmWarning.png',
            title: 'ไม่สามารถสร้างสัญญาได้',
            message:
                'คุณต้องมีทรัพย์ที่ผ่านการอนุมัติแล้วในระบบก่อน\nจึงจะสามารถสร้างเอกสารสัญญาได้',
            onOk: () {
              Navigator.of(context).pop(); // Pop bottom sheet
              Navigator.of(context).pop(); // Pop AddContractScreen
            },
          );
        }

        if (_propertyNameController.text != state.propertyName) {
          _propertyNameController.text = state.propertyName;
        }
        if (_signingPlaceController.text != state.signingPlace) {
          _signingPlaceController.text = state.signingPlace;
        }
      },
      child: BlocBuilder<ContractFormBloc, ContractFormState>(
        builder: (context, state) {
          final baseDate =
              state.contractDate ?? state.leaseStartDate ?? DateTime.now();

          return SizedBox(
            height: double.infinity,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Badge & Step
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppBadge(
                        label: context.l10n.general_information,
                        fontSize: 16,
                        color: BadgeColor.blue,
                      ),
                      AppBadge(
                        color: BadgeColor.default_,
                        label: '${state.step}/8',
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
                      label: context.l10n.propertyNameHint,
                      controller: controller,
                      focusNode: focusNode,
                      isRequired: true,
                      hintText: context.l10n.search_property_name,
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
                    suggestionsCallback: (pattern) async {
                      if (pattern.isEmpty) {
                        if (state.properties.isEmpty) {
                          context.read<ContractFormBloc>().add(
                            const ContractFormPropertiesFetched(''),
                          );
                          // Wait for fetching to start and then finish, or timeout
                          int retries = 0;
                          while (retries < 15 && mounted) {
                            final currentState = context
                                .read<ContractFormBloc>()
                                .state;
                            if (!currentState.isFetchingProperties) break;
                            await Future.delayed(
                              const Duration(milliseconds: 200),
                            );
                            retries++;
                          }
                        }
                        return context
                            .read<ContractFormBloc>()
                            .state
                            .properties;
                      }

                      final query = pattern.toLowerCase();
                      return state.properties.where((p) {
                        final nameMatch =
                            p.name?.toLowerCase().contains(query) ?? false;
                        final titleMatch = p.title.toLowerCase().contains(
                          query,
                        );
                        final addressMatch =
                            p.address?.toLowerCase().contains(query) ?? false;
                        return nameMatch || titleMatch || addressMatch;
                      }).toList();
                    },
                    itemBuilder: (context, property) {
                      if (property.approvalStatus !=
                          PropertyApprovalStatus.approved) {
                        return const SizedBox.shrink();
                      }
                      return ListTile(
                        title: Text.rich(
                          TextSpan(
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
                                    '(${AppUtils.generatePropertyCode(property)})',
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
                          '${property.name ?? property.title} (${AppUtils.generatePropertyCode(property)})';
                      context.read<ContractFormBloc>().add(
                        ContractFormPropertySelected(property),
                      );
                      FocusScope.of(context).unfocus();
                    },
                    loadingBuilder: (context) => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    emptyBuilder: (context) {
                      if (state.isFetchingProperties) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          context.l10n.propertyDataNotFound,
                          style: GoogleFonts.anuphan(color: AppColors.baseGrey),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.searchDataName,
                    style: GoogleFonts.anuphan(
                      color: AppColors.baseGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Signing Place Field
                  AppTextField(
                    label: context.l10n.signing_place,
                    isRequired: true,
                    controller: _signingPlaceController,
                    hintText: context.l10n.enter_signing_place,
                    onChanged: (value) {
                      context.read<ContractFormBloc>().add(
                        ContractFormSigningPlaceUpdated(value),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Contract Date Field
                  AppTextField(
                    label: context.l10n.contract_date,
                    isRequired: true,
                    readOnly: false,
                    controller: TextEditingController(
                      text: state.contractDate != null
                          ? '${state.contractDate!.day}/${state.contractDate!.month}/${state.contractDate!.year + 543}'
                          : '',
                    ),
                    hintText: context.l10n.contractSelect,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: state.contractDate ?? DateTime.now(),
                        firstDate: state.contractDate ?? DateTime.now(),
                        lastDate: (state.contractDate ?? DateTime.now()).add(
                          const Duration(days: 365 * 100),
                        ),
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
                    label: context.l10n.contractTypeTitle,
                    isRequired: true,
                    value: state.contractType,
                    options: [
                      // Tmp Close
                      // AppChipOption(
                      //   label: context.l10n.saleContractType,
                      //   value: ContractType.buy,
                      // ),
                      AppChipOption(
                        label: context.l10n.rentContractType,
                        value: ContractType.rent,
                      ),
                    ],
                    onChanged: (type) => context.read<ContractFormBloc>().add(
                      ContractFormTypeUpdated(type),
                    ),
                  ),

                  if (state.contractType == ContractType.rent) ...[
                    const SizedBox(height: 24),
                    AppChipSelection<String>(
                      label: context.l10n.contractFormat,
                      value: state.leaseFormat.isEmpty
                          ? null
                          : state.leaseFormat,
                      options: [
                        AppChipOption(
                          label: context.l10n.sixMonthLeaseContract,
                          value: context.l10n.sixMonthLeaseContract,
                        ),
                        AppChipOption(
                          label: context.l10n.twelveMonthLeaseContract,
                          value: context.l10n.twelveMonthLeaseContract,
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
                      label: context.l10n.contract_start_date,
                      isRequired: true,
                      controller: TextEditingController(
                        text: state.leaseStartDate != null
                            ? '${state.leaseStartDate!.day}/${state.leaseStartDate!.month}/${state.leaseStartDate!.year + 543}'
                            : '',
                      ),
                      hintText: context.l10n.selectContractStartDate,
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
                      label: context.l10n.contract_end_date,
                      isRequired: true,
                      readOnly: state.leaseFormat.isNotEmpty,
                      controller: TextEditingController(
                        text: state.leaseEndDate != null
                            ? '${state.leaseEndDate!.day}/${state.leaseEndDate!.month}/${state.leaseEndDate!.year + 543}'
                            : '',
                      ),
                      hintText: context.l10n.selectContractEndDate,
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
                      label: context.l10n.totalLeasePeriod,
                      readOnly: true,
                      controller: TextEditingController(
                        text: _formatDuration(
                          state.leaseStartDate,
                          state.leaseEndDate,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(DateTime? start, DateTime? end) {
    return AppUtils.formatLeaseDuration(start, end);
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
