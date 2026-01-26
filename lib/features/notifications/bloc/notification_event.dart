import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {
  const LoadNotifications();
}

class LoadMoreNotifications extends NotificationEvent {
  const LoadMoreNotifications();
}

class MarkAsRead extends NotificationEvent {
  final String notificationId;

  const MarkAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllAsRead extends NotificationEvent {
  const MarkAllAsRead();
}

class DeleteNotification extends NotificationEvent {
  final String notificationId;

  const DeleteNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class ArchiveNotification extends NotificationEvent {
  final String notificationId;

  const ArchiveNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

enum NotificationFilter { all, unread }

class FilterNotifications extends NotificationEvent {
  final NotificationFilter filter;

  const FilterNotifications(this.filter);

  @override
  List<Object?> get props => [filter];
}
