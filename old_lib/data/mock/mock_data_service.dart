import 'package:youragent/domain/entities/booking.dart';
import 'package:youragent/domain/entities/chat_message.dart';
import 'package:youragent/domain/entities/floor_plan.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/domain/entities/property_spec.dart';
import 'package:youragent/domain/entities/property_location.dart';
import 'package:youragent/domain/entities/property_image.dart';
import 'package:youragent/data/models/property_model.dart';

/// Mock Data Service - provides mock data for all entities
/// Makes it easy to implement UI screens without backend
class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  // Mock Properties
  List<PropertyModel> getMockProperties() {
    return [
      PropertyModel(
        id: 1,
        name: 'บ้านฉัตรสุนันทรา',
        description:
            'บ้านตั้งอยู่ในทำเลที่ดี ใกล้ BTS ห้างสรรพสินค้า โรงพยาบาลนานาชาติ และโรงเรียนชื่อดัง เดินทางสะดวก เหมาะสำหรับอยู่อาศัยระยะยาวและการลงทุน',
        location: 'ทุ่งมหาเมฆ สาทร, กรุงเทพ (ห่างจากมาจทะ 12 กม.)',
        price: 11250000,
        bedrooms: 4,
        bathrooms: 4,
        area: 99.9,
        propertyType: 'House',
        hasPool: false,
        hasFireplace: false,
        hasGarage: true,
        floors: 2,
        imageUrl: 'assets/images/imagewithfallback@2x.png',
        imageUrls: [
          'assets/images/imagewithfallback@2x.png',
          'assets/images/imagewithfallback-1@2x.png',
          'assets/images/imagewithfallback-2@2x.png',
          'assets/images/imagewithfallback-3@2x.png',
          'assets/images/imagewithfallback-4@2x.png',
        ],
        hasAgent: true,
        compatibility: 94.5,
        fengshuiScore: 94.5,
        approvalStatus: 'approved',
        viewCount: 150,
        clickCount: 45,
        favoriteCount: 12,
        built: '2022',
        specs: PropertySpec(
          id: 1,
          propertyId: 1,
          name: "T",
          bedrooms: 4,
          bathrooms: 4,
          garage: 4,
          type: 'House',
          status: 'พร้อมโอน',
          price: '11250000',
          description:
              'บ้านตั้งอยู่ในทำเลที่ดี ใกล้ BTS ห้างสรรพสินค้า โรงพยาบาลนานาชาติ และโรงเรียนชื่อดัง เดินทางสะดวก เหมาะสำหรับอยู่อาศัยระยะยาวและการลงทุน',
          buildingSize: 99.9,
          landSize: 120.5,
          fengshuiScore: 94.5,
        ),
        propertyLocation: PropertyLocation(
          id: 1,
          propertyId: 1,
          city: 'กรุงเทพ',
          state: 'กรุงเทพมหานคร',
          country: 'Thailand',
          direction: 'ทิศเหนือ',
          latitude: 13.7563,
          longitude: 100.5018,
        ),
        images: [
          PropertyImage(
            id: 1,
            propertyId: 1,
            url: 'assets/images/imagewithfallback@2x.png',
            validatedUrl: 'assets/images/imagewithfallback@2x.png',
            isUrlValid: true,
          ),
          PropertyImage(
            id: 2,
            propertyId: 1,
            url: 'assets/images/imagewithfallback-1@2x.png',
            validatedUrl: 'assets/images/imagewithfallback-1@2x.png',
            isUrlValid: true,
          ),
          PropertyImage(
            id: 3,
            propertyId: 1,
            url: 'assets/images/imagewithfallback-2@2x.png',
            validatedUrl: 'assets/images/imagewithfallback-2@2x.png',
            isUrlValid: true,
          ),
          PropertyImage(
            id: 4,
            propertyId: 1,
            url: 'assets/images/imagewithfallback-3@2x.png',
            validatedUrl: 'assets/images/imagewithfallback-3@2x.png',
            isUrlValid: true,
          ),
          PropertyImage(
            id: 5,
            propertyId: 1,
            url: 'assets/images/imagewithfallback-4@2x.png',
            validatedUrl: 'assets/images/imagewithfallback-4@2x.png',
            isUrlValid: true,
          ),
        ],
      ),
      PropertyModel(
        id: 2,
        name: 'Modern House in Chiang Mai',
        description:
            'บ้านตั้งอยู่ในทำเลที่ดี ใกล้ BTS ห้างสรรพสินค้า โรงพยาบาลนานาชาติ และโรงเรียนชื่อดัง เดินทางสะดวก เหมาะสำหรับอยู่อาศัยระยะยาวและการลงทุน',
        location: 'Chiang Mai, Thailand',
        price: 8500000,
        bedrooms: 4,
        bathrooms: 3,
        area: 200.0,
        propertyType: 'House',
        hasPool: false,
        hasFireplace: true,
        hasGarage: true,
        floors: 2,
        imageUrl: 'assets/images/imagewithfallback-1@2x.png',
        imageUrls: [
          'assets/images/imagewithfallback-1@2x.png',
          'assets/images/imagewithfallback-2@2x.png',
        ],
        hasAgent: false,
        compatibility: 88.0,
        fengshuiScore: 88.0,
        approvalStatus: 'approved',
        viewCount: 98,
        clickCount: 32,
        favoriteCount: 8,
        built: '2020',
        specs: PropertySpec(
          id: 2,
          name: "T",
          propertyId: 2,
          bedrooms: 4,
          bathrooms: 3,
          garage: 2,
          type: 'House',
          status: 'พร้อมโอน',
          price: '8500000',
          description: 'Modern house with great amenities',
          buildingSize: 200.0,
          landSize: 250.0,
          fengshuiScore: 88.0,
        ),
        propertyLocation: PropertyLocation(
          id: 2,
          propertyId: 2,
          city: 'Chiang Mai',
          state: 'Chiang Mai',
          country: 'Thailand',
          direction: 'ทิศใต้',
          latitude: 18.7883,
          longitude: 98.9853,
        ),
        images: [
          PropertyImage(
            id: 6,
            propertyId: 2,
            url: 'assets/images/imagewithfallback-1@2x.png',
            validatedUrl: 'assets/images/imagewithfallback-1@2x.png',
            isUrlValid: true,
          ),
          PropertyImage(
            id: 7,
            propertyId: 2,
            url: 'assets/images/imagewithfallback-2@2x.png',
            validatedUrl: 'assets/images/imagewithfallback-2@2x.png',
            isUrlValid: true,
          ),
        ],
      ),
      PropertyModel(
        id: 3,
        name: 'Penthouse Suite',
        description:
            'บ้านตั้งอยู่ในทำเลที่ดี ใกล้ BTS ห้างสรรพสินค้า โรงพยาบาลนานาชาติ และโรงเรียนชื่อดัง เดินทางสะดวก เหมาะสำหรับอยู่อาศัยระยะยาวและการลงทุน',
        location: 'Phuket, Thailand',
        price: 25000000,
        bedrooms: 5,
        bathrooms: 4,
        area: 350.0,
        propertyType: 'Condo',
        hasPool: true,
        hasFireplace: true,
        hasGarage: true,
        floors: 1,
        imageUrl: 'assets/images/imagewithfallback-2@2x.png',
        imageUrls: [
          'assets/images/imagewithfallback-2@2x.png',
          'assets/images/imagewithfallback-3@2x.png',
          'assets/images/imagewithfallback-4@2x.png',
        ],
        hasAgent: true,
        compatibility: 92.3,
        fengshuiScore: 92.3,
        approvalStatus: 'pending',
        viewCount: 75,
        clickCount: 20,
        favoriteCount: 5,
        built: '2021',
        specs: PropertySpec(
          id: 3,
          propertyId: 3,
          name: "T",
          bedrooms: 5,
          bathrooms: 4,
          garage: 3,
          type: 'Condo',
          status: 'พร้อมโอน',
          price: '25000000',
          description: 'Luxury penthouse with amazing views',
          buildingSize: 350.0,
          fengshuiScore: 92.3,
        ),
        propertyLocation: PropertyLocation(
          id: 3,
          propertyId: 3,
          city: 'Phuket',
          state: 'Phuket',
          country: 'Thailand',
          direction: 'ทิศตะวันออก',
          latitude: 7.8804,
          longitude: 98.3923,
        ),
        images: [
          PropertyImage(
            id: 8,
            propertyId: 3,
            url: 'assets/images/imagewithfallback-2@2x.png',
            validatedUrl: 'assets/images/imagewithfallback-2@2x.png',
            isUrlValid: true,
          ),
          PropertyImage(
            id: 9,
            propertyId: 3,
            url: 'assets/images/imagewithfallback-3@2x.png',
            validatedUrl: 'assets/images/imagewithfallback-3@2x.png',
            isUrlValid: true,
          ),
          PropertyImage(
            id: 10,
            propertyId: 3,
            url: 'assets/images/imagewithfallback-4@2x.png',
            validatedUrl: 'assets/images/imagewithfallback-4@2x.png',
            isUrlValid: true,
          ),
        ],
      ),
    ];
  }

  // Mock Bookings
  List<Booking> getMockBookings() {
    return [
      Booking(
        id: 1,
        propertyId: 1,
        buyerId: 1,
        agentId: 1,
        ymd: '2024-12-15',
        time: '10:00',
        status: BookingStatus.pending,
        autoMatched: false,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Booking(
        id: 2,
        propertyId: 2,
        buyerId: 2,
        agentId: 1,
        ymd: '2024-12-16',
        time: '14:00',
        status: BookingStatus.confirmed,
        autoMatched: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        confirmedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      Booking(
        id: 3,
        propertyId: 3,
        buyerId: 3,
        agentId: 2,
        ymd: '2024-12-17',
        time: '16:00',
        status: BookingStatus.cancelled,
        autoMatched: false,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        cancelledAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];
  }

  // Mock Chat Messages
  List<ChatMessage> getMockChatMessages({required int bookingId}) {
    return [
      ChatMessage(
        id: 1,
        bookingId: bookingId,
        senderType: SenderType.buyer,
        senderId: 1,
        message: 'Hello, I am interested in viewing this property.',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        senderName: 'John Doe',
      ),
      ChatMessage(
        id: 2,
        bookingId: bookingId,
        senderType: SenderType.agent,
        senderId: 1,
        message:
            'Thank you for your interest! I can arrange a viewing for you.',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        senderName: 'Agent Smith',
      ),
      ChatMessage(
        id: 3,
        bookingId: bookingId,
        senderType: SenderType.buyer,
        senderId: 1,
        message: 'That would be great! When is the best time?',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        senderName: 'John Doe',
      ),
    ];
  }

  // Mock Floor Plans
  List<FloorPlan> getMockFloorPlans({required int propertyId}) {
    return [
      FloorPlan(
        id: 1,
        propertyId: propertyId,
        story: 1,
        filename: 'floor_plan_1.json',
        url: 'https://example.com/floorplan1.json',
        validatedUrl: 'https://example.com/floorplan1.json',
        fileType: FloorPlanFileType.json,
        isUrlValid: true,
      ),
      FloorPlan(
        id: 2,
        propertyId: propertyId,
        story: 2,
        filename: 'floor_plan_2.gltf',
        url: 'https://example.com/floorplan2.gltf',
        validatedUrl: 'https://example.com/floorplan2.gltf',
        fileType: FloorPlanFileType.gltf,
        isUrlValid: true,
      ),
    ];
  }

  // Mock User
  User getMockUser({UserRole role = UserRole.agent}) {
    return User(
      id: '1',
      email: 'user@example.com',
      displayName: 'John Doe',
      role: role,
      provider: 'email',
    );
  }

  // Mock Available Times
  List<Map<String, dynamic>> getMockAvailableTimes() {
    return [
      {
        'id': 1,
        'date': '2024-12-15',
        'start_time': '09:00',
        'end_time': '12:00',
        'is_available': true,
      },
      {
        'id': 2,
        'date': '2024-12-15',
        'start_time': '14:00',
        'end_time': '17:00',
        'is_available': true,
      },
      {
        'id': 3,
        'date': '2024-12-16',
        'start_time': '10:00',
        'end_time': '13:00',
        'is_available': false,
      },
    ];
  }

  // Mock Payments
  List<Map<String, dynamic>> getMockPayments() {
    return [
      {
        'id': 1,
        'amount': 5000.0,
        'status': 'completed',
        'date': '2024-12-01',
        'description': 'Property listing fee',
      },
      {
        'id': 2,
        'amount': 2500.0,
        'status': 'pending',
        'date': '2024-12-10',
        'description': 'Premium feature upgrade',
      },
    ];
  }

  // Mock Support Tickets
  List<Map<String, dynamic>> getMockSupportTickets() {
    return [
      {
        'id': 1,
        'subject': 'Property listing issue',
        'status': 'open',
        'created_at': '2024-12-05',
        'last_message': 'I need help with my property listing.',
      },
      {
        'id': 2,
        'subject': 'Payment question',
        'status': 'resolved',
        'created_at': '2024-12-01',
        'last_message': 'When will my payment be processed?',
      },
    ];
  }
}
