import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/data/mock/mock_data_service.dart';
import 'package:youragent/widgets/custom_header.dart';
// import 'package:youragent/widgets/footer.dart';

/// Payment List Screen - shows payment history
class PaymentListScreen extends StatelessWidget {
  final Function(Locale) changeLocale;

  const PaymentListScreen({super.key, required this.changeLocale});

  @override
  Widget build(BuildContext context) {
    final mockData = MockDataService();
    final payments = mockData.getMockPayments();

    return Scaffold(
      backgroundColor: AppColors.wildSand,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(changeLocale: changeLocale),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payments',
                      style: GoogleFonts.anuphan(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.baseDarkGrey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...payments.map(
                      (payment) => _buildPaymentCard(context, payment),
                    ),
                  ],
                ),
              ),
            ),
            // const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, Map<String, dynamic> payment) {
    final status = payment['status'] as String;
    final statusColor = status == 'completed'
        ? AppColors.jungleGreen
        : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bonJour, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                payment['description'] as String,
                style: GoogleFonts.anuphan(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.anuphan(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '฿${(payment['amount'] as double).toStringAsFixed(2)}',
            style: GoogleFonts.anuphan(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.jungleGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Date: ${payment['date']}',
            style: GoogleFonts.anuphan(
              fontSize: 14,
              color: AppColors.shadyLady,
            ),
          ),
        ],
      ),
    );
  }
}
