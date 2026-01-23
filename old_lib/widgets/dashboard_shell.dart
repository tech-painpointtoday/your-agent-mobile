import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/features/auth/bloc/auth_bloc.dart';
import 'package:youragent/features/auth/bloc/auth_state.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/widgets/custom_header.dart';
// import 'package:youragent/widgets/footer.dart';
import 'package:youragent/widgets/dashboard_sidebar.dart';

/// Common layout for authenticated agent/agency screens
/// Places the sidebar under the app bar and wraps the main content.
class AppLayout extends StatelessWidget {
  final Function(Locale) changeLocale;
  final Widget child;

  const AppLayout({super.key, required this.changeLocale, required this.child});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.path;
    final authState = context.watch<AuthBloc>().state;
    final role = authState is Authenticated
        ? authState.user.role
        : UserRole.agent;

    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(changeLocale: changeLocale),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSidebar(role: role, currentRoute: currentRoute),
                  Expanded(child: child),
                ],
              ),
            ),
            // const Footer(),
          ],
        ),
      ),
    );
  }
}
