import 'package:flutter/material.dart';
import 'package:youragent/core/theme/app_colors.dart';

/// Signature card widget displaying signature image with signer info
class SignatureCard extends StatelessWidget {
  final String? signatureImageUrl;
  final String signerName;
  final String role;
  final String? timestamp;

  const SignatureCard({
    super.key,
    this.signatureImageUrl,
    required this.signerName,
    required this.role,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Signature image placeholder/display
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gray300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: signatureImageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(signatureImageUrl!, fit: BoxFit.contain),
                )
              : Center(
                  child: Text(
                    'No signature',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray400),
                  ),
                ),
        ),
        const SizedBox(height: 12),
        // Signer info
        Text(
          '($signerName)',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.gray900, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(role, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray600)),
        if (timestamp != null) ...[
          const SizedBox(height: 4),
          Text(timestamp!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray500)),
        ],
      ],
    );
  }
}
