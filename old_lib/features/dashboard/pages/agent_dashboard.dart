import 'package:flutter/material.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/features/auth/bloc/auth_bloc.dart';
import 'package:youragent/features/auth/bloc/auth_state.dart';
import 'package:youragent/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:youragent/features/dashboard/bloc/dashboard_event.dart';
import 'package:youragent/features/dashboard/bloc/dashboard_state.dart';
import 'package:youragent/widgets/custom_header.dart';
// import 'package:youragent/widgets/footer.dart';
import 'package:youragent/widgets/app_sidebar.dart';
import 'package:youragent/widgets/dashboard/stats_subsection.dart';
import 'package:youragent/widgets/dashboard/stats_wrapper_subsection.dart';
import 'package:youragent/widgets/dashboard/div_wrapper_subsection.dart';
import 'package:youragent/domain/entities/user.dart';

class AgentDashboard extends StatefulWidget {
  final Function(Locale) changeLocale;

  const AgentDashboard({super.key, required this.changeLocale});

  @override
  State<AgentDashboard> createState() => _AgentDashboardState();
}

class _AgentDashboardState extends State<AgentDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Dispatch event to load dashboard data
    context.read<DashboardBloc>().add(const DashboardLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.path;
    final authState = context.watch<AuthBloc>().state;
    final role = authState is Authenticated
        ? authState.user.role
        : UserRole.agent;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.basePaleGrey,
          drawer: isMobile
              ? Drawer(
                  child: AppSidebar(role: role, currentRoute: currentRoute),
                )
              : null,
          body: SafeArea(
            child: Column(
              children: [
                CustomHeader(
                  changeLocale: widget.changeLocale,
                  onMenuTap: isMobile
                      ? () => _scaffoldKey.currentState?.openDrawer()
                      : null,
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sidebar (hidden on mobile, shown as drawer)
                      if (!isMobile)
                        AppSidebar(role: role, currentRoute: currentRoute),
                      // Main Content
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Content
                              Padding(
                                padding: EdgeInsets.all(isMobile ? 16 : 40),
                                child: BlocBuilder<DashboardBloc, DashboardState>(
                                  builder: (context, state) {
                                    if (state is DashboardLoading) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }

                                    if (state is DashboardError) {
                                      return Center(
                                        child: Text(
                                          '${AppLocalizations.of(context)!.error_occurred}: ${state.message}',
                                          style: const TextStyle(
                                            color: AppColors.ruby500,
                                          ),
                                        ),
                                      );
                                    }

                                    final userName = state is DashboardLoaded
                                        ? state.userName
                                        : 'Admin Agent';
                                    final propertyCount =
                                        state is DashboardLoaded
                                        ? state.propertyCount
                                        : 0;
                                    final upcomingBookingCount =
                                        state is DashboardLoaded
                                        ? state.upcomingBookingCount
                                        : 0;

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Stats Subsection (Welcome + Stats Cards)
                                        StatsSubsection(
                                          userName: userName,
                                          isMobile: isMobile,
                                        ),
                                        SizedBox(height: isMobile ? 12 : 16),
                                        // Stats Wrapper Subsection (Property Breakdown + Appointments)
                                        StatsWrapperSubsection(
                                          propertyCount: propertyCount,
                                          monthlyAppointments:
                                              upcomingBookingCount,
                                          isMobile: isMobile,
                                          bookings: state is DashboardLoaded
                                              ? state.bookings
                                              : null,
                                          propertyById: state is DashboardLoaded
                                              ? state.propertyById
                                              : null,
                                        ),
                                        SizedBox(height: isMobile ? 12 : 16),
                                        // Div Wrapper Subsection (Tenant Cards)
                                        DivWrapperSubsection(
                                          isMobile: isMobile,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
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
