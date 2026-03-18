import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/core/enums/booking_attendance_status.dart';
import 'package:youragent/core/enums/booking_status.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/booking.dart';
import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/features/property/widgets/property_image_carousel.dart';
import 'package:youragent/features/calendar/utils/booking_confirm_flow_ui.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/utils/app_utils.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:youragent/widgets/map/map_view.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import 'package:youragent/widgets/modals/app_confirmation_bottom_sheet.dart';
import 'package:youragent/widgets/modals/app_call_bottom_sheet.dart';

class BookingDetailScreen extends StatefulWidget {
  final int bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  bool _isLoading = true;
  Booking? _booking;
  String? _error;
  final _bookingApiService = DependencyInjection.bookingApiService;

  @override
  void initState() {
    super.initState();
    _fetchBookingDetail();
  }

  Future<void> _fetchBookingDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final booking = await _bookingApiService.getBookingById(widget.bookingId);
      setState(() {
        _booking = booking;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateStatus(int status) async {
    try {
      await StatusDialog.showLoadingWhile(
        context: context,
        operation: () =>
            _bookingApiService.updateBookingStatus(widget.bookingId, status),
      );

      if (mounted) {
        StatusDialog.showSuccess(
          context: context,
          title: AppLocalizations.of(context).success,
          message: AppLocalizations.of(context).calendar_success_update,
        );
        _fetchBookingDetail();
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

  Future<void> _confirmAppointment() async {
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
              final result = await _bookingApiService.updateAttendanceStatus(
                id: widget.bookingId,
                status: BookingAttendanceStatus.confirmedOnDate,
              );
              if (!mounted) return;
              StatusDialog.showSuccess(
                context: context,
                title: l10n.successTitle,
                message: result.statusLabel ?? result.message ?? '',
              );
            },
          );
          if (!mounted) return;
          _fetchBookingDetail();
        } catch (e) {
          if (!mounted) return;
          StatusDialog.showError(
            context: context,
            title: l10n.errorOccurredTitle,
            message: e.toString(),
          );
        }
      },
    );
  }

  Future<void> _startTravel(Booking booking) async {
    final l10n = AppLocalizations.of(context);
    AppConfirmationBottomSheet.show(
      context: context,
      title: l10n.booking_confirm_traveling_title,
      description: l10n.booking_confirm_traveling_desc,
      confirmLabel: l10n.booking_start_traveling,
      onConfirm: () async {
        try {
          await StatusDialog.showLoadingWhile(
            context: context,
            operation: () async {
              if (booking.attendance?.seller?.confirmedOnDateAt == null) {
                await _bookingApiService.updateAttendanceStatus(
                  id: widget.bookingId,
                  status: BookingAttendanceStatus.confirmedOnDate,
                );
              }
              await _bookingApiService.updateAttendanceStatus(
                id: widget.bookingId,
                status: BookingAttendanceStatus.traveling,
              );
            },
          );
          if (!mounted) return;
          StatusDialog.showSuccess(
            context: context,
            title: l10n.successTitle,
            message: l10n.booking_start_traveling,
          );
          _fetchBookingDetail();
          context.push('/agent/bookings/${booking.id}/route');
        } catch (e) {
          if (!mounted) return;
          StatusDialog.showError(
            context: context,
            title: l10n.errorOccurredTitle,
            message: e.toString(),
          );
        }
      },
    );
  }

