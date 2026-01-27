import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/widgets/app_loader.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/widgets/app_layout.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

/// Availability Calendar Screen - shows calendar grid view of available times
class AvailabilityCalendarScreen extends StatefulWidget {
  final Function(Locale) changeLocale;
  final UserRole? role;

  const AvailabilityCalendarScreen({
    super.key,
    required this.changeLocale,
    this.role,
  });

  @override
  State<AvailabilityCalendarScreen> createState() =>
      _AvailabilityCalendarScreenState();
}

class _AvailabilityCalendarScreenState
    extends State<AvailabilityCalendarScreen> {
  late DateTime _currentMonth;
  List<Map<String, dynamic>> _availableTimes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _loadAvailableTimes();
  }

  Future<void> _loadAvailableTimes() async {
    setState(() => _isLoading = true);
    try {
      final times = await DependencyInjection.availabilityApiService
          .listAvailableTimes();
      setState(() {
        _availableTimes = times;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Handle error if needed
      }
    }
  }

  List<Map<String, dynamic>> _getTimesForDate(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    // Also handle dates formatted as "2024-12-15" which is standard ISO
    // The API might return different date formats, assuming consistent with what create/list uses.
    // If the API Create uses "dd MM yyyy" (e.g. 15 12 2024), we should check that format too.
    // `listAvailableTimes` probably returns same format as supplied in create.
    // Let's handle parsing carefully.

    return _availableTimes.where((time) {
      final tDateStr = time['date'] as String;
      try {
        // Try parsing the time date string to compare
        // It might be "2024-12-15" or "15/12/2024" or "15 12 2024"
        // Simplest is to strict parse if we know format, or loose parse.
        // Assuming standard format for now since I controlled create.

        // If create sent "dd MM yyyy", then we compare against that.
        final targetFormat = DateFormat('dd MM yyyy').format(date);
        if (tDateStr == targetFormat) return true;

        // Fallback check for ISO
        if (tDateStr == dateStr) return true;

        // Try parse
        final tDate = DateTime.tryParse(tDateStr);
        if (tDate != null) {
          return tDate.year == date.year &&
              tDate.month == date.month &&
              tDate.day == date.day;
        }
      } catch (_) {}
      return false;
    }).toList();
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  void _goToToday() {
    setState(() {
      _currentMonth = DateTime.now();
    });
  }

  String _getBasePath() {
    return widget.role == UserRole.agent
        ? '/agent/availability'
        : '/availability';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return AppLayout(
      changeLocale: widget.changeLocale,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          _buildHeaderSection(context, l10n, isDesktop),
          const SizedBox(height: 24),
          // Calendar card
          _isLoading
              ? const AppLoader()
              : _buildCalendarCard(context, l10n, isDesktop),
          const SizedBox(height: 16),
          // Legend
          _buildLegend(context, l10n),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
  ) {
    return isDesktop
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.calendar_view,
                style: GoogleFonts.anuphan(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.baseDarkGrey,
                ),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => context.go(_getBasePath()),
                    icon: const Icon(Icons.list, size: 18),
                    label: Text(l10n.list_view_button),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.baseDarkGrey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => context.push('${_getBasePath()}/create'),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.add_time_slot),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.calendar_view,
                style: GoogleFonts.anuphan(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.baseDarkGrey,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.go(_getBasePath()),
                      icon: const Icon(Icons.list, size: 16),
                      label: Text(
                        l10n.list_view_button,
                        style: const TextStyle(fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.baseDarkGrey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('${_getBasePath()}/create'),
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(
                        l10n.add_time_slot,
                        style: const TextStyle(fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
  }

  Widget _buildCalendarCard(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bonJour, width: 0.5),
      ),
      child: Column(
        children: [
          // Month navigation
          _buildMonthNavigation(context, l10n),
          // Day headers
          _buildDayHeaders(context, l10n),
          // Calendar grid
          _buildCalendarGrid(context, l10n, isDesktop),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation(BuildContext context, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context);
    final monthFormat = locale.languageCode == 'th'
        ? DateFormat('MMMM yyyy', 'th')
        : DateFormat('MMMM yyyy');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.bonJour, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            monthFormat.format(_currentMonth),
            style: GoogleFonts.anuphan(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.baseDarkGrey,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: _previousMonth,
                icon: const Icon(Icons.chevron_left),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.wildSand,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _nextMonth,
                icon: const Icon(Icons.chevron_right),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.wildSand,
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _goToToday,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.wildSand,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: Text(
                  l10n.today,
                  style: GoogleFonts.anuphan(color: AppColors.baseDarkGrey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayHeaders(BuildContext context, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context);
    final days = locale.languageCode == 'th'
        ? [
            l10n.day_sun,
            l10n.day_mon,
            l10n.day_tue,
            l10n.day_wed,
            l10n.day_thu,
            l10n.day_fri,
            l10n.day_sat,
          ]
        : [
            l10n.day_sun,
            l10n.day_mon,
            l10n.day_tue,
            l10n.day_wed,
            l10n.day_thu,
            l10n.day_fri,
            l10n.day_sat,
          ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: AppColors.baseDarkGrey),
      child: Row(
        children: days
            .map(
              (day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: GoogleFonts.anuphan(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
  ) {
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    // Get days from previous month to fill the first week
    final prevMonthLastDay = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      0,
    );
    final daysFromPrevMonth = firstWeekday;

    // Calculate total rows needed
    final totalDays = daysFromPrevMonth + daysInMonth;
    final totalRows = (totalDays / 7).ceil();

    return Column(
      children: List.generate(totalRows, (rowIndex) {
        return Row(
          children: List.generate(7, (colIndex) {
            final dayIndex = rowIndex * 7 + colIndex;
            final dayNumber = dayIndex - daysFromPrevMonth + 1;

            if (dayNumber < 1) {
              // Previous month days
              final prevDay =
                  prevMonthLastDay.day - (daysFromPrevMonth - dayIndex - 1);
              return _buildDayCell(
                context,
                l10n,
                null,
                prevDay,
                true,
                isDesktop,
              );
            } else if (dayNumber > daysInMonth) {
              // Next month days
              final nextDay = dayNumber - daysInMonth;
              return _buildDayCell(
                context,
                l10n,
                null,
                nextDay,
                true,
                isDesktop,
              );
            } else {
              // Current month days
              final date = DateTime(
                _currentMonth.year,
                _currentMonth.month,
                dayNumber,
              );
              return _buildDayCell(
                context,
                l10n,
                date,
                dayNumber,
                false,
                isDesktop,
              );
            }
          }),
        );
      }),
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    AppLocalizations l10n,
    DateTime? date,
    int dayNumber,
    bool isOutsideMonth,
    bool isDesktop,
  ) {
    final isToday = date != null && _isSameDay(date, DateTime.now());
    final timesForDate = date != null
        ? _getTimesForDate(date)
        : <Map<String, dynamic>>[];
    final hasTimeSlots = timesForDate.isNotEmpty;
    final hasAvailable = timesForDate.any((t) => t['is_available'] == true);
    final hasUnavailable = timesForDate.any((t) => t['is_available'] == false);

    Color bgColor = Colors.transparent;
    Color textColor = isOutsideMonth
        ? AppColors.shadyLady
        : AppColors.baseDarkGrey;

    if (isToday && !isOutsideMonth) {
      bgColor = AppColors.buttonPrimary.withValues(alpha: 0.2);
    }

    return Expanded(
      child: Container(
        height: isDesktop ? 100 : 80,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: AppColors.bonJour, width: 0.5),
        ),
        child: Stack(
          children: [
            // Day number and add button
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dayNumber.toString(),
                    style: GoogleFonts.anuphan(
                      fontSize: 14,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: textColor,
                    ),
                  ),
                  if (!isOutsideMonth && date != null)
                    InkWell(
                      onTap: () => context.push('${_getBasePath()}/create'),
                      child: const Icon(
                        Icons.add,
                        size: 16,
                        color: AppColors.shadyLady,
                      ),
                    ),
                ],
              ),
            ),
            // Time slots info or "no time slots" message
            if (!isOutsideMonth)
              Positioned(
                bottom: 8,
                left: 4,
                right: 4,
                child: hasTimeSlots
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...timesForDate.take(2).map((time) {
                            final isAvailable =
                                time['is_available'] as bool? ?? true;
                            return InkWell(
                              onTap: () => context.push(
                                '${_getBasePath()}/${time['id']}/edit',
                              ),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 2),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: isAvailable
                                      ? AppColors.emerald500.withValues(
                                          alpha: 0.2,
                                        )
                                      : AppColors.ruby500.withValues(
                                          alpha: 0.2,
                                        ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${time['start_time']} - ${time['end_time']}',
                                  style: GoogleFonts.anuphan(
                                    fontSize: 9,
                                    color: isAvailable
                                        ? AppColors.emerald500
                                        : AppColors.ruby500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          }),
                          if (timesForDate.length > 2)
                            Text(
                              '+${timesForDate.length - 2}',
                              style: GoogleFonts.anuphan(
                                fontSize: 9,
                                color: AppColors.shadyLady,
                              ),
                            ),
                        ],
                      )
                    : Text(
                        l10n.no_available_times,
                        style: GoogleFonts.anuphan(
                          fontSize: isDesktop ? 10 : 8,
                          color: AppColors.shadyLady,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
            // Status indicators
            if (hasTimeSlots && !isOutsideMonth)
              Positioned(
                top: 8,
                right: 30,
                child: Row(
                  children: [
                    if (hasAvailable)
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 2),
                        decoration: BoxDecoration(
                          color: AppColors.emerald500,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    if (hasUnavailable)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.ruby500,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildLegend(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bonJour, width: 0.5),
      ),
      child: Row(
        children: [
          Text(
            l10n.legend,
            style: GoogleFonts.anuphan(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 24),
          _buildLegendItem(AppColors.emerald500, l10n.status_available),
          const SizedBox(width: 16),
          _buildLegendItem(AppColors.ruby500, l10n.status_unavailable),
          const SizedBox(width: 16),
          _buildLegendItem(AppColors.buttonPrimary, l10n.today),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.anuphan(fontSize: 12, color: AppColors.shadyLady),
        ),
      ],
    );
  }
}
