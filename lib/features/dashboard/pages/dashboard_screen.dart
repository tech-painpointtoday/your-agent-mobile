import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/user.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';

class DashboardScreen extends StatelessWidget {
  final UserRole role;
  const DashboardScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text('Dashboard (${role.name})'),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.eerieBlack,
        actions: [
          TextButton(
            onPressed: () => context.read<AuthBloc>().add(const SignOutEvent()),
            child: const Text('ออกจากระบบ'),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Logged in as ${role.name}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

