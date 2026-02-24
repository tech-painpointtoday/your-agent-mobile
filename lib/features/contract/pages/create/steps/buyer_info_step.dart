import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/contract_type.dart';
import 'package:youragent/domain/entities/person_type.dart';
import 'package:youragent/domain/entities/buyer.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_bloc.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_event.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_state.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/widgets/inputs/app_text_field.dart';
import 'package:youragent/widgets/inputs/app_chip_selection.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import '../../../widgets/user_registration_bottom_sheet.dart';
import 'package:youragent/core/extensions/l10n_extensions.dart';
import 'package:youragent/utils/thai_phone_input_formatter.dart';
import 'package:youragent/utils/thai_id_input_formatter.dart';

class BuyerInfoStep extends StatefulWidget {
  final bool hideHeader;

  const BuyerInfoStep({super.key, this.hideHeader = false});

  @override
  State<BuyerInfoStep> createState() => _BuyerInfoStepState();
}

class _BuyerInfoStepState extends State<BuyerInfoStep> {
  late final TextEditingController _nameController;
  late final TextEditingController _idCardController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final state = context.read<ContractFormBloc>().state;
    _nameController = TextEditingController(text: state.buyerName);
    _idCardController = TextEditingController(text: state.buyerIdCard);
    _addressController = TextEditingController(text: state.buyerAddress);
    _phoneController = TextEditingController(text: state.buyerPhone);
    _emailController = TextEditingController(text: state.buyerEmail);

