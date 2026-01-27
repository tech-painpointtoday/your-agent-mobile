import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/di/dependency_injection.dart';
import '../domain/entities/user.dart';
import '../features/activities/pages/all_activities_screen.dart';
import '../features/auth/pages/email_verification_pending_screen.dart';
import '../features/auth/pages/forgot_password_screen.dart';
import '../features/auth/pages/login_screen.dart';
import '../features/auth/pages/register_screen.dart';
import '../features/auth/pages/reset_password_screen.dart';
import '../features/bureau/pages/bureau_screen.dart';
import '../features/co_agent/pages/co_agent_screen.dart';
import '../features/contract/pages/contract_screen.dart';
import '../features/dashboard/pages/dashboard_home_screen.dart';
import '../features/dashboard/pages/dashboard_screen.dart';
import '../features/notifications/bloc/notification_bloc.dart';
import '../features/notifications/bloc/notification_event.dart';
import '../features/notifications/pages/notification_detail_screen.dart';
import '../features/notifications/pages/notifications_screen.dart';
import '../features/property/pages/property_detail_screen.dart';
import '../features/property/pages/property_screen.dart';
import '../features/public/pages/policy_screen.dart';
import '../features/splash/splash_screen.dart';
import '../widgets/main_navigation_screen.dart';

class AppRouter {
  final Function(Locale) changeLocale;
  AppRouter({required this.changeLocale});

  late final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/splash',
    refreshListenable: DependencyInjection.authRepository as ChangeNotifier,
    redirect: (context, state) {
      final authRepo = DependencyInjection.authRepository;
      final isLoggedIn = authRepo.isAuthenticated;
      final currentPath = state.uri.path;
      final isLoginRoute = currentPath.startsWith('/login');
      final isRegisterRoute = currentPath.startsWith('/register');

      // allow public routes (accessible regardless of auth status)
      if (currentPath.startsWith('/splash') ||
          currentPath.startsWith('/policy') ||
          currentPath.startsWith('/forgot-password') ||
          currentPath.startsWith('/reset-password') ||
          currentPath.startsWith('/email-verification-pending')) {
        return null;
      }

      // Protected routes that require authentication
      final protectedRoutes = [
        '/',
        '/home-screen',
        '/property',
        '/money',
        '/calendar',
        '/contact',
        '/dashboard',
        '/co-agent',
        '/contract',
        '/bureau',
        '/activities',
        '/notifications',
      ];

      final isProtectedRoute = protectedRoutes.any(
        (route) => currentPath.startsWith(route),
      );

      if (isLoggedIn) {
        // If logged in, redirect away from auth routes
        if (isLoginRoute || isRegisterRoute) {
          return '/'; // Redirect to main navigation
        }
        return null;
      }

      // not logged in -> allow auth routes, block protected routes
      if (isLoginRoute || isRegisterRoute) {
        return null; // Allow access to login/register when not logged in
      }

      if (isProtectedRoute) {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(changeLocale: changeLocale),
      ),
      // Main navigation with PageView
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const MainNavigationScreen(initialIndex: 0),
      ),
      GoRoute(
        path: '/property',
        builder: (context, state) =>
            const MainNavigationScreen(initialIndex: 1),
      ),
      GoRoute(
        path: '/property/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PropertyDetailScreen(propertyId: id);
        },
      ),
      GoRoute(
        path: '/money',
        builder: (context, state) =>
            const MainNavigationScreen(initialIndex: 2),
      ),
      GoRoute(
        path: '/calendar',
        builder: (context, state) =>
            const MainNavigationScreen(initialIndex: 3),
      ),
      GoRoute(
        path: '/contact',
        builder: (context, state) =>
            const MainNavigationScreen(initialIndex: 4),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/notifications/:id',
        builder: (context, state) {
          final notificationId = state.pathParameters['id']!;
          return BlocProvider(
            create: (context) =>
                NotificationBloc()..add(const LoadNotifications()),
            child: NotificationDetailScreen(notificationId: notificationId),
          );
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => RegisterScreen(changeLocale: changeLocale),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/policy',
        builder: (context, state) {
          final typeParam = state.uri.queryParameters['type'];
          PolicyType? type;
          switch (typeParam) {
            case 'terms':
              type = PolicyType.terms;
              break;
            case 'privacy':
              type = PolicyType.privacy;
              break;
            case 'disclaimer':
              type = PolicyType.disclaimer;
              break;
          }
          return PolicyScreen(
            changeLocale: changeLocale,
            initialPolicyType: type,
          );
        },
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          final email = state.uri.queryParameters['email'] ?? '';
          if (token.isEmpty || email.isEmpty) {
            return LoginScreen(changeLocale: changeLocale);
          }
          return ResetPasswordScreen(token: token, email: email);
        },
      ),
      GoRoute(
        path: '/email-verification-pending',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          if (email.isEmpty) {
            return LoginScreen(changeLocale: changeLocale);
          }
          return EmailVerificationPendingScreen(email: email);
        },
      ),
      // Legacy route - redirects to main navigation
      GoRoute(path: '/home-screen', redirect: (context, state) => '/'),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardHomeScreen(),
      ),
      GoRoute(
        path: '/co-agent',
        builder: (context, state) => const CoAgentScreen(),
      ),
      GoRoute(
        path: '/contract',
        builder: (context, state) => const ContractScreen(),
      ),
      GoRoute(
        path: '/bureau',
        builder: (context, state) => const BureauScreen(),
      ),
      GoRoute(
        path: '/activities',
        builder: (context, state) => const AllActivitiesScreen(),
      ),
      GoRoute(
        path: '/dashboard/agent',
        builder: (context, state) =>
            const DashboardScreen(role: UserRole.agent),
      ),
      GoRoute(
        path: '/dashboard/agency',
        builder: (context, state) =>
            const DashboardScreen(role: UserRole.agency),
      ),
    ],
  );
}
