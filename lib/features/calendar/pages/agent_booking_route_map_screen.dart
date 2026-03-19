import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youragent/core/config/app_config.dart';
import 'package:youragent/core/enums/booking_status.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/core/enums/booking_attendance_status.dart';
import 'package:youragent/domain/entities/booking.dart';
import 'package:youragent/features/calendar/utils/booking_confirm_flow_ui.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/services/booking_api_service.dart';
import 'package:youragent/utils/map_marker_utils.dart';
import 'package:youragent/utils/permission_helper.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:youragent/widgets/badges/app_badge.dart';

import '../../../core/di/dependency_injection.dart';

/// Agent route map screen: shows route from current location to booking property
/// with bottom sheet card (address, ETA, status, primary action).
class AgentBookingRouteMapScreen extends StatefulWidget {
  final int bookingId;

  const AgentBookingRouteMapScreen({super.key, required this.bookingId});

  @override
  State<AgentBookingRouteMapScreen> createState() =>
      _AgentBookingRouteMapScreenState();
}

class _AgentBookingRouteMapScreenState
    extends State<AgentBookingRouteMapScreen> {
  final BookingApiService _bookingApiService =
      DependencyInjection.bookingApiService;

  GoogleMapController? _mapController;
  Booking? _booking;
  TravelTimeResult? _travelTime;
  LatLng? _currentLatLng;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _loading = true;
  String? _error;
  Timer? _refreshTimer;
  bool _isFetchingRoute = false;
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _refreshLocation(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Widget _toolbarIconButton({
    required VoidCallback onPressed,
    required Widget icon,
    String? tooltip,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
        ),
        child: IconButton(onPressed: onPressed, icon: icon, tooltip: tooltip),
      ),
    );
  }

  Future<void> _loadInitial() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final booking = await _bookingApiService.getBookingById(widget.bookingId);
      if (!mounted) return;

      final position = await PermissionHelper.getCurrentPosition(context);
      if (!mounted) return;

      if (position == null) {
        setState(() {
          _booking = booking;
          _loading = false;
        });
        return;
      }

      final current = LatLng(position.latitude, position.longitude);
      final travel = await _bookingApiService.calculateTravelTime(
        id: widget.bookingId,
        currentLat: current.latitude,
        currentLng: current.longitude,
      );

      if (!mounted) return;

      setState(() {
        _booking = booking;
        _travelTime = travel;
        _currentLatLng = current;
        _loading = false;
      });

      await _buildMarkers();
      await _fetchRealRoute();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _refreshLocation() async {
    if (!mounted || _booking == null) return;
    try {
      final position = await PermissionHelper.getCurrentPosition(context);
      if (!mounted || position == null) return;

      final current = LatLng(position.latitude, position.longitude);
      final travel = await _bookingApiService.calculateTravelTime(
        id: widget.bookingId,
        currentLat: current.latitude,
        currentLng: current.longitude,
      );

      if (!mounted) return;
      setState(() {
        _currentLatLng = current;
        _travelTime = travel;
      });
      await _buildMarkers();
      await _fetchRealRoute();
    } catch (_) {
      // Silently ignore refresh errors
    }
  }

  LatLng? _destinationLatLng() {
    final booking = _booking;
    if (booking == null) return null;

    final property = booking.property;
    final destLat = property?.latitude;
    final destLng = property?.longitude;
    if (destLat == null || destLng == null) return null;
    return LatLng(destLat, destLng);
  }

  Future<void> _buildMarkers() async {
    final destination = _destinationLatLng();
    if (destination == null) return;

    final destinationIcon = await MapMarkerUtils.createCustomMarkerIcon();
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        icon: destinationIcon,
      ),
    };

    if (!mounted) return;
    setState(() => _markers = markers);
  }

  Future<void> _fetchRealRoute() async {
    if (_isFetchingRoute) return;
    final destination = _destinationLatLng();
    if (destination == null) return;

    final origin = _currentLatLng ?? destination;
    _isFetchingRoute = true;

    final polylinePoints = PolylinePoints();
    try {
      final result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: AppConfig.googleMapsApiKey,
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,
        ),
      );

      final points = result.points
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList(growable: false);

      if (!mounted) return;
      if (points.isNotEmpty) {
        setState(() {
          _polylines = {
            Polyline(
              polylineId: const PolylineId('real_route_border'),
              color: const Color(0xFF0029A2),
              width: 8,
              points: points,
            ),
            Polyline(
              polylineId: const PolylineId('real_route'),
              color: const Color(0xFF175CD3),
              width: 5,
              points: points,
              zIndex: 1,
            ),
          };
        });
        return;
      }
    } catch (_) {
      // ignore, will fallback below
    } finally {
      _isFetchingRoute = false;
    }

    if (!mounted) return;
    setState(() {
      _polylines = {
        Polyline(
          polylineId: const PolylineId('fallback_route_border'),
          color: const Color(0xFF0029A2),
          width: 8,
          points: [origin, destination],
        ),
        Polyline(
          polylineId: const PolylineId('fallback_route'),
          color: const Color(0xFF175CD3),
          width: 5,
          points: [origin, destination],
          zIndex: 1,
        ),
      };
    });
  }

  Future<void> _onArrived() async {
    final l10n = AppLocalizations.of(context);
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
      context.canPop() ? context.pop() : context.go('/calendar');
    } catch (e) {
      if (!mounted) return;
      StatusDialog.showError(
        context: context,
        title: l10n.errorOccurredTitle,
        message: e.toString(),
      );
    }
  }

  Future<void> _openExternalMaps() async {
    final property = _booking?.property;
    final lat = property?.latitude;
    final lng = property?.longitude;
    if (lat == null || lng == null) return;

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_loading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            l10n.booking_detail_title,
            style: GoogleFonts.anuphan(fontWeight: FontWeight.w600),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _booking == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            l10n.booking_detail_title,
            style: GoogleFonts.anuphan(fontWeight: FontWeight.w600),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error ?? l10n.error_occurred,
                style: GoogleFonts.anuphan(color: AppColors.baseDarkGrey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              AppButton(
                width: 120,
                text: l10n.retryButton,
                style: AppButtonStyle.primary,
                onPressed: _loadInitial,
              ),
            ],
          ),
        ),
      );
    }

    final booking = _booking!;
    final property = booking.property;

    final address =
        property?.formattedAddressTh ??
        [
          property?.address,
          property?.subdistrict,
          property?.district,
          property?.city,
          property?.postalCode,
        ].whereType<String>().where((e) => e.isNotEmpty).join(' ');

    final destLat = property?.latitude ?? 13.7563;
    final destLng = property?.longitude ?? 100.5018;
    final center = _currentLatLng ?? LatLng(destLat, destLng);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: center, zoom: 13),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
            Positioned(
              top: MediaQuery.of(context).viewPadding.top + 12,
              right: 16,
              child: _toolbarIconButton(
                onPressed: _openExternalMaps,
                tooltip: l10n.booking_route_map_button,
                icon: SvgPicture.asset(
                  'assets/icons/map-marker-filled.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _RouteInfoCard(
                isCollapsed: _isCollapsed,
                onToggleCollapsed: () {
                  setState(() => _isCollapsed = !_isCollapsed);
                },
                onBack: () => Navigator.of(context).pop(),
                address: address.isEmpty ? l10n.booking_location : address,
                booking: booking,
                durationFormatted:
                    _travelTime?.timeUntilAppointmentFormatted ??
                    _travelTime?.travelTimeFormatted,
                travelTimeSeconds: _travelTime?.travelTimeSeconds,
                lateMinutes: (() {
                  final travelSeconds = _travelTime?.travelTimeSeconds;
                  final untilSeconds = _travelTime?.timeUntilAppointmentSeconds;
                  if (travelSeconds == null ||
                      untilSeconds == null ||
                      untilSeconds <= 0 ||
                      travelSeconds <= untilSeconds) {
                    return null;
                  }
                  return ((travelSeconds - untilSeconds) / 60).ceil();
                })(),
                onArrived: _onArrived,
                onExit: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteInfoCard extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onToggleCollapsed;
  final VoidCallback onBack;
  final String address;
  final Booking booking;
  final String? durationFormatted;
  final int? travelTimeSeconds;
  final int? lateMinutes;
  final VoidCallback onArrived;
  final VoidCallback onExit;

  const _RouteInfoCard({
    required this.isCollapsed,
    required this.onToggleCollapsed,
    required this.onBack,
    required this.address,
    required this.booking,
    required this.durationFormatted,
    required this.travelTimeSeconds,
    required this.lateMinutes,
    required this.onArrived,
    required this.onExit,
  });

  String? _arrivalTime() {
    final seconds = travelTimeSeconds;
    if (seconds == null || seconds <= 0) return null;
    final arrival = DateTime.now().add(Duration(seconds: seconds));
    return DateFormat('HH:mm').format(arrival);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArrived = booking.attendance?.seller?.arrivedAt != null;
    final arrivalTime = _arrivalTime();
    final ui = booking.status == BookingStatus.confirm
        ? computeAgentConfirmFlowUi(
            booking: booking,
            l10n: l10n,
            now: DateTime.now(),
          )
        : null;

    final buyerAttendance = booking.attendance?.buyer;

    final buyerStartTravelTime = buyerAttendance?.travelingAt != null
        ? DateFormat('HH:mm').format(buyerAttendance!.travelingAt!.toLocal())
        : null;
    final buyerArrivedTime = buyerAttendance?.arrivedAt != null
        ? DateFormat('HH:mm').format(buyerAttendance!.arrivedAt!.toLocal())
        : null;

    // Show buyer timing only when we have both traveling + arrived times.
    final showBuyerTiming =
        buyerAttendance?.travelingAt != null &&
        buyerAttendance?.arrivedAt != null;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: EdgeInsets.only(
        top: 0,
        left: 0,
        right: 0,
        bottom: MediaQuery.of(context).viewPadding.bottom,
      ),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x1E000000),
            blurRadius: 32,
            offset: Offset(0, -12),
            spreadRadius: 0,
          ),
        ],
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 8,
            left: 24,
            right: 24,
            bottom: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: onToggleCollapsed,
                behavior: HitTestBehavior.opaque,
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        width: 48,
                        height: 6,
                        decoration: ShapeDecoration(
                          color: AppColors.baseLightGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        address,
                        style: GoogleFonts.anuphan(
                          color: const Color(0xFF181D27),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isCollapsed) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.booking_route_duration_label,
                          style: GoogleFonts.anuphan(
                            color: const Color(0xFF717680),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          durationFormatted ?? '-',
                          style: GoogleFonts.anuphan(
                            color: const Color(0xFF181D27),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (arrivalTime != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFF9F0FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          l10n.booking_route_you_will_arrive_at(arrivalTime),
                          style: GoogleFonts.anuphan(
                            color: const Color(0xFFA053FF),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                const _DashedDivider(color: Color(0xFFE9EAEB)),
                const SizedBox(height: 20),
                if (ui != null) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppBadge(
                      label: ui.badgeLabel,
                      color: ui.badgeColor,
                      style: BadgeStyle.dot,
                    ),
                  ),
                  if (showBuyerTiming) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _BuyerTimingRow(
                        startTravelTime: buyerStartTravelTime,
                        arrivalTime: buyerArrivedTime,
                      ),
                    ),
                  ] else if (ui.statusLine != null &&
                      ui.statusLine!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        ui.statusLine!,
                        style: GoogleFonts.anuphan(
                          color: const Color(0xFF717680),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ],
                if (lateMinutes != null && lateMinutes! > 0) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: ShapeDecoration(
                      color: AppColors.supportOrangeLight,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 1,
                          color: AppColors.supportOrangeDark,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 16,
                          color: AppColors.supportOrangeDark,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.calendar_delay_warning(lateMinutes!),
                            style: GoogleFonts.anuphan(
                              color: AppColors.supportOrangeDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  _CollapsedBackButton(onPressed: onBack),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppButton(
                      height: 44,
                      text: l10n.calendar_status_arrived,
                      style: AppButtonStyle.primary,
                      onPressed: isArrived ? null : onArrived,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollapsedBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CollapsedBackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
    );
  }
}

class _DashedDivider extends StatelessWidget {
  final Color color;

  const _DashedDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    const height = 1.0;
    const dashWidth = 6.0;
    const dashGap = 4.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final total = constraints.maxWidth;
        if (total <= 0) return const SizedBox.shrink();
        final dashCount = (total / (dashWidth + dashGap)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            );
          }),
        );
      },
    );
  }
}

class _BuyerTimingRow extends StatelessWidget {
  final String? startTravelTime;
  final String? arrivalTime;

  const _BuyerTimingRow({
    required this.startTravelTime,
    required this.arrivalTime,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Text(
      l10n.booking_route_buyer_arrived_time(arrivalTime ?? '--:--'),
      style: GoogleFonts.anuphan(
        color: const Color(0xFFA4A7AE),
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
    );
  }
}
