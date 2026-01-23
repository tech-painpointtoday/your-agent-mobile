import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:youragent/core/di/dependency_injection.dart'
    show DependencyInjection, navigatorKey;
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/features/auth/pages/login_screen.dart';
import 'package:youragent/features/auth/pages/register_screen.dart';
import 'package:youragent/features/auth/pages/reset_password_screen.dart';
import 'package:youragent/features/auth/pages/email_verification_pending_screen.dart';
import 'package:youragent/features/contracts/pages/contracts_list_screen.dart';
import 'package:youragent/features/dashboard/pages/agent_dashboard.dart';
import 'package:youragent/features/dashboard/pages/agency_dashboard.dart';
import 'package:youragent/features/property/pages/property_list_screen.dart';
import 'package:youragent/features/property/pages/property_detail_screen.dart';
import 'package:youragent/features/property/pages/property_create_screen.dart';
import 'package:youragent/features/property/pages/property_edit_screen.dart';
import 'package:youragent/features/property/pages/property_map_screen.dart';
import 'package:youragent/features/property/pages/property_workflow_screen.dart';
import 'package:youragent/features/property/pages/property_floorplans_screen.dart';
import 'package:youragent/features/booking/pages/booking_list_screen.dart';
import 'package:youragent/features/booking/pages/booking_detail_screen.dart';
import 'package:youragent/features/chat/pages/chat_list_screen.dart';
import 'package:youragent/features/chat/pages/chat_detail_screen.dart';
import 'package:youragent/features/profile/pages/profile_show_screen.dart';
import 'package:youragent/features/profile/pages/profile_edit_screen.dart';
import 'package:youragent/features/availability/pages/availability_list_screen.dart';
import 'package:youragent/features/availability/pages/availability_create_screen.dart';
import 'package:youragent/features/availability/pages/availability_edit_screen.dart';
import 'package:youragent/features/availability/pages/availability_calendar_screen.dart';
import 'package:youragent/features/contracts/pages/contract_create_screen.dart';
import 'package:youragent/features/contracts/pages/contract_detail_screen.dart';
import 'package:youragent/features/contracts/pages/contract_edit_screen.dart';
import 'package:youragent/features/payment/pages/payment_list_screen.dart';
import 'package:youragent/features/support/pages/support_list_screen.dart';
import 'package:youragent/features/support/pages/support_detail_screen.dart';
import 'package:youragent/features/public/pages/policy_screen.dart'
    show PolicyScreen, PolicyType;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:youragent/features/property/bloc/properties_bloc.dart';

class AppRouter {
  final Function(Locale) changeLocale;

  AppRouter({required this.changeLocale});

