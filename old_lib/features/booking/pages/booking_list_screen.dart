import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/booking.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/data/models/property_model.dart';
import 'package:youragent/widgets/app_layout.dart';
import 'package:youragent/features/booking/bloc/booking_list_bloc.dart';
import 'package:youragent/features/booking/bloc/booking_list_event.dart';
import 'package:youragent/features/booking/bloc/booking_list_state.dart';
import 'package:youragent/widgets/app_loader.dart';
import 'package:youragent/features/booking/bloc/booking_list_sort.dart';

/// Booking List Screen - shows all bookings
class BookingListScreen extends StatefulWidget {
  final Function(Locale) changeLocale;
  final UserRole? role;

  const BookingListScreen({super.key, required this.changeLocale, this.role});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  final ScrollController _cardsController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Bloc will load via provider
  }

  @override
  void dispose() {
    _cardsController.dispose();
    super.dispose();
  }

  void _scrollCards(double delta) {
    final target = (_cardsController.offset + delta).clamp(
      0.0,
      _cardsController.position.maxScrollExtent,
    );
    _cardsController.animateTo(
      target,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider(
      create: (_) =>
          BookingListBloc(role: widget.role)
            ..add(const BookingListLoadRequested()),
      child: AppLayout(
        changeLocale: widget.changeLocale,
        child: BlocBuilder<BookingListBloc, BookingListState>(
          builder: (context, state) {
            if (state is BookingListLoading) {
              return const AppLoader();
            }

            if (state is BookingListError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<BookingListBloc>().add(
                          const BookingListLoadRequested(),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final loaded = state as BookingListLoaded;
            final bookings = loaded.bookings;
            final propertyById = loaded.propertyById;
            final sort = loaded.sort;

            return LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 1100;
                final count = bookings.length;
                final title = 'การนัดหมายของคุณ $count รายการ';

                final content = ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 992),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.eerieBlack,
                            ),
                          ),
                          _SortDropdown(
                            value: sort,
                            onChanged: (v) => context
                                .read<BookingListBloc>()
                                .add(BookingListSortChanged(v)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      if (isNarrow)
                        Column(
                          children: bookings
                              .map(
                                (b) => Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: _BookingCard(
                                    booking: b,
                                    property: propertyById[b.propertyId],
                                  ),
                                ),
                              )
                              .toList(),
                        )
                      else
                        SizedBox(
                          height: 642,
                          child: ListView.separated(
                            controller: _cardsController,
                            scrollDirection: Axis.horizontal,
                            itemCount: bookings.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 24),
                            itemBuilder: (context, index) {
                              final b = bookings[index];
                              return _BookingCard(
                                booking: b,
                                property: propertyById[b.propertyId],
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );

                if (isNarrow) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Center(child: content),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CircleNavButton(
                        icon: Icons.chevron_left,
                        onTap: () => _scrollCards(-360),
                      ),
                      const SizedBox(width: 40),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          child: Center(child: content),
                        ),
                      ),
                      const SizedBox(width: 40),
                      _CircleNavButton(
                        icon: Icons.chevron_right,
                        onTap: () => _scrollCards(360),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _CircleNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleNavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Icon(icon, size: 22, color: AppColors.eerieBlack),
          ),
        ),
      ),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  final BookingSort value;
  final ValueChanged<BookingSort> onChanged;

  const _SortDropdown({required this.value, required this.onChanged});

  String _label(BookingSort v) {
    switch (v) {
      case BookingSort.compatibilityHighToLow:
        return 'เรียงจากความเข้ากันมากไปน้อย';
      case BookingSort.newest:
        return 'ใหม่ล่าสุด';
      case BookingSort.soonest:
        return 'ใกล้ถึงก่อน';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<BookingSort>(
      onSelected: onChanged,
      itemBuilder: (context) => BookingSort.values
          .map((v) => PopupMenuItem(value: v, child: Text(_label(v))))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE9E9EB)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D0A0D12),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _label(value),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.eerieBlack),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final PropertyModel? property;

  const _BookingCard({required this.booking, required this.property});

  String _formatPrice(int? price) {
    if (price == null) return '-';
    return NumberFormat('#,###').format(price);
  }

  String _formatArea(double? sqm) {
    if (sqm == null) return '-';
    final sqWah = sqm * 0.25;
    return '${sqm.toStringAsFixed(1)} ตร.ม. | ${sqWah.toStringAsFixed(1)} ตร.ว.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = property?.name ?? 'Property #${booking.propertyId}';
    final location = property?.location ?? '-';
    final price = property?.price;
    final area = property?.area;
    final compatibility = property?.compatibility ?? 0.0;

    final dateTime = _tryParseDateTime(booking);
    final timeLabel = dateTime != null
        ? 'เวลานัด: ${DateFormat('d MMM', 'th').format(dateTime)}, ${DateFormat('HH:mm').format(dateTime)} น.'
        : 'เวลานัด: ${booking.ymd}, ${booking.time}';

    final statusBadge = _statusBadge(context, booking, timeLabel);

    return Container(
      width: 315,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0A0D12),
            blurRadius: 24,
            offset: Offset(0, 20),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 200,
            child: _PropertyImage(imageUrl: property?.imageUrl),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/level1FengshuiActive.png',
                          width: 42,
                          height: 42,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ความเข้ากัน',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: const Color(0xFFA4A7AE),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${compatibility.toStringAsFixed(1)}%',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: AppColors.jungleGreen,
                                fontWeight: FontWeight.w600,
                                fontSize: 30,
                                height: 38 / 30,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: AppColors.eerieBlack,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '฿${_formatPrice(price)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppColors.alizarinCrimson,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatArea(area),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFA4A7AE),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFA4A7AE),
                      ),
                    ),
                    const SizedBox(height: 16),
                    statusBadge,
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 44,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: booking.id == null
                            ? null
                            : () => context.push('/booking/${booking.id}/chat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.jungleGreen,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: Text(
                          'แชทกับเรา',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 44,
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF717680),
                          side: const BorderSide(color: Color(0xFFE9E9EB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'ยกเลิกนัด',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFD5D6D9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _tryParseDateTime(Booking b) {
    try {
      final date = DateTime.tryParse(b.ymd);
      if (date == null) return null;
      final parts = b.time.split(':');
      final h = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
      final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      return DateTime(date.year, date.month, date.day, h, m);
    } catch (_) {
      return null;
    }
  }

  Widget _statusBadge(BuildContext context, Booking booking, String timeLabel) {
    // Minimal mapping to resemble HTML:
    // - pending => "กำลังนัดหมาย" (orange)
    // - confirmed => show time in blue badge
    // - cancelled => show time in red badge
    switch (booking.status) {
      case BookingStatus.pending:
        return Column(
          children: [
            _pill(
              context,
              bg: const Color(0xFFF3F3FF),
              dot: const Color(0xFF7959F8),
              text: 'จองเบอร์: -',
              textColor: const Color(0xFF5925DB),
            ),
            const SizedBox(height: 8),
            _pill(
              context,
              bg: const Color(0xFFFFF9EB),
              dot: const Color(0xFFF78F08),
              text: 'กำลังนัดหมาย',
              textColor: const Color(0xFFB54707),
            ),
          ],
        );
      case BookingStatus.confirmed:
        return Column(
          children: [
            _pill(
              context,
              bg: const Color(0xFFF3F3FF),
              dot: const Color(0xFF7959F8),
              text: 'จองเบอร์: -',
              textColor: const Color(0xFF5925DB),
            ),
            const SizedBox(height: 8),
            _pill(
              context,
              bg: const Color(0xFFEFF8FF),
              dot: const Color(0xFF2E90FA),
              text: timeLabel,
              textColor: const Color(0xFF175CD3),
            ),
          ],
        );
      case BookingStatus.cancelled:
        return _pill(
          context,
          bg: const Color(0xFFFEF1F2),
          dot: const Color(0xFFF53D68),
          text: timeLabel,
          textColor: const Color(0xFFC00F47),
        );
    }
  }

  Widget _pill(
    BuildContext context, {
    required Color bg,
    required Color dot,
    required String text,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dot,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyImage extends StatelessWidget {
  final String? imageUrl;

  const _PropertyImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return Container(color: const Color(0xFFE9E9EB));
    }
    if (url.startsWith('assets/')) {
      return Image.asset(url, fit: BoxFit.cover);
    }
    return Image.network(url, fit: BoxFit.cover);
  }
}
