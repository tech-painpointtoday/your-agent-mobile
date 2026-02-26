import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:youragent/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../widgets/modals/app_confirmation_bottom_sheet.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../models/notification_model.dart';

class NotificationListItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationListItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  String _formatTimestamp(BuildContext context, DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    if (difference.inMinutes < 1) {
      return l10n.notifications_now;
    } else if (difference.inHours < 1) {
      return l10n.notifications_minutes_ago(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return l10n.notifications_hours_ago(difference.inHours);
    } else if (difference.inDays < 30) {
      return l10n.notifications_days_ago(difference.inDays);
    } else {
      if (locale == 'th') {
        final year = timestamp.year + 543;
        final dateFormat = DateFormat('d MMM', 'th');
        final timeFormat = DateFormat('HH:mm');
        return '${dateFormat.format(timestamp)}. $year, ${timeFormat.format(timestamp)} น.';
      } else {
        return DateFormat('d MMM yyyy, HH:mm').format(timestamp);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Slidable(
      key: ValueKey(notification.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          // Archive action
          SlidableAction(
            onPressed: (context) {
              context.read<NotificationBloc>().add(
                ArchiveNotification(notification.id),
              );
            },
            backgroundColor: AppColors.warning,
            foregroundColor: AppColors.white,
            icon: notification.isArchived ? Icons.unarchive : Icons.archive,
            label: notification.isArchived
                ? l10n.notifications_cancel_label
                : l10n.notifications_archive,
          ),
          // Delete action
          SlidableAction(
            onPressed: (context) {
              AppConfirmationBottomSheet.show(
                context: context,
                title: l10n.notifications_delete_confirm_title,
                description: l10n.notifications_delete_confirm_desc,
                confirmLabel: l10n.notifications_delete_label,
                cancelLabel: l10n.notifications_cancel_label,
                style: ConfirmationStyle.destructive,
                onConfirm: () {
                  if (context.mounted) {
                    context.read<NotificationBloc>().add(
                      DeleteNotification(notification.id),
                    );
                  }
                },
              );
            },
            backgroundColor: AppColors.supportRedDeep,
            foregroundColor: AppColors.white,
            icon: Icons.delete,
            label: l10n.notifications_delete_label,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.baseBlack.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: GoogleFonts.anuphan(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.anuphan(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.baseDarkGrey,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatTimestamp(context, notification.timestamp),
                        style: GoogleFonts.anuphan(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.baseDarkGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: AppColors.supportRedDeep,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
