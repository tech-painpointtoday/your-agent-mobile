import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/widgets/custom_header.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/data/mock/mock_data_service.dart';
// import 'package:youragent/widgets/footer.dart';
import 'package:go_router/go_router.dart';

/// Support List Screen - shows support tickets
class SupportListScreen extends StatelessWidget {
  final Function(Locale) changeLocale;

  const SupportListScreen({super.key, required this.changeLocale});

  @override
  Widget build(BuildContext context) {
    final mockData = MockDataService();
    final tickets = mockData.getMockSupportTickets();

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Support',
                          style: GoogleFonts.anuphan(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.eerieBlack,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Create new ticket
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('New Ticket'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.jungleGreen,
                            foregroundColor: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ...tickets.map(
                      (ticket) => _buildTicketCard(context, ticket),
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

  Widget _buildTicketCard(BuildContext context, Map<String, dynamic> ticket) {
    final status = ticket['status'] as String;
    final statusColor = status == 'resolved'
        ? AppColors.jungleGreen
        : Colors.orange;

    return InkWell(
      onTap: () {
        context.push('/support/${ticket['id']}');
      },
      child: Container(
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
                Expanded(
                  child: Text(
                    ticket['subject'] as String,
                    style: GoogleFonts.anuphan(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
              ticket['last_message'] as String,
              style: GoogleFonts.anuphan(
                fontSize: 14,
                color: AppColors.shadyLady,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              'Created: ${ticket['created_at']}',
              style: GoogleFonts.anuphan(
                fontSize: 12,
                color: AppColors.shadyLady,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
