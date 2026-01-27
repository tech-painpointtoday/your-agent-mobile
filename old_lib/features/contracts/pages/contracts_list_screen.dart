import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/features/auth/bloc/auth_bloc.dart';
import 'package:youragent/features/auth/bloc/auth_state.dart';
import 'package:youragent/features/contracts/bloc/contracts_bloc.dart';
import 'package:youragent/features/contracts/widgets/contracts_filter_section.dart';
import 'package:youragent/features/contracts/widgets/contracts_pagination.dart';
import 'package:youragent/features/contracts/widgets/contracts_summary_row.dart';
import 'package:youragent/features/contracts/widgets/contracts_table_content.dart';
import 'package:youragent/services/role_service.dart';
import 'package:youragent/widgets/app_sidebar.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/widgets/custom_header.dart';

/// Contracts List Screen - shows all contracts in a table format with filters
class ContractsListScreen extends StatefulWidget {
  final Function(Locale)? changeLocale;
  final UserRole? role;

  const ContractsListScreen({super.key, this.changeLocale, this.role});

  @override
  State<ContractsListScreen> createState() => _ContractsListScreenState();
}

class _ContractsListScreenState extends State<ContractsListScreen> {
  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.path;
    final authState = context.watch<AuthBloc>().state;
    final roleService = RoleService();
    final userRole =
        widget.role ??
        (authState is Authenticated ? authState.user.role : null) ??
        roleService.currentRole ??
        UserRole.agent;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final scaffoldKey = GlobalKey<ScaffoldState>();

        return Scaffold(
          key: scaffoldKey,
          backgroundColor: AppColors.basePaleGrey,
          drawer: isMobile
              ? Drawer(
                  child: AppSidebar(role: userRole, currentRoute: currentRoute),
                )
              : null,
          body: SafeArea(
            child: Column(
              children: [
                CustomHeader(
                  changeLocale: widget.changeLocale,
                  onMenuTap: isMobile
                      ? () => scaffoldKey.currentState?.openDrawer()
                      : null,
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sidebar (hidden on mobile, shown as drawer)
                      if (!isMobile)
                        AppSidebar(role: userRole, currentRoute: currentRoute),
                      // Main Content
                      Expanded(
                        child: BlocProvider(
                          create: (context) =>
                              ContractsBloc()
                                ..add(const ContractsLoadRequested()),
                          child: BlocBuilder<ContractsBloc, ContractsState>(
                            builder: (context, state) {
                              return SingleChildScrollView(
                                key: const PageStorageKey(
                                  'contracts_list_scroll',
                                ),
                                padding: EdgeInsets.all(isMobile ? 16 : 24),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Title
                                    Text(
                                      'เอกสารสัญญา',
                                      style: GoogleFonts.anuphan(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.baseDarkGrey,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    // Main Card - Contains Filter, Table, and Pagination
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFE9EAEB),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          // Filter Section
                                          const ContractsFilterSection(),
                                          const SizedBox(height: 24),
                                          Divider(
                                            color: AppColors.baseLightGrey,
                                            height: 1,
                                          ),
                                          const SizedBox(height: 24),
                                          // Summary Row with Create Button
                                          ContractsSummaryRow(
                                            state: state,
                                            role: userRole,
                                          ),
                                          const SizedBox(height: 16),
                                          // Table Content
                                          _buildTableContent(
                                            context,
                                            state,
                                            userRole,
                                          ),
                                          const SizedBox(height: 24),
                                          // Pagination
                                          state is ContractsLoaded
                                              ? ContractsPagination(
                                                  state: state,
                                                )
                                              : const ContractsPaginationPlaceholder(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableContent(
    BuildContext context,
    ContractsState state,
    UserRole userRole,
  ) {
    if (state is ContractsLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (state is ContractsError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            children: [
              Text(
                state.message,
                style: GoogleFonts.anuphan(color: AppColors.ruby500),
              ),
              const SizedBox(height: 16),
              AppButtons.primary(
                label: 'Retry',
                onPressed: () {
                  context.read<ContractsBloc>().add(
                    const ContractsLoadRequested(),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }
    if (state is ContractsLoaded) {
      return ContractsTableContent(
        contracts: state.paginatedContracts,
        role: userRole,
      );
    }
    return const SizedBox.shrink();
  }
}