  late final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/login/agent',
    refreshListenable: DependencyInjection.authRepository as ChangeNotifier,
    redirect: (context, state) {
      final authRepo = DependencyInjection.authRepository;
      final isLoggedIn = authRepo.isAuthenticated;
      final isLoggingIn =
          state.uri.path.startsWith('/login') ||
          state.uri.path.startsWith('/register');
      final role = authRepo.currentRole;
      final currentPath = state.uri.path;

      // Debug logging for troubleshooting
      debugPrint(
        '🔍 Router redirect check: path=$currentPath, isLoggedIn=$isLoggedIn, role=${role?.name ?? "null"}',
      );

      // Allow public routes (policy, reset-password, email-verification-pending) to be accessed without authentication
      if (currentPath.startsWith('/policy') ||
          currentPath.startsWith('/reset-password') ||
          currentPath.startsWith('/email-verification-pending')) {
        return null;
      }

      if (isLoggedIn) {
        // CRITICAL: If logged in, NEVER redirect back to login.
        // This prevents redirect loops after successful login.

        // If logged in and trying to access login/register pages, redirect to dashboard
        if (isLoggingIn) {
          if (role != null) {
            final dashboardRoute = '/home-screen';
            debugPrint(
              '🔄 Router: Redirecting logged-in user from $currentPath to $dashboardRoute',
            );
            return dashboardRoute;
          } else {
            debugPrint(
              '🔄 Router: Redirecting logged-in user from $currentPath to /home-screen (default)',
            );
            return '/home-screen'; // Default
          }
        }

        // If logged in and accessing ANY other route (protected or public),
        // allow access. The user is authenticated, so they should be allowed to navigate freely.
        debugPrint(
          '✅ Router: User is authenticated, allowing access to $currentPath',
        );
        return null;
      } else {
        // If NOT logged in and trying to access protected routes, redirect to login
        // But only if we're not already on a login/register page
        final isProtectedRoute =
            state.uri.path.startsWith('/home-screen') ||
            state.uri.path.startsWith('/dashboard') ||
            state.uri.path.startsWith('/profile') ||
            state.uri.path.startsWith('/booking') ||
            state.uri.path.startsWith('/chat') ||
            state.uri.path.startsWith('/availability') ||
            state.uri.path.startsWith('/payment') ||
            state.uri.path.startsWith('/support') ||
            state.uri.path.startsWith('/agent/') ||
            state.uri.path.startsWith('/agency/') ||
            state.uri.path.startsWith('/property/create') ||
            (state.uri.path.startsWith('/property/') &&
                state.uri.path.contains('/edit'));

        if (isProtectedRoute && !isLoggingIn) {
          debugPrint(
            '🔄 Router: Redirecting unauthenticated user from $currentPath to /login/agent',
          );
          return '/login/agent';
        }
      }
      return null;
    },
    routes: [
      // Login routes (agent and agency only)
      GoRoute(
        path: '/login/agent',
        builder: (context, state) {
          return LoginScreen(role: UserRole.agent, changeLocale: changeLocale);
        },
      ),
      GoRoute(
        path: '/login/agency',
        builder: (context, state) {
          return LoginScreen(role: UserRole.agency, changeLocale: changeLocale);
        },
      ),
      // Register routes (agent and agency only)
      GoRoute(
        path: '/register/agent',
        builder: (context, state) {
          return RegisterScreen(
            role: UserRole.agent,
            changeLocale: changeLocale,
          );
        },
      ),
      GoRoute(
        path: '/register/agency',
        builder: (context, state) {
          return RegisterScreen(
            role: UserRole.agency,
            changeLocale: changeLocale,
          );
        },
      ),
      // Public routes
      GoRoute(
        path: '/policy',
        builder: (context, state) {
          // Extract policy type from query parameter
          final typeParam = state.uri.queryParameters['type'];
          PolicyType? initialPolicyType;
          if (typeParam != null) {
            switch (typeParam) {
              case 'terms':
                initialPolicyType = PolicyType.terms;
                break;
              case 'privacy':
                initialPolicyType = PolicyType.privacy;
                break;
              case 'disclaimer':
                initialPolicyType = PolicyType.disclaimer;
                break;
            }
          }
          return PolicyScreen(
            changeLocale: changeLocale,
            initialPolicyType: initialPolicyType,
          );
        },
      ),
      // Reset password route (public)
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          // Extract token and email from query parameters
          final token = state.uri.queryParameters['token'] ?? '';
          final email = state.uri.queryParameters['email'] ?? '';

          if (token.isEmpty || email.isEmpty) {
            // If missing required params, redirect to login
            return LoginScreen(
              role: UserRole.agent,
              changeLocale: changeLocale,
            );
          }

          return ResetPasswordScreen(token: token, email: email);
        },
      ),
      // Email verification pending route (public)
      GoRoute(
        path: '/email-verification-pending',
        builder: (context, state) {
          // Extract email from query parameters
          final email = state.uri.queryParameters['email'] ?? '';

          if (email.isEmpty) {
            // If missing required param, redirect to login
            return LoginScreen(
              role: UserRole.agent,
              changeLocale: changeLocale,
            );
          }

          return EmailVerificationPendingScreen(email: email);
        },
      ),
      // Agent-specific routes
      GoRoute(
        path: '/agent/properties',
        builder: (context, state) {
          return BlocProvider(
            create: (context) =>
                PropertiesBloc(DependencyInjection.propertyApiService)
                  ..add(const PropertiesLoadRequested()),
            child: PropertyListScreen(),
          );
        },
      ),
      GoRoute(
        path: '/agent/properties/create',
        builder: (context, state) {
          return PropertyCreateScreen();
        },
      ),
      GoRoute(
        path: '/agent/properties/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return PropertyDetailScreen(
            changeLocale: changeLocale,
            propertyId: id,
          );
        },
      ),
      GoRoute(
        path: '/agent/properties/:id/edit',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          debugPrint(
            'Router: Creating PropertyEditScreen with propertyId: $id',
          );
          return PropertyEditScreen(changeLocale: changeLocale, propertyId: id);
        },
      ),
      GoRoute(
        path: '/agent/contracts',
        builder: (context, state) {
          return ContractsListScreen();
        },
      ),
      GoRoute(
        path: '/agent/contracts/create',
        builder: (context, state) {
          final propertyId = state.uri.queryParameters['propertyId'];
          return ContractCreateScreen(propertyId: propertyId);
        },
      ),
      GoRoute(
        path: '/agent/contracts/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ContractDetailScreen(contractId: id);
        },
      ),
      GoRoute(
        path: '/agent/contracts/:id/edit',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ContractEditScreen(contractId: id);
        },
      ),
      GoRoute(
        path: '/agent/bookings',
        builder: (context, state) {
          return BookingListScreen(
            changeLocale: changeLocale,
            role: UserRole.agent,
          );
        },
      ),
      GoRoute(
        path: '/agent/bookings/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return BookingDetailScreen(changeLocale: changeLocale, bookingId: id);
        },
      ),
      GoRoute(
        path: '/agent/chats',
        builder: (context, state) {
          return ChatListScreen(
            changeLocale: changeLocale,
            role: UserRole.agent,
          );
        },
      ),
      GoRoute(
        path: '/agent/chats/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ChatDetailScreen(changeLocale: changeLocale, bookingId: id);
        },
      ),
      GoRoute(
        path: '/agent/availability',
        builder: (context, state) {
          return AvailabilityListScreen(
            changeLocale: changeLocale,
            role: UserRole.agent,
          );
        },
      ),
      GoRoute(
        path: '/agent/availability/create',
        builder: (context, state) {
          return AvailabilityCreateScreen(changeLocale: changeLocale);
        },
      ),
      GoRoute(
        path: '/agent/availability/:id/edit',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return AvailabilityEditScreen(
            changeLocale: changeLocale,
            availabilityId: id,
          );
        },
      ),
      GoRoute(
        path: '/agent/availability/calendar',
        builder: (context, state) {
          return AvailabilityCalendarScreen(
            changeLocale: changeLocale,
            role: UserRole.agent,
          );
        },
      ),
      GoRoute(
        path: '/agent/support',
        builder: (context, state) {
          return SupportListScreen(changeLocale: changeLocale);
        },
      ),
      GoRoute(
        path: '/agent/support/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return SupportDetailScreen(changeLocale: changeLocale, ticketId: id);
        },
      ),
      GoRoute(
        path: '/agent/profile',
        builder: (context, state) {
          return ProfileShowScreen(
            changeLocale: changeLocale,
            role: UserRole.agent,
          );
        },
      ),
      // Agency-specific routes
      GoRoute(
        path: '/agency/properties',
        builder: (context, state) {
          return PropertyListScreen();
        },
      ),
      GoRoute(
        path: '/agency/properties/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return PropertyDetailScreen(
            changeLocale: changeLocale,
            propertyId: id,
          );
        },
      ),
      GoRoute(
        path: '/agency/properties/create',
        builder: (context, state) {
          return PropertyCreateScreen();
        },
      ),
      GoRoute(
        path: '/agency/properties/:id/edit',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          debugPrint(
            'Router: Creating PropertyEditScreen with propertyId: $id',
          );
          return PropertyEditScreen(changeLocale: changeLocale, propertyId: id);
        },
      ),
      GoRoute(
        path: '/agency/contracts/create',
        builder: (context, state) {
          final propertyId = state.uri.queryParameters['propertyId'];
          return ContractCreateScreen(propertyId: propertyId);
        },
      ),
      GoRoute(
        path: '/agency/bookings',
        builder: (context, state) {
          return BookingListScreen(
            changeLocale: changeLocale,
            role: UserRole.agency,
          );
        },
      ),
      GoRoute(
        path: '/agency/bookings/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return BookingDetailScreen(changeLocale: changeLocale, bookingId: id);
        },
      ),
      GoRoute(
        path: '/agency/profile',
        builder: (context, state) {
          return ProfileShowScreen(
            changeLocale: changeLocale,
            role: UserRole.agency,
          );
        },
      ),
      // Property routes (generic - redirects based on role)
      GoRoute(
        path: '/property',
        builder: (context, state) {
          return PropertyListScreen();
        },
      ),
      GoRoute(
        path: '/property/create',
        builder: (context, state) {
          return PropertyCreateScreen();
        },
      ),
      GoRoute(
        path: '/property/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return PropertyDetailScreen(
            changeLocale: changeLocale,
            propertyId: id,
          );
        },
      ),
      GoRoute(
        path: '/property/:id/edit',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          debugPrint(
            'Router: Creating PropertyEditScreen with propertyId: $id',
          );
          return PropertyEditScreen(changeLocale: changeLocale, propertyId: id);
        },
      ),
      GoRoute(
        path: '/property/:id/floorplans',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return PropertyFloorPlansScreen(
            changeLocale: changeLocale,
            propertyId: id,
          );
        },
      ),
      GoRoute(
        path: '/property/map',
        builder: (context, state) {
          return PropertyMapScreen(changeLocale: changeLocale);
        },
      ),
      GoRoute(
        path: '/property/workflow',
        builder: (context, state) {
          return PropertyWorkflowScreen(changeLocale: changeLocale);
        },
      ),
      // Booking routes
      GoRoute(
        path: '/booking',
        builder: (context, state) {
          final role = DependencyInjection.authRepository.currentRole;
          return BookingListScreen(changeLocale: changeLocale, role: role);
        },
      ),
      GoRoute(
        path: '/booking/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return BookingDetailScreen(changeLocale: changeLocale, bookingId: id);
        },
      ),
      // Chat routes
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          final role = DependencyInjection.authRepository.currentRole;
          return ChatListScreen(changeLocale: changeLocale, role: role);
        },
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ChatDetailScreen(changeLocale: changeLocale, bookingId: id);
        },
      ),
      GoRoute(
        path: '/booking/:id/chat',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ChatDetailScreen(changeLocale: changeLocale, bookingId: id);
        },
      ),
      // Profile routes
      GoRoute(
        path: '/profile',
        builder: (context, state) {
          final role = DependencyInjection.authRepository.currentRole;
          return ProfileShowScreen(changeLocale: changeLocale, role: role);
        },
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) {
          return ProfileEditScreen(changeLocale: changeLocale);
        },
      ),
      // Availability routes
      GoRoute(
        path: '/availability',
        builder: (context, state) {
          final role = DependencyInjection.authRepository.currentRole;
          return AvailabilityListScreen(changeLocale: changeLocale, role: role);
        },
      ),
      GoRoute(
        path: '/availability/create',
        builder: (context, state) {
          return AvailabilityCreateScreen(changeLocale: changeLocale);
        },
      ),
      GoRoute(
        path: '/availability/:id/edit',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return AvailabilityEditScreen(
            changeLocale: changeLocale,
            availabilityId: id,
          );
        },
      ),
      GoRoute(
        path: '/availability/calendar',
        builder: (context, state) {
          final role = DependencyInjection.authRepository.currentRole;
          return AvailabilityCalendarScreen(
            changeLocale: changeLocale,
            role: role,
          );
        },
      ),
      // Payment routes
      GoRoute(
        path: '/payment',
        builder: (context, state) {
          return PaymentListScreen(changeLocale: changeLocale);
        },
      ),
      // Support routes
      GoRoute(
        path: '/support',
        builder: (context, state) {
          return SupportListScreen(changeLocale: changeLocale);
        },
      ),
      GoRoute(
        path: '/support/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return SupportDetailScreen(changeLocale: changeLocale, ticketId: id);
        },
      ),
    ],
  );
}
