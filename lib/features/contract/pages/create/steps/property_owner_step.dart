import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/person_type.dart';
import 'package:youragent/domain/entities/property_owner.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_bloc.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_event.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_state.dart';
import 'package:youragent/widgets/inputs/app_text_field.dart';
import 'package:youragent/widgets/inputs/app_chip_selection.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import '../../../widgets/user_registration_bottom_sheet.dart';
import 'package:youragent/l10n/app_localizations.dart';

class PropertyOwnerStep extends StatefulWidget {
  final bool hideHeader;

  const PropertyOwnerStep({super.key, this.hideHeader = false});

  @override
  State<PropertyOwnerStep> createState() => _PropertyOwnerStepState();
}

class _PropertyOwnerStepState extends State<PropertyOwnerStep> {
  late final TextEditingController _nameController;
  late final TextEditingController _idCardController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _signatoryController;

  @override
  void initState() {
    super.initState();
    final state = context.read<ContractFormBloc>().state;
    _nameController = TextEditingController(text: state.ownerName);
    _idCardController = TextEditingController(text: state.ownerIdCard);
    _addressController = TextEditingController(text: state.ownerAddress);
    _phoneController = TextEditingController(text: state.ownerPhone);
    _emailController = TextEditingController(text: state.ownerEmail);
    _signatoryController = TextEditingController(text: state.ownerSignatory);

    // Initial fetch for owners if needed
    context.read<ContractFormBloc>().add(const ContractFormOwnersFetched(''));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idCardController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _signatoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContractFormBloc, ContractFormState>(
      listenWhen: (prev, curr) => prev.selectedOwner != curr.selectedOwner,
      listener: (context, state) {
        if (state.selectedOwner != null) {
          _nameController.text = state.ownerName;
          _idCardController.text = state.ownerIdCard;
          _addressController.text = state.ownerAddress;
          _phoneController.text = state.ownerPhone;
          _emailController.text = state.ownerEmail;
          _signatoryController.text = state.ownerSignatory;
        }
      },
      child: BlocBuilder<ContractFormBloc, ContractFormState>(
        builder: (context, state) {
          return SizedBox(
            height: double.infinity,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Badge & Step
                  if (!widget.hideHeader)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppBadge(
                          label: AppLocalizations.of(context)!.dataProperty,
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
                  if (!widget.hideHeader) const SizedBox(height: 32),

                  // Person Type Selection
                  AppChipSelection<PersonType>(
                    label: AppLocalizations.of(context)!.personTypeLabel,
                    isRequired: true,
                    value: state.ownerType,
                    options: [
                      AppChipOption(
                        label: AppLocalizations.of(context)!.individual,
                        value: PersonType.individual,
                      ),
                      AppChipOption(
                        label: AppLocalizations.of(context)!.juristic_person,
                        value: PersonType.juristic,
                      ),
                    ],
                    onChanged: (type) => context.read<ContractFormBloc>().add(
                      ContractFormOwnerTypeUpdated(type),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Owner Name with TypeAhead
                  TypeAheadField<PropertyOwner>(
                    controller: _nameController,
                    builder: (context, controller, focusNode) => AppTextField(
                      label: AppLocalizations.of(context)!.full_name_or_company,
                      controller: controller,
                      focusNode: focusNode,
                      isRequired: true,
                      hintText: AppLocalizations.of(
                        context,
                      )!.full_name_or_company,
                      onChanged: (value) => context
                          .read<ContractFormBloc>()
                          .add(ContractFormOwnerNameUpdated(value)),
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
                      context.read<ContractFormBloc>().add(
                        ContractFormOwnersFetched(pattern),
                      );
                      return state.owners;
                    },
                    itemBuilder: (context, owner) {
                      return ListTile(
                        title: Text(owner.name),
                        subtitle: Text(owner.email ?? owner.phone ?? ''),
                      );
                    },
                    onSelected: (owner) {
                      context.read<ContractFormBloc>().add(
                        ContractFormOwnerSelected(owner),
                      );

                      FocusScope.of(context).unfocus();
                    },
                    emptyBuilder: (context) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        AppLocalizations.of(context)!.propertyOwnerNotFound,
                        style: GoogleFonts.anuphan(color: AppColors.baseGrey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.searchDataNameProperty,
                    style: GoogleFonts.anuphan(
                      color: AppColors.baseGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Create New Account Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => UserRegistrationBottomSheet.show(
                        context,
                        RegistrationUserType.owner,
                      ),
                      icon: const Icon(Icons.add, size: 20),
                      label: Text(
                        AppLocalizations.of(context)!.createNewAccountTitle,
                        style: GoogleFonts.anuphan(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.brandGreen,
                        backgroundColor: AppColors.brandLightGreen,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(
                          color: AppColors.brandLightGreen,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ID Card / Tax ID
                  AppTextField(
                    label: AppLocalizations.of(context)!.id_card_or_tax_id,
                    controller: _idCardController,
                    isRequired: true,
                    hintText: AppLocalizations.of(context)!.id_card_or_tax_id,
                    onChanged: (value) => context.read<ContractFormBloc>().add(
                      ContractFormOwnerIdCardUpdated(value),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Address
                  AppTextField(
                    label: AppLocalizations.of(context)!.currentAddressLabel,
                    controller: _addressController,
                    isRequired: true,
                    hintText: AppLocalizations.of(context)!.currentAddressLabel,
                    onChanged: (value) => context.read<ContractFormBloc>().add(
                      ContractFormOwnerAddressUpdated(value),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Phone
                  AppTextField(
                    label: AppLocalizations.of(context)!.phone_number,
                    controller: _phoneController,
                    isRequired: true,
                    hintText: AppLocalizations.of(context)!.phone_number,
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => context.read<ContractFormBloc>().add(
                      ContractFormOwnerPhoneUpdated(value),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Email
                  AppTextField(
                    label: AppLocalizations.of(context)!.email,
                    controller: _emailController,
                    isRequired: true,
                    hintText: AppLocalizations.of(context)!.email,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => context.read<ContractFormBloc>().add(
                      ContractFormOwnerEmailUpdated(value),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Signatory
                  AppTextField(
                    label: AppLocalizations.of(context)!.authorized_signatory,
                    controller: _signatoryController,
                    isRequired: true,
                    hintText: AppLocalizations.of(
                      context,
                    )!.authorized_signatory,
                    onChanged: (value) => context.read<ContractFormBloc>().add(
                      ContractFormOwnerSignatoryUpdated(value),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
