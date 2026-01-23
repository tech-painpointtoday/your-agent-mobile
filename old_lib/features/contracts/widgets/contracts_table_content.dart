import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/data/models/contract_model.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/domain/entities/contract_status.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:youragent/widgets/buttons/action_icon_button.dart';
import 'package:youragent/widgets/tables/app_generic_table.dart';

class ContractsTableContent extends StatelessWidget {
  final List<ContractModel> contracts;
  final UserRole role;

  const ContractsTableContent({
    super.key,
    required this.contracts,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return AppGenericTable<ContractModel>(
      items: contracts,
      columns: [
        DataColumn(label: _buildHeader('เลขที่สัญญา')),
        DataColumn(label: _buildHeader('ชื่ออสังหาฯ')),
        DataColumn(label: _buildHeader('สถานะสัญญา')),
        DataColumn(label: _buildHeader('ประเภทอสังหาฯ')),
        DataColumn(label: _buildHeader('ผู้ให้เช่า')),
        DataColumn(label: _buildHeader('ผู้เช่า')),
        DataColumn(label: _buildHeaderWithSort('สร้างเมื่อ')),
      ],
      rowBuilder: (contract, index) => [
        DataCell(
          Text(
            contract.contractNumber ?? 'N/A',
            style: GoogleFonts.anuphan(
              fontSize: 14,
              color: AppColors.eerieBlack,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 200,
            child: Text(
              contract.propertyName ?? 'N/A',
              style: GoogleFonts.anuphan(
                fontSize: 14,
                color: AppColors.eerieBlack,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
        DataCell(_buildStatusBadge(contract.status)),
        DataCell(
          Text(
            contract.propertyType ?? 'N/A',
            style: GoogleFonts.anuphan(
              fontSize: 14,
              color: AppColors.eerieBlack,
            ),
          ),
        ),
        DataCell(
          Text(
            contract.lessor ?? 'N/A',
            style: GoogleFonts.anuphan(
              fontSize: 14,
              color: AppColors.eerieBlack,
            ),
          ),
        ),
        DataCell(
          Text(
            contract.lessee ?? 'N/A',
            style: GoogleFonts.anuphan(
              fontSize: 14,
              color: AppColors.eerieBlack,
            ),
          ),
        ),
        DataCell(
          Text(
            _formatThaiDate(contract.createdAt),
            style: GoogleFonts.anuphan(
              fontSize: 14,
              color: AppColors.eerieBlack,
            ),
          ),
        ),
      ],
      actionsBuilder: (contract, index) => Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ActionIconButton(
            icon: Icons.visibility_outlined,
            onPressed: () {
              context.push('/${role.name}/contracts/${contract.id}');
            },
          ),
          const SizedBox(width: 2),
          ActionIconButton(
            icon: Icons.edit_outlined,
            onPressed: () {
              context.push('/${role.name}/contracts/${contract.id}/edit');
            },
          ),
          const SizedBox(width: 2),
          ActionIconButton(
            icon: Icons.delete_outline,
            onPressed: () {
              _showDeleteDialog(context, contract);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String label) {
    return Text(
      label,
      style: GoogleFonts.anuphan(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.eerieBlack,
      ),
    );
  }

  Widget _buildHeaderWithSort(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.anuphan(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.eerieBlack,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(
          Icons.arrow_upward,
          size: 16,
          color: AppColors.eerieBlack,
        ),
      ],
    );
  }

  String _formatThaiDate(DateTime? date) {
    if (date == null) return '-';
    final thaiMonths = [
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.',
    ];
    final thaiYear = date.year + 543;
    return '${date.day} ${thaiMonths[date.month - 1]} $thaiYear';
  }

  Widget _buildStatusBadge(ContractStatus? status) {
    if (status == null) {
      return AppBadge(
        label: 'N/A',
        style: BadgeStyle.plain,
        color: BadgeColor.default_,
      );
    }

    // Use enum to determine badge style and colors
    switch (status) {
      case ContractStatus.draft:
        // 'draft' -> ยังไม่สมบูรณ์ (Incomplete/Draft)
        return AppBadge(
          label: status.getLabel(),
          style: BadgeStyle.dot,
          customBackgroundColor: const Color(0xFFFFFAEB), // #FFFAEB
          customTextColor: const Color(0xFFB54708), // #B54708
          customDotColor: const Color(0xFFF79009), // #F79009
        );
      case ContractStatus.pendingSignature:
        // 'pending_signature' -> รอการลงนาม (Pending Signature)
        return AppBadge(
          label: status.getLabel(),
          style: BadgeStyle.dot,
          color: BadgeColor.blue,
        );
      case ContractStatus.signed:
      case ContractStatus.completed:
        // 'signed' or 'completed' -> สมบูรณ์ (Complete)
        return AppBadge(
          label: status.getLabel(),
          style: BadgeStyle.dot,
          color: BadgeColor.green,
        );
      case ContractStatus.cancelled:
        // 'cancelled' -> ยกเลิก (Cancelled)
        return AppBadge(
          label: status.getLabel(),
          style: BadgeStyle.plain,
          color: BadgeColor.red,
        );
    }
  }

  void _showDeleteDialog(BuildContext context, ContractModel contract) {
    final l10n = AppLocalizations.of(context)!;
    StatusDialog.showDestructive(
      context: context,
      title: l10n.confirm,
      message: l10n.confirm_delete_contract,
      confirmText: l10n.delete,
      cancelText: l10n.cancel_button,
    ).then((confirmed) {
      if (confirmed == true && context.mounted) {
        // Handle delete
        StatusDialog.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.contract_deleted_success,
        );
      }
    });
  }
}
