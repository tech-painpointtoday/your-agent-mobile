import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:youragent/services/role_service.dart';

/// Mixin to handle app landing logic - checks authentication status on screen load
/// If user is already authenticated, redirects to appropriate dashboard
/// Use this mixin in any screen that needs to check auth status on load
mixin AuthLandingMixin<T extends StatefulWidget> on State<T> {
  /// Check authentication status and redirect if already logged in
  /// Call this in initState() using WidgetsBinding.instance.addPostFrameCallback
  void checkAuthStatusOnLanding() {
    final roleService = RoleService();
    if (roleService.isAuthenticated && mounted) {
      // User is already logged in, redirect to appropriate dashboard
      final dashboardRoute = roleService.dashboardRoute;
      if (dashboardRoute != null) {
        context.go(dashboardRoute);
      }
    }
    // If not logged in, stay on current screen
  }
}
