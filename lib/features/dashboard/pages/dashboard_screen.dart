import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/user.dart';

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
      ),
      body: Center(
        child: Text(
          'Dashboard for ${role.name}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
