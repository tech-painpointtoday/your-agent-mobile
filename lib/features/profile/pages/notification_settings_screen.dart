import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/core/services/deep_link_service.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:youragent/widgets/modals/app_confirmation_bottom_sheet.dart';

import 'package:flutter_line_sdk/flutter_line_sdk.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _lineNotifications = false;
  bool _emailNotifications = true;
  bool _pushNotifications = false;
  bool _isLineConnected = false;
  bool _isLoading = false;
  StreamSubscription<DeepLinkStatus>? _deepLinkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
    _fetchLineStatus();
    _setupLineSDK();
  }

  Future<void> _setupLineSDK() async {
    // Placeholder Channel ID as requested.
    // In a real app, this should come from AppConfig or an environment variable.
    await LineSDK.instance
        .setup("YOUR_CHANNEL_ID")
        .then((_) {
          // SDK setup success
        })
        .catchError((e) {
          // SDK setup failed
          // DependencyInjection.talker?.error('LineSDK Setup Failed: $e');
        });
  }

  Future<void> _fetchLineStatus() async {
    final isSubscribed = await DependencyInjection.settingsApiService
        .getLineStatus();
    if (mounted) {
      setState(() {
        _isLineConnected = isSubscribed;
      });
    }
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    super.dispose();
  }

  void _initDeepLinkListener() {
    _deepLinkSubscription = DependencyInjection.deepLinkService.statusStream
        .listen((status) {
          if (!mounted) return;

          if (status == DeepLinkStatus.success) {
            setState(() {
              _isLineConnected = true;
            });
            StatusDialog.showSuccess(
              context: context,
              title: AppLocalizations.of(context).success,
              message: 'เชื่อมต่อบัญชี LINE เรียบร้อยแล้ว',
            );
          } else if (status == DeepLinkStatus.failure) {
            StatusDialog.showError(
              context: context,
              title: 'การเชื่อมต่อล้มเหลว',
              message: 'ไม่สามารถเชื่อมต่อบัญชี LINE ได้ในขณะนี้',
            );
          }
        });
  }

  Future<void> _handleConnectLine() async {
    if (_isLoading) return;

    if (_isLineConnected) {
      _handleDisconnectLine();
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Login with LINE SDK
      final result = await LineSDK.instance.login(
        scopes: ["profile", "openid"],
      );

      final accessToken = result.accessToken.value;

      // Link account with backend
      final success = await DependencyInjection.settingsApiService
          .linkLineAccount(accessToken);

      if (success && mounted) {
        setState(() {
          _isLineConnected = true;
        });
        StatusDialog.showSuccess(
          context: context,
          title: AppLocalizations.of(context).success,
          message: 'เชื่อมต่อบัญชี LINE เรียบร้อยแล้ว',
        );
      }
    } on PlatformException catch (e) {
      // Handle user cancellation or SDK specific errors
      if (mounted) {
        // Don't show error if user cancelled (checking error code if possible,
        // but generic handling for now as 'User Cancelled' is common)
        if (!e.message.toString().contains('User cancelled')) {
          // Heuristic
          StatusDialog.showError(
            context: context,
            title: 'การเชื่อมต่อล้มเหลว',
            message: e.message ?? 'Unknown LINE SDK Error',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        StatusDialog.showError(
          context: context,
          title: 'เกิดข้อผิดพลาด',
          message: e.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleDisconnectLine() async {
    AppConfirmationBottomSheet.show(
      context: context,
      title: 'ยกเลิกการเชื่อมต่อ LINE?',
      description:
          'คุณต้องการยกเลิกการเชื่อมต่อบัญชี LINE หรือไม่? คุณจะไม่ได้รับการแจ้งเตือนผ่านช่องทางนี้',
      confirmLabel: 'ยกเลิกการเชื่อมต่อ',
      cancelLabel: 'ปิด',
      style: ConfirmationStyle.destructive,
      onConfirm: () async {
        setState(() => _isLoading = true);
        try {
          final success = await DependencyInjection.settingsApiService
              .unsubscribeLine();
          if (success && mounted) {
            setState(() {
              _isLineConnected = false;
            });
            StatusDialog.showSuccess(
              context: context,
              title: 'สำเร็จ',
              message: 'ยกเลิกการเชื่อมต่อ LINE เรียบร้อยแล้ว',
            );
          }
        } catch (e) {
          if (mounted) {
            StatusDialog.showError(
              context: context,
              title: 'เกิดข้อผิดพลาด',
              message: e.toString(),
            );
          }
        } finally {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        title: Text(
          l10n.notificationSettingsTitle,
          style: GoogleFonts.anuphan(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/chevron-left.svg',
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            width: 18,
            height: 18,
            fit: BoxFit.contain,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: ListView(
            padding: const EdgeInsets.all(32),
            children: [
              _buildLineConnection(l10n),
              const SizedBox(height: 24),
              _NotificationItem(
                title: l10n.lineNotifications,
                subtitle: l10n.lineNotificationsSubtitle,
                value: _lineNotifications,
                onChanged: (val) {
                  setState(() {
                    _lineNotifications = val;
                  });
                },
              ),
              const SizedBox(height: 24),
              _NotificationItem(
                title: l10n.emailNotifications,
                subtitle: l10n.emailNotificationsSubtitle,
                value: _emailNotifications,
                onChanged: (val) {
                  setState(() {
                    _emailNotifications = val;
                  });
                },
              ),
              const SizedBox(height: 24),
              _NotificationItem(
                title: l10n.pushNotifications,
                subtitle: l10n.pushNotificationsSubtitle,
                value: _pushNotifications,
                onChanged: (val) {
                  setState(() {
                    _pushNotifications = val;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLineConnection(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.connectLineAccount,
                style: GoogleFonts.anuphan(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF181D27),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isLineConnected ? l10n.success : l10n.lineNotConnected,
                style: GoogleFonts.anuphan(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: _isLineConnected
                      ? AppColors.success
                      : const Color(0xFF717680),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _handleConnectLine,
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE9EAEB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: _isLoading
                ? const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/attachment.svg',
                        width: 12,
                        height: 12,
                        colorFilter: ColorFilter.mode(
                          _isLineConnected
                              ? AppColors.success
                              : const Color(0xFF717680),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isLineConnected
                            ? 'ยกเลิกการเชื่อมต่อ'
                            : l10n.connectButton,
                        style: GoogleFonts.anuphan(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _isLineConnected
                              ? AppColors.error
                              : const Color(0xFF717680),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationItem({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.anuphan(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF181D27),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.anuphan(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF717680),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _AppSwitch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AppSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 20,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: value ? AppColors.primary : const Color(0xFFE9EAEB),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