    // Initial fetch for buyers if needed
    context.read<ContractFormBloc>().add(const ContractFormBuyersFetched(''));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idCardController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: BlocListener<ContractFormBloc, ContractFormState>(
        listenWhen: (prev, curr) => prev.selectedBuyer != curr.selectedBuyer,
        listener: (context, state) {
          if (state.selectedBuyer != null) {
            _nameController.text = state.buyerName;
            _idCardController.text = state.buyerIdCard;
            _addressController.text = state.buyerAddress;
            _phoneController.text = state.buyerPhone;
            _emailController.text = state.buyerEmail;
          }
        },
        child: BlocBuilder<ContractFormBloc, ContractFormState>(
          builder: (context, state) {
            final isRent = state.contractType == ContractType.rent;

            return SizedBox(
              height: double.infinity,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Badge & Step
                    if (!widget.hideHeader)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppBadge(
                            label: isRent
                                ? context.l10n.renterInfo
                                : context.l10n.buyerInfo,
                            fontSize: 16,
                            color: BadgeColor.blue,
                          ),
                          AppBadge(
                            color: BadgeColor.default_,
                            fontSize: 16,
                            label: '${state.step}/8',
                          ),
                        ],
                      ),
                    if (!widget.hideHeader) const SizedBox(height: 32),

                    // Person Type Selection
                    AppChipSelection<PersonType>(
                      label: context.l10n.personTypeLabel,
                      isRequired: true,
                      value: state.buyerType,
                      options: [
                        AppChipOption(
                          label: context.l10n.individual,
                          value: PersonType.individual,
                        ),
                        AppChipOption(
                          label: context.l10n.juristic_person,
                          value: PersonType.juristic,
                        ),
                      ],
                      onChanged: (type) => context.read<ContractFormBloc>().add(
                        ContractFormBuyerTypeUpdated(type),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Buyer Name with TypeAhead
                    TypeAheadField<Buyer>(
                      controller: _nameController,
                      builder: (context, controller, focusNode) => AppTextField(
                        label: context.l10n.full_name_or_company,
                        controller: controller,
                        focusNode: focusNode,
                        isRequired: true,
                        hintText: context.l10n.full_name_or_company,
                        onChanged: (value) => context
                            .read<ContractFormBloc>()
                            .add(ContractFormBuyerNameUpdated(value)),
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
                        // Use local filtering on allBuyers for faster response
                        final allBuyers = state.allBuyers;
                        if (allBuyers.isEmpty) {
                          context.read<ContractFormBloc>().add(
                            ContractFormBuyersFetched(pattern),
                          );

                          // Wait for fetching to start and then finish, or timeout
                          int retries = 0;
                          while (retries < 15 && mounted) {
                            final currentState = context
                                .read<ContractFormBloc>()
                                .state;
                            if (!currentState.isFetchingBuyers) break;
                            await Future.delayed(
                              const Duration(milliseconds: 200),
                            );
                            retries++;
                          }
                          return context.read<ContractFormBloc>().state.buyers;
                        }

                        return allBuyers.where((buyer) {
                          final name = buyer.name.toLowerCase();
                          final query = pattern.toLowerCase();
                          return name.contains(query);
                        }).toList();
                      },
                      itemBuilder: (context, buyer) {
                        return ListTile(
                          title: Text(buyer.name),
                          subtitle: Text(buyer.email ?? buyer.phone ?? ''),
                        );
                      },
                      onSelected: (buyer) {
                        context.read<ContractFormBloc>().add(
                          ContractFormBuyerSelected(buyer),
                        );
                        FocusScope.of(context).unfocus();
                      },
                      loadingBuilder: (context) => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: SpinKitFadingCircle(
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                      ),
                      emptyBuilder: (context) {
                        if (state.isFetchingBuyers) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: SpinKitFadingCircle(
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            context.l10n.buyerDataNotFound,
                            style: GoogleFonts.anuphan(
                              color: AppColors.baseGrey,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context
                          .l10n
                          .searchDataNameProperty, // Hint text from image
                      style: GoogleFonts.anuphan(
                        color: AppColors.baseGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Create New Account Button
                    AppButton(
                      width: double.infinity,
                      text: context.l10n.createNewAccountTitle,
                      style: AppButtonStyle.outline,
                      backgroundColor: AppColors.brandLightGreen,
                      textColor: AppColors.brandGreen,
                      borderColor: AppColors.brandGreen.withValues(alpha: 0.16),
                      iconPath: 'assets/icons/plus.svg',
                      onPressed: () async {
                        final bloc = context.read<ContractFormBloc>();
                        final result = await UserRegistrationBottomSheet.show(
                          context,
                          RegistrationUserType.buyer,
                        );

                        if (result != null && mounted) {
                          // Update text controllers
                          _nameController.text = result.name;
                          _emailController.text = result.email;
                          _phoneController.text = result.phone;

                          // Update BLoC
                          bloc.add(ContractFormBuyerNameUpdated(result.name));
                          bloc.add(ContractFormBuyerEmailUpdated(result.email));
                          bloc.add(ContractFormBuyerPhoneUpdated(result.phone));
                          bloc.add(
                            ContractFormBuyerPasswordUpdated(result.password),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // ID Card / Tax ID
                    AppTextField(
                      label: context.l10n.id_card_or_tax_id,
                      controller: _idCardController,
                      isRequired: true,
                      hintText: 'x-xxxx-xxxxx-xx-x',
                      inputFormatters: [ThaiIdInputFormatter()],
                      validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        if (!ThaiIdInputFormatter.isValidThaiID(value)) {
                          return context.l10n.invalidThaiIdError;
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: (value) => context
                          .read<ContractFormBloc>()
                          .add(ContractFormBuyerIdCardUpdated(value)),
                    ),
                    const SizedBox(height: 24),

                    // Address
                    AppTextField(
                      label: context.l10n.currentAddressLabel,
                      controller: _addressController,
                      isRequired: true,
                      hintText: context.l10n.currentAddressLabel,
                      onChanged: (value) => context
                          .read<ContractFormBloc>()
                          .add(ContractFormBuyerAddressUpdated(value)),
                    ),
                    const SizedBox(height: 24),

                    // Phone
                    AppTextField(
                      label: context.l10n.phone_number,
                      controller: _phoneController,
                      isRequired: true,
                      hintText: context.l10n.phone_number,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [ThaiPhoneInputFormatter()],
                      onChanged: (value) => context
                          .read<ContractFormBloc>()
                          .add(ContractFormBuyerPhoneUpdated(value)),
                    ),
                    const SizedBox(height: 24),

                    // Email
                    AppTextField(
                      label: context.l10n.email,
                      controller: _emailController,
                      isRequired: true,
                      hintText: context.l10n.email,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) => context
                          .read<ContractFormBloc>()
                          .add(ContractFormBuyerEmailUpdated(value)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.connectPropertyOwnerEmailHint,
                      style: GoogleFonts.anuphan(
                        color: AppColors.baseGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
