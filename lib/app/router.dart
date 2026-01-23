import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:youragent/features/home/pages/home_screen.dart';

import '../core/di/dependency_injection.dart';
import '../domain/entities/user.dart';
import '../features/auth/pages/email_verification_pending_screen.dart';
import '../features/auth/pages/forgot_password_screen.dart';
import '../features/auth/pages/login_screen.dart';
import '../features/auth/pages/register_screen.dart';
import '../features/auth/pages/reset_password_screen.dart';
import '../features/activities/pages/all_activities_screen.dart';
import '../features/bureau/pages/bureau_screen.dart';
import '../features/calendar/pages/calendar_screen.dart';
import '../features/co_agent/pages/co_agent_screen.dart';
import '../features/contact/pages/contact_screen.dart';
import '../features/contract/pages/contract_screen.dart';
import '../features/dashboard/pages/dashboard_home_screen.dart';
import '../features/dashboard/pages/dashboard_screen.dart';
import '../features/money/pages/money_screen.dart';
import '../features/property/pages/property_screen.dart';
import '../features/public/pages/policy_screen.dart';

class AppRouter {
  final Function(Locale) changeLocale;
  AppRouter({required this.changeLocale});

  late final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/login',
    refreshListenable: DependencyInjection.authRepository as ChangeNotifier,
    redirect: (context, state) {
      final authRepo = DependencyInjection.authRepository;
      final isLoggedIn = authRepo.isAuthenticated;
      final isAuthRoute =
          state.uri.path.startsWith('/login') ||
          state.uri.path.startsWith('/register');

      // allow public routes
      if (state.uri.path.startsWith('/policy') ||
          state.uri.path.startsWith('/forgot-password') ||
          state.uri.path.startsWith('/reset-password') ||
          state.uri.path.startsWith('/email-verification-pending')) {
        return null;
      }

      // Protected routes that require authentication
      final protectedRoutes = [
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
      ];

      final isProtectedRoute = protectedRoutes.any(
        (route) => state.uri.path.startsWith(route),
      );

      if (isLoggedIn) {
        if (isAuthRoute) {
          return '/home-screen';
        }
        return null;
      }

      // not logged in -> block protected routes
      if (isProtectedRoute) {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(changeLocale: changeLocale),
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
      GoRoute(
        path: '/home-screen',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/property',
        builder: (context, state) => const PropertyScreen(),
      ),
      GoRoute(
        path: '/money',
        builder: (context, state) => const MoneyScreen(),
      ),
      GoRoute(
        path: '/calendar',
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: '/contact',
        builder: (context, state) => const ContactScreen(),
      ),
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
