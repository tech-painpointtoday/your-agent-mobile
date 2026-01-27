import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/data/mock/mock_property_data.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import 'package:intl/intl.dart';
import '../widgets/property_image_carousel.dart';
import '../widgets/property_detail_section.dart';
import '../widgets/property_status_badge.dart';

class PropertyDetailScreen extends StatefulWidget {
  final String propertyId;

  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  bool _isLoading = true;
  Property? _property;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPropertyDetail();
  }

  Future<void> _fetchPropertyDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Find property from mock data
      final property = MockPropertyData.getAllProperties().firstWhere(
        (p) => p.id == widget.propertyId,
        orElse: () => throw Exception('Property not found'),
      );

      setState(() {
        _property = property;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _property == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.supportRedDeep,
              ),
              const SizedBox(height: 16),
              Text(_error ?? 'Property not found', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              SizedBox(
                width: 200,
                child: AppButton(
                  text: 'ลองใหม่',
                  style: AppButtonStyle.outline,
                  onPressed: _fetchPropertyDetail,
                  height: 40,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [_buildBody(), _buildBottomBar()]),
    );
  }

  Widget _buildBody() {
    final property = _property!;
    // Using placeholders/mock values for missing fields in Property entity
    final imageUrls = [
      property.imageUrl,
      "https://placehold.co/600x400",
      "https://placehold.co/600x400",
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Image Carousel
          PropertyImageCarousel(imageUrls: imageUrls),

          // 2. Property Header Card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: AppColors.baseGrey),
                  borderRadius: BorderRadius.circular(12),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'รหัส: ${property.code}',
                    style: GoogleFonts.anuphan(
                      color: AppColors.baseGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    property.title,
                    style: GoogleFonts.anuphan(
                      color: const Color(0xFF181D27),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.location,
                    style: GoogleFonts.anuphan(
                      color: const Color(0xFF181D27),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 12),
                  PropertyStatusBadge(status: property.status),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // 3. Location Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: Color(0xFF181D27),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ตำแหน่งที่ตั้ง',
                      style: GoogleFonts.anuphan(
                        color: const Color(0xFF181D27),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.basePaleGrey,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(color: AppColors.basePaleGrey),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF0A0C12,
                                  ).withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.fullscreen,
                              color: Color(0xFF181D27),
                            ),
                          ),
                        ),
                        const Center(
                          child: Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 4. Property Detail Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PropertyDetailSection(
              title: 'รายละเอียดทรัพย์',
              icon: Icons.list_alt_outlined,
              rows: [
                const PropertyDetailRow(label: 'ประเภททรัพย์', value: 'บ้าน'),
                const PropertyDetailRow(label: 'ประเภทประกาศ', value: 'เช่า'),
                PropertyDetailRow(
                  label: 'สถานะ',
                  value: property.status == PropertyStatus.approved
                      ? 'ว่าง'
                      : property.statusLabel,
                ),
                PropertyDetailRow(
                  label: 'วันที่สร้าง',
                  value: DateFormat(
                    'dd ม.ค. yyyy',
                    'th',
                  ).format(property.createdAt),
                ),
                const PropertyDetailRow(label: 'สีทรัพย์', value: 'ขาว'),
                const PropertyDetailRow(label: 'ราคา', value: '10,000,000 บาท'),
                const PropertyDetailRow(label: 'จำนวนชั้น', value: '2 ชั้น'),
                const PropertyDetailRow(label: 'จำนวนห้องนอน', value: '4 ห้อง'),
                const PropertyDetailRow(label: 'จำนวนห้องน้ำ', value: '4 ห้อง'),
                const PropertyDetailRow(label: 'จำนวนที่จอดรถ', value: '4 ที่'),
                const PropertyDetailRow(
                  label: 'ขนาดที่ดิน',
                  value: '52.70 ตร.ว.',
                ),
                const PropertyDetailRow(
                  label: 'ขนาดพื้นที่ใช้สอย',
                  value: '80.00 ตร.ม.',
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 5. Additional Details Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 8),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 1, color: AppColors.baseGrey),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Color(0xFF181D27),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'รายละเอียดเพิ่มเติม',
                        style: GoogleFonts.anuphan(
                          color: const Color(0xFF181D27),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'สไตล์ทรัพย์',
                  style: GoogleFonts.anuphan(
                    color: AppColors.baseDarkGrey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                const AppBadge(label: 'โมเดิร์น', color: BadgeColor.blue),
                const SizedBox(height: 20),

                Text(
                  'จุดเด่นทรัพย์',
                  style: GoogleFonts.anuphan(
                    color: AppColors.baseDarkGrey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppBadge(label: 'Pet-friendly', color: BadgeColor.blue),
                    AppBadge(label: 'Elderly-friendly', color: BadgeColor.blue),
                    AppBadge(label: 'ใกล้รถไฟฟ้า', color: BadgeColor.blue),
                  ],
                ),
                const SizedBox(height: 20),

                Text(
                  'พื้นที่ส่วนกลาง',
                  style: GoogleFonts.anuphan(
                    color: AppColors.baseDarkGrey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppBadge(label: 'Co-working space', color: BadgeColor.blue),
                    AppBadge(label: 'สระว่ายน้ำ', color: BadgeColor.blue),
                    AppBadge(label: 'ฟิตเนส', color: BadgeColor.blue),
                  ],
                ),
                const SizedBox(height: 20),

                Text(
                  'รายละเอียด',
                  style: GoogleFonts.anuphan(
                    color: AppColors.baseDarkGrey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  property.description,
                  style: GoogleFonts.anuphan(
                    color: const Color(0xFF181D27),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'ดูเพิ่มเติม',
                      style: GoogleFonts.anuphan(
                        color: AppColors.primary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.primary,
                      size: 14,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 80,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x145A5A5A),
              blurRadius: 24,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.baseGrey),
              ),
              child: SvgPicture.asset(
                'assets/icons/chevron-left.svg',
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  AppColors.baseDarkGrey,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppButton(
                text: 'แก้ไขข้อมูล',
                style: AppButtonStyle.primary,
                onPressed: () {
                  // Confirmation logic
                },
                height: 44,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
