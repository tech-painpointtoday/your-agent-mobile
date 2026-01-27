import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/widgets/app_loader.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/features/auth/bloc/auth_bloc.dart';
import 'package:youragent/features/auth/bloc/auth_state.dart';

/// Notification popup widget that displays a list of notifications
/// This widget is designed to be shown as a positioned popup below a button
class NotificationPopup extends StatefulWidget {
  const NotificationPopup({super.key});

  @override
  State<NotificationPopup> createState() => _NotificationPopupState();
}

/// Shows the notification popup positioned relative to a button
class NotificationPopupRoute extends PopupRoute {
  final Offset position;
  final double width;

  NotificationPopupRoute({required this.position, this.width = 400});

  @override
  Color? get barrierColor => Colors.black.withAlpha(51);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Dismiss notifications';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _NotificationPopupPage(
      position: position,
      width: width,
      animation: animation,
    );
  }
}

class _NotificationPopupPage extends StatelessWidget {
  final Offset position;
  final double width;
  final Animation<double> animation;

  const _NotificationPopupPage({
    required this.position,
    required this.width,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate position - center horizontally on button, but adjust if near screen edges
    double left = position.dx - width / 2;
    if (left < 16) {
      left = 16; // Minimum margin from left edge
    } else if (left + width > screenWidth - 16) {
      left = screenWidth - width - 16; // Minimum margin from right edge
    }

    // Calculate top position - below button with small gap
    double top = position.dy + 8;
    const double maxHeight = 600;

    // If popup would go off screen, position it above the button instead
    if (top + maxHeight > screenHeight - 16) {
      top = position.dy - maxHeight - 8;
    }

    return Stack(
      children: [
        Positioned(
          left: left,
          top: top,
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: Material(
                color: Colors.transparent,
                child: NotificationPopup(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationPopupState extends State<NotificationPopup> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        final role = authState.user.role;
        final roleString = role == UserRole.agent ? 'agent' : 'agency';
        final unreadBookings = await DependencyInjection.chatApiService
            .getUnreadBookings(role: roleString);
        setState(() {
          _notifications = unreadBookings;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    // TODO: Implement mark all as read API call
    // For now, just refresh the list
    await _loadNotifications();
  }

  String _formatTimestamp(DateTime? dateTime, String locale) {
    if (dateTime == null) return locale == 'th' ? 'ตอนนี้' : 'Now';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return locale == 'th' ? 'ตอนนี้' : 'Now';
    } else if (difference.inMinutes < 60) {
      return locale == 'th'
          ? '${difference.inMinutes} นาทีที่แล้ว'
          : '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return locale == 'th'
          ? '${difference.inHours} ชั่วโมงที่แล้ว'
          : '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return locale == 'th'
          ? '${difference.inDays} วันที่แล้ว'
          : '${difference.inDays} days ago';
    } else {
      return DateFormat('d MMM yyyy, HH:mm', locale).format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    return Container(
      width: 400,
      constraints: const BoxConstraints(maxHeight: 600),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE9E9EB), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  locale == 'th' ? 'แจ้งเตือน' : 'Notifications',
                  style: GoogleFonts.anuphan(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.baseDarkGrey,
                  ),
                ),
                InkWell(
                  onTap: _markAllAsRead,
                  child: Text(
                    locale == 'th' ? 'อ่านทั้งหมด' : 'Read All',
                    style: GoogleFonts.anuphan(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.blue600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Notification List
          Flexible(
            child: _isLoading
                ? const AppLoader()
                : _notifications.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        locale == 'th' ? 'ไม่มีแจ้งเตือน' : 'No notifications',
                        style: GoogleFonts.anuphan(
                          fontSize: 14,
                          color: AppColors.baseDarkGrey,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      final isUnread = notification['is_unread'] ?? true;
                      final senderName =
                          notification['sender_name'] ?? 'Manpower Agency';
                      final message =
                          notification['message'] ??
                          'ตัวอย่างข้อความแจ้งเตือนแบบย่อที่คุณได้รับ จะปรากฏที่นี่ทั้งหมด';
                      final timestamp = notification['timestamp'];
                      DateTime? dateTime;
                      if (timestamp != null) {
                        if (timestamp is String) {
                          dateTime = DateTime.tryParse(timestamp);
                        } else if (timestamp is int) {
                          dateTime = DateTime.fromMillisecondsSinceEpoch(
                            timestamp,
                          );
                        }
                      }

                      return _NotificationItem(
                        avatarUrl: notification['avatar_url'],
                        senderName: senderName,
                        message: message,
                        timestamp: _formatTimestamp(dateTime, locale),
                        isUnread: isUnread,
                        onTap: () {
                          // Navigate to related booking/chat if available
                          final bookingId = notification['booking_id'];
                          if (bookingId != null) {
                            context.pop();
                            context.go('/agent/chats/$bookingId');
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Helper function to show notification popup positioned relative to a button
Future<void> showNotificationPopup(
  BuildContext context,
  GlobalKey buttonKey,
) async {
  final RenderBox? renderBox =
      buttonKey.currentContext?.findRenderObject() as RenderBox?;
  if (renderBox == null) return;

  final Offset position = renderBox.localToGlobal(Offset.zero);
  final Size size = renderBox.size;

  await Navigator.of(context).push(
    NotificationPopupRoute(
      position: Offset(position.dx + size.width / 2, position.dy + size.height),
    ),
  );
}

class _NotificationItem extends StatelessWidget {
  final String? avatarUrl;
  final String senderName;
  final String message;
  final String timestamp;
  final bool isUnread;
  final VoidCallback? onTap;

  const _NotificationItem({
    required this.avatarUrl,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.isUnread,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE9E9EB), width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.baseLightGrey,
              ),
              child: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildDefaultAvatar(),
                      ),
                    )
                  : _buildDefaultAvatar(),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sender name with unread indicator
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          senderName,
                          style: GoogleFonts.anuphan(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blue600,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.ruby500,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Message
                  Text(
                    message,
                    style: GoogleFonts.anuphan(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.baseDarkGrey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Timestamp
                  Text(
                    timestamp,
                    style: GoogleFonts.anuphan(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.baseDarkGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.baseLightGrey,
      ),
      child: Icon(Icons.person, color: AppColors.baseDarkGrey, size: 24),
    );
  }
}
