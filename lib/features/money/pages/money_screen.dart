import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/widgets/app_search_bar.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import 'package:youragent/widgets/backgrounds/blue_wave_background.dart';
import 'package:youragent/widgets/app_coming_soon_placeholder.dart';

import '../widgets/money_property_card.dart';
import 'package:youragent/widgets/modals/app_call_bottom_sheet.dart';
import 'payment_detail_screen.dart';
import 'payment_receipt_screen.dart';

class MoneyScreen extends StatefulWidget {
  const MoneyScreen({super.key});

  @override
  State<MoneyScreen> createState() => _MoneyScreenState();
}

class _MoneyScreenState extends State<MoneyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  late TextEditingController _searchController;
  double _appBarOpacity = 0.0;
  final double _fadeThreshold = 100.0;

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

  int _activeFilterIndex = 0;
  final List<String> _filters = ['ทั้งหมด', 'วันนี้', 'พรุ่งนี้', 'สัปดาห์นี้'];

  int _overdueFilterIndex = 0;
  final List<String> _overdueFilters = [
    'ทั้งหมด',
    'นานกว่า 7 วัน',
    'นานกว่า 14 วัน',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double headerHeight = constraints.maxHeight * 0.38;

          return Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: headerHeight,
                child: const BlueWaveBackground(),
              ),
              SafeArea(child: Center(child: const AppComingSoonPlaceholder())),
              Positioned(
                top: kToolbarHeight,
                left: 16,
                child: IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/chevron-left.svg',
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                    colorFilter: const ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          );
        },
      ),
    );

    // return Scaffold(
    //   backgroundColor: Colors.white,
    //   body: NestedScrollView(
    //     controller: _scrollController,
    //     headerSliverBuilder: (context, innerBoxIsScrolled) {
    //       return [_buildSliverAppBar()];
    //     },
    //     body: TabBarView(
    //       controller: _tabController,
    //       children: [
    //         SingleChildScrollView(
    //           padding: const EdgeInsets.only(bottom: 32),
    //           child: _buildCollectionSection(context),
    //         ),
    //         SingleChildScrollView(
    //           padding: const EdgeInsets.only(bottom: 32),
    //           child: _buildOverdueSection(context),
    //         ),
    //         SingleChildScrollView(
    //           padding: const EdgeInsets.only(bottom: 32),
    //           child: _buildHistorySection(context),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: MediaQuery.of(context).size.width * (186 / 360),
      collapsedHeight: MediaQuery.of(context).size.width * (68 / 360),
      backgroundColor: AppColors.primary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: const Text(
        'การเงิน',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontFamily: 'Anuphan',
          fontWeight: FontWeight.w500,
        ),
      ),
      flexibleSpace: Stack(
        children: [
          Positioned.fill(child: BlueWaveBackground(hasFilter: true)),
          Positioned(
            top: 108,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 1 - _appBarOpacity,
              child: _buildCommissionSection(),
            ),
          ),
        ],
      ),
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
            _buildQuickActionCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildCommissionSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'คอมมิชชันเดือนนี้',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'Anuphan',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '฿ 108,240',
              style: GoogleFonts.anuphan(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '.56',
              style: GoogleFonts.anuphan(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 0, left: 16, right: 16),
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
            Tab(text: 'รายการเรียกเก็บ'),
            Tab(text: 'รายการค้างชำระ'),
            Tab(text: 'ประวัติการชำระ'),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionSection(BuildContext context) {
    return Container(
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
                const Text(
                  'รายการเรียกเก็บ',
                  style: TextStyle(
                    color: Color(0xFF1743C7),
                    fontSize: 16,
                    fontFamily: 'Anuphan',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'รายการที่ต้องเรียกเก็บเงินทั้งหมด 5 รายการ',
                  style: TextStyle(
                    color: Color(0xFF737373),
                    fontSize: 12,
                    fontFamily: 'Anuphan',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Filters
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
          const SizedBox(height: 16),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppSearchBar(
              controller: _searchController,
              hintText: AppLocalizations.of(context).searchHint,
            ),
          ),
          const SizedBox(height: 16),
          // Property List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final mockData = [
                  {
                    'installment': 'งวดชำระที่ 7/12',
                    'tenant': 'สมหญิง สงวนงาม',
                    'tenant_phone': '0812345678',
                    'owner_phone': '0898765432',
                    'title':
                        'อสังหาริมทรัพย์ที่ 1 บ้านเช่าถูก ปุณณวิถี ใกล้บีทีเอส เดินทางสะดวก',
                    'price': '10,000',
                    'date': 'วันนี้',
                    'image':
                        'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=400',
                  },
                  {
                    'installment': 'งวดชำระที่ 7/12',
                    'tenant': 'สมหญิง สงวนงาม',
                    'tenant_phone': '0812345678',
                    'owner_phone': '0898765432',
                    'title':
                        'อสังหาริมทรัพย์ที่ 1 บ้านเช่าถูก ปุณณวิถี ใกล้บีทีเอส เดินทางสะดวก',
                    'price': '10,000',
                    'date': '25 ก.พ. 69',
                    'image':
                        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=400',
                  },
                  {
                    'installment': 'งวดชำระที่ 7/12',
                    'tenant': 'สมหญิง สงวนงาม',
                    'tenant_phone': '0812345678',
                    'owner_phone': '0898765432',
                    'title':
                        'อสังหาริมทรัพย์ที่ 1 บ้านเช่าถูก ปุณณวิถี ใกล้บีทีเอส เดินทางสะดวก',
                    'price': '10,000',
                    'date': '25 ก.พ. 69',
                    'image':
                        'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=400',
                  },
                ];
                final item = mockData[index];
                return MoneyPropertyCard(
                  installment: item['installment'],
                  tenantName: item['tenant'],
                  title: item['title']!,
                  price: item['price']!,
                  dueDate: item['date']!,
                  imageUrl: item['image'],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaymentDetailScreen(),
                      ),
                    );
                  },
                  onCall: () {
                    AppCallBottomSheet.show(
                      context: context,
                      options: [
                        if (item['owner_phone'] != null)
                          CallOption(
                            label: 'เจ้าของทรัพย์',
                            phone: item['owner_phone']!,
                          ),
                        if (item['tenant_phone'] != null)
                          CallOption(
                            label: 'ผู้เช่า',
                            phone: item['tenant_phone']!,
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverdueSection(BuildContext context) {
    return Container(
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
                const Text(
                  'รายการค้างชำระ',
                  style: TextStyle(
                    color: Color(0xFF1743C7),
                    fontSize: 16,
                    fontFamily: 'Anuphan',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'รายการที่ค้างชำระทั้งหมด 5 รายการ',
                  style: TextStyle(
                    color: Color(0xFF737373),
                    fontSize: 12,
                    fontFamily: 'Anuphan',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_overdueFilters.length, (index) {
                final isSelected = _overdueFilterIndex == index;
                return AppBadge(
                  label: _overdueFilters[index],
                  customBackgroundColor: isSelected
                      ? AppColors.supportBlueDeep
                      : AppColors.white,
                  customTextColor: isSelected
                      ? AppColors.supportBlueLight
                      : AppColors.baseDarkGrey,
                  hasBorder: !isSelected,
                  borderColor: const Color(0xFFE9EAEB),
                  onDismiss: () => setState(() => _overdueFilterIndex = index),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppSearchBar(
              controller: _searchController,
              hintText: AppLocalizations.of(context).searchHint,
            ),
          ),
          const SizedBox(height: 16),
          // Property List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 2,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final mockData = [
                  {
                    'installment': 'งวดชำระที่ 7/12',
                    'tenant': 'สมหญิง สงวนงาม',
                    'tenant_phone': '0812345678',
                    'owner_phone': '0898765432',
                    'title':
                        'อสังหาริมทรัพย์ที่ 1 บ้านเช่าถูก ปุณณวิถี ใกล้บีทีเอส เดินทางสะดวก',
                    'price': '10,000',
                    'date': '25 ก.พ. 69',
                    'fine': '400',
                    'status': 'ชำระล่าช้า : 2 วัน',
                    'image':
                        'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=400',
                  },
                  {
                    'installment': 'งวดชำระที่ 7/12',
                    'tenant': 'สมหญิง สงวนงาม',
                    'tenant_phone': '0812345678',
                    'owner_phone': '0898765432',
                    'title':
                        'อสังหาริมทรัพย์ที่ 1 บ้านเช่าถูก ปุณณวิถี ใกล้บีทีเอส เดินทางสะดวก',
                    'price': '10,000',
                    'date': '25 ก.พ. 69',
                    'fine': null,
                    'status': 'ชำระล่าช้า : 2 วัน',
                    'image':
                        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=400',
                  },
                ];
                final item = mockData[index];
                return MoneyPropertyCard(
                  installment: item['installment'],
                  tenantName: item['tenant'],
                  title: item['title']!,
                  price: item['price']!,
                  dueDate: item['date']!,
                  imageUrl: item['image'],
                  isOverdue: true,
                  fineAmount: item['fine'],
                  overdueStatus: item['status'],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaymentDetailScreen(),
                      ),
                    );
                  },
                  onCall: () {
                    AppCallBottomSheet.show(
                      context: context,
                      options: [
                        if (item['owner_phone'] != null)
                          CallOption(
                            label: 'เจ้าของทรัพย์',
                            phone: item['owner_phone']!,
                          ),
                        if (item['tenant_phone'] != null)
                          CallOption(
                            label: 'ผู้เช่า',
                            phone: item['tenant_phone']!,
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    return Container(
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
                const Text(
                  'ประวัติการชำระ',
                  style: TextStyle(
                    color: Color(0xFF1743C7),
                    fontSize: 16,
                    fontFamily: 'Anuphan',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'รายการที่ชำระแล้วทั้งหมด 5 รายการ',
                  style: TextStyle(
                    color: Color(0xFF737373),
                    fontSize: 12,
                    fontFamily: 'Anuphan',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Month Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFFE9EAEB)),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'มกราคม 2569',
                    style: GoogleFonts.anuphan(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF181D27),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF717680),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Property List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 2,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final mockData = [
                  {
                    'installment': 'งวดชำระที่ 7/12',
                    'tenant': 'สมหญิง สงวนงาม',
                    'title':
                        'อสังหาริมทรัพย์ที่ 1 บ้านเช่าถูก ปุณณวิถี ใกล้บีทีเอส เดินทางสะดวก',
                    'price': '10,000',
                    'date': '25 ก.พ. 69',
                    'paid_date': 'ชำระเมื่อ : 1 ม.ค. 69',
                    'image':
                        'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=400',
                  },
                  {
                    'installment': 'งวดชำระที่ 7/12',
                    'tenant': 'สมหญิง สงวนงาม',
                    'title':
                        'อสังหาริมทรัพย์ที่ 1 บ้านเช่าถูก ปุณณวิถี ใกล้บีทีเอส เดินทางสะดวก',
                    'price': '10,000',
                    'date': '25 ก.พ. 69',
                    'paid_date': 'ชำระเมื่อ : 1 ม.ค. 69',
                    'image':
                        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=400',
                  },
                ];
                final item = mockData[index];
                return MoneyPropertyCard(
                  installment: item['installment'],
                  tenantName: item['tenant'],
                  title: item['title']!,
                  price: item['price']!,
                  dueDate: item['date']!,
                  imageUrl: item['image'],
                  isPaid: true,
                  paidDate: item['paid_date'],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaymentReceiptScreen(),
                      ),
                    );
                  },
                  onCall: () {
                    AppCallBottomSheet.show(
                      context: context,
                      options: [
                        CallOption(label: 'เจ้าของทรัพย์', phone: '0898765432'),
                        CallOption(label: 'ผู้เช่า', phone: '0812345678'),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
