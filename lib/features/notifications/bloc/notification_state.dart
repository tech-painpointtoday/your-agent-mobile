import 'package:equatable/equatable.dart';

import '../models/notification_model.dart';
import 'notification_event.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final List<NotificationModel> filteredNotifications;
  final NotificationFilter currentFilter;
  final int currentPage;
  final bool hasMorePages;
  final bool isLoadingMore;

  const NotificationLoaded({
    required this.notifications,
    required this.filteredNotifications,
    this.currentFilter = NotificationFilter.all,
    this.currentPage = 1,
    this.hasMorePages = false,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [
        notifications,
        filteredNotifications,
        currentFilter,
        currentPage,
        hasMorePages,
        isLoadingMore,
      ];

  NotificationLoaded copyWith({
    List<NotificationModel>? notifications,
    List<NotificationModel>? filteredNotifications,
    NotificationFilter? currentFilter,
    int? currentPage,
    bool? hasMorePages,
    bool? isLoadingMore,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      filteredNotifications:
          filteredNotifications ?? this.filteredNotifications,
      currentFilter: currentFilter ?? this.currentFilter,
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  int get unreadCount =>
      notifications.where((n) => !n.isRead && !n.isArchived).length;
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
