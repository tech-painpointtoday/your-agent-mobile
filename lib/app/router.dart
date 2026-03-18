import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:youragent/domain/entities/contract.dart';
import 'package:youragent/features/chat/pages/chat_screen.dart';
import 'package:youragent/features/chat/pages/message_screen.dart';
import 'package:youragent/features/contract/pages/edit/edit_contract_form_screen.dart';
import 'package:youragent/features/contract/pages/edit/edit_contract_menu_screen.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_bloc.dart';
import 'package:youragent/features/contract/pages/create/add_contract_screen.dart';
import 'package:youragent/features/calendar/pages/booking_detail_screen.dart';
import 'package:youragent/features/home/pages/home_screen.dart';
import 'package:youragent/features/property/pages/create/create_property_screen.dart';
import 'package:youragent/features/property/pages/edit/edit_property_form_screen.dart';
import 'package:youragent/features/property/pages/edit/edit_property_menu_screen.dart';

import '../core/di/dependency_injection.dart';
import '../domain/entities/property.dart';
import '../features/activities/pages/all_activities_screen.dart';
import '../features/auth/pages/email_verification_pending_screen.dart';
import '../features/auth/pages/forgot_password_screen.dart';
import '../features/auth/pages/login_screen.dart';
import '../features/auth/pages/register_screen.dart';
import '../features/auth/pages/reset_password_screen.dart';
import '../features/bureau/pages/bureau_screen.dart';
import '../features/co_agent/pages/co_agent_screen.dart';
import '../features/contract/pages/contract_screen.dart';
import '../features/dashboard/pages/dashboard_screen.dart';
import '../features/notifications/bloc/notification_bloc.dart';
import '../features/notifications/bloc/notification_event.dart';
import '../features/notifications/pages/notification_detail_screen.dart';
import '../features/notifications/pages/notifications_screen.dart';
import '../features/property/pages/property_detail_screen.dart';
import '../features/property/pages/property_search_screen.dart';
import '../features/property/pages/mock_property_test_screen.dart';
import '../features/public/pages/policy_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/profile/bloc/profile_bloc.dart';
import '../features/profile/models/agent_profile.dart';
import '../features/profile/pages/profile_screen.dart';
import '../features/profile/pages/personal_info_form_screen.dart';
import '../features/profile/pages/service_area_form_screen.dart';
import '../features/profile/pages/work_info_form_screen.dart';
import '../features/profile/pages/settings_screen.dart';
import '../features/profile/pages/notification_settings_screen.dart';
import '../features/profile/pages/account_management_screen.dart';
import '../features/profile/pages/contact_us_screen.dart';
import '../widgets/main_navigation_screen.dart';
import '../features/calendar/pages/agent_booking_route_map_screen.dart';

/// Route observer used so ProfileScreen can refetch when user navigates back to it.
final RouteObserver<ModalRoute<dynamic>> profileRouteObserver =
    RouteObserver<ModalRoute<dynamic>>();

class AppRouter {
  final Function(Locale) changeLocale;
  AppRouter({required this.changeLocale});

  late final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/splash',
    refreshListenable: DependencyInjection.authRepository as ChangeNotifier,
    observers: [profileRouteObserver],
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
        '/property/create',
        '/property/edit',
        '/property/edit-form',
        '/money',
        '/calendar',
        '/contact',
        '/dashboard',
        '/co-agent',
        '/contract',
        '/bureau',
        '/activities',
        '/notifications',
        '/profile',
        '/agent',
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

