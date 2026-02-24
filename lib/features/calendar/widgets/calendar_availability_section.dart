import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import 'package:youragent/features/calendar/widgets/calendar_availability_bottom_sheet.dart';
import 'package:youragent/features/calendar/bloc/availability/availability_bloc.dart';
import 'package:youragent/features/calendar/bloc/availability/availability_state.dart';
import 'package:youragent/features/calendar/bloc/availability/availability_event.dart';
import 'package:youragent/domain/entities/available_time.dart';
import 'package:youragent/widgets/modals/app_confirmation_bottom_sheet.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:youragent/core/enums/thai_month.dart';
import 'package:youragent/l10n/app_localizations.dart';

enum _ViewMode { list, calendar }

/// Full ช่วงเวลาว่าง section – stateful, handles view toggle + calendar.
class CalendarAvailabilitySection extends StatefulWidget {
  const CalendarAvailabilitySection({super.key});

  @override
  State<CalendarAvailabilitySection> createState() =>
      _CalendarAvailabilitySectionState();
}

class _CalendarAvailabilitySectionState
    extends State<CalendarAvailabilitySection> {
  _ViewMode _viewMode = _ViewMode.list;

  // Calendar state — default to today
  late DateTime _focusedMonth;
  late DateTime _selectedDay;
  // Continuous drag height — 1 row = 36 px (30 cell + 3*2 margin)
  static const double _kRowHeight = 36.0;
  double _calendarGridHeight = _kRowHeight; // start collapsed (1 row)

  late List<DateTime> _historyMonths;
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = now;
    _historyMonths = List.generate(12, (i) {
      return DateTime(now.year, now.month - i, 1);
    });
    _selectedMonth = _historyMonths.first;
    _focusedMonth = _selectedMonth;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AvailabilityBloc, AvailabilityState>(
      listenWhen: (previous, current) {
        return (current.action == AvailabilityAction.delete ||
                current.action == AvailabilityAction.create ||
                current.action == AvailabilityAction.update) &&
            previous.status == AvailabilityStatus.loading &&
            current.status != AvailabilityStatus.loading;
      },
      listener: (context, state) {
        if (state.status == AvailabilityStatus.success) {
          String? successTitle;
          if (state.action == AvailabilityAction.delete) {
            successTitle = AppLocalizations.of(
              context,
            ).availability_delete_success;
          } else if (state.action == AvailabilityAction.create) {
            successTitle = AppLocalizations.of(
              context,
            ).availability_create_success;
          } else if (state.action == AvailabilityAction.update) {
            successTitle = AppLocalizations.of(
              context,
            ).availability_update_success;
          }

          if (successTitle != null) {
            StatusDialog.showSuccess(context: context, title: successTitle);
          }
        } else if (state.status == AvailabilityStatus.failure) {
          StatusDialog.showError(
            context: context,
            title:
                state.errorMessage ??
                AppLocalizations.of(context).availability_error,
          );
        }
      },
      child: BlocBuilder<AvailabilityBloc, AvailabilityState>(
        builder: (context, state) {
          final locale = Localizations.localeOf(context).languageCode;
          final groupedTimes = state.groupedTimes;
          final selectedDayStr = DateFormat('yyyy-MM-dd').format(_selectedDay);
          final slotsForSelectedDay = groupedTimes[selectedDayStr] ?? [];

          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (_viewMode == _ViewMode.list &&
                  !state.hasReachedMax &&
                  !state.isLoadingMore &&
                  scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent - 200) {
                context.read<AvailabilityBloc>().add(
                  const LoadMoreAvailability(),
                );
              }
              return false;
            },
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<AvailabilityBloc>().add(
                  FetchAvailability(date: _focusedMonth, forceRefresh: true),
                );
                await context.read<AvailabilityBloc>().stream.firstWhere(
                  (s) => s.status != AvailabilityStatus.loading,
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 32),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // ── Header row ──────────────────────────────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  ).availability_title,
                                  style: GoogleFonts.anuphan(
                                    color: const Color(0xFF1743C7),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  ).availability_subtitle,
                                  style: GoogleFonts.anuphan(
                                    color: const Color(0xFF737373),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Add button
                          GestureDetector(
                            onTap: () {
                              CalendarAvailabilityBottomSheet.show(
                                context,
                                mode: AvailabilityMode.add,
                                initialDate: _selectedDay,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: ShapeDecoration(
                                color: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── View toggle ─────────────────────────────────────────────
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () =>
                                setState(() => _viewMode = _ViewMode.list),
                            child: AppBadge(
                              label: AppLocalizations.of(
                                context,
                              ).availability_view_list,
                              style: BadgeStyle.plain,
                              customBackgroundColor: _viewMode == _ViewMode.list
                                  ? AppColors.primary
                                  : Colors.white,
                              customTextColor: _viewMode == _ViewMode.list
                                  ? AppColors.supportBlueLight
                                  : AppColors.baseDarkGrey,
                              hasBorder: true,
                              borderColor: _viewMode == _ViewMode.list
                                  ? AppColors.primary
                                  : AppColors.baseLightGrey,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _viewMode = _ViewMode.calendar),
                            child: AppBadge(
                              label: AppLocalizations.of(
                                context,
                              ).availability_view_calendar,
                              style: BadgeStyle.plain,
                              customBackgroundColor:
                                  _viewMode == _ViewMode.calendar
                                  ? AppColors.primary
                                  : Colors.white,
                              customTextColor: _viewMode == _ViewMode.calendar
                                  ? AppColors.supportBlueLight
                                  : AppColors.baseDarkGrey,
                              hasBorder: true,
                              borderColor: _viewMode == _ViewMode.calendar
                                  ? AppColors.primary
                                  : AppColors.baseLightGrey,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (_viewMode == _ViewMode.list) ...[
                        GestureDetector(
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
                                  ThaiMonth.fromDateTime(
                                    _selectedMonth,
                                  ).localizedNameWithYear(
                                    context,
                                    _selectedMonth.year,
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
                        const SizedBox(height: 16),
                      ],

                      // ── Calendar (calendar view only) ───────────────────────────
                      if (_viewMode == _ViewMode.calendar) ...[
                        _MiniCalendar(
                          focusedMonth: _focusedMonth,
                          selectedDay: _selectedDay,
                          gridHeight: _calendarGridHeight,
                          onDaySelected: (d) =>
                              setState(() => _selectedDay = d),
                          onMonthChanged: (m) {
                            setState(() => _focusedMonth = m);
                            context.read<AvailabilityBloc>().add(
                              FetchAvailability(date: m),
                            );
                          },
                          onGridHeightChanged: (h) =>
                              setState(() => _calendarGridHeight = h),
                        ),
                        const SizedBox(height: 16),
                        if (state.status == AvailabilityStatus.loading)
                          const Center(child: CircularProgressIndicator())
                        else if (slotsForSelectedDay.isEmpty)
                          Center(
                            child: Text(
                              AppLocalizations.of(
                                context,
                              ).availability_empty_day,
                              style: GoogleFonts.anuphan(
                                color: AppColors.baseGrey,
                                fontSize: 14,
                              ),
                            ),
                          )
                        else
                          ...slotsForSelectedDay.map((slot) {
                            final now = DateTime.now();
                            final slotDateTime = DateTime.parse(
                              '${slot.date} ${slot.endTime}',
                            );
                            final canEdit = slotDateTime.isAfter(now);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _SlotCard(
                                time: locale == 'th'
                                    ? '${slot.startTime.substring(0, 5)} - ${slot.endTime.substring(0, 5)} น.'
                                    : '${slot.startTime.substring(0, 5)} - ${slot.endTime.substring(0, 5)}',
                                available: slot.isAvailable,
                                showEdit: canEdit,
                                onEdit: () => _editSlot(context, slot),
                                onDelete: () => _deleteSlot(context, slot),
                              ),
                            );
                          }),
                      ],

                      // ── Grouped list (list view only) ───────────────────────────
                      if (_viewMode == _ViewMode.list) ...[
                        if (state.status == AvailabilityStatus.loading &&
                            state.times.isEmpty)
                          const Center(child: CircularProgressIndicator())
                        else if (groupedTimes.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                ).availability_empty_list,
                                style: GoogleFonts.anuphan(
                                  color: AppColors.baseGrey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        else
                          ...groupedTimes.entries.map((entry) {
                            // entries is MapEntry<String, List<AvailableTime>>
                            // entry.key is yyyy-MM-dd
                            final date = DateTime.parse(entry.key);
                            // For YourAgent, we usually display Buddhist year.
                            final thaiYear = date.year + 543;
                            final formattedLabel = locale == 'th'
                                ? '${DateFormat('d MMMM', 'th').format(date)} $thaiYear'
                                : DateFormat('d MMMM yyyy', 'en').format(date);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _DateHeader(label: formattedLabel),
                                const SizedBox(height: 8),
                                ...entry.value.map(
                                  (slot) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _SlotCard(
                                      time: locale == 'th'
                                          ? '${slot.startTime.substring(0, 5)} - ${slot.endTime.substring(0, 5)} น.'
                                          : '${slot.startTime.substring(0, 5)} - ${slot.endTime.substring(0, 5)}',
                                      available: slot.isAvailable,
                                      showEdit: DateTime.parse(
                                        '${slot.date} ${slot.endTime}',
                                      ).isAfter(DateTime.now()),
                                      onEdit: () => _editSlot(context, slot),
                                      onDelete: () =>
                                          _deleteSlot(context, slot),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                            );
                          }),
                        if (state.isLoadingMore)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
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
                  AppLocalizations.of(context).availability_select_month,
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
                  itemCount: _historyMonths.length,
                  itemBuilder: (ctx, i) {
                    final monthDate = _historyMonths[i];
                    final isSelected =
                        monthDate.year == _selectedMonth.year &&
                        monthDate.month == _selectedMonth.month;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedMonth = monthDate;
                          _focusedMonth = monthDate;
                        });
                        context.read<AvailabilityBloc>().add(
                          FetchAvailability(date: monthDate),
                        );
                        Navigator.pop(ctx);
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
                              ThaiMonth.fromDateTime(
                                monthDate,
                              ).localizedNameWithYear(context, monthDate.year),
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

  void _editSlot(BuildContext context, AvailableTime slot) {
    TimeOfDay? startT;
    TimeOfDay? endT;
    try {
      final s = slot.startTime.split(':');
      startT = TimeOfDay(hour: int.parse(s[0]), minute: int.parse(s[1]));
      final e = slot.endTime.split(':');
      endT = TimeOfDay(hour: int.parse(e[0]), minute: int.parse(e[1]));
    } catch (_) {}

    CalendarAvailabilityBottomSheet.show(
      context,
      mode: AvailabilityMode.edit,
      initialDate: DateTime.parse(slot.date),
      initialStartTime: startT,
      initialEndTime: endT,
      initialIsAvailable: slot.isAvailable,
      availableTimeId: slot.id,
    );
  }

  void _deleteSlot(BuildContext context, AvailableTime slot) {
    AppConfirmationBottomSheet.show(
      context: context,
      style: ConfirmationStyle.destructive,
      title: AppLocalizations.of(context).availability_confirm_delete_title,
      description: AppLocalizations.of(
        context,
      ).availability_confirm_delete_desc,
      confirmLabel: AppLocalizations.of(context).availability_delete_label,
      onConfirm: () {
        context.read<AvailabilityBloc>().add(DeleteAvailability(id: slot.id));
      },
    );
  }
}

// ── Date header ───────────────────────────────────────────────────────────────
class _DateHeader extends StatelessWidget {
  final String label;

  const _DateHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/icons/calendar.svg',
          width: 16,
          height: 16,
          colorFilter: const ColorFilter.mode(
            AppColors.baseDarkGrey,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.anuphan(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.baseBlack,
          ),
        ),
      ],
    );
  }
}

// ── Slot card ─────────────────────────────────────────────────────────────────
class _SlotCard extends StatelessWidget {
  final String time;
  final bool available;
  final bool showEdit;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _SlotCard({
    required this.time,
    required this.available,
    this.showEdit = true,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9EAEB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: GoogleFonts.anuphan(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.baseBlack,
                  ),
                ),
                const SizedBox(height: 6),
                AppBadge(
                  label: available
                      ? AppLocalizations.of(
                          context,
                        ).availability_status_available
                      : AppLocalizations.of(
                          context,
                        ).availability_status_unavailable,
                  style: available ? BadgeStyle.done : BadgeStyle.plain,
                  color: available ? BadgeColor.green : BadgeColor.red,
                  fontSize: 12,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                ),
              ],
            ),
          ),
          // Edit
          if (showEdit) ...[
            IconButton(
              onPressed: onEdit,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              style: IconButton.styleFrom(
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
              ),
              icon: SvgPicture.asset(
                'assets/icons/edit.svg',
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  AppColors.baseGrey,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          // Delete
          IconButton(
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            style: IconButton.styleFrom(
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.zero,
            ),
            icon: SvgPicture.asset(
              'assets/icons/trash.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.baseGrey,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mini calendar ─────────────────────────────────────────────────────────────
class _MiniCalendar extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime selectedDay;

  /// Current pixel height of the day grid (controls how many rows are visible).
  final double gridHeight;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onMonthChanged;

  /// Called with the new desired height; parent clamps and stores it.
  final ValueChanged<double> onGridHeightChanged;

  static const double _kRowHeight = 36.0;

  const _MiniCalendar({
    required this.focusedMonth,
    required this.selectedDay,
    required this.gridHeight,
    required this.onDaySelected,
    required this.onMonthChanged,
    required this.onGridHeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final year = focusedMonth.year;
    final month = focusedMonth.month;
    final locale = Localizations.localeOf(context).languageCode;
    final displayYear = locale == 'th' ? year + 543 : year;
    final l10n = AppLocalizations.of(context);
    final weekdays = [
      l10n.calendar_mon,
      l10n.calendar_tue,
      l10n.calendar_wed,
      l10n.calendar_thu,
      l10n.calendar_fri,
      l10n.calendar_sat,
      l10n.calendar_sun,
    ];

    // Build day grid
    final firstDay = DateTime(year, month, 1);
    // weekday: 1=Mon, 7=Sun → shift so Monday=0
    final startOffset = (firstDay.weekday - 1) % 7;
    final daysInMonth = DateUtils.getDaysInMonth(year, month);

    // Previous month fill
    final prevMonth = DateTime(year, month - 1);
    final daysInPrevMonth = DateUtils.getDaysInMonth(
      prevMonth.year,
      prevMonth.month,
    );

    // Compute full day list to show
    final List<_CalDay> days = [];
    for (int i = startOffset - 1; i >= 0; i--) {
      days.add(
        _CalDay(
          day: daysInPrevMonth - i,
          isCurrentMonth: false,
          date: DateTime(prevMonth.year, prevMonth.month, daysInPrevMonth - i),
        ),
      );
    }
    for (int d = 1; d <= daysInMonth; d++) {
      days.add(
        _CalDay(day: d, isCurrentMonth: true, date: DateTime(year, month, d)),
      );
    }

    // Compute rows
    final selectedRowIndex = days.indexWhere(
      (d) =>
          d.isCurrentMonth &&
          d.date.day == selectedDay.day &&
          d.date.month == month,
    );
    final selectedRow = selectedRowIndex >= 0 ? selectedRowIndex ~/ 7 : 0;
    final totalRows = (days.length / 7).ceil();
    final visibleRows = (gridHeight / _kRowHeight).round();
    final startRow = (selectedRow + visibleRows > totalRows)
        ? (totalRows - visibleRows).clamp(0, totalRows)
        : selectedRow;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.baseLightGrey),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Navigation header ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Year pill
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.baseLightGrey),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/chevron-left.svg',
                          width: 12,
                          height: 12,
                          colorFilter: const ColorFilter.mode(
                            AppColors.baseGrey,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$displayYear',
                          style: GoogleFonts.anuphan(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.baseBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  ThaiMonth.fromDateTime(focusedMonth).localizedName(context),
                  style: GoogleFonts.anuphan(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.baseBlack,
                  ),
                ),
                const Spacer(),
                _NavArrow(
                  icon: 'assets/icons/chevron-left.svg',
                  onTap: () => onMonthChanged(DateTime(year, month - 1)),
                ),
                const SizedBox(width: 4),
                _NavArrow(
                  icon: 'assets/icons/chevron-right.svg',
                  onTap: () => onMonthChanged(DateTime(year, month + 1)),
                ),
              ],
            ),
          ),

          // ── Weekday labels ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: weekdays
                  .map(
                    (d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: GoogleFonts.anuphan(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.baseGrey,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 4),

          // ── Day grid (clipped to draggable height) ──
          ClipRect(
            child: AnimatedContainer(
              duration: Duration.zero,
              height: gridHeight.clamp(_kRowHeight, totalRows * _kRowHeight),
              child: OverflowBox(
                alignment: Alignment.topCenter,
                maxHeight: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: List.generate(totalRows, (row) {
                      final displayRow = startRow + row;
                      if (displayRow >= totalRows) {
                        return const SizedBox.shrink();
                      }
                      final startIdx = displayRow * 7;
                      final endIdx = (startIdx + 7).clamp(0, days.length);
                      if (startIdx >= days.length) {
                        return const SizedBox.shrink();
                      }
                      final rowDays = days.sublist(
                        startIdx,
                        endIdx < days.length ? endIdx : days.length,
                      );
                      while (rowDays.length < 7) {
                        final nextDay = rowDays.last.date.add(
                          const Duration(days: 1),
                        );
                        rowDays.add(
                          _CalDay(
                            day: nextDay.day,
                            isCurrentMonth: false,
                            date: nextDay,
                          ),
                        );
                      }
                      return Row(
                        children: rowDays.map((calDay) {
                          final isSelected =
                              calDay.isCurrentMonth &&
                              calDay.date.day == selectedDay.day &&
                              calDay.date.month == month &&
                              calDay.date.year == year;
                          final isToday =
                              calDay.date.day == today.day &&
                              calDay.date.month == today.month &&
                              calDay.date.year == today.year;
                          return Expanded(
                            child: GestureDetector(
                              onTap: calDay.isCurrentMonth
                                  ? () => onDaySelected(calDay.date)
                                  : null,
                              child: Center(
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 3,
                                  ),
                                  decoration: ShapeDecoration(
                                    color: isSelected
                                        ? AppColors.supportBlueDark
                                        : isToday
                                        ? AppColors.supportBlueLight
                                        : Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${calDay.day}',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.anuphan(
                                        fontSize: 14,
                                        fontWeight: isSelected || isToday
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? Colors.white
                                            : isToday
                                            ? AppColors.supportBlueDark
                                            : calDay.isCurrentMonth
                                            ? AppColors.baseBlack
                                            : AppColors.baseGrey,
                                        height: 1.14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── Drag handle (continuous resize) ──
          GestureDetector(
            onTap: () {
              // Tap snaps between 1 row and full height
              final maxH = totalRows * _kRowHeight;
              final isCollapsed = gridHeight <= _kRowHeight + 4;
              onGridHeightChanged(isCollapsed ? maxH : _kRowHeight);
            },
            onVerticalDragUpdate: (details) {
              final maxH = totalRows * _kRowHeight;
              final newH = (gridHeight + details.delta.dy).clamp(
                _kRowHeight,
                maxH,
              );
              onGridHeightChanged(newH);
            },
            onVerticalDragEnd: (details) {
              // Snap to nearest full row
              final maxH = totalRows * _kRowHeight;
              final rows = ((gridHeight + _kRowHeight / 2) / _kRowHeight)
                  .round()
                  .clamp(1, totalRows);
              onGridHeightChanged(
                (rows * _kRowHeight).clamp(_kRowHeight, maxH),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 10, top: 6),
              alignment: Alignment.center,
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.baseGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalDay {
  final int day;
  final bool isCurrentMonth;
  final DateTime date;

  _CalDay({
    required this.day,
    required this.isCurrentMonth,
    required this.date,
  });
}

class _NavArrow extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;

  const _NavArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        child: SvgPicture.asset(
          icon,
          width: 16,
          height: 16,
          colorFilter: const ColorFilter.mode(
            AppColors.baseGrey,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
