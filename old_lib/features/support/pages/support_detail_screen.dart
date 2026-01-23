import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/data/mock/mock_data_service.dart';
import 'package:youragent/widgets/custom_header.dart';
// import 'package:youragent/widgets/footer.dart';
import 'package:go_router/go_router.dart';

/// Support Detail Screen - shows support ticket details
class SupportDetailScreen extends StatelessWidget {
  final Function(Locale) changeLocale;
  final int ticketId;

  const SupportDetailScreen({
    super.key,
    required this.changeLocale,
    required this.ticketId,
  });

  @override
  Widget build(BuildContext context) {
    final mockData = MockDataService();
    final tickets = mockData.getMockSupportTickets();
    final ticket = tickets.firstWhere(
      (t) => t['id'] == ticketId,
      orElse: () => tickets.first,
    );

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
                      ticket['subject'] as String,
                      style: GoogleFonts.anuphan(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.eerieBlack,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.bonJour,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket['last_message'] as String,
                            style: GoogleFonts.anuphan(
                              fontSize: 16,
                              color: AppColors.eerieBlack,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 16),
                          Text(
                            'Reply',
                            style: GoogleFonts.anuphan(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: 'Type your reply...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.bonJour,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.jungleGreen,
                              foregroundColor: AppColors.white,
                            ),
                            child: const Text('Send Reply'),
                          ),
                        ],
                      ),
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
}