  Future<void> _arrived() async {
    final l10n = AppLocalizations.of(context);
    AppConfirmationBottomSheet.show(
      context: context,
      title: l10n.booking_confirm_arrived_title,
      description: l10n.booking_confirm_arrived_desc,
      confirmLabel: l10n.calendar_status_arrived,
      onConfirm: () async {
        try {
          await StatusDialog.showLoadingWhile(
            context: context,
            operation: () async {
              final result = await _bookingApiService.updateAttendanceStatus(
                id: widget.bookingId,
                status: BookingAttendanceStatus.arrived,
              );
              if (!mounted) return;
              StatusDialog.showSuccess(
                context: context,
                title: l10n.successTitle,
                message: result.statusLabel ?? result.message ?? '',
              );
            },
          );
          if (!mounted) return;
          _fetchBookingDetail();
        } catch (e) {
          if (!mounted) return;
          StatusDialog.showError(
            context: context,
            title: l10n.errorOccurredTitle,
            message: e.toString(),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
        body: const Center(
          child: SpinKitFadingCircle(color: AppColors.primary, size: 32),
        ),
      );
    }

    if (_error != null || _booking == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.supportRedDeep,
              ),
              const SizedBox(height: 16),
              Text(_error ?? AppLocalizations.of(context).booking_not_found),
              const SizedBox(height: 16),
              AppButton(
                width: 120,
                text: AppLocalizations.of(context).booking_retry,
                style: AppButtonStyle.primary,
                onPressed: _fetchBookingDetail,
              ),
            ],
          ),
        ),
      );
    }

    final booking = _booking!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [_buildContent(booking), _buildBottomBar(context, booking)],
      ),
    );
  }

  Widget _buildContent(Booking booking) {
    final property = booking.property;
    final imageUrls =
        property?.images.map((e) => e.url).whereType<String>().toList() ?? [];

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Image Carousel & Info Card Overlap
          Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                height: 280,
                child: PropertyImageCarousel(
                  isFullScreen: true,
                  imageUrls: imageUrls,
                  height: 280,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: -108,
                child: _buildMainInfoCard(booking),
              ),
            ],
          ),

          const SizedBox(height: 148),
          // 3. Client Section
          // _buildClientSection(booking),
          // const SizedBox(height: 32),

          // 4. Booking Details Section
          _buildBookingDetailsSection(booking),

          // 5. Property Physical Details
          // _buildPropertyDetailsSection(booking),
          const SizedBox(height: 32),

          // 6. Location Section
          _buildLocationSection(booking),
          const SizedBox(height: 64),
        ],
      ),
    );
  }

  Widget _buildMainInfoCard(Booking booking) {
    final property = booking.property;
    final isTh = Localizations.localeOf(context).languageCode == 'th';
    final devName = isTh
        ? property?.developerNameTh
        : property?.developerNameEn;

    String? displayProjectName;
    if (property?.propertyType == PropertyType.condo) {
      displayProjectName = isTh
          ? property?.condoProjectNameTh
          : property?.condoProjectNameEn;
    } else {
      displayProjectName = property?.villageName;
    }

    String? headerDisplayInfo;
    if (devName != null && displayProjectName != null) {
      headerDisplayInfo = '$devName • $displayProjectName';
    } else if (displayProjectName != null) {
      headerDisplayInfo = displayProjectName;
    } else if (devName != null) {
      headerDisplayInfo = devName;
    }

    BadgeColor badgeColor = BadgeColor.default_;

    switch (booking.status) {
      case BookingStatus.pending:
        badgeColor = BadgeColor.yellow;
        break;
      case BookingStatus.confirm:
      case BookingStatus.closeDeal:
        badgeColor = BadgeColor.green;
        break;
      case BookingStatus.reject:
      case BookingStatus.cancelled:
        badgeColor = BadgeColor.red;
        break;
      case BookingStatus.expired:
        badgeColor = BadgeColor.orange;
        break;
      case BookingStatus.met:
        badgeColor = BadgeColor.purple;
        break;
      case BookingStatus.offer:
      case BookingStatus.contract:
        badgeColor = BadgeColor.blue;
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.baseLightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (property != null)
            Text(
              AppUtils.generatePropertyCode(property),
              style: GoogleFonts.anuphan(
                color: AppColors.baseGrey,
                fontSize: 12,
              ),
            ),
          const SizedBox(height: 6),
          Text(
            property?.title ??
                property?.name ??
                AppLocalizations.of(context).booking_unspecified_property,
            style: GoogleFonts.anuphan(
              color: AppColors.baseBlack,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (headerDisplayInfo != null) ...[
            const SizedBox(height: 6),
            Text(
              headerDisplayInfo,
              style: GoogleFonts.anuphan(
                color: AppColors.baseBlack,
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (booking.status == BookingStatus.confirm) ...[
            Builder(
              builder: (context) {
                final ui = computeAgentConfirmFlowUi(
                  booking: booking,
                  l10n: AppLocalizations.of(context),
                  now: DateTime.now(),
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppBadge(
                      label: ui.badgeLabel,
                      color: ui.badgeColor,
                      style: BadgeStyle.dot,
                    ),
                    if (ui.statusLine != null && ui.statusLine!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        ui.statusLine!,
                        style: GoogleFonts.anuphan(
                          color: AppColors.baseDarkGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ] else
            AppBadge(
              label: booking.statusLabel,
              color: badgeColor,
              style: BadgeStyle.dot,
            ),
        ],
      ),
    );
  }

  Widget _buildBookingDetailsSection(Booking booking) {
    final buyer = booking.buyer;

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
          displayDate = '${formatter.format(dt)} $thaiYear';
        } else {
          final formatter = DateFormat('d MMM yyyy', 'en');
          displayDate = formatter.format(dt);
        }
      } else {
        displayDate = booking.ymd;
      }
    } catch (_) {
      displayDate = booking.ymd;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            title: AppLocalizations.of(context).booking_detail_title,
            svgIcon: 'assets/icons/clock.svg',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            label: AppLocalizations.of(context).booking_client,
            value: buyer?.name ?? '-',
          ),
          _buildInfoRow(
            label: AppLocalizations.of(context).booking_date,
            value: displayDate,
          ),
          _buildInfoRow(
            label: AppLocalizations.of(context).booking_time,
            value:
                '${booking.time} ${AppLocalizations.of(context).now.contains('น') ? 'น.' : ''}',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({required String title, required String svgIcon}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: AppColors.baseLightGrey),
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            svgIcon,
            width: 18,
            height: 18,
            colorFilter: const ColorFilter.mode(
              AppColors.baseBlack,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.anuphan(
              color: AppColors.baseBlack,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.anuphan(
                color: AppColors.baseDarkGrey,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.anuphan(
                color: const Color(0xFF181D27),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(Booking booking) {
    final property = booking.property;
    final completeAddress =
        property?.formattedAddressTh ??
        [
          property?.address,
          property?.subdistrict,
          property?.district,
          property?.city,
          property?.postalCode,
        ].whereType<String>().where((e) => e.isNotEmpty).join(' ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).booking_location,
            style: GoogleFonts.anuphan(
              color: AppColors.baseDarkGrey,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (completeAddress.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              completeAddress,
              style: GoogleFonts.anuphan(
                color: AppColors.baseBlack,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
          ],
          if (property != null &&
              property.latitude != null &&
              property.longitude != null) ...[
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: MapView(
                properties: [property],
                height: 200,
                initialLocation: LatLng(
                  property.latitude!,
                  property.longitude!,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, Booking booking) {
    final l10n = AppLocalizations.of(context);
    Widget? actionButton;

    // if (booking.status == BookingStatus.pending) {
    //   actionButton = Row(
    //     children: [
    //       Expanded(
    //         child: AppButton(
    //           text: AppLocalizations.of(context).calendar_cancel_label,
    //           style: AppButtonStyle.outline,
    //           onPressed: () {
    //             AppConfirmationBottomSheet.show(
    //               context: context,
    //               title: AppLocalizations.of(
    //                 context,
    //               ).calendar_confirm_cancel_title,
    //               description: AppLocalizations.of(
    //                 context,
    //               ).calendar_confirm_cancel_desc,
    //               confirmLabel: AppLocalizations.of(
    //                 context,
    //               ).calendar_confirm_label,
    //               style: ConfirmationStyle.destructive,
    //               onConfirm: () => _updateStatus(BookingStatus.reject.value),
    //             );
    //           },
    //         ),
    //       ),
    //       const SizedBox(width: 12),
    //       Expanded(
    //         child: AppButton(
    //           text: AppLocalizations.of(context).booking_confirm_booking,
    //           style: AppButtonStyle.primary,
    //           onPressed: () {
    //             AppConfirmationBottomSheet.show(
    //               context: context,
    //               title: AppLocalizations.of(
    //                 context,
    //               ).booking_confirm_booking_title,
    //               description: AppLocalizations.of(
    //                 context,
    //               ).booking_confirm_booking_desc,
    //               confirmLabel: AppLocalizations.of(
    //                 context,
    //               ).calendar_confirm_label,
    //               onConfirm: () => _updateStatus(BookingStatus.confirm.value),
    //             );
    //           },
    //         ),
    //       ),
    //     ],
    //   );
    // } else if (booking.status == BookingStatus.confirm) {
    //   actionButton = AppButton(
    //     width: double.infinity,
    //     text: AppLocalizations.of(context).booking_start_traveling,
    //     style: AppButtonStyle.primary,
    //     onPressed: () {
    //       AppConfirmationBottomSheet.show(
    //         context: context,
    //         title: AppLocalizations.of(context).booking_confirm_traveling_title,
    //         description: AppLocalizations.of(
    //           context,
    //         ).booking_confirm_traveling_desc,
    //         confirmLabel: AppLocalizations.of(context).booking_start_traveling,
    //         onConfirm: () => _updateStatus(BookingStatus.met.value),
    //       );
    //     },
    //   );
    // }
    // else if (booking.status == BookingStatus.met) {
    //   actionButton = AppButton(
    //     width: double.infinity,
    //     text: AppLocalizations.of(context).booking_status_arrived_client,
    //     style: AppButtonStyle.primary,
    //     onPressed: () {
    //       AppConfirmationBottomSheet.show(
    //         context: context,
    //         title: AppLocalizations.of(context).booking_confirm_arrived_title,
    //         description: AppLocalizations.of(
    //           context,
    //         ).booking_confirm_arrived_desc,
    //         confirmLabel: l10n.booking_status_arrived_client,
    //         onConfirm: () => _updateStatus(BookingStatus.offer.value),
    //       );
    //     },
    //   );
    // } else if (booking.status == BookingStatus.offer) {
    //   actionButton = AppButton(
    //     width: double.infinity,
    //     text: l10n.booking_finish_work,
    //     style: AppButtonStyle.primary,
    //     onPressed: () {
    //       AppConfirmationBottomSheet.show(
    //         context: context,
    //         title: l10n.booking_confirm_finish_title,
    //         description: l10n.booking_confirm_finish_desc,
    //         confirmLabel: l10n.booking_finish_work,
    //         onConfirm: () => _updateStatus(BookingStatus.contract.value),
    //       );
    //     },
    //   );
    // }

    if (booking.status == BookingStatus.pending) {
      actionButton = AppButton(
        width: double.infinity,
        text: AppLocalizations.of(context).calendar_cancel_label,
        style: AppButtonStyle.outline,
        onPressed: () {
          AppConfirmationBottomSheet.show(
            context: context,
            title: AppLocalizations.of(context).calendar_confirm_cancel_title,
            description: AppLocalizations.of(
              context,
            ).calendar_confirm_cancel_desc,
            confirmLabel: AppLocalizations.of(context).calendar_confirm_label,
            style: ConfirmationStyle.destructive,
            onConfirm: () => _updateStatus(BookingStatus.reject.value),
          );
        },
      );
    } else if (booking.status == BookingStatus.confirm) {
      final sellerAttendance = booking.attendance?.seller;
      final buyerAttendance = booking.attendance?.buyer;

      final sellerAllAttendanceCompleted =
          sellerAttendance?.confirmedOnDateAt != null &&
          sellerAttendance?.travelingAt != null &&
          sellerAttendance?.arrivedAt != null;
      if (sellerAllAttendanceCompleted) {
        final phone = booking.buyer?.phone?.trim() ?? '';
        actionButton = Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.baseLightGrey),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SvgPicture.asset(
                    'assets/icons/chevron-left.svg',
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      AppColors.baseDarkGrey,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppButton(
                width: double.infinity,
                text: l10n.calendar_history_contact_button,
                style: AppButtonStyle.outline,
                onPressed: phone.isEmpty
                    ? null
                    : () {
                        AppCallBottomSheet.show(
                          context: context,
                          options: [
                            CallOption(
                              label: booking.buyer?.name ?? '',
                              phone: phone,
                            ),
                          ],
                        );
                      },
              ),
            ),
          ],
        );
      } else {
        final sellerTraveling =
            sellerAttendance?.travelingAt != null &&
            sellerAttendance?.arrivedAt == null;
        final sellerArrived = sellerAttendance?.arrivedAt != null;

        DateTime? appointmentDate;
        try {
          final ymd = booking.ymd;
          if (ymd.length == 8) {
            final year = int.parse(ymd.substring(0, 4));
            final month = int.parse(ymd.substring(4, 6));
            final day = int.parse(ymd.substring(6, 8));
            appointmentDate = DateTime(year, month, day);
          }
        } catch (_) {}

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final isNotYetAppointmentDay = appointmentDate?.isAfter(today) ?? false;

        final sellerConfirmed = sellerAttendance?.confirmedOnDateAt != null;
        final buyerConfirmed = buyerAttendance?.confirmedOnDateAt != null;

        void showCancelConfirm() {
          AppConfirmationBottomSheet.show(
            context: context,
            title: l10n.calendar_confirm_cancel_title,
            description: l10n.calendar_confirm_cancel_desc,
            confirmLabel: l10n.calendar_confirm_label,
            style: ConfirmationStyle.destructive,
            onConfirm: () => _updateStatus(BookingStatus.reject.value),
          );
        }

        if (!sellerConfirmed && !buyerConfirmed && isNotYetAppointmentDay) {
          actionButton = null;
        } else if (!sellerConfirmed) {
          actionButton = AppButton(
            width: double.infinity,
            text: l10n.booking_confirm_booking,
            style: AppButtonStyle.primary,
            onPressed: _confirmAppointment,
          );
        } else if (sellerConfirmed && !buyerConfirmed) {
          actionButton = Row(
            children: [
              Expanded(
                child: AppButton(
                  text: l10n.calendar_cancel_label,
                  style: AppButtonStyle.outline,
                  onPressed: showCancelConfirm,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: l10n.booking_start_traveling,
                  style: AppButtonStyle.primary,
                  onPressed: () => _startTravel(booking),
                ),
              ),
            ],
          );
        } else if (sellerTraveling && !sellerArrived) {
          actionButton = Row(
            children: [
              Expanded(
                child: AppButton(
                  text: l10n.booking_route_map_button,
                  style: AppButtonStyle.outline,
                  onPressed: () =>
                      context.push('/agent/bookings/${booking.id}/route'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: l10n.calendar_status_arrived,
                  style: AppButtonStyle.primary,
                  onPressed: _arrived,
                ),
              ),
            ],
          );
        } else {
          final buyerTraveling =
              buyerAttendance?.travelingAt != null &&
              buyerAttendance?.arrivedAt == null;
          final buyerArrived = buyerAttendance?.arrivedAt != null;
          if (buyerArrived || buyerTraveling) {
            actionButton = AppButton(
              width: double.infinity,
              text: l10n.calendar_status_arrived,
              style: AppButtonStyle.primary,
              onPressed: _arrived,
            );
          } else {
            actionButton = AppButton(
              width: double.infinity,
              text: l10n.booking_start_traveling,
              style: AppButtonStyle.primary,
              onPressed: () => _startTravel(booking),
            );
          }
        }
      }
    }

    if (actionButton == null) return const SizedBox.shrink();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: actionButton,
      ),
    );
  }
}
