import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/domain/repositories/auth_repository.dart';

import '../models/notification_model.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(const NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<LoadMoreNotifications>(_onLoadMoreNotifications);
    on<MarkAsRead>(_onMarkAsRead);
    on<MarkAllAsRead>(_onMarkAllAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<ArchiveNotification>(_onArchiveNotification);
    on<FilterNotifications>(_onFilterNotifications);
  }

  List<NotificationModel> _applyFilter(
    List<NotificationModel> notifications,
    NotificationFilter filter,
  ) {
    switch (filter) {
      case NotificationFilter.all:
        return notifications;
      case NotificationFilter.unread:
        return notifications.where((n) => !n.isRead).toList();
    }
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    try {
      // Get current user role from auth repository
      final authRepo = DependencyInjection.authRepository;
      if (!authRepo.isAuthenticated) {
        emit(const NotificationLoaded(
          notifications: [],
          filteredNotifications: [],
        ));
        return;
      }

      // Get user role - we need to get it from auth state
      // For now, we'll use a default role or get it from the auth repository
      // This might need to be adjusted based on your auth implementation
      final role = _getUserRole(authRepo);
      final roleString = role == UserRole.agent ? 'agent' : 'agency';

      // Fetch unread bookings from old_lib ChatApiService
      final unreadBookings = await DependencyInjection.chatApiService
          .getUnreadBookings(role: roleString);

      // Convert booking data to NotificationModel
      final notifications = unreadBookings
          .map((booking) => NotificationModel.fromUnreadBooking(booking))
          .toList();

      final filtered = _applyFilter(notifications, NotificationFilter.all);

      emit(
        NotificationLoaded(
          notifications: notifications,
          filteredNotifications: filtered,
          currentFilter: NotificationFilter.all,
          currentPage: 1,
          hasMorePages: false, // API doesn't support pagination yet
        ),
      );
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onLoadMoreNotifications(
    LoadMoreNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is! NotificationLoaded) return;

    final currentState = state as NotificationLoaded;

    // Don't load if already loading or no more pages
    if (currentState.isLoadingMore || !currentState.hasMorePages) return;

    // Set loading state
    emit(currentState.copyWith(isLoadingMore: true));

    try {
      // For now, API doesn't support pagination
      // This can be implemented when API supports it
      emit(currentState.copyWith(isLoadingMore: false));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;

      // Extract booking ID from notification ID (format: 'booking_123')
      final bookingIdStr = event.notificationId.replaceFirst('booking_', '');
      final bookingId = int.tryParse(bookingIdStr);

      if (bookingId != null) {
        try {
          final authRepo = DependencyInjection.authRepository;
          final role = _getUserRole(authRepo);
          final roleString = role == UserRole.agent ? 'agent' : 'agency';

          // Mark as read via API
          await DependencyInjection.chatApiService.markAsRead(
            role: roleString,
            chatId: bookingId,
          );
        } catch (e) {
          // Continue with local update even if API call fails
        }
      }

      final updatedNotifications = currentState.notifications.map((
        notification,
      ) {
        if (notification.id == event.notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();

      final filtered = _applyFilter(
        updatedNotifications,
        currentState.currentFilter,
      );

      emit(
        currentState.copyWith(
          notifications: updatedNotifications,
          filteredNotifications: filtered,
        ),
      );
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;

      // Mark all unread notifications as read
      final updatedNotifications = currentState.notifications.map((
        notification,
      ) {
        if (!notification.isRead) {
          // Extract booking ID and mark via API
          final bookingIdStr = notification.id.replaceFirst('booking_', '');
          final bookingId = int.tryParse(bookingIdStr);

          if (bookingId != null) {
            try {
              final authRepo = DependencyInjection.authRepository;
              final role = _getUserRole(authRepo);
              final roleString = role == UserRole.agent ? 'agent' : 'agency';

              DependencyInjection.chatApiService.markAsRead(
                role: roleString,
                chatId: bookingId,
              );
            } catch (e) {
              // Continue with local update
            }
          }

          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();

      final filtered = _applyFilter(
        updatedNotifications,
        currentState.currentFilter,
      );

      emit(
        currentState.copyWith(
          notifications: updatedNotifications,
          filteredNotifications: filtered,
        ),
      );
    }
  }

  Future<void> _onFilterNotifications(
    FilterNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;

      final filtered = _applyFilter(currentState.notifications, event.filter);

      emit(
        currentState.copyWith(
          filteredNotifications: filtered,
          currentFilter: event.filter,
        ),
      );
    }
  }

  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;

      // Remove notification from list
      final updatedNotifications = currentState.notifications
          .where((n) => n.id != event.notificationId)
          .toList();

      final filtered = _applyFilter(
        updatedNotifications,
        currentState.currentFilter,
      );

      emit(
        currentState.copyWith(
          notifications: updatedNotifications,
          filteredNotifications: filtered,
        ),
      );
    }
  }

  Future<void> _onArchiveNotification(
    ArchiveNotification event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;

      // Toggle archive status
      final updatedNotifications = currentState.notifications.map((
        notification,
      ) {
        if (notification.id == event.notificationId) {
          return notification.copyWith(isArchived: !notification.isArchived);
        }
        return notification;
      }).toList();

      final filtered = _applyFilter(
        updatedNotifications,
        currentState.currentFilter,
      );

      emit(
        currentState.copyWith(
          notifications: updatedNotifications,
          filteredNotifications: filtered,
        ),
      );
    }
  }

  /// Get user role from auth repository
  UserRole _getUserRole(AuthRepository authRepo) {
    final role = authRepo.currentRole;
    return role ?? UserRole.agent;
  }
}
