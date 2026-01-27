import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/image_url_helper.dart';
import '../../../widgets/app_search_bar.dart';
import '../../../widgets/backgrounds/blue_wave_background.dart';
import '../../../widgets/dialogs/status_dialog.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../../notifications/bloc/notification_bloc.dart';
import '../../notifications/bloc/notification_event.dart';
import '../../notifications/bloc/notification_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationBloc()..add(const LoadNotifications()),
      child: Scaffold(
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
      ),
    );
  }
}

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  UserProfileModel? _profileData;
  bool _isLoadingProfile = false;
  String? _fetchingUserId;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final authRepo = DependencyInjection.authRepository;
    final currentUser = authRepo.currentUser;
    final currentUserId = currentUser?.id;

    if (currentUser == null || currentUserId == null) return;
    if (_isLoadingProfile || _fetchingUserId == currentUserId) return;

    _fetchingUserId = currentUserId;
    setState(() {
      _isLoadingProfile = true;
    });

    try {
      final authApiService = DependencyInjection.authApiService;
      final userData = await authApiService.getCurrentUser();
      final profileData = UserProfileModel.fromJson(userData);

      if (mounted) {
        setState(() {
          _profileData = profileData;
          _isLoadingProfile = false;
          _fetchingUserId = null;
        });
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
          _fetchingUserId = null;
        });
      }
    }
  }

  Widget _buildGradientAvatar(String initial) {
    const blueTop = Color(0xFF3B82F6);
    const blueBottom = Color(0xFF1E40AF);

    return DecoratedBox(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [blueTop, blueBottom],
        ),
      ),
      child: Center(
        child: Text(
          initial.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = DependencyInjection.authRepository;
    final currentUser = authRepo.currentUser;

    // Get user name from profile data or fallback to currentUser
    final userName = _profileData?.name ?? currentUser?.displayName ?? '';
    final profilePhoto = _profileData?.profilePhoto;
    final profilePhotoUrl = ImageUrlHelper.getProfilePhotoUrl(profilePhoto);

    // Get initial for gradient avatar
    final initial = userName.trim().isNotEmpty
        ? userName.trim()[0].toUpperCase()
        : '?';

    return Row(
      children: [
        ClipOval(
          child: SizedBox(
            width: 40,
            height: 40,
            child: profilePhotoUrl != null
                ? CachedNetworkImage(
                    imageUrl: profilePhotoUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        _buildGradientAvatar(initial),
                    errorWidget: (context, url, error) =>
                        _buildGradientAvatar(initial),
                  )
                : _buildGradientAvatar(initial),
          ),
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
              Text(
                userName.isNotEmpty ? userName : 'เอเจนซี่ ดวงเด่น',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _HeaderActionIcon(
          svgPath: 'assets/images/bell-icon.svg',
          onTap: () => context.push('/notifications'),
          showBadge: true,
        ),
        const SizedBox(width: 10),
        _HeaderActionIcon(
          svgPath: 'assets/images/message-icon.svg',
          onTap: null,
        ),
        const SizedBox(width: 10),
        _LogoutButton(),
      ],
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _handleLogout(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(Icons.logout, size: 20, color: AppColors.white),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Store references before async operations to avoid context issues
    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      debugPrint('❌ Cannot get localizations, aborting logout');
      return;
    }

    // Get AuthBloc reference before async operations
    final authBloc = context.read<AuthBloc>();
    final router = GoRouter.of(context);

    // Use StatusDialog for consistent UI
    final confirmed = await StatusDialog.showDestructive(
      context: context,
      title: l10n.logout_title,
      message: l10n.logout_message,
      confirmText: l10n.logout_button,
      cancelText: l10n.cancel_button,
    );

    if (confirmed != true) {
      return; // User cancelled
    }

    // Get current role before logout (to determine login route)
    final role = DependencyInjection.authRepository.currentRole;
    final loginRoute = role != null ? '/login/${role.name}' : '/login/agent';

    // Dispatch logout event using stored reference
    authBloc.add(const SignOutEvent());

    // Wait for logout to complete by polling auth state
    // Check both AuthBloc state and authRepository.isAuthenticated
    bool logoutCompleted = false;
    int attempts = 0;
    const maxAttempts = 30; // 3 seconds max wait (30 * 100ms)

    while (!logoutCompleted && attempts < maxAttempts) {
      await Future.delayed(const Duration(milliseconds: 100));

      // Check AuthBloc state using stored reference
      final authState = authBloc.state;
      final isUnauthenticated =
          authState is Unauthenticated || authState is AuthError;

      // Also check authRepository directly
      final isLoggedOut = !DependencyInjection.authRepository.isAuthenticated;

      if (isUnauthenticated || isLoggedOut) {
        logoutCompleted = true;
        break;
      }

      attempts++;
    }

    // Navigate to login page using router reference
    // The router redirect should also handle this, but we navigate explicitly as well
    try {
      // Use router directly instead of context.go to avoid context issues
      router.go(loginRoute);
      debugPrint('✅ Logout completed, navigated to $loginRoute');
    } catch (e) {
      debugPrint('❌ Error navigating to login after logout: $e');
      // Try again after a short delay
      await Future.delayed(const Duration(milliseconds: 200));
      try {
        router.go(loginRoute);
        debugPrint('✅ Retry navigation successful');
      } catch (e2) {
        debugPrint('❌ Second attempt to navigate failed: $e2');
        // Last resort: use context if still mounted
        if (context.mounted) {
          try {
            context.go(loginRoute);
          } catch (e3) {
            debugPrint('❌ Final navigation attempt failed: $e3');
          }
        }
      }
    }
  }
}

class _HeaderActionIcon extends StatelessWidget {
  final String svgPath;
  final VoidCallback? onTap;
  final bool showBadge;

  const _HeaderActionIcon({
    required this.svgPath,
    required this.onTap,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SvgPicture.asset(
                svgPath,
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  AppColors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          if (showBadge)
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                final unreadCount = state is NotificationLoaded
                    ? state.unreadCount
                    : 0;

                if (unreadCount == 0) return const SizedBox.shrink();

                return Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.supportRedDeep,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Search bar for home screen with custom hint text
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppSearchBar(hintText: 'ค้นหาทรัพย์ของคุณ...');
  }
}

class HomeMenuItem {
  final String label;
  final String subtitle;
  final String imagePath;
  final String route;
  final Color accent;
  final bool enable;

  const HomeMenuItem({
    required this.label,
    required this.subtitle,
    required this.imagePath,
    required this.route,
    required this.accent,
    this.enable = true,
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
      enable: false,
    ),
    HomeMenuItem(
      label: 'Co-Agent',
      subtitle: 'ตัวแทนร่วม',
      imagePath: 'assets/images/home/co_agent.png',
      route: '/co-agent',
      accent: Color(0xFF6366F1),
      enable: false,
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
      enable: false,
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
      onTap: () => item.enable ? context.push(item.route) : null,
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
              opacity: AlwaysStoppedAnimation<double>(item.enable ? 1 : 0.2),
              errorBuilder: (context, error, stackTrace) => Container(
                width: 24,
                height: 24,
                color: AppColors.baseLightGrey,
                child: const Icon(
                  Icons.error_outline,
                  size: 16,
                  color: AppColors.baseGrey,
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
              color: AppColors.baseDarkGrey,
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
              color: AppColors.baseDarkGrey,
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
            color: AppColors.baseDarkGrey,
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
                      color: AppColors.basePaleGrey,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.basePaleGrey,
                      child: const Icon(
                        Icons.error_outline,
                        color: AppColors.baseGrey,
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
            color: i == index ? AppColors.primary : AppColors.baseLightGrey,
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
                      color: AppColors.baseDarkGrey,
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
                    color: AppColors.baseDarkGrey,
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
                    color: AppColors.baseDarkGrey,
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
                    color: AppColors.baseDarkGrey,
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
                            AppColors.baseDarkGrey,
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
                            AppColors.baseDarkGrey,
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
                          color: AppColors.baseDarkGrey,
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
              placeholder: (context, url) => Container(
                width: 76,
                height: 76,
                color: AppColors.basePaleGrey,
              ),
              errorWidget: (context, url, error) => Container(
                width: 76,
                height: 76,
                color: AppColors.basePaleGrey,
                child: const Icon(
                  Icons.error_outline,
                  color: AppColors.baseGrey,
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
