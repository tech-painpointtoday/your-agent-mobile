import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/person_type.dart';
import 'package:youragent/domain/entities/buyer.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_bloc.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_event.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_state.dart';
import 'package:youragent/widgets/inputs/app_text_field.dart';
import 'package:youragent/widgets/inputs/app_chip_selection.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import '../../../widgets/user_registration_bottom_sheet.dart';

class BuyerInfoStep extends StatefulWidget {
  const BuyerInfoStep({super.key});

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
    return BlocListener<ContractFormBloc, ContractFormState>(
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
                        label: 'ข้อมูลผู้ซื้อ',
                        fontSize: 16,
                        color: BadgeColor.blue,
                      ),
                      AppBadge(
                        color: BadgeColor.default_,
                        fontSize: 16,
                        label: '${state.step}/7',
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Person Type Selection
                  AppChipSelection<PersonType>(
                    label: 'ประเภทบุคคล',
                    isRequired: true,
                    value: state.buyerType,
                    options: const [
                      AppChipOption(
                        label: 'บุคคลธรรมดา',
                        value: PersonType.individual,
                      ),
                      AppChipOption(
                        label: 'นิติบุคคล',
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
                      label: 'ชื่อ-นามสกุล / ชื่อบริษัท',
                      controller: controller,
                      focusNode: focusNode,
                      isRequired: true,
                      hintText: 'ชื่อ-นามสกุล / ชื่อบริษัท',
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
                    suggestionsCallback: (pattern) {
                      context.read<ContractFormBloc>().add(
                        ContractFormBuyersFetched(pattern),
                      );
                      return state.buyers;
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
                    emptyBuilder: (context) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'ไม่พบข้อมูลผู้ซื้อ',
                        style: GoogleFonts.anuphan(color: AppColors.baseGrey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ค้นหาชื่อเจ้าของทรัพย์ในระบบ เพื่อเชื่อมต่อข้อมูล', // Hint text from image
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
                        RegistrationUserType.buyer,
                      ),
                      icon: const Icon(Icons.add, size: 20),
                      label: Text(
                        'สร้างบัญชีใหม่',
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
                    label: 'เลขบัตรประชาชน / เลขนิติบุคคล',
                    controller: _idCardController,
                    isRequired: true,
                    hintText: 'เลขบัตรประชาชน / เลขนิติบุคคล',
                    onChanged: (value) => context.read<ContractFormBloc>().add(
                      ContractFormBuyerIdCardUpdated(value),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Address
                  AppTextField(
                    label: 'ที่อยู่ปัจจุบัน',
                    controller: _addressController,
                    isRequired: true,
                    hintText: 'ที่อยู่ปัจจุบัน',
                    onChanged: (value) => context.read<ContractFormBloc>().add(
                      ContractFormBuyerAddressUpdated(value),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Phone
                  AppTextField(
                    label: 'หมายเลขโทรศัพท์',
                    controller: _phoneController,
                    isRequired: true,
                    hintText: 'หมายเลขโทรศัพท์',
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => context.read<ContractFormBloc>().add(
                      ContractFormBuyerPhoneUpdated(value),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Email
                  AppTextField(
                    label: 'อีเมล',
                    controller: _emailController,
                    isRequired: true,
                    hintText: 'อีเมล',
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => context.read<ContractFormBloc>().add(
                      ContractFormBuyerEmailUpdated(value),
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
