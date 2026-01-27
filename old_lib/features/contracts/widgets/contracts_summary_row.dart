import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/features/contracts/bloc/contracts_bloc.dart';

class ContractsSummaryRow extends StatelessWidget {
  final ContractsState state;
  final UserRole role;

  const ContractsSummaryRow({
    super.key,
    required this.state,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final filteredCount = state is ContractsLoaded
        ? (state as ContractsLoaded).filteredContracts.length
        : 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'รายการทั้งหมด $filteredCount รายการ',
          style: GoogleFonts.anuphan(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.baseDarkGrey,
          ),
        ),
        // // Create Contract Button
        // AppButtons.primary(
        //   label: 'สร้างสัญญา',
        //   icon: const Icon(Icons.add, size: 20),
        //   iconPosition: IconPosition.start,
        //   onPressed: () {
        //     context.push('/${role.name}/contracts/create');
        //   },
        // ),
      ],
    );
  }
}
