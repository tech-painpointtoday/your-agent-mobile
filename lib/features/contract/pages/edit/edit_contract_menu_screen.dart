import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yourhome/core/di/dependency_injection.dart';
import 'package:yourhome/core/theme/app_colors.dart';
import 'package:yourhome/domain/entities/contract.dart';
import 'package:yourhome/domain/entities/contract_type.dart';
import 'package:yourhome/features/contract/bloc/contract_form/contract_form_bloc.dart';
import 'package:yourhome/features/contract/bloc/contract_form/contract_form_event.dart';
import 'package:yourhome/features/contract/bloc/contract_form/contract_form_state.dart';
import 'edit_contract_form_screen.dart';
import 'package:yourhome/core/extensions/l10n_extensions.dart';

class EditContractMenuScreen extends StatelessWidget {
  final Contract contract;

  const EditContractMenuScreen({super.key, required this.contract});

  @override
  Widget build(BuildContext context) {
    final isRent = contract.contractType == ContractType.rent;

    return BlocProvider(
      create: (context) => ContractFormBloc(
        propertyApiService: DependencyInjection.propertyApiService,
        contractApiService: DependencyInjection.contractApiService,
      )..add(ContractFormEditStarted(contract.id!)),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(
          title: Text(
            context.l10n.editContract,
            style: GoogleFonts.anuphan(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          titleSpacing: 0,
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: SvgPicture.asset(
              'assets/icons/chevron-left.svg',
              width: 18,
              height: 18,
              fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Container(
          margin: const EdgeInsets.only(top: 16),
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildMenuItem(
                  context,
                  title: context.l10n.dataProperty,
                  subtitle: context.l10n.dataAddress,
                  iconPath: 'assets/icons/home.svg',
                  iconColor: AppColors.brandGreen,
                  bgColor: AppColors.supportGreenLight,
                  onTap: (bloc) {
                    context.push(
                      '/contract/edit-form',
                      extra: {
                        'contract': contract,
                        'stepType': EditContractStepType.ownerInfo,
                        'title': context.l10n.dataProperty,
                        'bloc': bloc,
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildMenuItem(
                  context,
                  title: isRent
                      ? context.l10n.renterInfo
                      : context.l10n.buyerInfo,
                  subtitle: isRent
                      ? context.l10n.renterInfo
                      : context.l10n.buyerInfo,
                  iconPath: 'assets/icons/user.svg', // Using user icon
                  iconColor: const Color(0xFF7F56D9), // Purple
                  bgColor: const Color(0xFFF9F5FF), // Light Purple
                  onTap: (bloc) {
                    context.push(
                      '/contract/edit-form',
                      extra: {
                        'contract': contract,
                        'stepType': EditContractStepType.buyerInfo,
                        'title': context.l10n.buyerInfo,
                        'bloc': bloc,
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildMenuItem(
                  context,
                  title: context.l10n.appliance,
                  subtitle: context.l10n.addApplianceAndDetails,
                  iconPath: 'assets/icons/television.svg',
                  iconColor: AppColors.supportOrangeDark,
                  bgColor: AppColors.supportOrangeLight,
                  onTap: (bloc) {
                    context.push(
                      '/contract/edit-form',
                      extra: {
                        'contract': contract,
                        'stepType': EditContractStepType.appliances,
                        'title': context.l10n.appliance,
                        'bloc': bloc,
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildMenuItem(
                  context,
                  title: context.l10n.furnitureTitle,
                  subtitle: context.l10n.addFurnitureDetails,
                  iconPath: 'assets/icons/sofa.svg',
                  iconColor: AppColors.supportRedDark,
                  bgColor: AppColors.supportRedLight,
                  onTap: (bloc) {
                    context.push(
                      '/contract/edit-form',
                      extra: {
                        'contract': contract,
                        'stepType': EditContractStepType.furniture,
                        'title': context.l10n.furnitureTitle,
                        'bloc': bloc,
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildMenuItem(
                  context,
                  title: context.l10n.payment,
                  subtitle: context.l10n.paymentMethods,
                  iconPath: 'assets/icons/dollar.svg',
                  iconColor: AppColors.supportGreenDark,
                  bgColor: AppColors.supportGreenLight,
                  onTap: (bloc) {
                    context.push(
                      '/contract/edit-form',
                      extra: {
                        'contract': contract,
                        'stepType': EditContractStepType.payment,
                        'title': context.l10n.payment,
                        'bloc': bloc,
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildMenuItem(
                  context,
                  title: context.l10n.additional_conditions,
                  subtitle: context.l10n.addContractConditionsAdditional,
                  iconPath: 'assets/icons/star-moving.svg',
                  iconColor: AppColors.supportPinkDark,
                  bgColor: AppColors.supportPinkLight,
                  onTap: (bloc) {
                    context.push(
                      '/contract/edit-form',
                      extra: {
                        'contract': contract,
                        'stepType': EditContractStepType.additionalConditions,
                        'title': context.l10n.additional_conditions,
                        'bloc': bloc,
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildMenuItem(
                  context,
                  title: context.l10n.contractFile,
                  subtitle: context.l10n.editAddContractFile,
                  iconPath: 'assets/icons/file-2.svg',
                  iconColor: AppColors.primary,
                  bgColor: AppColors.primary.withValues(alpha: 0.1),
                  onTap: (bloc) {
                    context.push(
                      '/contract/edit-form',
                      extra: {
                        'contract': contract,
                        'stepType': EditContractStepType.attachments,
                        'title': context.l10n.contractFile,
                        'bloc': bloc,
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String iconPath,
    required Color iconColor,
    required Color bgColor,
    required Function(ContractFormBloc) onTap,
  }) {
    // Check if icon exists, fallback if not (simplified for this context)
    // In real app, we ensure assets exist. For now assuming they might need placeholders.
    // Using standard Flutter icons if SVG asset not found is tricky without try-catch or known assets.
    // I will assume assets exist or use generic names that likely exist based on project structure.

    return BlocBuilder<ContractFormBloc, ContractFormState>(
      builder: (context, state) {
        final bloc = context.read<ContractFormBloc>();
        return InkWell(
          onTap: () => onTap(bloc),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SvgPicture.asset(
                    iconPath,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    // Fallback would be good here but SvgPicture doesn't support it easily inline
                    placeholderBuilder: (BuildContext context) =>
                        Icon(Icons.error, color: iconColor, size: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.anuphan(
                          color: AppColors.baseBlack,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.anuphan(
                          color: AppColors.baseDarkGrey,
                          fontSize:
                              12, // Increased slightly for readability per design
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                SvgPicture.asset(
                  'assets/icons/chevron-right.svg',
                  colorFilter: const ColorFilter.mode(
                    AppColors.baseGrey,
                    BlendMode.srcIn,
                  ),
                  width: 20,
                  height: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
