import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../utils/permission_helper.dart';
import '../../../widgets/modals/app_confirmation_bottom_sheet.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../widgets/notification_empty_state.dart';
import '../widgets/notification_list_item.dart';
import '../../../l10n/app_localizations.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationBloc()..add(const LoadNotifications()),
      child: const _NotificationsScreenContent(),
    );
  }
}

class _NotificationsScreenContent extends StatefulWidget {
  const _NotificationsScreenContent();

  @override
  State<_NotificationsScreenContent> createState() =>
      _NotificationsScreenContentState();
}

class _NotificationsScreenContentState
    extends State<_NotificationsScreenContent> {
  @override
  void initState() {
    super.initState();
    // When user opens Notifications screen, prompt again if permission not granted yet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        PermissionHelper.ensureNotificationReady(context);
      }
    });
  }

  void _markAllAsRead(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    AppConfirmationBottomSheet.show(
      context: context,
      title: l10n.notifications_confirm_mark_all_read_title,
      description: l10n.notifications_confirm_mark_all_read_desc,
      confirmLabel: l10n.notifications_mark_all_read,
      cancelLabel: l10n.notifications_cancel_label,
      style: ConfirmationStyle.normal,
      onConfirm: () {
        context.read<NotificationBloc>().add(const MarkAllAsRead());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            final bloc = context.read<NotificationBloc>();
            final hasUnread =
                state is NotificationLoaded && state.unreadCount > 0;

            return CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  backgroundColor: AppColors.white,
                  surfaceTintColor: AppColors.white,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  pinned: true,
                  titleSpacing: 0,
                  leading: IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/chevron-left.svg',
                      width: 18,
                      height: 18,
                      fit: BoxFit.contain,
                      colorFilter: const ColorFilter.mode(
                        AppColors.baseDarkGrey,
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed: () => context.pop(),
                  ),
                  title: Text(
                    AppLocalizations.of(context).notifications_title,
                    style: GoogleFonts.anuphan(
                      fontSize: 18,
                      color: AppColors.baseBlack,
                    ),
                  ),
                  actions: [
                    // TextButton(
                    //   onPressed: hasUnread
                    //       ? () => _markAllAsRead(context)
                    //       : null,
                    //   child: Text(
                    //     AppLocalizations.of(
                    //       context,
                    //     ).notifications_mark_all_read,
                    //     style: GoogleFonts.anuphan(
                    //       fontSize: 14,
                    //       color: hasUnread
                    //           ? AppColors.primary
                    //           : AppColors.baseGrey,
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(width: 8),
                  ],
                ),

                // Sticky Filter Header
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _FilterHeaderDelegate(
                    child: Container(
                      color: AppColors.white,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child:
                                BlocBuilder<
                                  NotificationBloc,
                                  NotificationState
                                >(
                                  builder: (context, state) {
                                    final currentFilter =
                                        state is NotificationLoaded
                                        ? state.currentFilter
                                        : NotificationFilter.all;

                                    return Row(
                                      children: [
                                        _FilterBadge(
                                          label: AppLocalizations.of(
                                            context,
                                          ).notifications_filter_all,
                                          isSelected:
                                              currentFilter ==
                                              NotificationFilter.all,
                                          onTap: () {
                                            bloc.add(
                                              const FilterNotifications(
                                                NotificationFilter.all,
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        _FilterBadge(
                                          label: AppLocalizations.of(
                                            context,
                                          ).notifications_filter_unread,
                                          isSelected:
                                              currentFilter ==
                                              NotificationFilter.unread,
                                          onTap: () {
                                            bloc.add(
                                              const FilterNotifications(
                                                NotificationFilter.unread,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Content
                if (state is NotificationLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: SpinKitFadingCircle(
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                  )
                else if (state is NotificationError)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        AppLocalizations.of(
                          context,
                        ).notifications_error(state.message),
                        style: GoogleFonts.anuphan(
                          color: AppColors.supportRedDeep,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                else if (state is NotificationLoaded)
                  state.filteredNotifications.isEmpty
                      ? SliverFillRemaining(child: NotificationEmptyState())
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final notification =
                                state.filteredNotifications[index];
                            return NotificationListItem(
                              notification: notification,
                              onTap: () {
                                // Mark as read if unread
                                if (!notification.isRead) {
                                  bloc.add(MarkAsRead(notification.id));
                                }
                                // Navigate to detail screen
                                context.push(
                                  '/notifications/${notification.id}',
                                );
                              },
                            );
                          }, childCount: state.filteredNotifications.length),
                        ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FilterBadge extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterBadge({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.basePaleGrey,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.anuphan(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? AppColors.supportBlueLight
                : AppColors.baseDarkGrey,
          ),
        ),
      ),
    );
  }
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _FilterHeaderDelegate({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => 65.0;

  @override
  double get minExtent => 65.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
