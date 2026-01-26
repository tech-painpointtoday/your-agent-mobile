import 'package:equatable/equatable.dart';

/// Represents the status/approval state of a property listing
enum PropertyStatus {
  pending, // รอการอนุมัติ - Pending approval
  approved, // อนุมัติแล้ว - Approved
  rejected, // ไม่อนุมัติ - Rejected
}

/// Property entity representing a real estate property listing
class Property extends Equatable {
  final String id;
  final String code; // e.g., "000010"
  final String title;
  final String description;
  final String location; // e.g., "ปุณณวิถี, กรุงเทพมหานคร"
  final double latitude;
  final double longitude;
  final String imageUrl;
  final PropertyStatus status;
  final DateTime createdAt;

  const Property({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        code,
        title,
        description,
        location,
        latitude,
        longitude,
        imageUrl,
        status,
        createdAt,
      ];

  /// Returns the Thai label for the property status
  String get statusLabel {
    switch (status) {
      case PropertyStatus.pending:
        return 'รอการอนุมัติ';
      case PropertyStatus.approved:
        return 'อนุมัติแล้ว';
      case PropertyStatus.rejected:
        return 'ไม่อนุมัติ';
    }
  }
}
