import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/booking.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;

  // Additional callbacks will be added later for button actions
  final VoidCallback? onCoAgentTap;
  final VoidCallback? onPrimaryActionTap;

  const BookingCard({
    super.key,
    required this.booking,
    this.onCoAgentTap,
    this.onPrimaryActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildStatusAndSubtext(),
          _buildWarningSection(),
          const SizedBox(height: 16),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final locationInfo = [
      booking.property?.title ?? booking.property?.name,
      booking.property?.subdistrict,
      booking.property?.district,
      booking.property?.city,
    ].where((e) => e != null && e.isNotEmpty).join(' ');

    final buyerName = booking.buyer?.name ?? 'ไม่ระบุชื่อ';

    // Format Date: e.g. 20251127 -> 27 พ.ย. 2568
    String displayDate = '';
    try {
      final ymd = booking.ymd;
      if (ymd.length == 8) {
        final year = int.parse(ymd.substring(0, 4));
        final month = int.parse(ymd.substring(4, 6));
        final day = int.parse(ymd.substring(6, 8));
        final dt = DateTime(year, month, day);
        final thaiYear = year + 543;
        final formatter = DateFormat('d MMM', 'th');
        displayDate = '${formatter.format(dt)} $thaiYear, ${booking.time} น.';
      } else {
        displayDate = '${booking.ymd}, ${booking.time} น.';
      }
    } catch (_) {
      displayDate = '${booking.ymd}, ${booking.time} น.';
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
                      locationInfo.isEmpty ? 'ไม่ระบุตำแหน่ง' : locationInfo,
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

  Widget _buildStatusAndSubtext() {
    String statusLabel = 'ลูกค้ารอยืนยัน';
    BadgeColor badgeColor = BadgeColor.blue;
    String subtext = '';

    if (booking.status == 1) {
      statusLabel = 'ยืนยันนัดแล้ว';
      badgeColor = BadgeColor.green;
      subtext = 'ผู้จองเข้าชมบ้านยังไม่เริ่มเดินทาง';
    } else if (booking.status == 2) {
      statusLabel = 'ยกเลิกนัดหมาย';
      badgeColor = BadgeColor.red;
      subtext = 'เหตุผล : ผู้จองเข้าชมไม่มาตามนัด';
    } else if (booking.status == 3) {
      statusLabel = 'เสร็จสิ้น';
      badgeColor = BadgeColor.green;
      subtext = 'เวลา 11:55 - 12:30 --- ระยะเวลา 35 นาที';
    } else if (booking.status == 4) {
      statusLabel = 'ลูกค้ากำลังเดินทาง';
      badgeColor = BadgeColor.blue;
      subtext = 'เริ่มเดินทาง 11:20 --- จะถึงตอน 11:55';
    } else {
      statusLabel = 'ลูกค้ารอยืนยัน';
      badgeColor = BadgeColor.blue;
      subtext = 'รอการยืนยันจากตัวแทน';
    }

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBadges.status(label: statusLabel, color: badgeColor),
          if (subtext.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subtext,
              style: GoogleFonts.anuphan(
                color: AppColors.baseDarkGrey,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWarningSection() {
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
            'คุณอาจจะไปถึงช้าประมาณ 10 นาที',
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
    if (booking.status == 0) {
      return Row(
        children: [
          Expanded(
            child: AppButton(
              height: 32,
              textSize: 12,
              text: 'ยกเลิกนัด',
              style: AppButtonStyle.outline,
              onPressed: () {
                StatusDialog.showDestructive(
                  context: context,
                  title: 'ยกเลิกนัดหมาย?',
                  message: 'คุณต้องการยกเลิกนัดหมายนี้หรือไม่?',
                  actionLabel: 'ยกเลิกนัด',
                  onAction: () {
                    // TODO: Dispatch event
                  },
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppButton(
              height: 32,
              textSize: 12,
              text: 'ยืนยันนัด',
              style: AppButtonStyle.primary,
              onPressed: () {
                StatusDialog.confirm(
                  context: context,
                  title: 'ยืนยันนัดหมาย?',
                  message: 'คุณต้องการยืนยันนัดหมายนี้หรือไม่?',
                  confirmLabel: 'ยืนยัน',
                  onConfirm: onPrimaryActionTap,
                );
              },
            ),
          ),
        ],
      );
    } else if (booking.status == 1) {
      return AppButton(
        width: double.infinity,
        height: 32,
        textSize: 12,
        text: 'เริ่มเดินทาง',
        style: AppButtonStyle.primary,
        onPressed: () {
          StatusDialog.confirm(
            context: context,
            title: 'เริ่มเดินทาง?',
            message: 'คุณกำลังเริ่มเดินทางไปหาลูกค้าใช่หรือไม่?',
            confirmLabel: 'เริ่มเดินทาง',
            onConfirm: onPrimaryActionTap,
          );
        },
      );
    } else if (booking.status == 4) {
      return AppButton(
        width: double.infinity,
        height: 32,
        textSize: 12,
        text: 'ถึงแล้ว',
        style: AppButtonStyle.primary,
        onPressed: () {
          StatusDialog.confirm(
            context: context,
            title: 'ถึงที่หมาย?',
            message: 'คุณถึงที่หมายแล้วใช่หรือไม่?',
            confirmLabel: 'ถึงแล้ว',
            onConfirm: onPrimaryActionTap,
          );
        },
      );
    } else if (booking.status == 3) {
      // Completed - optionally show Contact button if requested
      // For now, based on user input, we hide it or keep it simple.
      return AppButton(
        width: double.infinity,
        height: 32,
        textSize: 12,
        text: 'ติดต่อผู้จอง',
        style: AppButtonStyle.primary,
        onPressed: () {
          // TODO: Open contact info
        },
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
