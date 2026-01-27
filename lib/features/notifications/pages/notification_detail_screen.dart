import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_state.dart';
import '../models/notification_model.dart';
import '../utils/notification_colors.dart';

class NotificationDetailScreen extends StatelessWidget {
  final String notificationId;

  const NotificationDetailScreen({super.key, required this.notificationId});

  String _formatTimestamp(DateTime timestamp) {
    final months = [
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฎาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม',
    ];

    final day = timestamp.day;
    final month = months[timestamp.month - 1];
    final year = timestamp.year + 543; // Buddhist year
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');

    return '$day ${month.substring(0, 3)}. $year, $hour:$minute น.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.baseDarkGrey,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'การแจ้งเตือน',
          style: GoogleFonts.anuphan(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.baseDarkGrey,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is! NotificationLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final notification = state.notifications.firstWhere(
            (n) => n.id == notificationId,
            orElse: () => NotificationModel(
              id: '',
              title: 'Notification not found',
              message: '',
              type: NotificationType.info,
              timestamp: DateTime.now(),
            ),
          );

          if (notification.id.isEmpty) {
            return Center(
              child: Text(
                'ไม่พบการแจ้งเตือน',
                style: GoogleFonts.anuphan(
                  fontSize: 16,
                  color: AppColors.baseDarkGrey,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colored header bar with icon
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: NotificationColors.getBackgroundColor(
                      notification.type,
                    ),
                    border: Border(
                      left: BorderSide(
                        color: NotificationColors.getPrimaryColor(
                          notification.type,
                        ),
                        width: 4,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        NotificationColors.getIcon(notification.type),
                        color: NotificationColors.getPrimaryColor(
                          notification.type,
                        ),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              notification.title,
                              style: GoogleFonts.anuphan(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: NotificationColors.getPrimaryColor(
                                  notification.type,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Timestamp
                            Text(
                              _formatTimestamp(notification.timestamp),
                              style: GoogleFonts.anuphan(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.baseDarkGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message
                      Text(
                        notification.message,
                        style: GoogleFonts.anuphan(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.baseDarkGrey,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
