import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/widgets/app_search_bar.dart';
import 'package:youragent/widgets/backgrounds/blue_wave_background.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import '../widgets/calendar_appointment_card.dart';
import '../widgets/calendar_history_card.dart';
import '../widgets/calendar_availability_section.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  late TextEditingController _searchController;
  double _appBarOpacity = 0.0;
  final double _fadeThreshold = 100.0;

  int _activeFilterIndex = 0;
  final List<String> _filters = ['ทั้งหมด', 'วันนี้', 'พรุ่งนี้', 'สัปดาห์นี้'];

  // History month selector state
  int _selectedHistoryMonthIndex = 0; // 0 = มกราคม
  static const List<String> _thaiMonths = [
    'มกราคม 2569',
    'กุมภาพันธ์ 2569',
    'มีนาคม 2569',
    'เมษายน 2569',
    'พฤษภาคม 2569',
    'มิถุนายน 2569',
    'กรกฎาคม 2569',
    'สิงหาคม 2569',
    'กันยายน 2569',
    'ตุลาคม 2569',
    'พฤศจิกายน 2569',
    'ธันวาคม 2569',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showMonthPicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9EAEB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'เลือกเดือน',
                  style: GoogleFonts.anuphan(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.baseBlack,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: AppColors.basePaleGrey),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _thaiMonths.length,
                  itemBuilder: (ctx, i) {
                    final isSelected = i == _selectedHistoryMonthIndex;
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedHistoryMonthIndex = i);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.supportBlueLight
                              : Colors.transparent,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _thaiMonths[i],
                              style: GoogleFonts.anuphan(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? AppColors.supportBlueDeep
                                    : AppColors.baseBlack,
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_rounded,
                                size: 18,
                                color: AppColors.supportBlueDeep,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _scrollListener() {
    final double newOpacity = (_scrollController.offset / _fadeThreshold).clamp(
      0.0,
      1.0,
    );
    if ((newOpacity - _appBarOpacity).abs() > 0.01) {
      setState(() {
        _appBarOpacity = newOpacity;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [_buildSliverAppBar()];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAppointmentListSection(context),
            _buildHistorySection(context),
            _buildAvailabilitySection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 0,
      collapsedHeight: MediaQuery.of(context).size.width * (68 / 360),
      backgroundColor: AppColors.primary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Text(
        'ตารางเวลา',
        style: GoogleFonts.anuphan(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      flexibleSpace: const BlueWaveBackground(hasFilter: true),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(36),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                Container(height: 18, color: Colors.transparent),
                Container(height: 18, color: Colors.white),
              ],
            ),
            _buildTabCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFF5F8FF),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: AppColors.supportBlueDark,
            borderRadius: BorderRadius.circular(8),
          ),
          labelColor: AppColors.supportBlueLight,
          unselectedLabelColor: AppColors.baseDarkGrey,
          labelStyle: GoogleFonts.anuphan(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: GoogleFonts.anuphan(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          padding: EdgeInsets.zero,
          indicatorPadding: EdgeInsets.zero,
          labelPadding: EdgeInsets.zero,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'รายการนัดหมาย'),
            Tab(text: 'ประวัติการนัด'),
            Tab(text: 'ช่วงเวลาว่าง'),
          ],
        ),
      ),
    );
  }

  // ── Tab 1: Appointment list ─────────────────────────────────────────────
  Widget _buildAppointmentListSection(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'รายการนัดหมาย',
                    style: GoogleFonts.anuphan(
                      color: const Color(0xFF1743C7),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'รายการนัดหมายทั้งหมด 5 รายการ',
                    style: GoogleFonts.anuphan(
                      color: const Color(0xFF737373),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Filter badges
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_filters.length, (index) {
                  final isSelected = _activeFilterIndex == index;
                  return AppBadge(
                    label: _filters[index],
                    customBackgroundColor: isSelected
                        ? AppColors.supportBlueDeep
                        : AppColors.white,
                    customTextColor: isSelected
                        ? AppColors.supportBlueLight
                        : AppColors.baseDarkGrey,
                    hasBorder: !isSelected,
                    borderColor: const Color(0xFFE9EAEB),
                    onDismiss: () => setState(() => _activeFilterIndex = index),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppSearchBar(
                controller: _searchController,
                hintText: AppLocalizations.of(context).searchHint,
              ),
            ),
            const SizedBox(height: 16),
            // Appointment list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _mockAppointments.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _mockAppointments[index];
                  return CalendarAppointmentCard(
                    propertyTitle: item['title']!,
                    propertyAddress: item['address']!,
                    imageUrl: item['image'],
                    visitorName: item['visitor']!,
                    dateTime: item['dateTime']!,
                    confirmStatus: item['status'] == 'confirmed'
                        ? AppointmentStatus.confirmed
                        : AppointmentStatus.pending,
                    travelStatus: item['travel'] == 'arriving'
                        ? TravelStatus.arriving
                        : TravelStatus.notStarted,
                    arrivingIn: item['arrivingIn'],
                    // First item starts expanded as demo
                    initiallyExpanded: index == 0,
                    onSecondaryAction: () {},
                    onPrimaryAction: () {},
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<Map<String, String?>> _mockAppointments = [
    {
      'title':
          'อสังหาริมทรัพย์ที่ 1 บ้านเช่าถูก ปุณณวิถี ใกล้บีทีเอส เดินทางสะดวก',
      'address': 'ปุณณวิถี 33 แขวงบางจาก เขตพระโขนง กรุงเทพมหานคร 10260',
      'image':
          'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=400',
      'visitor': 'สมชาย ใจดี',
      'dateTime': '5 ม.ค. 2569, 08:00 น.',
      'status': 'confirmed',
      'travel': 'arriving',
      'arrivingIn': '07:55 น.',
    },
    {
      'title':
          'อสังหาริมทรัพย์ 2: คอนโดใหญ่ขนาดกว้าง ในสีลม เหมาะสำหรับมืออาชีพ...',
      'address': 'สีลม 10, เขตบางรัก, กรุงเทพมหานคร 10500',
      'image':
          'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=400',
      'visitor': 'สมชาย ใจดี',
      'dateTime': '5 ม.ค. 2569, 08:00 น.',
      'status': 'pending',
      'travel': 'notStarted',
      'arrivingIn': null,
    },
    {
      'title':
          'อสังหาริมทรัพย์ที่ 1 บ้านเช่าถูก ปุณณวิถี ใกล้บีทีเอส เดินทางสะดวก',
      'address': 'ปุณณวิถี 33 แขวงบางจาก เขตพระโขนง กรุงเทพมหานคร 10260',
      'image':
          'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=400',
      'visitor': 'สมชาย ใจดี',
      'dateTime': '5 ม.ค. 2569, 08:00 น.',
      'status': 'pending',
      'travel': 'notStarted',
      'arrivingIn': null,
    },
  ];

  // ── Tab 2: Appointment history ──────────────────────────────────────────
  Widget _buildHistorySection(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ประวัติการนัด',
                    style: GoogleFonts.anuphan(
                      color: AppColors.brandBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'รายการนัดหมายย้อนหลังทั้งหมด 5 รายการ',
                    style: GoogleFonts.anuphan(
                      color: AppColors.baseDarkGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ── Month selector (tappable dropdown) ───────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: _showMonthPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: AppColors.baseLightGrey,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x0C000000),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _thaiMonths[_selectedHistoryMonthIndex],
                        style: GoogleFonts.anuphan(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.baseBlack,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: AppColors.baseDarkGrey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // ── History cards ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _mockHistory.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _mockHistory[index];
                  return CalendarHistoryCard(
                    propertyTitle: item['title']!,
                    propertyAddress: item['address']!,
                    imageUrl: item['image'],
                    visitorName: item['visitor']!,
                    dateTime: item['dateTime']!,
                    status: item['status'] == 'visited'
                        ? AppointmentHistoryStatus.visited
                        : AppointmentHistoryStatus.cancelled,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<Map<String, String?>> _mockHistory = [
    {
      'title':
          'อสังหาริมทรัพย์ที่ 1 บ้านเช่าถูก ปุณณวิถี ใกล้บีทีเอส เดินทางสะดวก',
      'address': 'ปุณณวิถี 33 แขวงบางจาก เขตพระโขนง กรุงเทพมหานคร 10260',
      'image':
          'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=400',
      'visitor': 'สมชาย ใจดี',
      'dateTime': '5 ม.ค. 2569, 08:00 น.',
      'status': 'visited',
    },
    {
      'title':
          'อสังหาริมทรัพย์ที่ 1 บ้านเช่าถูก ปุณณวิถี ใกล้บีทีเอส เดินทางสะดวก',
      'address': 'ปุณณวิถี 33 แขวงบางจาก เขตพระโขนง กรุงเทพมหานคร 10260',
      'image':
          'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=400',
      'visitor': 'สมชาย ใจดี',
      'dateTime': '5 ม.ค. 2569, 08:00 น.',
      'status': 'cancelled',
    },
    {
      'title':
          'อสังหาริมทรัพย์ที่ 1 บ้านเช่าถูก ปุณณวิถี ใกล้บีทีเอส เดินทางสะดวก',
      'address': 'ปุณณวิถี 33 แขวงบางจาก เขตพระโขนง กรุงเทพมหานคร 10260',
      'image':
          'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=400',
      'visitor': 'สมชาย ใจดี',
      'dateTime': '5 ม.ค. 2569, 08:00 น.',
      'status': 'visited',
    },
    {
      'title':
          'อสังหาริมทรัพย์ที่ 1 บ้านเช่าถูก ปุณณวิถี ใกล้บีทีเอส เดินทางสะดวก',
      'address': 'ปุณณวิถี 33 แขวงบางจาก เขตพระโขนง กรุงเทพมหานคร 10260',
      'image':
          'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=400',
      'visitor': 'สมชาย ใจดี',
      'dateTime': '5 ม.ค. 2569, 08:00 น.',
      'status': 'visited',
    },
  ];

  // ── Tab 3: Availability ───────────────────────────────────────────────
  Widget _buildAvailabilitySection(BuildContext context) {
    return const CalendarAvailabilitySection();
  }

  // ── Shared empty state ───────────────────────────────────────────────
}
