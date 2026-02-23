import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import 'package:youragent/widgets/buttons/app_button.dart';

/// Appointment confirmation status
enum AppointmentStatus { confirmed, pending }

/// Travel / journey status
enum TravelStatus { arriving, notStarted }

class CalendarAppointmentCard extends StatefulWidget {
  final String propertyTitle;
  final String propertyAddress;
  final String? imageUrl;
  final String visitorName;
  final String dateTime;

  final AppointmentStatus confirmStatus;
  final TravelStatus travelStatus;

  /// Countdown text shown when [travelStatus] is [TravelStatus.arriving],
  /// e.g. "07:55 น."
  final String? arrivingIn;

  /// Initially expanded or collapsed
  final bool initiallyExpanded;

  final VoidCallback? onSecondaryAction; // ต้องการ Co-agent / ยกเลิกนัด
  final VoidCallback? onPrimaryAction; // เริ่มเดินทาง / ยืนยันนัด

  const CalendarAppointmentCard({
    super.key,
    required this.propertyTitle,
    required this.propertyAddress,
    required this.visitorName,
    required this.dateTime,
    this.imageUrl,
    this.confirmStatus = AppointmentStatus.pending,
    this.travelStatus = TravelStatus.notStarted,
    this.arrivingIn,
    this.initiallyExpanded = false,
    this.onSecondaryAction,
    this.onPrimaryAction,
  });

  @override
  State<CalendarAppointmentCard> createState() =>
      _CalendarAppointmentCardState();
}

class _CalendarAppointmentCardState extends State<CalendarAppointmentCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _animController;
  late final Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: _isExpanded ? 1.0 : 0.0,
    );
    _expandAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9EAEB), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top: title + image ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.propertyTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.anuphan(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.baseBlack,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.propertyAddress,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.anuphan(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.baseDarkGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: widget.imageUrl != null
                      ? Image.network(
                          widget.imageUrl!,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => _placeholder(),
                        )
                      : _placeholder(),
                ),
              ],
            ),
          ),

          // ── Expandable details section ───────────────────────────────
          SizeTransition(
            sizeFactor: _expandAnim,
            axisAlignment: -1,
            child: Column(
              children: [
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF2F4F7),
                ),
                // Visitor + date row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _InfoColumn(
                          label: 'ผู้จองเข้าชม',
                          value: widget.visitorName,
                        ),
                      ),
                      Expanded(
                        child: _InfoColumn(
                          label: 'วันที่และเวลา',
                          value: widget.dateTime,
                          crossAxisAlignment: CrossAxisAlignment.end,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badges
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      _buildConfirmBadge(),
                      const SizedBox(width: 8),
                      _buildTravelBadge(),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // ── Action buttons ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Expand / collapse chevron
                GestureDetector(
                  onTap: _toggle,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE9EAEB),
                        width: 1,
                      ),
                    ),
                    child: AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/chevron-down.svg',
                          width: 12,
                          height: 12,
                          fit: BoxFit.scaleDown,
                          colorFilter: ColorFilter.mode(
                            AppColors.baseDarkGrey,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Secondary action
                Expanded(
                  child: AppButton(
                    text: widget.confirmStatus == AppointmentStatus.confirmed
                        ? 'ต้องการ Co-agent'
                        : 'ยกเลิกนัด',
                    style: AppButtonStyle.outline,
                    height: 32,
                    textSize: 12,
                    onPressed: widget.onSecondaryAction,
                  ),
                ),
                const SizedBox(width: 8),
                // Primary action
                Expanded(
                  child: AppButton(
                    text: widget.confirmStatus == AppointmentStatus.confirmed
                        ? 'เริ่มเดินทาง'
                        : 'ยืนยันนัด',
                    style: AppButtonStyle.primary,
                    height: 32,
                    textSize: 12,
                    backgroundColor:
                        widget.confirmStatus == AppointmentStatus.confirmed
                        ? AppColors.supportGreenDark
                        : AppColors.primary,
                    onPressed: widget.onPrimaryAction,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmBadge() {
    if (widget.confirmStatus == AppointmentStatus.confirmed) {
      return AppBadge(
        label: 'ยืนยันแล้ว',
        style: BadgeStyle.done,
        customBackgroundColor: const Color(0xFFDCFCE7),
        customTextColor: const Color(0xFF16A34A),
        fontSize: 12,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      );
    }
    return AppBadge(
      label: 'รอการยืนยัน',
      customBackgroundColor: const Color(0xFFF2F4F7),
      customTextColor: const Color(0xFF737373),
      fontSize: 12,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    );
  }

  Widget _buildTravelBadge() {
    if (widget.travelStatus == TravelStatus.arriving &&
        widget.arrivingIn != null) {
      return AppBadge(
        label: 'จะถึง ${widget.arrivingIn}',
        customBackgroundColor: const Color(0xFFEFF6FF),
        customTextColor: const Color(0xFF2563EB),
        fontSize: 12,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      );
    }
    return AppBadge(
      label: 'ยังไม่เริ่มเดินทาง',
      customBackgroundColor: const Color(0xFFF2F4F7),
      customTextColor: const Color(0xFF737373),
      fontSize: 12,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.home_outlined,
        color: Color(0xFFCBD0D8),
        size: 28,
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final CrossAxisAlignment crossAxisAlignment;

  const _InfoColumn({
    required this.label,
    required this.value,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: GoogleFonts.anuphan(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: AppColors.baseDarkGrey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.anuphan(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.baseBlack,
          ),
        ),
      ],
    );
  }
}
