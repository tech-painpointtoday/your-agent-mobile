import '../../domain/entities/property.dart';

/// Mock data service for testing property features
class MockPropertyData {
  static final List<Property> mockProperties = [
    Property(
      id: 1,
      code: '000010',
      title:
          'อสังหาริมทรัพย์ที่ 1 บ้านเช่าถูก ปุณณวิถี ใกล้บีทีเอส เดินทางสะดวก',
      description: 'บ้านเช่าถูก ปุณณวิถี ใกล้บีทีเอส เดินทางสะดวก',
      address: 'ปุณณวิถี, กรุงเทพมหานคร',
      latitude: 13.7563,
      longitude: 100.5018,
      price: 15000000,
      approvalStatus: PropertyApprovalStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      bedrooms: 3,
      bathrooms: 2,
      area: 150,
      propertyType: 'บ้านเดี่ยว',
      imageUrl: 'https://placehold.co/600x400',
    ),
    Property(
      id: 2,
      code: '000009',
      title:
          'อสังหาริมทรัพย์ที่ 2 บ้านเช่าถูก ปุณณวิถี ใกล้บีทีเอส เดินทางสะดวก',
      description: 'บ้านเช่าถูก ปุณณวิถี ใกล้บีทีเอส เดินทางสะดวก',
      address: 'ปุณณวิถี, กรุงเทพมหานคร',
      latitude: 13.7650,
      longitude: 100.5120,
      imageUrl: 'https://placehold.co/600x400',
      approvalStatus: PropertyApprovalStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Property(
      id: 3,
      code: '000008',
      title:
          'อสังหาริมทรัพย์ที่ 3 บ้านเช่าถูก ปุณณวิถี ใกล้บีทีเอส เดินทางสะดวก',
      description: 'บ้านเช่าถูก ปุณณวิถี ใกล้บีทีเอส เดินทางสะดวก',
      address: 'ปุณณวิถี, กรุงเทพมหานคร',
      latitude: 13.7480,
      longitude: 100.4950,
      imageUrl: 'https://placehold.co/600x400',
      approvalStatus: PropertyApprovalStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Property(
      id: 4,
      code: '000007',
      title: 'อสังหาริมทรัพย์ที่ 4',
      description: 'บ้านเช่าถูก',
      address: 'ปุณณวิถี, กรุงเทพมหานคร',
      latitude: 13.7700,
      longitude: 100.5250,
      imageUrl: 'https://placehold.co/600x400',
      approvalStatus: PropertyApprovalStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    Property(
      id: 5,
      code: '000006',
      title: 'อสังหาริมทรัพย์ที่ 5',
      description: 'บ้านเช่าถูก',
      address: 'ปุณณวิถี, กรุงเทพมหานคร',
      latitude: 13.7420,
      longitude: 100.4850,
      imageUrl: 'https://placehold.co/600x400',
      approvalStatus: PropertyApprovalStatus.rejected,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Property(
      id: 6,
      code: '000005',
      title: 'อสังหาริมทรัพย์ที่ 6',
      description: 'คอนโดใกล้ BTS',
      address: 'สุขุมวิท, กรุงเทพมหานคร',
      latitude: 13.7320,
      longitude: 100.5600,
      imageUrl: 'https://placehold.co/600x400',
      approvalStatus: PropertyApprovalStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    Property(
      id: 7,
      code: '000004',
      title: 'อสังหาริมทรัพย์ที่ 7',
      description: 'ทาวน์โฮม 3 ชั้น',
      address: 'ลาดพร้าว, กรุงเทพมหานคร',
      latitude: 13.8100,
      longitude: 100.6050,
      imageUrl: 'https://placehold.co/600x400',
      approvalStatus: PropertyApprovalStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Property(
      id: 8,
      code: '000003',
      title: 'อสังหาริมทรัพย์ที่ 8',
      description: 'บ้านเดี่ยว 2 ชั้น',
      address: 'รามคำแหง, กรุงเทพมหานคร',
      latitude: 13.7590,
      longitude: 100.6500,
      imageUrl: 'https://placehold.co/600x400',
      approvalStatus: PropertyApprovalStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    Property(
      id: 9,
      code: '000002',
      title: 'อสังหาริมทรัพย์ที่ 9',
      description: 'คอนโดหรู ริมแม่น้ำ',
      address: 'สาธร, กรุงเทพมหานคร',
      latitude: 13.7230,
      longitude: 100.5280,
      imageUrl: 'https://placehold.co/600x400',
      approvalStatus: PropertyApprovalStatus.rejected,
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
    ),
    Property(
      id: 10,
      code: '000001',
      title: 'อสังหาริมทรัพย์ที่ 10',
      description: 'บ้านพร้อมสวน',
      address: 'บางนา, กรุงเทพมหานคร',
      latitude: 13.6680,
      longitude: 100.6000,
      imageUrl: 'https://placehold.co/600x400',
      approvalStatus: PropertyApprovalStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  /// Get all mock properties
  static List<Property> getAllProperties() => mockProperties;

  /// Get properties by status
  static List<Property> getPropertiesByStatus(PropertyApprovalStatus status) {
    return mockProperties.where((p) => p.approvalStatus == status).toList();
  }
}
