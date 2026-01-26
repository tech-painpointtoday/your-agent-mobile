import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final bool isArchived;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.isArchived = false,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    bool? isArchived,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: _typeFromString(json['type']?.toString() ?? 'info'),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isRead: json['isRead'] ?? json['is_read'] ?? false,
      isArchived: json['isArchived'] ?? json['is_archived'] ?? false,
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
    final createdAt = bookingData['created_at']?.toString() ??
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
    };
  }

  static NotificationType _typeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'success':
        return NotificationType.success;
      case 'warning':
        return NotificationType.warning;
      case 'error':
        return NotificationType.error;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.info;
    }
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
      ];
}

enum NotificationType { info, success, warning, error, system }
