import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/l10n/app_localizations.dart';

/// Status badge widget that displays property status with appropriate colors
class PropertyStatusBadge extends StatelessWidget {
  final PropertyApprovalStatus status;

  const PropertyStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(context, status);

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

  _StatusConfig _getStatusConfig(
    BuildContext context,
    PropertyApprovalStatus status,
  ) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case PropertyApprovalStatus.draft:
        return _StatusConfig(
          label: l10n.draftLabel,
          backgroundColor: const Color(0xFFFFF6E8),
          dotColor: const Color(0xFFFA7C2E),
          textColor: const Color(0xFFFA7C2E),
        );
      case PropertyApprovalStatus.pending:
        return _StatusConfig(
          label: l10n.pendingAt,
          backgroundColor: const Color(0xFFFFF6E8),
          dotColor: const Color(0xFFFA7C2E),
          textColor: const Color(0xFFFA7C2E),
        );
      case PropertyApprovalStatus.approved:
        return _StatusConfig(
          label: l10n.approvedAt,
          backgroundColor: const Color(0xFFE8FCEC),
          dotColor: const Color(0xFF3FBE59),
          textColor: const Color(0xFF3FBE59),
        );
      case PropertyApprovalStatus.rejected:
        return _StatusConfig(
          label: l10n.disapprovedAt,
          backgroundColor: const Color(0xFFFFECEC),
          dotColor: const Color(0xFFF04437),
          textColor: const Color(0xFFF04437),
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
