import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/data/mock/mock_data_service.dart';
import 'package:youragent/domain/entities/booking.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/widgets/app_layout.dart';

/// Chat List Screen - shows all chat conversations
class ChatListScreen extends StatelessWidget {
  final Function(Locale) changeLocale;
  final UserRole? role;

  const ChatListScreen({super.key, required this.changeLocale, this.role});

  @override
  Widget build(BuildContext context) {
    final mockData = MockDataService();
    final bookings = mockData.getMockBookings();

    return AppLayout(
      changeLocale: changeLocale,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chats',
              style: GoogleFonts.anuphan(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.baseDarkGrey,
              ),
            ),
            const SizedBox(height: 24),
            ...bookings.map((booking) => _buildChatCard(context, booking)),
          ],
        ),
      ),
    );
  }

  Widget _buildChatCard(BuildContext context, Booking booking) {
    return InkWell(
      onTap: () {
        context.push('/chat/${booking.id}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.bonJour, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.jungleGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chat, color: AppColors.jungleGreen),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Property #${booking.propertyId}',
                    style: GoogleFonts.anuphan(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last message preview...',
                    style: GoogleFonts.anuphan(
                      fontSize: 14,
                      color: AppColors.shadyLady,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.shadyLady),
          ],
        ),
      ),
    );
  }
}
