import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/features/auth/bloc/auth_bloc.dart';
import 'package:youragent/features/auth/bloc/auth_state.dart';
import 'package:go_router/go_router.dart';

/// Header for login/register flow screens
/// Shows role dropdown during login/register, profile widget when logged in
class AuthHeader extends StatefulWidget {
  const AuthHeader({
    super.key,
    required this.changeLocale,
    this.currentRole,
    this.onRoleChanged,
  });

  final Function(Locale) changeLocale;
  final UserRole? currentRole;
  final Function(UserRole)? onRoleChanged;

  @override
  State<AuthHeader> createState() => _AuthHeaderState();
}

class _AuthHeaderState extends State<AuthHeader> {
  Locale? _currentLocale;

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
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool isInLoginFlow = widget.onRoleChanged != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompact = constraints.maxWidth < 600;
        final bool isSemiCompact =
            constraints.maxWidth >= 600 && constraints.maxWidth < 800;
        final bool isFullMode = constraints.maxWidth >= 800;

        final double horizontalPadding = isCompact ? 4.0 : 24.0;
        final double verticalPadding = isCompact ? 6.0 : 16.0;
        final double logoIconSize = isCompact ? 18 : 24;
        final double logoFontSize = isCompact ? 14 : 16;
        final double buttonFontSize = 14;
        final double buttonHorizontalPadding = isCompact ? 8 : 18;
        final double buttonVerticalPadding = isCompact ? 6 : 12;

        return Card(
          elevation: 8,
          margin: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo Section
                Flexible(
                  flex: isCompact ? 0 : 1,
                  child: InkWell(
                    onTap: () {
                      context.go('/login/agent');
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
                            'assets/icons/logo.svg',
                            width: logoIconSize,
                            height: logoIconSize,
                          ),
                          if (isFullMode || isSemiCompact) ...[
                            const SizedBox(width: 10),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/youragent.svg',
                                        height: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          l10n.app_title,
                                          style: GoogleFonts.anuphan(
                                            fontSize: logoFontSize,
                                            color: AppColors.eerieBlack,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
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
                SizedBox(width: isCompact ? 4 : 8),
                // Buttons Section
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Language Dropdown
                    PopScope(
                      canPop: false,
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
                            icon: SvgPicture.asset(
                              'assets/images/arrow-down-9.svg',
                              width: 10,
                            ),
                            dropdownColor: AppColors.white,
                            onChanged: (Locale? newLocale) {
                              if (newLocale != null &&
                                  newLocale.languageCode !=
                                      _currentLocale?.languageCode) {
                                setState(() {
                                  _currentLocale = newLocale;
                                });
                                // Call the change locale callback asynchronously to avoid navigation issues
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  widget.changeLocale(newLocale);
                                });
                              }
                            },
                            items: const [Locale('th'), Locale('en')]
                                .map<DropdownMenuItem<Locale>>((Locale locale) {
                                  final String shortCode =
                                      locale.languageCode == 'th'
                                      ? 'THA'
                                      : 'ENG';
                                  return DropdownMenuItem<Locale>(
                                    value: locale,
                                    child: Text(
                                      shortCode,
                                      style: GoogleFonts.anuphan(
                                        fontSize: buttonFontSize,
                                        color: AppColors.eerieBlack,
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                            selectedItemBuilder: (BuildContext context) {
                              return const [
                                Locale('th'),
                                Locale('en'),
                              ].map<Widget>((Locale locale) {
                                final String shortCode =
                                    locale.languageCode == 'th' ? 'THA' : 'ENG';
                                final currentLocale =
                                    _currentLocale ?? const Locale('th');
                                if (locale.languageCode ==
                                    currentLocale.languageCode) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/tha-4.svg',
                                        width: 16,
                                        height: 16,
                                      ),
                                      if (isFullMode || isSemiCompact) ...[
                                        const SizedBox(width: 4),
                                        Text(
                                          shortCode,
                                          style: GoogleFonts.anuphan(
                                            fontSize: buttonFontSize,
                                            color: AppColors.eerieBlack,
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
                    SizedBox(width: isCompact ? 4 : 8),

                    // Show role dropdown or profile widget
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        final isLoggedIn = authState is Authenticated;
                        final currentUser = isLoggedIn ? authState.user : null;

                        if (isLoggedIn) {
                          // LOGGED IN: Show profile widget
                          return Container(
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
                                Image.asset(
                                  'assets/icons/${currentUser?.role.name ?? 'agent'}_profile.png',
                                  width: 20,
                                  height: 20,
                                ),
                                if (isFullMode && currentUser != null) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    _getRoleName(currentUser.role, l10n),
                                    style: GoogleFonts.anuphan(
                                      fontSize: buttonFontSize,
                                      color: AppColors.eerieBlack,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        } else if (isInLoginFlow) {
                          // IN LOGIN FLOW: Show role dropdown
                          return Container(
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
                                icon: SvgPicture.asset(
                                  'assets/images/arrow-down-9.svg',
                                  width: 10,
                                ),
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
                                        color: AppColors.eerieBlack,
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
                                          color: AppColors.eerieBlack,
                                        ),
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                          );
                        } else {
                          // NOT IN LOGIN FLOW: Show register button
                          return InkWell(
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
                                  if (isFullMode) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      l10n.login,
                                      style: GoogleFonts.anuphan(
                                        fontSize: buttonFontSize,
                                        color: AppColors.eerieBlack,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
