import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:youragent/core/di/dependency_injection.dart'
    show DependencyInjection, navigatorKey;
import 'package:youragent/core/config/app_config.dart';
import 'package:youragent/core/services/device_service.dart';

// 🎨 Cyberpunk Colors
const _hackerGreen = Color(0xFF00FF41);
const _hackerBlack = Color(0xFF0D0D0D);
const _hackerDarkGray = Color(0xFF1A1A1A);

class DebugLogOverlay {
  static OverlayEntry? _overlayEntry;
  static bool _isVisible = false;

  static void show() {
    if (!AppConfig.isDev) return;
    if (_isVisible) return;

    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => _DebugLogOverlayWidget(onClose: () => hide()),
    );

    overlay.insert(_overlayEntry!);
    _isVisible = true;
  }

  static void hide() {
    if (!_isVisible) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isVisible = false;
  }

  static void toggle() {
    if (_isVisible) {
      hide();
    } else {
      show();
    }
  }

  static bool get isVisible => _isVisible;
}

class _DebugLogOverlayWidget extends StatefulWidget {
  final VoidCallback onClose;

  const _DebugLogOverlayWidget({required this.onClose});

  @override
  State<_DebugLogOverlayWidget> createState() => _DebugLogOverlayWidgetState();
}

class _DebugLogOverlayWidgetState extends State<_DebugLogOverlayWidget> {
  int _refreshKey = 0;
  static String? _fcmToken;

  void _clearLogs() {
    final talker = DependencyInjection.talker;
    if (talker != null) {
      talker.cleanHistory();
      // Force rebuild to refresh TalkerScreen
      setState(() {
        _refreshKey++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final talker = DependencyInjection.talker;
    if (talker == null) {
      return const SizedBox.shrink();
    }

    // Use monospace font - works on all platforms including web
    final monoStyle = TextStyle(fontFamily: 'monospace', color: _hackerGreen);

    return Material(
      color: Colors.black.withValues(alpha: 0.6),
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _hackerBlack,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: _hackerGreen, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: _hackerGreen.withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData.dark(useMaterial3: true).copyWith(
                scaffoldBackgroundColor: _hackerBlack,
                textTheme: TextTheme(
                  bodyMedium: monoStyle,
                  bodyLarge: monoStyle,
                  titleLarge: monoStyle,
                ),
              ),
              home: Scaffold(
                backgroundColor: _hackerBlack,
                body: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        color: _hackerDarkGray,
                        border: Border(
                          bottom: BorderSide(color: _hackerGreen, width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.terminal,
                            size: 20,
                            color: _hackerGreen,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '> SYSTEM_LOGS_ACCESS',
                              style: monoStyle.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(
                              Icons.generating_tokens,
                              size: 20,
                              color: Colors.lightBlueAccent,
                            ),
                            tooltip: 'FCM Token',
                            onPressed: () {
                              DeviceService().registerDevice();
                              debugPrint(
                                'deviceInfo: ${DeviceService().cachedInfo}',
                              );
                              setState(() {
                                _fcmToken = DeviceService().cachedInfo?.token;
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.clear_all,
                              size: 20,
                              color: _hackerGreen,
                            ),
                            tooltip: 'Clear logs',
                            onPressed: _clearLogs,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.power_settings_new,
                              size: 20,
                              color: Colors.redAccent,
                            ),
                            tooltip: 'Close',
                            onPressed: widget.onClose,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    if (_fcmToken != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: _hackerGreen, width: 1),
                          ),
                        ),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'FCM Token: ',
                                style: monoStyle.copyWith(color: _hackerGreen),
                              ),
                              TextSpan(
                                text: _fcmToken,
                                style: monoStyle.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Talker Content
                    Expanded(
                      child: TalkerScreen(
                        key: ValueKey(_refreshKey),
                        talker: talker,
                        theme: TalkerScreenTheme(
                          backgroundColor: _hackerBlack,
                          textColor: Colors.white,
                          cardColor: _hackerDarkGray,
                          logColors: {
                            'http-response': const Color(0xFF00FF41), // Green
                            'http-request': const Color(0xFF00FFFF), // Cyan
                            'error': const Color(0xFFFF0055), // Red
                            'info': const Color(0xFFFFFF00), // Yellow
                            'warning': const Color(0xFFFFAA00), // Orange
                            'verbose': const Color(0xFF888888), // Gray
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
