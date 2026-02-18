import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/router.dart';
import 'core/di/dependency_injection.dart';
import 'core/theme/app_theme.dart';
import 'flavors.dart';
import 'l10n/app_localizations.dart';
import 'features/property/bloc/property_metadata/property_metadata_bloc.dart';
import 'features/property/bloc/property_metadata/property_metadata_event.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DependencyInjection.authBloc),
        BlocProvider(
          create: (_) => PropertyMetadataBloc(
            propertyApiService: DependencyInjection.propertyApiService,
          )..add(const LoadPropertyMetadata()),
        ),
      ],
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
          final mediaQueryData = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQueryData.copyWith(
              textScaler: mediaQueryData.textScaler,
            ),
            child: Stack(
              children: [
                child ?? const SizedBox.shrink(),
                // Flavor banner: show when build is not production (dev/staging)
                if (!F.isProduction && F.bannerLabel.isNotEmpty)
                  Positioned(
                    top: 36,
                    right: 0,
                    child: IgnorePointer(
                      child: SafeArea(
                        top: false,
                        child: Material(
                          elevation: 2,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            topLeft: Radius.circular(8),
                          ),
                          child: Container(
                            width: 56,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: F.appFlavor == Flavor.dev
                                  ? Colors.orange
                                  : Colors.blue,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              F.bannerLabel,
                              style: GoogleFonts.anuphan(
                                color: Colors.white,
                                letterSpacing: 2,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                kDebugMode
                    ? const DebugLogFloatingButton()
                    : const SizedBox.shrink(),
              ],
            ),
          );
        },
      ),
    );
  }
}
