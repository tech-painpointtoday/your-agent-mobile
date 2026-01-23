import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/features/auth/bloc/auth_bloc.dart';
import 'package:youragent/features/auth/bloc/auth_event.dart';

import 'flavors.dart';
import 'app/router.dart';
import 'core/di/dependency_injection.dart';
import 'services/session_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'widgets/common/responsive_app_frame.dart';
import 'widgets/debug/debug_log_floating_button.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  Locale? _currentLocale;
  AppRouter? _appRouter;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _currentLocale = const Locale('th');
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  /// Initialize app: restore auth state, then create router
  Future<void> _initializeApp() async {
    // First, try to restore auth state from token
    final authRepo = DependencyInjection.authRepository;
    if (!authRepo.isAuthenticated) {
      debugPrint(
        '🔍 App startup: Attempting to restore auth state from token...',
      );
      await authRepo.restoreAuthState();
    }

    // Then check session validity
    await _checkSessionOnStart();

    // Create router after auth state is restored
    if (mounted) {
      setState(() {
        _appRouter = AppRouter(changeLocale: _changeLocale);
        _isInitializing = false;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _checkSessionValidity();
    } else if (state == AppLifecycleState.paused) {
      SessionService().updateActivity();
    }
  }

  Future<void> _checkSessionOnStart() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _checkSessionValidity();
  }

  Future<void> _checkSessionValidity() async {
    final authRepo = DependencyInjection.authRepository;
    if (!authRepo.isAuthenticated) {
      return;
    }

    final sessionService = SessionService();
    final lastActivity = await sessionService.getLastActivity();

    // If no session activity recorded yet, initialize it (fresh login)
    // Don't logout on fresh login
    if (lastActivity == null) {
      await sessionService.initializeSession();
      return;
    }

    final isValid = await sessionService.isSessionValid();

    if (!isValid && mounted) {
      // Check if this might be a timing issue (session check happening too soon after login)
      final now = DateTime.now();
      final timeSinceLastActivity = now.difference(lastActivity);

      // If session expired but it's been less than 2 seconds since last activity,
      // it might be a timing issue - don't logout immediately, just re-initialize
      if (timeSinceLastActivity.inSeconds < 2) {
        debugPrint(
          '⚠️ Session check happening too soon after login, re-initializing session',
        );
        await sessionService.initializeSession();
        return;
      }

      debugPrint('⏰ Session expired - logging out user');
      try {
        final signOut = DependencyInjection.signOutUseCase;
        await signOut();
      } catch (e) {
        debugPrint('Error during auto sign-out on session expiry: $e');
      }
    } else if (isValid) {
      await sessionService.updateActivity();
    }
  }

  void _changeLocale(Locale newLocale) {
    setState(() {
      _currentLocale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while initializing auth state
    if (_isInitializing || _appRouter == null) {
      return MaterialApp(
        title: F.title,
        home: Scaffold(
          backgroundColor: AppColors.white,
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      );
    }

    return BlocProvider<AuthBloc>(
      create: (context) =>
          DependencyInjection.authBloc..add(const CheckAuthStatusEvent()),
      child: MaterialApp.router(
        title: F.title,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', ''), Locale('th', '')],
        locale: _currentLocale,
        theme: AppTheme.lightTheme,
        routerConfig: _appRouter!.router,
        builder: (context, child) {
          final content = ResponsiveAppFrame(
            child: child ?? const SizedBox.shrink(),
          );
          final withBanner = _flavorBanner(child: content, show: kDebugMode);

          // Add debug log floating button overlay
          return Stack(children: [withBanner, const DebugLogFloatingButton()]);
        },
      ),
    );
  }

  Widget _flavorBanner({required Widget child, bool show = true}) => show
      ? Banner(
          location: BannerLocation.topStart,
          message: F.name,
          color: Colors.green.withAlpha(150),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12.0,
            letterSpacing: 1.0,
          ),
          textDirection: TextDirection.ltr,
          child: child,
        )
      : Container(child: child);
}
