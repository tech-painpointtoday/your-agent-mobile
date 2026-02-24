import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final bool isArchived;
  final Map<String, dynamic>? data;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.isArchived = false,
    this.data,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    bool? isArchived,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isArchived: isArchived ?? this.isArchived,
      data: data ?? this.data,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Determine isRead from read_at
    final readAt = json['read_at'];
    final isRead =
        readAt != null || (json['is_read'] ?? json['isRead'] ?? false);

    // Get message from message or body
    final message = json['message'] ?? json['body'] ?? '';

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      message: message,
      type: _typeFromString(json['type']?.toString() ?? 'info'),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : (json['created_at'] != null
                ? DateTime.parse(json['created_at'])
                : DateTime.now()),
      isRead: isRead,
      isArchived: json['isArchived'] ?? json['is_archived'] ?? false,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  /// Create NotificationModel from unread booking data (from old_lib ChatApiService)
  factory NotificationModel.fromUnreadBooking(
    Map<String, dynamic> bookingData,
  ) {
    // Extract relevant information from booking data
    final bookingId = bookingData['id']?.toString() ?? '';
    final property = bookingData['property'] as Map<String, dynamic>?;
    final buyer = bookingData['buyer'] as Map<String, dynamic>?;
    final propertyTitle = property?['title']?.toString() ?? 'อสังหาริมทรัพย์';
    final buyerName = buyer?['name']?.toString() ?? 'ผู้ซื้อ';
    final createdAt =
        bookingData['created_at']?.toString() ??
        bookingData['createdAt']?.toString();

    return NotificationModel(
      id: 'booking_$bookingId',
      title: 'การจองใหม่',
      message: '$buyerName ได้จอง $propertyTitle',
      type: NotificationType.info,
      timestamp: createdAt != null
          ? DateTime.tryParse(createdAt) ?? DateTime.now()
          : DateTime.now(),
      isRead: false,
      isArchived: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'isArchived': isArchived,
      if (data != null) 'data': data,
    };
  }

  static NotificationType _typeFromString(String type) {
    final lowerType = type.toLowerCase();

    // Handle new type patterns from API: App\Notifications\TestFcmNotification, App\Notifications\CustomFcmNotification
    if (lowerType.contains('success')) return NotificationType.success;
    if (lowerType.contains('warning')) return NotificationType.warning;
    if (lowerType.contains('error')) return NotificationType.error;
    if (lowerType.contains('system')) return NotificationType.system;

    // Default cases for specific known notifications
    if (lowerType.contains('testfcm')) return NotificationType.info;
    if (lowerType.contains('customfcm')) return NotificationType.info;

    return NotificationType.info;
  }

  @override
  List<Object?> get props => [
    id,
    title,
    message,
    type,
    timestamp,
    isRead,
    isArchived,
    data,
  ];
}

enum NotificationType { info, success, warning, error, system }
