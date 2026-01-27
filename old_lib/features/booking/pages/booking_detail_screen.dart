import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/data/mock/mock_data_service.dart';
import 'package:youragent/widgets/custom_header.dart';
// import 'package:youragent/widgets/footer.dart';
import 'package:youragent/domain/entities/booking.dart';
import 'package:go_router/go_router.dart';

/// Booking Detail Screen - shows booking details
class BookingDetailScreen extends StatelessWidget {
  final Function(Locale) changeLocale;
  final int bookingId;

  const BookingDetailScreen({
    super.key,
    required this.changeLocale,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context) {
    final mockData = MockDataService();
    final bookings = mockData.getMockBookings();
    final booking = bookings.firstWhere(
      (b) => b.id == bookingId,
      orElse: () => bookings.first,
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
                      'Booking Details',
                      style: GoogleFonts.anuphan(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.baseDarkGrey,
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
                          _buildDetailRow(
                            'Property ID',
                            '${booking.propertyId}',
                          ),
                          const Divider(),
                          _buildDetailRow('Date', booking.ymd),
                          const Divider(),
                          _buildDetailRow('Time', booking.time),
                          const Divider(),
                          _buildDetailRow('Status', booking.status.name),
                          if (booking.confirmedAt != null) ...[
                            const Divider(),
                            _buildDetailRow(
                              'Confirmed At',
                              booking.confirmedAt!.toString(),
                            ),
                          ],
                          if (booking.cancelledAt != null) ...[
                            const Divider(),
                            _buildDetailRow(
                              'Cancelled At',
                              booking.cancelledAt!.toString(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              context.push('/booking/${booking.id}/chat');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.jungleGreen,
                              foregroundColor: AppColors.white,
                            ),
                            child: const Text('Open Chat'),
                          ),
                        ),
                        if (booking.status == BookingStatus.pending) ...[
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                // Confirm booking
                              },
                              child: const Text('Confirm'),
                            ),
                          ),
                        ],
                      ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.anuphan(
              fontSize: 14,
              color: AppColors.shadyLady,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.anuphan(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.baseDarkGrey,
            ),
          ),
        ],
      ),
    );
  }
}
