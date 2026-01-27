import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/data/models/contract_model.dart';
import 'package:youragent/features/contracts/bloc/contracts_bloc.dart';
import 'package:youragent/domain/entities/contract_status.dart';
import 'package:youragent/widgets/inputs/app_dropdown.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/l10n/app_localizations.dart';

class ContractsFilterSection extends StatefulWidget {
  const ContractsFilterSection({super.key});

  @override
  State<ContractsFilterSection> createState() => _ContractsFilterSectionState();
}

class _ContractsFilterSectionState extends State<ContractsFilterSection> {
  final TextEditingController _contractNumberController =
      TextEditingController();
  final TextEditingController _propertyNameController = TextEditingController();
  final TextEditingController _lessorController = TextEditingController();
  final TextEditingController _lesseeController = TextEditingController();

  @override
  void dispose() {
    _contractNumberController.dispose();
    _propertyNameController.dispose();
    _lessorController.dispose();
    _lesseeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContractsBloc, ContractsState>(
      builder: (context, state) {
        final loadedState = state is ContractsLoaded ? state : null;
        final selectedStatus = loadedState?.selectedStatus;
        final selectedPropertyType = loadedState?.selectedPropertyType;
        final allContracts = loadedState?.allContracts ?? [];

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 1200;
            final isMedium = constraints.maxWidth > 800;

            if (isWide) {
              return _buildWideLayout(
                selectedStatus,
                selectedPropertyType,
                allContracts,
              );
            } else if (isMedium) {
              return _buildMediumLayout(
                selectedStatus,
                selectedPropertyType,
                allContracts,
              );
            }
            return _buildNarrowLayout(
              selectedStatus,
              selectedPropertyType,
              allContracts,
            );
          },
        );
      },
    );
  }

  Widget _buildWideLayout(
    ContractStatus? selectedStatus,
    String? selectedPropertyType,
    List<ContractModel> allContracts,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                _contractNumberController,
                l10n.search_contract_number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                _propertyNameController,
                l10n.search_property_name,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(_lessorController, l10n.search_lessor),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(_lesseeController, l10n.search_lessee),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatusDropdown(
                value: selectedStatus,
                hint: l10n.select_contract_status,
                onChanged: (value) {
                  context.read<ContractsBloc>().add(
                    ContractsFilterChanged(selectedStatus: value),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown(
                value: selectedPropertyType,
                hint: l10n.select_property_type_contract,
                items: _getUniquePropertyTypes(allContracts),
                onChanged: (value) {
                  context.read<ContractsBloc>().add(
                    ContractsFilterChanged(selectedPropertyType: value),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            _buildActionButtons(),
          ],
        ),
      ],
    );
  }

  Widget _buildMediumLayout(
    ContractStatus? selectedStatus,
    String? selectedPropertyType,
    List<ContractModel> allContracts,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                _contractNumberController,
                l10n.search_contract_number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                _propertyNameController,
                l10n.search_property_name,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(_lessorController, l10n.search_lessor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(_lesseeController, l10n.search_lessee),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatusDropdown(
                value: selectedStatus,
                hint: l10n.select_contract_status,
                onChanged: (value) {
                  context.read<ContractsBloc>().add(
                    ContractsFilterChanged(selectedStatus: value),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown(
                value: selectedPropertyType,
                hint: l10n.select_property_type_contract,
                items: _getUniquePropertyTypes(allContracts),
                onChanged: (value) {
                  context.read<ContractsBloc>().add(
                    ContractsFilterChanged(selectedPropertyType: value),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            _buildActionButtons(expanded: false),
          ],
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(
    ContractStatus? selectedStatus,
    String? selectedPropertyType,
    List<ContractModel> allContracts,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildTextField(_contractNumberController, l10n.search_contract_number),
        const SizedBox(height: 12),
        _buildTextField(_propertyNameController, l10n.search_property_name),
        const SizedBox(height: 12),
        _buildTextField(_lessorController, l10n.search_lessor),
        const SizedBox(height: 12),
        _buildTextField(_lesseeController, l10n.search_lessee),
        const SizedBox(height: 12),
        _buildStatusDropdown(
          value: selectedStatus,
          hint: l10n.select_contract_status,
          onChanged: (value) {
            context.read<ContractsBloc>().add(
              ContractsFilterChanged(selectedStatus: value),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildDropdown(
          value: selectedPropertyType,
          hint: l10n.select_property_type_contract,
          items: _getUniquePropertyTypes(allContracts),
          onChanged: (value) {
            context.read<ContractsBloc>().add(
              ContractsFilterChanged(selectedPropertyType: value),
            );
          },
        ),
        const SizedBox(height: 16),
        Row(children: [Expanded(child: _buildActionButtons(split: true))]),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.anuphan(color: const Color(0xFFA4A7AE)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE9EAEB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE9EAEB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildActionButtons({bool expanded = false, bool split = false}) {
    final l10n = AppLocalizations.of(context)!;
    final searchButton = AppButtons.secondary(
      label: l10n.search,
      icon: const Icon(Icons.search, size: 20, color: AppColors.white),
      iconPosition: IconPosition.start,
      onPressed: () {
        context.read<ContractsBloc>().add(
          ContractsFilterChanged(
            contractNumber: _contractNumberController.text,
            propertyName: _propertyNameController.text,
            lessor: _lessorController.text,
            lessee: _lesseeController.text,
          ),
        );
      },
    );

    final clearButton = AppButtons.outlined(
      label: l10n.clear_data,
      icon: const Icon(Icons.clear, size: 20, color: AppColors.baseDarkGrey),
      iconPosition: IconPosition.start,
      color: ButtonColor.gray,
      onPressed: () {
        _contractNumberController.clear();
        _propertyNameController.clear();
        _lessorController.clear();
        _lesseeController.clear();
        context.read<ContractsBloc>().add(
          const ContractsFilterChanged(
            contractNumber: '',
            propertyName: '',
            lessor: '',
            lessee: '',
            selectedStatus: null,
            selectedPropertyType: null,
          ),
        );
      },
    );

    if (split) {
      return Row(
        children: [
          Expanded(child: searchButton),
          const SizedBox(width: 12),
          Expanded(child: clearButton),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (expanded) Expanded(child: searchButton) else searchButton,
        const SizedBox(width: 12),
        if (expanded) Expanded(child: clearButton) else clearButton,
      ],
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return AppDropdown<String>(
      value: value,
      hint: hint,
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildStatusDropdown({
    required ContractStatus? value,
    required String hint,
    required Function(ContractStatus?) onChanged,
  }) {
    // Use AppDropdown but with a custom display by creating a wrapper
    // that converts enum to display string and back
    return _ContractStatusDropdownWrapper(
      value: value,
      hint: hint,
      items: ContractStatus.values,
      onChanged: onChanged,
    );
  }

  List<String> _getUniquePropertyTypes(List<ContractModel> allContracts) {
    final propertyTypes = allContracts
        .map((c) => c.propertyType)
        .whereType<String>()
        .toSet()
        .toList();
    propertyTypes.sort();
    return propertyTypes;
  }
}

/// Custom dropdown wrapper for ContractStatus that displays Thai labels
class _ContractStatusDropdownWrapper extends StatelessWidget {
  final ContractStatus? value;
  final String hint;
  final List<ContractStatus> items;
  final Function(ContractStatus?) onChanged;

  const _ContractStatusDropdownWrapper({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Convert enum to display string for the dropdown
    final displayValue = value?.getLabel();
    final displayItems = items.map((status) => status.getLabel()).toList();

    return AppDropdown<String>(
      value: displayValue,
      hint: hint,
      items: displayItems,
      onChanged: (displayLabel) {
        // Convert display string back to enum
        if (displayLabel == null) {
          onChanged(null);
        } else {
          final status = items.firstWhere(
            (s) => s.getLabel() == displayLabel,
            orElse: () => items.first,
          );
          onChanged(status);
        }
      },
    );
  }
}
