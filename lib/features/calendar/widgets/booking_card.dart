import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:youragent/core/enums/booking_status.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/booking.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/widgets/modals/app_confirmation_bottom_sheet.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;

  // Additional callbacks will be added later for button actions
  final VoidCallback? onCoAgentTap;
  final Function(int status)? onStatusAction;

  const BookingCard({
    super.key,
    required this.booking,
    this.onCoAgentTap,
    this.onStatusAction,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/booking/${booking.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: AppColors.baseWhite,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: AppColors.baseOffWhite),
            borderRadius: BorderRadius.circular(12),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 16,
              offset: Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildStatusAndSubtext(context),
            _buildWarningSection(context),
            const SizedBox(height: 16),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locationInfo = [
      booking.property?.title ?? booking.property?.name,
      booking.property?.subdistrict,
      booking.property?.district,
      booking.property?.city,
    ].where((e) => e != null && e.isNotEmpty).join(' ');

    final buyerName = booking.buyer?.name ?? l10n.calendar_unspecified_name;

    // Format Date: e.g. 20251127 -> 27 พ.ย. 2568
    String displayDate = '';
    try {
      final ymd = booking.ymd;
      if (ymd.length == 8) {
        final year = int.parse(ymd.substring(0, 4));
        final month = int.parse(ymd.substring(4, 6));
        final day = int.parse(ymd.substring(6, 8));
        final dt = DateTime(year, month, day);

        final locale = Localizations.localeOf(context).languageCode;
        if (locale == 'th') {
          final thaiYear = year + 543;
          final formatter = DateFormat('d MMM', 'th');
          displayDate =
              '${formatter.format(dt)} $thaiYear, ${booking.time} ${l10n.now.contains('น') ? 'น.' : ''}';
        } else {
          final formatter = DateFormat('d MMM yyyy', 'en');
          displayDate = '${formatter.format(dt)}, ${booking.time}';
        }
      } else {
        displayDate = '${booking.ymd}, ${booking.time}';
      }
    } catch (_) {
      displayDate = '${booking.ymd}, ${booking.time}';
    }

    final imageUrl = booking.property?.imageUrl;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayDate,
                style: GoogleFonts.anuphan(
                  color: AppColors.baseBlack,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/user.svg',
                    width: 12,
                    height: 12,
                    colorFilter: const ColorFilter.mode(
                      AppColors.baseBlack,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    buyerName,
                    style: GoogleFonts.anuphan(
                      color: AppColors.baseBlack,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: SvgPicture.asset(
                      'assets/icons/map-pin.svg',
                      width: 12,
                      height: 12,
                      colorFilter: const ColorFilter.mode(
                        AppColors.baseDarkGrey,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      locationInfo.isEmpty
                          ? l10n.calendar_unspecified_location
                          : locationInfo,
                      style: GoogleFonts.anuphan(
                        color: AppColors.baseDarkGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        CachedNetworkImage(
          imageUrl: imageUrl ?? '',
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          imageBuilder: (context, imageProvider) => Container(
            width: 70,
            height: 70,
            decoration: ShapeDecoration(
              color: AppColors.basePaleGrey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: Image(image: imageProvider, fit: BoxFit.cover),
          ),
          placeholder: (context, url) => Container(
            width: 70,
            height: 70,
            decoration: ShapeDecoration(
              color: AppColors.basePaleGrey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            width: 70,
            height: 70,
            decoration: ShapeDecoration(
              color: AppColors.basePaleGrey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SvgPicture.asset(
                'assets/icons/image.svg',
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  AppColors.baseGrey,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusAndSubtext(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String statusLabel = 'Unknown';
    BadgeColor badgeColor = BadgeColor.default_;

    switch (booking.status) {
      case BookingStatus.pending:
        return SizedBox.shrink();
      case BookingStatus.confirm:
        statusLabel = l10n.calendar_status_confirmed;
        badgeColor = BadgeColor.green;
        break;
      case BookingStatus.reject:
        statusLabel = l10n.calendar_status_cancelled;
        badgeColor = BadgeColor.red;
        break;
      case BookingStatus.met:
        statusLabel = l10n.calendar_status_finished;
        badgeColor = BadgeColor.green;
        break;
      case BookingStatus.traveling:
        statusLabel = l10n.calendar_status_traveling;
        badgeColor = BadgeColor.blue;
        break;
      case BookingStatus.arrived:
        statusLabel = l10n.calendar_status_arrived;
        badgeColor = BadgeColor.blue;
        break;
      case BookingStatus.offer:
        statusLabel = l10n.calendar_status_offer;
        badgeColor = BadgeColor.orange;
        break;
      case BookingStatus.contract:
        statusLabel = l10n.calendar_status_contract;
        badgeColor = BadgeColor.orange;
        break;
      case BookingStatus.closeDeal:
        statusLabel = l10n.calendar_status_closed;
        badgeColor = BadgeColor.green;
        break;
      case BookingStatus.expired:
        statusLabel = l10n.calendar_status_expired;
        badgeColor = BadgeColor.orange;
        break;
      case BookingStatus.cancelled:
        statusLabel = l10n.calendar_status_cancelled;
        badgeColor = BadgeColor.red;
        break;
    }

    return AppBadges.status(label: statusLabel, color: badgeColor);
  }

  Widget _buildWarningSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Mocking delay warning for now. In reality, check booking data.
    final hasDelay =
        booking.timeUntilBookingSeconds != null &&
        booking.timeUntilBookingSeconds! < 0;

    if (!hasDelay) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: ShapeDecoration(
        color: AppColors.supportOrangeLight,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: AppColors.supportOrangeDark),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/alert-triangle.svg',
            width: 16,
            height: 16,
            colorFilter: const ColorFilter.mode(
              AppColors.supportOrangeDark,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.calendar_delay_warning(10),
            style: GoogleFonts.anuphan(
              color: AppColors.supportOrangeDark,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // if (booking.status == BookingStatus.pending) {
    //   return Row(
    //     children: [
    //       Expanded(
    //         child: AppButton(
    //           height: 32,
    //           textSize: 12,
    //           text: 'ยกเลิกนัด',
    //           style: AppButtonStyle.outline,
    //           onPressed: () {
    //             AppConfirmationBottomSheet.show(
    //               context: context,
    //               title: 'ยกเลิกนัดหมาย?',
    //               description: 'คุณต้องการยกเลิกนัดหมายนี้หรือไม่?',
    //               confirmLabel: 'ยกเลิกนัด',
    //               style: ConfirmationStyle.destructive,
    //               onConfirm: () =>
    //                   onStatusAction?.call(BookingStatus.reject.value),
    //             );
    //           },
    //         ),
    //       ),
    //       const SizedBox(width: 8),
    //       Expanded(
    //         child: AppButton(
    //           height: 32,
    //           textSize: 12,
    //           text: 'ยืนยันนัด',
    //           style: AppButtonStyle.primary,
    //           onPressed: () {
    //             AppConfirmationBottomSheet.show(
    //               context: context,
    //               title: 'ยืนยันนัดหมาย?',
    //               description: 'คุณต้องการยืนยันนัดหมายนี้หรือไม่?',
    //               confirmLabel: 'ยืนยัน',
    //               onConfirm: () =>
    //                   onStatusAction?.call(BookingStatus.confirm.value),
    //             );
    //           },
    //         ),
    //       ),
    //     ],
    //   );
    // } else if (booking.status == BookingStatus.confirm) {
    //   return Column(
    //     children: [
    //       AppButton(
    //         width: double.infinity,
    //         height: 32,
    //         textSize: 12,
    //         text: 'เริ่มเดินทาง',
    //         style: AppButtonStyle.primary,
    //         onPressed: () {
    //           AppConfirmationBottomSheet.show(
    //             context: context,
    //             title: 'เริ่มเดินทาง?',
    //             description: 'คุณกำลังเริ่มเดินทางไปหาลูกค้าใช่หรือไม่?',
    //             confirmLabel: 'เริ่มเดินทาง',
    //             onConfirm: () =>
    //                 onStatusAction?.call(BookingStatus.traveling.value),
    //           );
    //         },
    //       ),
    //       const SizedBox(height: 8),
    //       AppButton(
    //         width: double.infinity,
    //         height: 32,
    //         textSize: 12,
    //         text: 'ยกเลิกนัด',
    //         style: AppButtonStyle.outline,
    //         onPressed: () {
    //           AppConfirmationBottomSheet.show(
    //             context: context,
    //             title: 'ยกเลิกนัดหมาย?',
    //             description: 'คุณต้องการยกเลิกนัดหมายนี้หรือไม่?',
    //             confirmLabel: 'ยกเลิกนัด',
    //             style: ConfirmationStyle.destructive,
    //             onConfirm: () =>
    //                 onStatusAction?.call(BookingStatus.reject.value),
    //           );
    //         },
    //       ),
    //     ],
    //   );
    // } else if (booking.status == BookingStatus.traveling) {
    //   return AppButton(
    //     width: double.infinity,
    //     height: 32,
    //     textSize: 12,
    //     text: 'ถึงแล้ว',
    //     style: AppButtonStyle.primary,
    //     onPressed: () {
    //       AppConfirmationBottomSheet.show(
    //         context: context,
    //         title: 'ถึงที่หมาย?',
    //         description: 'คุณถึงที่หมายแล้วใช่หรือไม่?',
    //         confirmLabel: 'ถึงแล้ว',
    //         onConfirm: () => onStatusAction?.call(BookingStatus.arrived.value),
    //       );
    //     },
    //   );
    // } else if (booking.status == BookingStatus.arrived) {
    //   return AppButton(
    //     width: double.infinity,
    //     height: 32,
    //     textSize: 12,
    //     text: 'เสร็จงาน',
    //     style: AppButtonStyle.primary,
    //     onPressed: () {
    //       AppConfirmationBottomSheet.show(
    //         context: context,
    //         title: 'เสร็จสิ้นงาน?',
    //         description: 'คุณดำเนินการเข้าชมบ้านเสร็จสิ้นแล้วใช่หรือไม่?',
    //         confirmLabel: 'เสร็จงาน',
    //         onConfirm: () => onStatusAction?.call(BookingStatus.met.value),
    //       );
    //     },
    //   );
    // }

    if (booking.status == BookingStatus.confirm) {
      return AppButton(
        width: double.infinity,
        height: 32,
        textSize: 12,
        text: l10n.calendar_cancel_label,
        style: AppButtonStyle.outline,
        onPressed: () {
          AppConfirmationBottomSheet.show(
            context: context,
            title: l10n.calendar_confirm_cancel_title,
            description: l10n.calendar_confirm_cancel_desc,
            confirmLabel: l10n.calendar_confirm_label,
            style: ConfirmationStyle.destructive,
            onConfirm: () => onStatusAction?.call(2),
          );
        },
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
