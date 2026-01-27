import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/features/auth/bloc/auth_bloc.dart';
import 'package:youragent/features/auth/bloc/auth_state.dart';
import 'package:youragent/features/auth/bloc/auth_event.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/services/role_service.dart';
import 'package:youragent/utils/image_url_helper.dart';
import 'package:youragent/data/models/user_profile_model.dart';
import 'package:youragent/services/user_profile_storage_service.dart';
import 'package:youragent/widgets/notifications/notification_popup.dart'
    show showNotificationPopup;
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:go_router/go_router.dart';

// --------------------------------------------------------------------------
// CUSTOM HEADER WIDGET
// --------------------------------------------------------------------------

class CustomHeader extends StatefulWidget {
  const CustomHeader({
    super.key,
    this.changeLocale,
    this.currentRole,
    this.onRoleChanged,
    this.transparentBackground = false,
    this.onMenuTap,
  });

  final Function(Locale)? changeLocale;
  final UserRole? currentRole;
  final Function(UserRole)? onRoleChanged;
  final bool transparentBackground;
  final VoidCallback? onMenuTap;

  @override
  State<CustomHeader> createState() => _CustomHeaderState();
}

class _CustomHeaderState extends State<CustomHeader> {
  // Use Locale for state management instead of bool
  // Will be initialized from context in didChangeDependencies
  Locale? _currentLocale;

  // Profile data cache
  UserProfileModel? _profileData;
  bool _isLoadingProfile = false;
  String?
  _fetchingUserId; // Track which user we're fetching for to prevent duplicate calls

  // Unread notification count
  int _unreadNotificationCount = 0;

