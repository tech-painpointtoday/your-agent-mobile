import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:yourhome/core/theme/app_colors.dart';
import 'package:yourhome/l10n/app_localizations.dart';
import 'package:yourhome/widgets/app_search_bar.dart';
import 'package:yourhome/widgets/backgrounds/blue_wave_background.dart';
import 'package:yourhome/widgets/badges/app_badge.dart';
import 'package:yourhome/core/di/dependency_injection.dart';
import 'package:yourhome/features/calendar/bloc/availability/availability_bloc.dart';
import 'package:yourhome/features/calendar/bloc/availability/availability_event.dart';
import 'package:yourhome/widgets/modals/app_call_bottom_sheet.dart';
import '../widgets/calendar_history_card.dart';
import '../widgets/calendar_availability_section.dart';
import 'package:yourhome/features/calendar/bloc/booking_list/booking_list_bloc.dart';
import 'package:yourhome/features/calendar/bloc/booking_list/booking_list_event.dart';
import 'package:yourhome/features/calendar/bloc/booking_list/booking_list_state.dart';
import 'package:yourhome/features/calendar/bloc/booking_list/booking_date_filter.dart';
import '../widgets/booking_card.dart';
import 'package:yourhome/widgets/dialogs/status_dialog.dart';
import 'package:yourhome/core/enums/thai_month.dart';
import 'package:yourhome/core/enums/booking_attendance_status.dart';
import 'package:yourhome/domain/entities/booking.dart';
import 'package:yourhome/widgets/modals/app_confirmation_bottom_sheet.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AvailabilityBloc _availabilityBloc;
  late BookingListBloc _bookingListBloc;
  late BookingListBloc _historyBloc;
  late ScrollController _scrollController;
  late TextEditingController _searchController;
  double _appBarOpacity = 0.0;
  final double _fadeThreshold = 100.0;
  List<String> get _filters => [
    AppLocalizations.of(context).calendar_all,
    AppLocalizations.of(context).calendar_today,
    AppLocalizations.of(context).calendar_tomorrow,
    AppLocalizations.of(context).calendar_this_week,
  ];

  // History month selector state
  late List<DateTime> _historyMonths;
  late DateTime _selectedHistoryMonth;
  bool _isAllHistory = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        switch (_tabController.index) {
          case 0:
            _bookingListBloc.add(const FetchBookings(refresh: true));
            break;
          case 1:
            _refreshHistory();
            break;
          case 2:
            _availabilityBloc.add(
              FetchAvailability(date: DateTime.now(), forceRefresh: true),
            );
            break;
        }
        setState(() {});
      }
    });
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _searchController = TextEditingController();
    final now = DateTime.now();
    // Current month + last 12 months (total 13 options)
    _historyMonths = List.generate(13, (i) {
      return DateTime(now.year, now.month - i, 1);
    });
    _selectedHistoryMonth = _historyMonths.first;
    _isAllHistory = false;

    _availabilityBloc = AvailabilityBloc(
      apiService: DependencyInjection.availableTimeApiService,
    )..add(FetchAvailability(date: DateTime.now()));
    _bookingListBloc = BookingListBloc(
      apiService: DependencyInjection.bookingApiService,
    )..add(const FetchBookings());
    _historyBloc = BookingListBloc(
      apiService: DependencyInjection.bookingApiService,
    );
    _refreshHistory();
  }

  void _fetchHistoryForMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    _historyBloc.add(SetCustomDateRange(firstDay, lastDay));
  }

  void _fetchHistoryAllTime() {
    _historyBloc.add(const FilterBookings(BookingDateFilter.all));
  }

  void _refreshHistory() {
    if (_isAllHistory) {
      _fetchHistoryAllTime();
    } else {
      _fetchHistoryForMonth(_selectedHistoryMonth);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    _availabilityBloc.close();
    _bookingListBloc.close();
    _historyBloc.close();
    super.dispose();
  }

  Future<void> _updateBookingStatus(int bookingId, int status) async {
    try {
      await StatusDialog.showLoadingWhile(
        context: context,
        operation: () => DependencyInjection.bookingApiService
            .updateBookingStatus(bookingId, status),
      );

      if (mounted) {
        StatusDialog.showSuccess(
          context: context,
          title: AppLocalizations.of(context).success,
          message: AppLocalizations.of(context).calendar_success_update,
        );
        _bookingListBloc.add(const FetchBookings());
        _historyBloc.add(const FetchBookings());
      }
    } catch (e) {
      if (mounted) {
        StatusDialog.showError(
          context: context,
          title: AppLocalizations.of(context).error,
          message: '${AppLocalizations.of(context).calendar_error_update}: $e',
        );
      }
    }
  }

  Future<void> _cancelBooking(int bookingId) async {
    try {
      await StatusDialog.showLoadingWhile(
        context: context,
        operation: () =>
            DependencyInjection.bookingApiService.cancelBooking(bookingId),
      );

      if (mounted) {
        StatusDialog.showSuccess(
          context: context,
          title: AppLocalizations.of(context).success,
          message: AppLocalizations.of(context).calendar_cancel_success,
        );
        _bookingListBloc.add(const FetchBookings(refresh: true));
      }
    } catch (e) {
      if (mounted) {
        StatusDialog.showError(
          context: context,
          title: AppLocalizations.of(context).error,
          message: AppLocalizations.of(context).calendar_cancel_error,
        );
      }
    }
  }

  Future<void> _onStartTravel(BuildContext context, Booking booking) async {
    final l10n = AppLocalizations.of(context);
    try {
      await StatusDialog.showLoadingWhile(
        context: context,
        operation: () async {
          if (booking.attendance?.seller?.confirmedOnDateAt == null) {
            await DependencyInjection.bookingApiService.updateAttendanceStatus(
              id: booking.id,
              status: BookingAttendanceStatus.confirmedOnDate,
            );
          }
          await DependencyInjection.bookingApiService.updateAttendanceStatus(
            id: booking.id,
            status: BookingAttendanceStatus.traveling,
          );
        },
      );

      if (!context.mounted) return;

      StatusDialog.showSuccess(
        context: context,
        title: l10n.successTitle,
        message: l10n.booking_start_traveling,
      );

      _bookingListBloc.add(const FetchBookings(refresh: true));
      context.push('/seller/bookings/${booking.id}/route');
    } catch (e) {
      if (!context.mounted) return;
      StatusDialog.showError(
        context: context,
        title: l10n.errorOccurredTitle,
        message: e.toString(),
      );
    }
  }

  Future<void> _onArrivedFromList(BuildContext context, Booking booking) async {
    final l10n = AppLocalizations.of(context);
    try {
      await StatusDialog.showLoadingWhile(
        context: context,
        operation: () async {
          final result = await DependencyInjection.bookingApiService
              .updateAttendanceStatus(
            id: booking.id,
            status: BookingAttendanceStatus.arrived,
          );
          if (!context.mounted) return;
          StatusDialog.showSuccess(
            context: context,
            title: l10n.successTitle,
            message: result.statusLabel ?? result.message ?? '',
          );
        },
      );

      if (!context.mounted) return;

      _bookingListBloc.add(const FetchBookings(refresh: true));
    } catch (e) {
      if (!context.mounted) return;
      StatusDialog.showError(
        context: context,
        title: l10n.errorOccurredTitle,
        message: e.toString(),
      );
    }
  }

  Future<void> _onSellerConfirmFromList(
    BuildContext context,
    Booking booking,
  ) async {
    final l10n = AppLocalizations.of(context);
    AppConfirmationBottomSheet.show(
      context: context,
      title: l10n.booking_confirm_booking_title,
      description: l10n.booking_confirm_booking_desc,
      confirmLabel: l10n.confirm,
      onConfirm: () async {
        try {
          await StatusDialog.showLoadingWhile(
            context: context,
            operation: () async {
              final result = await DependencyInjection.bookingApiService
                  .updateAttendanceStatus(
                id: booking.id,
                status: BookingAttendanceStatus.confirmedOnDate,
              );
              if (!context.mounted) return;
              StatusDialog.showSuccess(
                context: context,
                title: l10n.successTitle,
                message: result.statusLabel ?? result.message ?? '',
              );
            },
          );
          if (!context.mounted) return;
          _bookingListBloc.add(const FetchBookings(refresh: true));
        } catch (e) {
          if (!context.mounted) return;
          StatusDialog.showError(
            context: context,
            title: l10n.errorOccurredTitle,
            message: e.toString(),
          );
        }
      },
    );
  }

  void _showMonthPicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9EAEB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  AppLocalizations.of(context).calendar_select_month,
                  style: GoogleFonts.anuphan(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.baseBlack,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  // First option = "All time", followed by current + last 12 months
                  itemCount: _historyMonths.length + 1,
                  itemBuilder: (ctx, i) {
                    if (i == 0) {
                      final isSelected = _isAllHistory;
                      final label =
                          AppLocalizations.of(context).calendar_all;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _isAllHistory = true;
                          });
                          Navigator.pop(ctx);
                          _fetchHistoryAllTime();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.supportBlueLight
                                : Colors.transparent,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                label,
                                style: GoogleFonts.anuphan(
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? AppColors.supportBlueDeep
                                      : AppColors.baseBlack,
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: AppColors.supportBlueDeep,
                                ),
                            ],
                          ),
                        ),
                      );
                    }

                    final monthDate = _historyMonths[i - 1];
                    final isSelected =
                        !_isAllHistory && monthDate == _selectedHistoryMonth;
                    final thaiMonth = ThaiMonth.fromDateTime(monthDate);
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _isAllHistory = false;
                          _selectedHistoryMonth = monthDate;
                        });
                        Navigator.pop(ctx);
                        _fetchHistoryForMonth(monthDate);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.supportBlueLight
                              : Colors.transparent,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              thaiMonth.localizedNameWithYear(
                                context,
                                monthDate.year,
                              ),
                              style: GoogleFonts.anuphan(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? AppColors.supportBlueDeep
                                    : AppColors.baseBlack,
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_rounded,
                                size: 18,
                                color: AppColors.supportBlueDeep,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _scrollListener() {
    final double newOpacity = (_scrollController.offset / _fadeThreshold).clamp(
      0.0,
      1.0,
    );
    if ((newOpacity - _appBarOpacity).abs() > 0.01) {
      setState(() {
        _appBarOpacity = newOpacity;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _availabilityBloc),
        BlocProvider.value(value: _bookingListBloc),
      ],
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [_buildSliverAppBar()];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildAppointmentListSection(context),
              _buildHistorySection(context),
              _buildAvailabilitySection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 0,
      collapsedHeight: MediaQuery.of(context).size.width * (68 / 360),
      backgroundColor: AppColors.primary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Text(
        AppLocalizations.of(context).availability,
        style: GoogleFonts.anuphan(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      flexibleSpace: const BlueWaveBackground(hasFilter: true),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(36),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                Container(height: 18, color: Colors.transparent),
                Container(height: 18, color: Colors.white),
              ],
            ),
            _buildTabCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFF5F8FF),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: AppColors.supportBlueDark,
            borderRadius: BorderRadius.circular(8),
          ),
          labelColor: AppColors.supportBlueLight,
          unselectedLabelColor: AppColors.baseDarkGrey,
          labelStyle: GoogleFonts.anuphan(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: GoogleFonts.anuphan(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          padding: EdgeInsets.zero,
          indicatorPadding: EdgeInsets.zero,
          labelPadding: EdgeInsets.zero,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: [
            Tab(text: AppLocalizations.of(context).calendar_tab_appointments),
            Tab(text: AppLocalizations.of(context).calendar_tab_history),
            Tab(text: AppLocalizations.of(context).calendar_tab_availability),
          ],
        ),
      ),
    );
  }

  // ── Tab 1: Appointment list ─────────────────────────────────────────────
  Widget _buildAppointmentListSection(BuildContext context) {
    return BlocBuilder<BookingListBloc, BookingListState>(
      builder: (context, state) {
        if (state.status == BookingListStatus.initial ||
            state.status == BookingListStatus.loading) {
          return const Center(
            child: SpinKitFadingCircle(color: AppColors.primary, size: 32),
          );
        }

        if (state.status == BookingListStatus.failure) {
          return Center(
            child: Text(
              '${AppLocalizations.of(context).error}: ${state.errorMessage}',
            ),
          );
        }
        final bookings = state.filteredBookings;

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200) {
              context.read<BookingListBloc>().add(const LoadMoreBookings());
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: () async {
              _bookingListBloc.add(const FetchBookings(refresh: true));
              await _bookingListBloc.stream.firstWhere(
                (s) => s.status != BookingListStatus.loading,
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 32),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(
                              context,
                            ).calendar_appointments_title,
                            style: GoogleFonts.anuphan(
                              color: const Color(0xFF1743C7),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(
                              context,
                            ).calendar_total_appointments(bookings.length),
                            style: GoogleFonts.anuphan(
                              color: const Color(0xFF737373),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Filter badges
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(
                          BookingDateFilter.values.length,
                          (index) {
                            final filterToken = BookingDateFilter.values[index];
                            final isSelected =
                                state.selectedFilter == filterToken;
                            final label = (index < _filters.length)
                                ? _filters[index]
                                : filterToken.name;
                            return AppBadge(
                              label: label,
                              customBackgroundColor: isSelected
                                  ? AppColors.supportBlueDeep
                                  : AppColors.white,
                              customTextColor: isSelected
                                  ? AppColors.supportBlueLight
                                  : AppColors.baseDarkGrey,
                              hasBorder: !isSelected,
                              borderColor: const Color(0xFFE9EAEB),
                              onDismiss: () {
                                context.read<BookingListBloc>().add(
                                  FilterBookings(filterToken),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // ── Month selector (tappable dropdown) ───────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AppSearchBar(
                        controller: _searchController,
                        hintText: AppLocalizations.of(context).searchHint,
                        onChanged: (value) {
                          context.read<BookingListBloc>().add(
                            SearchBookings(value),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Appointment list
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: bookings.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 32,
                                ),
                                child: Text(
                                  'ไม่มีรายการนัดหมาย',
                                  style: GoogleFonts.anuphan(
                                    fontSize: 14,
                                    color: AppColors.baseGrey,
                                  ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: bookings.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                            final booking = bookings[index];
                            return BookingCard(
                              booking: booking,
                              onStatusAction: (status) =>
                                  _updateBookingStatus(
                                    booking.id,
                                    status,
                                  ),
                              onCancelTap: () => _cancelBooking(booking.id),
                              onCoAgentTap: () {},
                              onStartTravelTap: () =>
                                  _onStartTravel(context, booking),
                              onArrivedTap: () =>
                                  _onArrivedFromList(context, booking),
                              onConfirmAppointmentTap: () =>
                                  _onSellerConfirmFromList(context, booking),
                              onRouteMapTap: () => context.push(
                                '/seller/bookings/${booking.id}/route',
                              ),
                            );
                              },
                            ),
                    ),
                    if (state.isLoadingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: SpinKitFadingCircle(
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Tab 2: Appointment history ──────────────────────────────────────────
  Widget _buildHistorySection(BuildContext context) {
    return BlocBuilder<BookingListBloc, BookingListState>(
      bloc: _historyBloc,
      builder: (context, state) {
        final bookings = state.filteredBookings;

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200) {
              _historyBloc.add(const LoadMoreBookings());
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: () async {
              _refreshHistory();
              await _historyBloc.stream.firstWhere(
                (s) => s.status != BookingListStatus.loading,
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 32),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).calendar_history_title,
                            style: GoogleFonts.anuphan(
                              color: AppColors.brandBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(
                              context,
                            ).calendar_total_history(bookings.length),
                            style: GoogleFonts.anuphan(
                              color: AppColors.baseDarkGrey,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ── Month selector (tappable dropdown) ───────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GestureDetector(
                        onTap: _showMonthPicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 1,
                                color: AppColors.baseLightGrey,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x0C000000),
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _isAllHistory
                                    ? AppLocalizations.of(context).calendar_all
                                    : ThaiMonth.fromDateTime(
                                        _selectedHistoryMonth,
                                      ).localizedNameWithYear(
                                        context,
                                        _selectedHistoryMonth.year,
                                      ),
                                style: GoogleFonts.anuphan(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.baseBlack,
                                ),
                              ),
                              SvgPicture.asset(
                                'assets/icons/chevron-down.svg',
                                width: 20,
                                height: 20,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.baseDarkGrey,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ── History cards ────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child:
                          state.status == BookingListStatus.initial ||
                              state.status == BookingListStatus.loading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 32),
                                child: SpinKitFadingCircle(
                                  color: AppColors.primary,
                                  size: 32,
                                ),
                              ),
                            )
                          : state.status == BookingListStatus.failure
                          ? Center(
                              child: Text(
                                '${AppLocalizations.of(context).error}: ${state.errorMessage}',
                              ),
                            )
                          : bookings.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 32,
                                ),
                                child: Text(
                                  'ไม่มีรายการนัดหมาย',
                                  style: GoogleFonts.anuphan(
                                    fontSize: 14,
                                    color: AppColors.baseGrey,
                                  ),
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                ListView.separated(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: bookings.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    String displayDate = '';
                                    try {
                                      final ymd = bookings[index].ymd;
                                      if (ymd.length == 8) {
                                        final year = int.parse(
                                          ymd.substring(0, 4),
                                        );
                                        final month = int.parse(
                                          ymd.substring(4, 6),
                                        );
                                        final day = int.parse(
                                          ymd.substring(6, 8),
                                        );
                                        final dt = DateTime(year, month, day);
                                        final thaiYear = year + 543;
                                        final formatter = DateFormat(
                                          'd MMM',
                                          'th',
                                        );
                                        displayDate =
                                            '${formatter.format(dt)} $thaiYear, ${bookings[index].time} น.';
                                      } else {
                                        displayDate =
                                            '${bookings[index].ymd}, ${bookings[index].time} น.';
                                      }
                                    } catch (_) {
                                      displayDate =
                                          '${bookings[index].ymd}, ${bookings[index].time} น.';
                                    }

                                    final booking = bookings[index];
                                    return CalendarHistoryCard(
                                      propertyAddress:
                                          booking.property?.title ??
                                          'Unknown Address',
                                      imageUrl:
                                          booking.property?.images.isNotEmpty ==
                                              true
                                          ? booking.property!.images.first.url
                                          : null,
                                      visitorName:
                                          booking.buyer?.name ?? 'Unknown',
                                      dateStr: displayDate,
                                      status: booking.status,
                                      statusLabel: booking.statusLabel,
                                      onContactTap: booking.buyer?.phone != null
                                          ? () {
                                              AppCallBottomSheet.show(
                                                context: context,
                                                options: [
                                                  CallOption(
                                                    label:
                                                        booking.buyer?.name ??
                                                        'Unknown',
                                                    phone:
                                                        booking.buyer?.phone ??
                                                        '',
                                                  ),
                                                ],
                                              );
                                            }
                                          : null,
                                      onTap: () => context.push(
                                        '/booking/${booking.id}',
                                      ),
                                    );
                                  },
                                ),
                                if (state.isLoadingMore)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: Center(
                                      child: SpinKitFadingCircle(
                                        color: AppColors.primary,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Tab 3: Availability ───────────────────────────────────────────────
  Widget _buildAvailabilitySection(BuildContext context) {
    return const CalendarAvailabilitySection();
  }

  // ── Shared empty state ───────────────────────────────────────────────
}
