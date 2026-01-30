import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/contract_status.dart';

class ContractStatusBadge extends StatelessWidget {
  final ContractStatus status;

  const ContractStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          const SizedBox(width: 8),
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

  _StatusConfig _getStatusConfig(ContractStatus status) {
    switch (status) {
      case ContractStatus.draft:
        return const _StatusConfig(
          label: 'ฉบับร่าง',
          backgroundColor: Color(0xFFF5F3FF),
          dotColor: Color(0xFF8B5CF6),
          textColor: Color(0xFF8B5CF6),
        );
      case ContractStatus.pendingSignature:
        return const _StatusConfig(
          label: 'ยังไม่สมบูรณ์',
          backgroundColor: Color(0xFFFFF7ED),
          dotColor: Color(0xFFF97316),
          textColor: Color(0xFFF97316),
        );
      case ContractStatus.signed:
      case ContractStatus.completed:
        return const _StatusConfig(
          label: 'สมบูรณ์',
          backgroundColor: Color(0xFFF0FDF4),
          dotColor: Color(0xFF22C55E),
          textColor: Color(0xFF22C55E),
        );
      case ContractStatus.cancelled:
        return const _StatusConfig(
          label: 'ยกเลิก',
          backgroundColor: Color(0xFFFEF2F2),
          dotColor: Color(0xFFEF4444),
          textColor: Color(0xFFEF4444),
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
