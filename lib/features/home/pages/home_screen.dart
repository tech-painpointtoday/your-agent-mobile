import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../widgets/backgrounds/blue_wave_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bottomIndex = 0;

  BottomNavigationBarItem _buildBottomNavItem({
    required String iconPath,
    required String unselectedIconPath,
    required String label,
    required bool isSelected,
  }) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        unselectedIconPath,
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(
          AppColors.gray400,
          BlendMode.srcIn,
        ),
      ),
      activeIcon: SvgPicture.asset(
        iconPath,
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(
          AppColors.primary,
          BlendMode.srcIn,
        ),
      ),
      label: label,
    );
  }

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
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: const [
                      SizedBox(height: 12),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: HomeHeader(),
                      ),
                      SizedBox(height: 14),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: HomeSearchBar(),
                      ),
                      SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: MenuGridCard(),
                      ),
                      SizedBox(height: 18),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: RecommendedSection(),
                      ),
                      SizedBox(height: 18),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: ActivitiesSection(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomIndex,
        onTap: (i) => setState(() => _bottomIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.gray400,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          _buildBottomNavItem(
            iconPath: 'assets/icons/home-2-filled.svg',
            unselectedIconPath: 'assets/icons/home.svg',
            label: 'Home',
            isSelected: _bottomIndex == 0,
          ),
          _buildBottomNavItem(
            iconPath: 'assets/icons/building-filled.svg',
            unselectedIconPath: 'assets/icons/building.svg',
            label: 'Property',
            isSelected: _bottomIndex == 1,
          ),
          _buildBottomNavItem(
            iconPath: 'assets/icons/wallet-filled.svg',
            unselectedIconPath: 'assets/icons/wallet.svg',
            label: 'Money',
            isSelected: _bottomIndex == 2,
          ),
          _buildBottomNavItem(
            iconPath: 'assets/icons/calendar-filled.svg',
            unselectedIconPath: 'assets/icons/calendar.svg',
            label: 'Calendar',
            isSelected: _bottomIndex == 3,
          ),
          _buildBottomNavItem(
            iconPath: 'assets/icons/contact-book-filled.svg',
            unselectedIconPath: 'assets/icons/contact-book.svg',
            label: 'Contact',
            isSelected: _bottomIndex == 4,
          ),
        ],
      ),
    );
  }
}

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundImage: AssetImage('assets/icons/placeholder_profile.png'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ยินดีต้อนรับ',
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.90),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'เอเจนซี่ ดวงเด่น',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _HeaderActionIcon(icon: Icons.notifications_none_rounded, onTap: null),
        const SizedBox(width: 10),
        _HeaderActionIcon(icon: Icons.chat_bubble_outline_rounded, onTap: null),
      ],
    );
  }
}

class _HeaderActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _HeaderActionIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.white, size: 20),
      ),
    );
  }
}

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: const [
          Icon(Icons.search_rounded, color: AppColors.gray500),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'ค้นหาทรัพย์ของคุณ...',
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeMenuItem {
  final String label;
  final String subtitle;
  final String imagePath;
  final String route;
  final Color accent;

  const HomeMenuItem({
    required this.label,
    required this.subtitle,
    required this.imagePath,
    required this.route,
    required this.accent,
  });
}

class MenuGridCard extends StatelessWidget {
  const MenuGridCard({super.key});

  static const List<HomeMenuItem> _items = [
    HomeMenuItem(
      label: 'Property',
      subtitle: 'อสังหาริมทรัพย์',
      imagePath: 'assets/images/home/property.png',
      route: '/property',
      accent: Color(0xFF2563EB),
    ),
    HomeMenuItem(
      label: 'Money',
      subtitle: 'การเงิน',
      imagePath: 'assets/images/home/money.png',
      route: '/money',
      accent: Color(0xFF10B981),
    ),
    HomeMenuItem(
      label: 'Calendar',
      subtitle: 'ตารางเวลา',
      imagePath: 'assets/images/home/calendar.png',
      route: '/calendar',
      accent: Color(0xFFF59E0B),
    ),
    HomeMenuItem(
      label: 'Contact',
      subtitle: 'รายชื่อผู้ติดต่อ',
      imagePath: 'assets/images/home/contact.png',
      route: '/contact',
      accent: Color(0xFF22C55E),
    ),
    HomeMenuItem(
      label: 'Dashboard',
      subtitle: 'แดชบอร์ด',
      imagePath: 'assets/images/home/dashboard.png',
      route: '/dashboard',
      accent: Color(0xFFF97316),
    ),
    HomeMenuItem(
      label: 'Co-Agent',
      subtitle: 'ตัวแทนร่วม',
      imagePath: 'assets/images/home/co_agent.png',
      route: '/co-agent',
      accent: Color(0xFF6366F1),
    ),
    HomeMenuItem(
      label: 'Contract',
      subtitle: 'เอกสารสัญญา',
      imagePath: 'assets/images/home/contract.png',
      route: '/contract',
      accent: Color(0xFF0EA5E9),
    ),
    HomeMenuItem(
      label: 'Bureau',
      subtitle: 'ข้อมูลลูกค้า',
      imagePath: 'assets/images/home/bureau.png',
      route: '/bureau',
      accent: Color(0xFF06B6D4),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 8,
          childAspectRatio: 0.80,
        ),
        itemCount: _items.length,
        itemBuilder: (context, index) => _MenuGridItem(item: _items[index]),
      ),
    );
  }
}

