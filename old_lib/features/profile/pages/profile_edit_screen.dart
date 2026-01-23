import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/widgets/app_sidebar.dart';
import 'package:youragent/widgets/custom_header.dart';
import 'package:youragent/features/profile/bloc/profile_bloc.dart';
import 'package:youragent/features/profile/widgets/profile_edit_form.dart';

/// Profile Edit Screen - edit user profile
class ProfileEditScreen extends StatelessWidget {
  final Function(Locale) changeLocale;

  const ProfileEditScreen({super.key, required this.changeLocale});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(const ProfileLoadRequested()),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;
          final scaffoldKey = GlobalKey<ScaffoldState>();
          final userRole =
              DependencyInjection.authRepository.currentRole ?? UserRole.agent;

          return Scaffold(
            key: scaffoldKey,
            backgroundColor: AppColors.gray100,
            drawer: isMobile
                ? Drawer(
                    child: AppSidebar(
                      role: userRole,
                      currentRoute: '/profile/edit',
                    ),
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
                        // Sidebar
                        if (!isMobile)
                          AppSidebar(
                            role: userRole,
                            currentRoute: '/profile/edit',
                          ),
                        // Main Content
                        Expanded(
                          child: const ProfileEditForm(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