  // GlobalKey for notification button to position popup
  final GlobalKey _notificationButtonKey = GlobalKey();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync with current app locale - normalize to language code only
    final locale = Localizations.localeOf(context);
    final normalizedLocale = Locale(locale.languageCode);
    if (_currentLocale?.languageCode != normalizedLocale.languageCode) {
      setState(() {
        _currentLocale = normalizedLocale;
      });
    }
  }

  Future<void> _loadUnreadNotifications() async {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        final role = authState.user.role;
        final roleString = role == UserRole.agent ? 'agent' : 'agency';
        final unreadBookings = await DependencyInjection.chatApiService
            .getUnreadBookings(role: roleString);
        if (mounted) {
          setState(() {
            _unreadNotificationCount = unreadBookings.length;
          });
        }
      }
    } catch (e) {
      // Silently fail - notifications are optional
      if (mounted) {
        debugPrint('Failed to load unread notifications: $e');
      }
    }
  }

  String _getRoleName(UserRole role, AppLocalizations l10n) {
    switch (role) {
      case UserRole.agent:
        return l10n.role_agent;
      case UserRole.agency:
        return l10n.role_agency;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the localization instance (used for L10n texts if needed)
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool isInLoginFlow = widget.onRoleChanged != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Advanced responsive breakpoints
        // Full mode: >800px (show all text)
        // Semi-compact: 600-800px (show some text)
        // Compact: <600px (icon only)
        final bool isCompact = constraints.maxWidth < 768;
        final bool isSemiCompact =
            constraints.maxWidth >= 768 && constraints.maxWidth < 1024;
        final bool isFullMode = constraints.maxWidth >= 1024;

        // Responsive values
        final double horizontalPadding = isCompact ? 4.0 : 24.0;
        final double verticalPadding = isCompact ? 6.0 : 16.0;
        final double logoIconSize = isCompact ? 18 : 24;
        final double logoFontSize = isCompact ? 14 : 16;
        final double buttonFontSize = isCompact
            ? 14
            : 14; // Reduced font size for dropdowns
        // Consistent padding for all buttons to ensure same height
        final double buttonHorizontalPadding = 8;
        final double buttonVerticalPadding = isCompact ? 6 : 12;
        // Fixed height for all buttons to ensure consistency
        final double buttonHeight = 48.0;

        return Card(
          elevation: widget.transparentBackground ? 0 : 4,
          margin: EdgeInsets.zero,
          color: widget.transparentBackground ? Colors.transparent : null,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            decoration: BoxDecoration(
              color: widget.transparentBackground
                  ? Colors.transparent
                  : AppColors.white,
              border: widget.transparentBackground
                  ? null
                  : const Border(
                      bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
                    ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left side: Menu button (mobile only) + Logo
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Menu button (mobile only)
                    if (widget.onMenuTap != null) ...[
                      SizedBox(
                        height: buttonHeight,
                        child: IconButton(
                          onPressed: widget.onMenuTap,
                          icon: const Icon(Icons.menu),
                          padding: EdgeInsets.symmetric(
                            horizontal: buttonHorizontalPadding,
                            vertical: buttonVerticalPadding,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: isCompact ? 4 : 8),
                    ],
                    // Logo Section - show only icon in mobile, full logo in desktop
                    InkWell(
                      onTap: () {
                        final roleService = RoleService();
                        final dashboardRoute = roleService.dashboardRoute;
                        if (dashboardRoute != null) {
                          context.go(dashboardRoute);
                        }
                      },
                      child: SizedBox(
                        height: buttonHeight,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: buttonHorizontalPadding,
                            vertical: buttonVerticalPadding,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: isCompact
                              ? SvgPicture.asset(
                                  'assets/icons/logo.svg',
                                  width: logoIconSize,
                                  height: logoIconSize,
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/logo.svg',
                                      width: logoIconSize,
                                      height: logoIconSize,
                                    ),
                                    // Show logo text only in full or semi-compact mode
                                    if (isFullMode || isSemiCompact) ...[
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: SvgPicture.asset(
                                                'assets/icons/youragent.svg',
                                                height: 16,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              flex: 2,
                                              child: Text(
                                                l10n.app_title,
                                                style: GoogleFonts.anuphan(
                                                  fontSize: logoFontSize,
                                                  color: AppColors.baseDarkGrey,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: isCompact ? 4 : 8),
                // Buttons Section
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    final isLoggedIn = authState is Authenticated;
                    final currentUser = isLoggedIn ? authState.user : null;

                    // Clear profile cache if user changed or logged out
                    if (currentUser?.id != _profileData?.id.toString() ||
                        !isLoggedIn) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _profileData = null;
                            _isLoadingProfile = false;
                            _fetchingUserId = null; // Reset user ID tracking
                          });
                        }
                      });
                    }

                    if (isLoggedIn) {
                      // LOGGED IN: Show Profile -> Language -> Notification -> Logout
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Profile
                          _buildProfileButton(
                            context,
                            currentUser,
                            isFullMode,
                            buttonHorizontalPadding,
                            buttonVerticalPadding,
                            buttonFontSize,
                            buttonHeight,
                            l10n,
                          ),
                          SizedBox(width: 4),
                          // Language
                          _buildLanguageDropdown(
                            buttonHeight,
                            buttonHorizontalPadding,
                            buttonVerticalPadding,
                            buttonFontSize,
                            isFullMode,
                            isSemiCompact,
                          ),
                          SizedBox(width: 4),
                          // Notification
                          _buildNotificationButton(
                            buttonHeight,
                            buttonHorizontalPadding,
                            buttonVerticalPadding,
                          ),
                          SizedBox(width: 4),
                          // Logout
                          _buildLogoutButton(
                            context,
                            buttonHeight,
                            buttonHorizontalPadding,
                            buttonVerticalPadding,
                          ),
                        ],
                      );
                    } else if (isInLoginFlow) {
                      // IN LOGIN FLOW: Show role dropdown and language
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Language
                          _buildLanguageDropdown(
                            buttonHeight,
                            buttonHorizontalPadding,
                            buttonVerticalPadding,
                            buttonFontSize,
                            isFullMode,
                            isSemiCompact,
                          ),
                          SizedBox(width: 4),
                          // Role dropdown
                          SizedBox(
                            height: buttonHeight,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: buttonHorizontalPadding,
                                vertical: buttonVerticalPadding,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(35),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<UserRole>(
                                  value: widget.currentRole,
                                  isDense: true,
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  dropdownColor: AppColors.white,
                                  onChanged: (UserRole? newRole) {
                                    if (newRole != null) {
                                      widget.onRoleChanged!(newRole);
                                    }
                                  },
                                  items: UserRole.values.map((role) {
                                    return DropdownMenuItem<UserRole>(
                                      value: role,
                                      child: Text(
                                        _getRoleName(role, l10n),
                                        style: GoogleFonts.anuphan(
                                          fontSize: buttonFontSize,
                                          color: AppColors.baseDarkGrey,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  selectedItemBuilder: (context) {
                                    return UserRole.values.map((role) {
                                      return Center(
                                        child: Text(
                                          _getRoleName(role, l10n),
                                          style: GoogleFonts.anuphan(
                                            fontSize: buttonFontSize,
                                            color: AppColors.baseDarkGrey,
                                          ),
                                        ),
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      // NOT LOGGED IN & NOT IN LOGIN FLOW: Show language and login button
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Language
                          _buildLanguageDropdown(
                            buttonHeight,
                            buttonHorizontalPadding,
                            buttonVerticalPadding,
                            buttonFontSize,
                            isFullMode,
                            isSemiCompact,
                          ),
                          SizedBox(width: 4),
                          // Login button
                          SizedBox(
                            height: buttonHeight,
                            child: InkWell(
                              onTap: () {
                                context.push('/login/agent');
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: buttonHorizontalPadding,
                                  vertical: buttonVerticalPadding,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(35),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/lock-3.svg',
                                      width: 18,
                                      height: 18,
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.primary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    // Show register text only in full mode
                                    if (isFullMode) ...[
                                      const SizedBox(width: 4),
                                      Text(
                                        l10n.login,
                                        style: GoogleFonts.anuphan(
                                          fontSize: buttonFontSize,
                                          color: AppColors.baseDarkGrey,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build language dropdown
  Widget _buildLanguageDropdown(
    double buttonHeight,
    double buttonHorizontalPadding,
    double buttonVerticalPadding,
    double buttonFontSize,
    bool isFullMode,
    bool isSemiCompact,
  ) {
    return PopScope(
      canPop: false,
      child: SizedBox(
        height: buttonHeight,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: buttonHorizontalPadding,
            vertical: buttonVerticalPadding,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(35),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Locale>(
              value: _currentLocale ?? const Locale('th'),
              isDense: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              dropdownColor: AppColors.white,
              onChanged: (Locale? newLocale) {
                if (newLocale != null &&
                    newLocale.languageCode != _currentLocale?.languageCode) {
                  // Update local state
                  setState(() {
                    _currentLocale = newLocale;
                  });
                  // Call the change locale callback asynchronously to avoid navigation issues
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    widget.changeLocale?.call(newLocale);
                  });
                }
              },
              items: const [Locale('th'), Locale('en')]
                  .map<DropdownMenuItem<Locale>>((Locale locale) {
                    final String shortCode = locale.languageCode == 'th'
                        ? 'THA'
                        : 'ENG';
                    return DropdownMenuItem<Locale>(
                      value: locale,
                      child: Text(
                        shortCode,
                        style: GoogleFonts.anuphan(
                          fontSize: buttonFontSize,
                          color: AppColors.baseDarkGrey,
                        ),
                      ),
                    );
                  })
                  .toList(),
              selectedItemBuilder: (BuildContext context) {
                return const [Locale('th'), Locale('en')].map<Widget>((
                  Locale locale,
                ) {
                  final String shortCode = locale.languageCode == 'th'
                      ? 'THA'
                      : 'ENG';
                  final currentLocale = _currentLocale ?? const Locale('th');
                  if (locale.languageCode == currentLocale.languageCode) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/images/tha-4.svg',
                          width: 16,
                          height: 16,
                        ),
                        // Show language text only in full or semi-compact mode
                        if (isFullMode || isSemiCompact) ...[
                          const SizedBox(width: 4),
                          Text(
                            shortCode,
                            style: GoogleFonts.anuphan(
                              fontSize: buttonFontSize,
                              color: AppColors.baseDarkGrey,
                            ),
                          ),
                        ],
                      ],
                    );
                  }
                  return Container();
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Build profile button (without dropdown menu)
  /// Shows avatar widget style with user name (like ProfileAvatar)
  Widget _buildProfileButton(
    BuildContext context,
    User? currentUser,
    bool isFullMode,
    double buttonHorizontalPadding,
    double buttonVerticalPadding,
    double buttonFontSize,
    double buttonHeight,
    AppLocalizations l10n,
  ) {
    // Load profile from SharedPreferences first, then fetch from API if needed
    final currentUserId = currentUser?.id;
    if (currentUser != null &&
        currentUserId != null &&
        _profileData == null &&
        !_isLoadingProfile &&
        _fetchingUserId != currentUserId) {
      _fetchingUserId = currentUserId;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted &&
            _profileData == null &&
            !_isLoadingProfile &&
            _fetchingUserId == currentUserId) {
          // Try to load from SharedPreferences first (for fast display)
          final cachedProfile = await UserProfileStorageService().getProfile();
          if (cachedProfile != null && mounted) {
            setState(() {
              _profileData = cachedProfile;
            });
          }
          // Then fetch from API to update (always fetch for latest data)
          _fetchProfile(currentUser);
        } else {
          if (_fetchingUserId == currentUserId) {
            _fetchingUserId = null;
          }
        }
      });
    }

    // Get user name from profile data or fallback to currentUser
    final userName = _profileData?.name ?? currentUser?.displayName ?? '';
    final profilePhoto = _profileData?.profilePhoto;
    final profilePhotoUrl = ImageUrlHelper.getProfilePhotoUrl(profilePhoto);

    // Get initial for gradient avatar (like ProfileAvatar)
    final initial = userName.trim().isNotEmpty
        ? userName.trim()[0].toUpperCase()
        : '?';

    // Blue gradient colors for avatar (matching ProfileAvatar)
    const blueTop = Color(0xFF3B82F6);
    const blueBottom = Color(0xFF1E40AF);

    return SizedBox(
      height: buttonHeight,
      child: InkWell(
        onTap: () {
          // Route to role-specific profile
          final roleService = RoleService();
          final profileRoute = roleService.profileRoute;
          if (profileRoute != null) {
            context.go(profileRoute);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: buttonHorizontalPadding,
            vertical: buttonVerticalPadding,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(35),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile avatar (like ProfileAvatar widget)
              ClipOval(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: profilePhotoUrl != null
                      ? CachedNetworkImage(
                          imageUrl: profilePhotoUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => _buildGradientAvatar(
                            initial,
                            blueTop,
                            blueBottom,
                          ),
                          errorWidget: (context, url, error) =>
                              _buildGradientAvatar(
                                initial,
                                blueTop,
                                blueBottom,
                              ),
                        )
                      : _buildGradientAvatar(initial, blueTop, blueBottom),
                ),
              ),
              // Show user name text only in full mode
              if (isFullMode && userName.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  userName,
                  style: GoogleFonts.anuphan(
                    fontSize: buttonFontSize,
                    color: AppColors.baseDarkGrey,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build gradient avatar (matching ProfileAvatar style)
  Widget _buildGradientAvatar(
    String initial,
    Color topColor,
    Color bottomColor,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [topColor, bottomColor],
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  /// Build notification button with bell icon
  Widget _buildNotificationButton(
    double buttonHeight,
    double buttonHorizontalPadding,
    double buttonVerticalPadding,
  ) {
    return SizedBox(
      key: _notificationButtonKey,
      height: buttonHeight,
      child: InkWell(
        onTap: () {
          // Show notification popup positioned below the button
          showNotificationPopup(context, _notificationButtonKey).then((_) {
            // Refresh notification count after popup is closed
            _loadUnreadNotifications();
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: buttonHorizontalPadding,
            vertical: buttonVerticalPadding,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(35),
          ),
          alignment: Alignment.center,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SvgPicture.asset(
                'assets/images/bell-icon.svg',
                width: 20,
                height: 20,
              ),
              // Red badge indicator - only show if there are unread notifications
              if (_unreadNotificationCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.alizarinCrimson,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Center(
                      child: Text(
                        _unreadNotificationCount > 99
                            ? '99+'
                            : '$_unreadNotificationCount',
                        style: GoogleFonts.anuphan(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              else
                // Small red dot if count is 0 but we want to show something (optional)
                // Remove this else block if you only want to show badge when count > 0
                const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build logout button
  Widget _buildLogoutButton(
    BuildContext context,
    double buttonHeight,
    double buttonHorizontalPadding,
    double buttonVerticalPadding,
  ) {
    return SizedBox(
      height: buttonHeight,
      child: InkWell(
        onTap: () => _handleLogout(context),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: buttonHorizontalPadding,
            vertical: buttonVerticalPadding,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(35),
          ),
          child: Icon(Icons.logout, size: 20, color: AppColors.baseDarkGrey),
        ),
      ),
    );
  }

  /// Handle logout action
  void _handleLogout(BuildContext context) async {
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

  /// Fetch profile data using getCurrentUser endpoint
  Future<void> _fetchProfile(User user) async {
    if (_isLoadingProfile) return;

    setState(() {
      _isLoadingProfile = true;
    });

    try {
      // Use getCurrentUser endpoint (GET /user)
      final authApiService = DependencyInjection.authApiService;
      final userData = await authApiService.getCurrentUser();
      final profileData = UserProfileModel.fromJson(userData);

      // Save to SharedPreferences
      await UserProfileStorageService().saveProfile(profileData);

      if (mounted) {
        setState(() {
          _profileData = profileData;
          _isLoadingProfile = false;
          _fetchingUserId =
              null; // Reset user ID tracking after fetch completes
        });
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
          _fetchingUserId = null; // Reset user ID tracking on error
        });
      }
    }
  }
}
