import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:yourhome/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_state.dart';
import '../models/notification_model.dart';
import '../utils/notification_colors.dart';

class NotificationDetailScreen extends StatelessWidget {
  final String notificationId;

  const NotificationDetailScreen({super.key, required this.notificationId});

  String _formatTimestamp(BuildContext context, DateTime timestamp) {
    final locale = Localizations.localeOf(context).languageCode;

    if (locale == 'th') {
      final year = timestamp.year + 543;
      final dateFormat = DateFormat('d MMM', 'th');
      final timeFormat = DateFormat('HH:mm');
      return '${dateFormat.format(timestamp)}. $year, ${timeFormat.format(timestamp)} น.';
    } else {
      return DateFormat('d MMM yyyy, HH:mm').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/chevron-left.svg',
            width: 18,
            height: 18,
            fit: BoxFit.contain,
            colorFilter: const ColorFilter.mode(
              AppColors.baseDarkGrey,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.notifications_title,
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
            return const Center(
              child: SpinKitFadingCircle(
                color: AppColors.primary,
                size: 32,
              ),
            );
          }

          final notification = state.notifications.firstWhere(
            (n) => n.id == notificationId,
            orElse: () => NotificationModel(
              id: '',
              title: l10n.notifications_not_found,
              message: '',
              type: NotificationType.info,
              timestamp: DateTime.now(),
            ),
          );

          if (notification.id.isEmpty) {
            return Center(
              child: Text(
                l10n.notifications_not_found,
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
                              _formatTimestamp(context, notification.timestamp),
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
