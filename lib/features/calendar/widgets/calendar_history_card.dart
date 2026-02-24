import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/core/enums/booking_status.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/l10n/app_localizations.dart';

class CalendarHistoryCard extends StatelessWidget {
  final BookingStatus status;
  final String dateStr;
  final String propertyAddress;
  final String? imageUrl;
  final String visitorName;

  final String? appointmentDuration;
  final String? appointmentNote;
  final String? cancelReason;

  final VoidCallback? onContactTap;
  final VoidCallback? onTap;

  const CalendarHistoryCard({
    super.key,
    required this.status,
    required this.dateStr,
    required this.visitorName,
    required this.propertyAddress,
    this.imageUrl,
    this.appointmentDuration,
    this.appointmentNote,
    this.cancelReason,
    this.onContactTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: ShapeDecoration(
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: AppColors.baseOffWhite),
            borderRadius: BorderRadius.circular(16),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateStr,
                        style: GoogleFonts.anuphan(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.baseBlack,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/user.svg',
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(
                              AppColors.baseBlack,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              visitorName,
                              style: GoogleFonts.anuphan(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.baseBlack,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/map-pin.svg',
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(
                              AppColors.baseDarkGrey,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              propertyAddress,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.anuphan(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.baseDarkGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl != null && imageUrl!.isNotEmpty
                      ? Image.network(
                          imageUrl!,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => _placeholder(),
                        )
                      : _placeholder(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Status Badge
            _buildStatusBadge(context),
            const SizedBox(height: 16),
            // Additional Context
            if (status == BookingStatus.met) ...[
              if (appointmentDuration != null) ...[
                Text(
                  appointmentDuration!,
                  style: GoogleFonts.anuphan(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.baseDarkGrey,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (appointmentNote != null)
                Text(
                  AppLocalizations.of(
                    context,
                  ).calendar_history_personal_note(appointmentNote!),
                  style: GoogleFonts.anuphan(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.baseDarkGrey,
                  ),
                ),
            ] else if (status == BookingStatus.expired) ...[
              Text(
                AppLocalizations.of(context).calendar_history_expired_desc,
                style: GoogleFonts.anuphan(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.baseDarkGrey,
                ),
              ),
            ] else if (status == BookingStatus.cancelled) ...[
              Text(
                AppLocalizations.of(context).calendar_history_reason(
                  cancelReason ??
                      AppLocalizations.of(context).calendar_history_no_show,
                ),
                style: GoogleFonts.anuphan(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.baseDarkGrey,
                ),
              ),
            ],

            // Button
            if (onContactTap != null) ...[
              const SizedBox(height: 16),
              AppButton(
                iconPath: 'assets/icons/phone.svg',
                iconSize: 16,
                iconSpace: 16,
                width: double.infinity,
                text: AppLocalizations.of(
                  context,
                ).calendar_history_contact_button,
                textColor: AppColors.baseWhite,
                style: AppButtonStyle.primary,
                onPressed: onContactTap ?? () {},
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    BadgeColor bgColor;
    Color textColor;
    String label;

    switch (status) {
      case BookingStatus.pending:
        return const SizedBox.shrink();
      case BookingStatus.confirm:
        bgColor = BadgeColor.green;
        textColor = AppColors.supportGreenDark;
        label = AppLocalizations.of(context).calendar_status_confirmed;
        break;
      case BookingStatus.reject:
        bgColor = BadgeColor.red;
        textColor = AppColors.supportRedDark;
        label = AppLocalizations.of(context).calendar_history_reject;
        break;
      case BookingStatus.expired:
        bgColor = BadgeColor.orange;
        textColor = AppColors.supportOrangeDark;
        label = AppLocalizations.of(context).calendar_status_expired;
        break;
      case BookingStatus.cancelled:
        bgColor = BadgeColor.red;
        textColor = AppColors.supportRedDark;
        label = AppLocalizations.of(context).calendar_status_cancelled;
        break;
      case BookingStatus.met:
        bgColor = BadgeColor.green;
        textColor = AppColors.supportGreenDark;
        label = AppLocalizations.of(context).calendar_status_finished;
        break;
      case BookingStatus.traveling:
        bgColor = BadgeColor.blue;
        textColor = AppColors.supportBlueDeep;
        label = AppLocalizations.of(context).calendar_status_traveling;
        break;
      case BookingStatus.arrived:
        bgColor = BadgeColor.blue;
        textColor = AppColors.supportBlueDeep;
        label = AppLocalizations.of(context).calendar_status_arrived;
        break;
      case BookingStatus.offer:
        bgColor = BadgeColor.blue;
        textColor = AppColors.supportBlueDeep;
        label = AppLocalizations.of(context).calendar_status_offer;
        break;
      case BookingStatus.contract:
        bgColor = BadgeColor.orange;
        textColor = AppColors.supportOrangeDark;
        label = AppLocalizations.of(context).calendar_status_contract;
        break;
      case BookingStatus.closeDeal:
        bgColor = BadgeColor.green;
        textColor = AppColors.supportGreenDark;
        label = AppLocalizations.of(context).calendar_status_closed;
        break;
    }

    return AppBadge(
      label: label,
      style: BadgeStyle.dot,
      color: bgColor,
      customTextColor: textColor,
    );
  }

  Widget _placeholder() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.basePaleGrey,
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