class _MenuGridItem extends StatelessWidget {
  final HomeMenuItem item;
  const _MenuGridItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(item.route),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              item.imagePath,
              width: 40,
              height: 40,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 24,
                height: 24,
                color: AppColors.gray200,
                child: const Icon(
                  Icons.error_outline,
                  size: 16,
                  color: AppColors.gray400,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),
          Text(
            item.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.subtitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }
}

class RecommendedSection extends StatefulWidget {
  const RecommendedSection({super.key});

  @override
  State<RecommendedSection> createState() => _RecommendedSectionState();
}

class _RecommendedSectionState extends State<RecommendedSection> {
  int _index = 0;
  final PageController _controller = PageController();

  // Placeholder images from Unsplash for property/buildings
  static const List<String> _images = [
    'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&h=600&fit=crop',
    'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&h=600&fit=crop',
    'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&h=600&fit=crop',
    'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800&h=600&fit=crop',
    'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=800&h=600&fit=crop',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'แนะนำสำหรับคุณ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'คัดสรรสิ่งที่ดีที่สุดมาเพื่อคุณโดยเฉพาะ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.gray500,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _index = i),
            itemCount: _images.length,
            itemBuilder: (context, i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: _images[i],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.gray100,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.gray100,
                      child: const Icon(
                        Icons.error_outline,
                        color: AppColors.gray400,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        _DotsIndicator(count: _images.length, index: _index),
      ],
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int index;

  const _DotsIndicator({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: i == index ? 8 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: i == index ? AppColors.primary : AppColors.gray300,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}

class ActivitiesSection extends StatelessWidget {
  const ActivitiesSection({super.key});

  static const List<ActivityItem> _activities = [
    ActivityItem(
      title: 'ตัวอย่างประชาสัมพันธ์',
      description:
          'Figma Ipsum Component Variant Main Layer. Edit Effect Pencil Draft Pixel Underline. Scale Figma Draft Rotate Invite Figma Italic Compo...',
      imageUrl:
          'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=200&h=200&fit=crop',
      type: ActivityType.publicRelations,
    ),
    ActivityItem(
      title: 'ตัวอย่างข่าวสาร',
      description:
          'Figma Ipsum Component Variant Main Layer. Edit Effect Pencil Draft Pixel Underline. Scale...',
      imageUrl:
          'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=200&h=200&fit=crop',
      type: ActivityType.news,
      metadata: 'ก้องเกียร การธุรกิจเลิศ • 12 นาที',
    ),
    ActivityItem(
      title: 'ตัวอย่างกิจกรรม',
      description:
          'Figma Ipsum Component Variant Main Layer. Edit Effect Pencil Draft Pixel Underline. Scale...',
      imageUrl:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=200&h=200&fit=crop',
      type: ActivityType.activity,
      metadata: '24 ธ.ค. 2568, 12:00 น.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'กิจกรรม',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'รวมกิจกรรม ข่าวสาร และประชาสัมพันธ์ที่น่าสนใจ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => context.push('/activities'),
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  'ดูทั้งหมด',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray500,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ..._activities.map(
          (activity) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ActivityCard(activity: activity),
          ),
        ),
      ],
    );
  }
}

enum ActivityType { publicRelations, news, activity }

class ActivityItem {
  final String title;
  final String description;
  final String imageUrl;
  final ActivityType type;
  final String? metadata;

  const ActivityItem({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.type,
    this.metadata,
  });
}

class _ActivityCard extends StatelessWidget {
  final ActivityItem activity;
  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gray700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray500,
                    height: 1.35,
                  ),
                ),
                if (activity.metadata != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (activity.type == ActivityType.activity)
                        SvgPicture.asset(
                          'assets/icons/calendar.svg',
                          width: 10,
                          height: 10,
                          colorFilter: const ColorFilter.mode(
                            AppColors.gray500,
                            BlendMode.srcIn,
                          ),
                        ),
                      if (activity.type == ActivityType.activity)
                        const SizedBox(width: 4),
                      if (activity.type == ActivityType.news)
                        SvgPicture.asset(
                          'assets/icons/clock.svg',
                          width: 10,
                          height: 10,
                          colorFilter: const ColorFilter.mode(
                            AppColors.gray500,
                            BlendMode.srcIn,
                          ),
                        ),
                      if (activity.type == ActivityType.news)
                        const SizedBox(width: 4),
                      Text(
                        activity.metadata!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: activity.imageUrl,
              width: 76,
              height: 76,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(width: 76, height: 76, color: AppColors.gray100),
              errorWidget: (context, url, error) => Container(
                width: 76,
                height: 76,
                color: AppColors.gray100,
                child: const Icon(
                  Icons.error_outline,
                  color: AppColors.gray400,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
