import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yourhome/core/di/dependency_injection.dart';
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
      final authRepo = DependencyInjection.authRepository;
      if (!authRepo.isAuthenticated) {
        emit(
          const NotificationLoaded(
            notifications: [],
            filteredNotifications: [],
          ),
        );
        return;
      }

      final response = await DependencyInjection.notificationApiService
          .getNotifications(page: 1, perPage: 10);

      final List<dynamic> notificationData = response['data']['notifications'];
      final Map<String, dynamic> pagination = response['data']['pagination'];

      final notifications = notificationData
          .map((json) => NotificationModel.fromJson(json))
          .toList();

      final filtered = _applyFilter(notifications, NotificationFilter.all);

      emit(
        NotificationLoaded(
          notifications: notifications,
          filteredNotifications: filtered,
          currentFilter: NotificationFilter.all,
          currentPage: pagination['current_page'] ?? 1,
          hasMorePages:
              (pagination['current_page'] ?? 1) <
              (pagination['last_page'] ?? 1),
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
      final nextPage = currentState.currentPage + 1;
      final response = await DependencyInjection.notificationApiService
          .getNotifications(page: nextPage, perPage: 10);

      final List<dynamic> notificationData = response['data']['notifications'];
      final Map<String, dynamic> pagination = response['data']['pagination'];

      final newNotifications = notificationData
          .map((json) => NotificationModel.fromJson(json))
          .toList();

      final allNotifications = List<NotificationModel>.from(
        currentState.notifications,
      )..addAll(newNotifications);

      final filtered = _applyFilter(
        allNotifications,
        currentState.currentFilter,
      );

      emit(
        currentState.copyWith(
          notifications: allNotifications,
          filteredNotifications: filtered,
          currentPage: pagination['current_page'] ?? nextPage,
          hasMorePages:
              (pagination['current_page'] ?? nextPage) <
              (pagination['last_page'] ?? 1),
          isLoadingMore: false,
        ),
      );
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

      try {
        // Mark as read via API
        await DependencyInjection.notificationApiService.markAsRead(
          event.notificationId,
        );
      } catch (e) {
        // Continue with local update even if API call fails
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

      try {
        await DependencyInjection.notificationApiService.markAllAsRead();
      } catch (e) {
        // Continue with local update even if API call fails
      }

      // Mark all unread notifications as read
      final updatedNotifications = currentState.notifications.map((
        notification,
      ) {
        if (!notification.isRead) {
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
}