      if (isProtectedRoute || kDebugMode) {
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
        path: '/property/create',
        builder: (context, state) {
          final property = state.extra as Property?;
          return CreatePropertyScreen(property: property);
        },
      ),
      GoRoute(
        path: '/property/edit',
        builder: (context, state) {
          final property = state.extra as Property;
          return EditPropertyMenuScreen(property: property);
        },
      ),
      GoRoute(
        path: '/property/edit-form',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return EditPropertyFormScreen(
            property: extra['property'] as Property,
            stepType: extra['stepType'] as EditPropertyStepType,
            title: extra['title'] as String,
          );
        },
      ),
      GoRoute(
        path: '/property/search',
        builder: (context, state) => const PropertySearchScreen(),
      ),
      GoRoute(
        path: '/property/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PropertyDetailScreen(propertyId: int.tryParse(id));
        },
      ),
      GoRoute(
        path: '/test-mock-properties',
        builder: (context, state) => const MockPropertyTestScreen(),
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
        path: '/agent/bookings/:id/route',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return AgentBookingRouteMapScreen(bookingId: id);
        },
      ),
      GoRoute(
        path: '/booking/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return BookingDetailScreen(bookingId: id);
        },
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
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
      GoRoute(
        path: '/chat/:bookingId',
        builder: (context, state) {
          final bookingId = int.parse(state.pathParameters['bookingId']!);
          final participantName = state.extra as String? ?? 'การสนทนา';
          final participantPhone = state.extra as String? ?? '';
          return MessageScreen(
            bookingId: bookingId,
            participantName: participantName,
            participantPhone: participantPhone,
          );
        },
      ),
      GoRoute(
        path: '/chat/inquiry/:inquiryId',
        builder: (context, state) {
          final inquiryId = int.parse(state.pathParameters['inquiryId']!);
          final participantName = state.extra as String? ?? 'การสนทนา';
          final participantPhone = state.extra as String? ?? '';
          return MessageScreen(
            bookingId: inquiryId,
            participantName: participantName,
            participantPhone: participantPhone,
            isInquiry: true,
          );
        },
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) {
          final agent = state.extra as AgentDetails?;
          return BlocProvider(
            create: (context) =>
                ProfileBloc(DependencyInjection.authApiService),
            child: PersonalInfoFormScreen(agent: agent),
          );
        },
      ),
      GoRoute(
        path: '/agent/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/work-info',
        builder: (context, state) {
          final agent = state.extra as AgentDetails?;
          return BlocProvider(
            create: (context) =>
                ProfileBloc(DependencyInjection.authApiService),
            child: WorkInfoFormScreen(agent: agent),
          );
        },
      ),
      GoRoute(
        path: '/profile/service-area',
        builder: (context, state) {
          final agent = state.extra as AgentDetails?;
          return BlocProvider(
            create: (context) =>
                ProfileBloc(DependencyInjection.authApiService),
            child: ServiceAreaFormScreen(agent: agent),
          );
        },
      ),
      GoRoute(
        path: '/profile/settings',
        builder: (context, state) => BlocProvider(
          create: (context) =>
              ProfileBloc(DependencyInjection.authApiService)
                ..add(FetchProfile()),
          child: SettingsScreen(changeLocale: changeLocale),
        ),
      ),
      GoRoute(
        path: '/profile/settings/account',
        builder: (context, state) => const AccountManagementScreen(),
      ),
      GoRoute(
        path: '/profile/settings/notifications',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/profile/settings/contact',
        builder: (context, state) => const ContactUsScreen(),
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
          final showBottom = state.uri.queryParameters['showBottom'] != 'false';
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
            showBottomButtons: showBottom,
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
        builder: (context, state) => const DashboardScreen(),
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
        path: '/contract/create',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Property) {
            return AddContractScreen(property: extra);
          } else if (extra is Contract) {
            return AddContractScreen(contract: extra);
          }
          return const AddContractScreen();
        },
      ),
      GoRoute(
        path: '/contract/edit',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Contract) {
            return EditContractMenuScreen(contract: extra);
          }
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: '/contract/edit-form',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            return EditContractFormScreen(
              contract: extra['contract'] as Contract,
              stepType: extra['stepType'] as EditContractStepType,
              title: extra['title'] as String,
              bloc: extra['bloc'] as ContractFormBloc?,
            );
          }

          return const HomeScreen();
        },
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
        builder: (context, state) => const DashboardScreen(),
      ),
      // GoRoute(
      //   path: '/dashboard/agency',
      //   builder: (context, state) =>
      //       const DashboardScreen(role: UserRole.agency),
      // ),
    ],
  );
}
