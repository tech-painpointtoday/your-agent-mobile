import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../widgets/dialogs/status_dialog.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../models/notification_model.dart';
import '../utils/notification_colors.dart';

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

    if (difference.inMinutes < 1) {
      return 'ตอนนี้';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} นาทีที่แล้ว';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} วันที่แล้ว';
    } else {
      // Format as date: DD MMM YYYY, HH:mm
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
  }

  @override
  Widget build(BuildContext context) {
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
            label: notification.isArchived ? 'ยกเลิก' : 'เก็บถาวร',
          ),
          // Delete action
          SlidableAction(
            onPressed: (context) async {
              final confirmed = await StatusDialog.showDestructive(
                context: context,
                title: 'ลบการแจ้งเตือน?',
                message:
                    'คุณต้องการลบการแจ้งเตือนนี้หรือไม่? การกระทำนี้ไม่สามารถย้อนกลับได้',
                confirmText: 'ลบ',
                cancelText: 'ยกเลิก',
              );
              if (confirmed && context.mounted) {
                context.read<NotificationBloc>().add(
                  DeleteNotification(notification.id),
                );
              }
            },
            backgroundColor: AppColors.supportRedDeep,
            foregroundColor: AppColors.white,
            icon: Icons.delete,
            label: 'ลบ',
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.baseLightGrey, width: 1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type indicator circle
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6, right: 12),
                decoration: BoxDecoration(
                  color: NotificationColors.getPrimaryColor(notification.type),
                  shape: BoxShape.circle,
                ),
              ),
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
    );
  }
}
