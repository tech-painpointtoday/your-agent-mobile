import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:youragent/domain/entities/property.dart';

/// Status badge widget that displays property status with appropriate colors
class PropertyStatusBadge extends StatelessWidget {
  final PropertyApprovalStatus status;

  const PropertyStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: ShapeDecoration(
        color: config.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: ShapeDecoration(
              color: config.dotColor,
              shape: const CircleBorder(),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            config.label,
            style: GoogleFonts.anuphan(
              color: config.textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(PropertyApprovalStatus status) {
    switch (status) {
      case PropertyApprovalStatus.draft:
        return const _StatusConfig(
          label: 'ร่าง',
          backgroundColor: Color(0xFFFFF6E8),
          dotColor: Color(0xFFFA7C2E),
          textColor: Color(0xFFFA7C2E),
        );
      case PropertyApprovalStatus.pending:
        return const _StatusConfig(
          label: 'รอการอนุมัติ',
          backgroundColor: Color(0xFFFFF6E8),
          dotColor: Color(0xFFFA7C2E),
          textColor: Color(0xFFFA7C2E),
        );
      case PropertyApprovalStatus.approved:
        return const _StatusConfig(
          label: 'อนุมัติแล้ว',
          backgroundColor: Color(0xFFE8FCEC),
          dotColor: Color(0xFF3FBE59),
          textColor: Color(0xFF3FBE59),
        );
      case PropertyApprovalStatus.rejected:
        return const _StatusConfig(
          label: 'ไม่อนุมัติ',
          backgroundColor: Color(0xFFFFECEC),
          dotColor: Color(0xFFF04437),
          textColor: Color(0xFFF04437),
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color backgroundColor;
  final Color dotColor;
  final Color textColor;

  const _StatusConfig({
    required this.label,
    required this.backgroundColor,
    required this.dotColor,
    required this.textColor,
  });
}
