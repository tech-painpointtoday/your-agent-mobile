import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/router.dart';
import 'services/api_client.dart';
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
    ApiClient.currentLocale = _locale.languageCode;
  }

  void _changeLocale(Locale locale) {
    setState(() => _locale = Locale(locale.languageCode));
    ApiClient.currentLocale = locale.languageCode;
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
                          elevation: 0,
                          color: Colors.transparent,
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
                                  ? const Color(0xFF0A1F4B)
                                  : const Color(0xFF3D0A50),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                              border: Border(
                                top: BorderSide(
                                  color: F.appFlavor == Flavor.dev
                                      ? const Color(0xFF00FF9D)
                                      : const Color(0xFFFF00E5),
                                  width: 1,
                                ),
                                bottom: BorderSide(
                                  color: F.appFlavor == Flavor.dev
                                      ? const Color(0xFF00FF9D)
                                      : const Color(0xFFFF00E5),
                                  width: 1,
                                ),
                                left: BorderSide(
                                  color: F.appFlavor == Flavor.dev
                                      ? const Color(0xFF00FF9D)
                                      : const Color(0xFFFF00E5),
                                  width: 1,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: F.appFlavor == Flavor.dev
                                      ? const Color(
                                          0xFF00FF9D,
                                        ).withValues(alpha: 0.6)
                                      : const Color(
                                          0xFFFF00E5,
                                        ).withValues(alpha: 0.6),
                                  blurRadius: 12,
                                  spreadRadius: 0,
                                ),
                                BoxShadow(
                                  color: F.appFlavor == Flavor.dev
                                      ? const Color(
                                          0xFF00FF9D,
                                        ).withValues(alpha: 0.35)
                                      : const Color(
                                          0xFFFF00E5,
                                        ).withValues(alpha: 0.35),
                                  blurRadius: 24,
                                  spreadRadius: -2,
                                ),
                              ],
                            ),
                            child: Text(
                              F.bannerLabel,
                              style: GoogleFonts.anuphan(
                                color: F.appFlavor == Flavor.dev
                                    ? const Color(0xFF00FF9D)
                                    : const Color(0xFFFF00E5),
                                letterSpacing: 2,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                shadows: [
                                  Shadow(
                                    color:
                                        (F.appFlavor == Flavor.dev
                                                ? const Color(0xFF00FF9D)
                                                : const Color(0xFFFF00E5))
                                            .withValues(alpha: 0.9),
                                    blurRadius: 6,
                                  ),
                                ],
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
