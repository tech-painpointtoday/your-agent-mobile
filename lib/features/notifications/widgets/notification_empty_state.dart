import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

class NotificationEmptyState extends StatelessWidget {
  const NotificationEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder for empty state icon - you can add an SVG asset later
            Image.asset('assets/images/noti_empty.png', fit: BoxFit.contain),
            const SizedBox(height: 24),

            Text(
              'ยังไม่มีการแจ้งเตือนตอนนี้\nเราจะอัปเดตให้คุณทราบที่นี่เมื่อมีแจ้งเตือน',
              textAlign: TextAlign.center,
              style: GoogleFonts.anuphan(
                fontSize: 14,
                color: AppColors.baseGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
