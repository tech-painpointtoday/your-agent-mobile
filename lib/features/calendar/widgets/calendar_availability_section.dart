import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/widgets/app_search_bar.dart';
import 'package:youragent/widgets/badges/app_badge.dart';

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
  final TextEditingController _searchCtrl = TextEditingController();

  // Calendar state
  DateTime _focusedMonth = DateTime(2569 - 543, 1); // Jan 2026 (BE 2569)
  DateTime _selectedDay = DateTime(2569 - 543, 1, 1);
  bool _calendarExpanded = false;

  static const List<Map<String, dynamic>> _mockSlots = [
    {
      'date': '2 มกราคม 2569',
      'slots': [
        {'time': '10:00 - 12:00 น.', 'available': true},
      ],
    },
    {
      'date': '1 มกราคม 2569',
      'slots': [
        {'time': '08:00 - 09:00 น.', 'available': true},
        {'time': '10:00 - 12:00 น.', 'available': false},
        {'time': '15:00 - 18:00 น.', 'available': false},
      ],
    },
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                        'ช่วงเวลาว่าง',
                        style: GoogleFonts.anuphan(
                          color: const Color(0xFF1743C7),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ช่วงเวลาว่างของคุณที่พร้อมให้บริการ',
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
                  onTap: () {},
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF3E6CF4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── View toggle ─────────────────────────────────────────────
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _viewMode = _ViewMode.list),
                  child: AppBadge(
                    label: 'มุมมองรายการ',
                    style: BadgeStyle.plain,
                    customBackgroundColor: _viewMode == _ViewMode.list
                        ? const Color(0xFF175CD3)
                        : Colors.white,
                    customTextColor: _viewMode == _ViewMode.list
                        ? const Color(0xFFEFF8FF)
                        : const Color(0xFF717680),
                    hasBorder: true,
                    borderColor: _viewMode == _ViewMode.list
                        ? const Color(0xFF175CD3)
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
                  onTap: () => setState(() => _viewMode = _ViewMode.calendar),
                  child: AppBadge(
                    label: 'มุมมองปฏิทิน',
                    style: BadgeStyle.plain,
                    customBackgroundColor: _viewMode == _ViewMode.calendar
                        ? const Color(0xFF175CD3)
                        : Colors.white,
                    customTextColor: _viewMode == _ViewMode.calendar
                        ? const Color(0xFFEFF8FF)
                        : const Color(0xFF717680),
                    hasBorder: true,
                    borderColor: _viewMode == _ViewMode.calendar
                        ? const Color(0xFF175CD3)
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

            // ── Search bar + filter (list view only) ────────────────────
            if (_viewMode == _ViewMode.list) ...[
              Row(
                children: [
                  Expanded(
                    child: AppSearchBar(
                      controller: _searchCtrl,
                      hintText: 'ค้นหา...',
                    ),
                  ),
                  const SizedBox(width: 8),
                  _FilterButton(),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // ── Calendar (calendar view only) ───────────────────────────
            if (_viewMode == _ViewMode.calendar) ...[
              _MiniCalendar(
                focusedMonth: _focusedMonth,
                selectedDay: _selectedDay,
                expanded: _calendarExpanded,
                onDaySelected: (d) => setState(() => _selectedDay = d),
                onMonthChanged: (m) => setState(() => _focusedMonth = m),
                onExpandToggle: () =>
                    setState(() => _calendarExpanded = !_calendarExpanded),
              ),
              const SizedBox(height: 16),
              // Slots for selected day
              ..._slotsForSelectedDay().map(
                (slot) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SlotCard(
                    time: slot['time'] as String,
                    available: slot['available'] as bool,
                    onEdit: () {},
                    onDelete: () {},
                  ),
                ),
              ),
            ],

            // ── Grouped list (list view only) ───────────────────────────
            if (_viewMode == _ViewMode.list) ...[
              ..._mockSlots.map(
                (group) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DateHeader(label: group['date'] as String),
                    const SizedBox(height: 8),
                    ...(group['slots'] as List<Map<String, dynamic>>).map(
                      (slot) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SlotCard(
                          time: slot['time'] as String,
                          available: slot['available'] as bool,
                          onEdit: () {},
                          onDelete: () {},
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _slotsForSelectedDay() {
    // For demo purposes return the items for "1 มกราคม 2569"
    final group = _mockSlots.firstWhere(
      (g) => (g['date'] as String).startsWith('1 '),
      orElse: () => _mockSlots.last,
    );
    return List<Map<String, dynamic>>.from(group['slots'] as List);
  }
}

// ── Filter button ────────────────────────────────────────────────────────────
class _FilterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9EAEB)),
      ),
      child: const Icon(Icons.tune_rounded, size: 20, color: Color(0xFF737373)),
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
        const Icon(
          Icons.calendar_month_outlined,
          size: 16,
          color: Color(0xFF181D27),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.anuphan(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF181D27),
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
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _SlotCard({
    required this.time,
    required this.available,
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
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF181D27),
                  ),
                ),
                const SizedBox(height: 6),
                AppBadge(
                  label: available ? 'พร้อมให้บริการ' : 'ไม่พร้อมให้บริการ',
                  style: available ? BadgeStyle.done : BadgeStyle.plain,
                  customBackgroundColor: available
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFFEEE8),
                  customTextColor: available
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFE53E3E),
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
          IconButton(
            onPressed: onEdit,
            icon: const Icon(
              Icons.edit_outlined,
              size: 20,
              color: Color(0xFF9AA4B2),
            ),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          // Delete
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: Color(0xFF9AA4B2),
            ),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
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
  final bool expanded;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onMonthChanged;
  final VoidCallback onExpandToggle;

  const _MiniCalendar({
    required this.focusedMonth,
    required this.selectedDay,
    required this.expanded,
    required this.onDaySelected,
    required this.onMonthChanged,
    required this.onExpandToggle,
  });

  static const _weekdays = ['ง.', 'อ.', 'พ.', 'พฤ.', 'ศ.', 'ส.', 'อา.'];
  static const _thaiMonths = [
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม',
  ];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final year = focusedMonth.year;
    final month = focusedMonth.month;
    final beYear = year + 543;

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

    // Determine rows to show: collapsed = only current week row, expanded = all
    final selectedRowIndex = days.indexWhere(
      (d) =>
          d.isCurrentMonth &&
          d.date.day == selectedDay.day &&
          d.date.month == month,
    );
    final selectedRow = selectedRowIndex >= 0 ? selectedRowIndex ~/ 7 : 0;

    final totalRows = (days.length / 7).ceil();
    final rowsToShow = expanded ? totalRows : 1;
    final startRow = expanded ? 0 : selectedRow;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9EAEB)),
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
                      border: Border.all(color: const Color(0xFFE9EAEB)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.chevron_left,
                          size: 14,
                          color: Color(0xFF737373),
                        ),
                        Text(
                          '$beYear',
                          style: GoogleFonts.anuphan(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF181D27),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _thaiMonths[month - 1],
                  style: GoogleFonts.anuphan(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF181D27),
                  ),
                ),
                const Spacer(),
                _NavArrow(
                  icon: Icons.chevron_left,
                  onTap: () => onMonthChanged(DateTime(year, month - 1)),
                ),
                const SizedBox(width: 4),
                _NavArrow(
                  icon: Icons.chevron_right,
                  onTap: () => onMonthChanged(DateTime(year, month + 1)),
                ),
              ],
            ),
          ),

          // ── Weekday labels ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: _weekdays
                  .map(
                    (d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: GoogleFonts.anuphan(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFA4A7AE),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 4),

          // ── Day grid ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: List.generate(rowsToShow, (rowOffset) {
                final row = startRow + rowOffset;
                final startIdx = row * 7;
                final endIdx = (startIdx + 7).clamp(0, days.length);
                if (startIdx >= days.length) return const SizedBox.shrink();
                final rowDays = days.sublist(
                  startIdx,
                  endIdx < days.length ? endIdx : days.length,
                );
                // Pad to 7 if needed
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
                            margin: const EdgeInsets.symmetric(vertical: 3),
                            decoration: ShapeDecoration(
                              color: isSelected
                                  ? const Color(0xFF2E90FA)
                                  : isToday
                                  ? const Color(0xFFEFF8FF)
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
                                      ? const Color(0xFF2E90FA)
                                      : calDay.isCurrentMonth
                                      ? const Color(0xFF181D27)
                                      : const Color(0xFFE9EAEB),
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

          const SizedBox(height: 8),

          // ── Expand / collapse drag handle ──
          GestureDetector(
            onTap: onExpandToggle,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 10),
              alignment: Alignment.center,
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD0D8),
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
  final IconData icon;
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
        child: Icon(icon, size: 18, color: const Color(0xFF9AA4B2)),
      ),
    );
  }
}
