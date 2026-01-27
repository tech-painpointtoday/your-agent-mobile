import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/router.dart';
import 'core/di/dependency_injection.dart';
import 'core/theme/app_theme.dart';
import 'flavors.dart';
import 'l10n/app_localizations.dart';
import 'widgets/debug/debug_log_floating_button.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  Locale _locale = const Locale('th');
  late final AppRouter _router = AppRouter(changeLocale: _changeLocale);

  @override
  void initState() {
    super.initState();
    // Attempt restore
    DependencyInjection.authRepository.restoreAuthState();
  }

  void _changeLocale(Locale locale) {
    setState(() => _locale = Locale(locale.languageCode));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DependencyInjection.authBloc,
      child: MaterialApp.router(
        title: F.title,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: _locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: _router.router,
        builder: (context, child) {
          // Add debug log floating button overlay
          return Stack(
            children: [
              child ?? const SizedBox.shrink(),
              const DebugLogFloatingButton(),
            ],
          );
        },
      ),
    );
  }
}

