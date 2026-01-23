import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/domain/entities/user.dart';

/// Singleton service for accessing current user role and dashboard routes
class RoleService {
  static final RoleService _instance = RoleService._internal();
  factory RoleService() => _instance;
  RoleService._internal();

  /// Get current user role from auth repository
  UserRole? get currentRole => DependencyInjection.authRepository.currentRole;

  /// Get dashboard route for current role
  /// Returns null if not authenticated
  String? get dashboardRoute {
    final role = currentRole;
    if (role == null) return null;
    return '/home-screen';
  }

  /// Get dashboard route for a specific role
  static String getDashboardRoute(UserRole role) {
    return '/home-screen';
  }

  /// Get profile route for a specific role
  String? get profileRoute {
    final role = currentRole;
    if (role == null) return null;
    return '/${role.name}/profile';
  }

  static String getProfileRoute(UserRole role) {
    return '/${role.name}/profile';
  }

  /// Check if user is authenticated
  bool get isAuthenticated =>
      DependencyInjection.authRepository.isAuthenticated;
}
