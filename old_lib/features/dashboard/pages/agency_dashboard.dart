import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/services/auth_service.dart' hide UserRole;
import 'package:youragent/widgets/custom_header.dart';
// import 'package:youragent/widgets/footer.dart';
import 'package:youragent/widgets/app_sidebar.dart';
import 'package:youragent/domain/entities/user.dart' show UserRole;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/features/auth/bloc/auth_bloc.dart';
import 'package:youragent/features/auth/bloc/auth_state.dart';

class AgencyDashboard extends StatelessWidget {
  final Function(Locale) changeLocale;

  const AgencyDashboard({super.key, required this.changeLocale});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.path;
    final authState = context.watch<AuthBloc>().state;
    final role = authState is Authenticated
        ? authState.user.role
        : UserRole.agency;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final scaffoldKey = GlobalKey<ScaffoldState>();

        return Scaffold(
          key: scaffoldKey,
          backgroundColor: AppColors.wildSand,
          drawer: isMobile
              ? Drawer(
                  child: AppSidebar(role: role, currentRoute: currentRoute),
                )
              : null,
          body: SafeArea(
            child: Column(
              children: [
                CustomHeader(
                  changeLocale: changeLocale,
                  onMenuTap: isMobile
                      ? () => scaffoldKey.currentState?.openDrawer()
                      : null,
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMobile)
                        AppSidebar(role: role, currentRoute: currentRoute),
                      // Main Content
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(isMobile ? 16 : 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Agency Dashboard', // TODO: Localize
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.anuphan(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Welcome, ${AuthService().currentRole?.name ?? "User"}',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.anuphan(
                                    fontSize: 16,
                                    color: AppColors.shadyLady,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    _DashboardButton(
                                      label: 'Properties',
                                      icon: Icons.home_work_outlined,
                                      onTap: () =>
                                          context.go('/agency/properties'),
                                    ),
                                    _DashboardButton(
                                      label: 'Bookings',
                                      icon: Icons.event_note_outlined,
                                      onTap: () =>
                                          context.go('/agency/bookings'),
                                    ),
                                    _DashboardButton(
                                      label: 'Profile',
                                      icon: Icons.person_outline,
                                      onTap: () =>
                                          context.go('/agency/profile'),
                                    ),
                                    _DashboardButton(
                                      label: 'Support',
                                      icon: Icons.support_agent,
                                      onTap: () => context.go('/support'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // const Footer(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.eerieBlack,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.bonJour, width: 0.5),
          ),
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.anuphan(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
