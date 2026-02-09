import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:youragent/features/property/pages/create/property_location_picker_screen.dart';
import 'package:youragent/utils/location_permission_helper.dart';
import 'package:youragent/widgets/form_fields/app_text_form_field.dart';
import 'package:youragent/widgets/map/map_view.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/badges/app_badge.dart';
import '../../../widgets/buttons/app_button.dart';
import '../../../widgets/dialogs/status_dialog.dart';
import '../../../widgets/inputs/app_text_field.dart';
import '../../../widgets/modals/app_confirmation_bottom_sheet.dart';
import '../bloc/profile_bloc.dart';
import '../models/agent_profile.dart';
import 'profile_screen.dart';
import 'package:youragent/l10n/app_localizations.dart';

class ServiceAreaFormScreen extends StatefulWidget {
  final AgentDetails? agent;

  const ServiceAreaFormScreen({super.key, this.agent});

  @override
  State<ServiceAreaFormScreen> createState() => _ServiceAreaFormScreenState();
}

class _ServiceAreaFormScreenState extends State<ServiceAreaFormScreen> {
  late final TextEditingController _radiusController;
  late final TextEditingController _addressController;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _radiusController = TextEditingController(
      text: widget.agent?.reachableRadius ?? '0',
    );
    _addressController = TextEditingController();
    if (widget.agent?.serviceAreaCenterLat != null &&
        widget.agent?.serviceAreaCenterLng != null) {
      final lat = double.tryParse(widget.agent!.serviceAreaCenterLat!);
      final lng = double.tryParse(widget.agent!.serviceAreaCenterLng!);
      if (lat != null && lng != null) {
        _selectedLocation = LatLng(lat, lng);
        _initAddressFromLocation(lat, lng);
      }
    }
  }

  Future<void> _initAddressFromLocation(double lat, double lng) async {
    final places = DependencyInjection.googlePlacesService;
    if (!places.isConfigured) return;
    final result = await places.reverseGeocode(
      lat: lat,
      lng: lng,
      language: 'th',
    );
    if (result != null && mounted) {
      setState(() {
        _addressController.text = result.formattedAddressEn;
      });
    }
  }

  @override
  void dispose() {
    _radiusController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_selectedLocation == null) {
      StatusDialog.showWarning(
        context: context,
        title: AppLocalizations.of(context).specifyLocationTitle,
        message: AppLocalizations.of(context).specifyLocationMessage,
      );
      return;
    }

    final data = {
      'service_area_center_lat': _selectedLocation!.latitude,
      'service_area_center_lng': _selectedLocation!.longitude,
      'reachable_radius': double.tryParse(_radiusController.text.trim()) ?? 0,
    };

    AppConfirmationBottomSheet.show(
      context: context,
      title: AppLocalizations.of(context).saveServiceAreaTitle,
      description: AppLocalizations.of(context).saveServiceAreaMessage,
      confirmLabel: AppLocalizations.of(context).confirmSaveLabel,
      onConfirm: () {
        context.read<ProfileBloc>().add(UpdateServiceArea(data));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<ProfileBloc>(),
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            ProfileScreen.needsRefresh = true;
            context.pop();
          } else if (state is ProfileError) {
            StatusDialog.showError(
              context: context,
              title: AppLocalizations.of(context).errorOccurredTitle,
              message: state.message,
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.primary,
          appBar: _buildAppBar(context),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.translucent,
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppBadge(
                            label: AppLocalizations.of(
                              context,
                            ).serviceAreaLabel,
                            color: BadgeColor.blue,
                            style: BadgeStyle.plain,
                          ),
                          SizedBox(height: 24),
                          // Location Section
                          AppTextFormField(
                            label: AppLocalizations.of(context).serviceAreaHint,
                            controller: _addressController,
                            hintText: AppLocalizations.of(
                              context,
                            ).serviceAreaHint,
                            isRequired: true,
                            readOnly: false,
                            showCursor: false,
                            maxLines: 2,
                            onTap: () => _openLocationSearch(_selectedLocation),
                            suffix: Padding(
                              padding: const EdgeInsets.all(8),
                              child: SvgPicture.asset(
                                'assets/icons/search.svg',
                                width: 16,
                                height: 16,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.baseGrey,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context).serviceAreaDescription,
                            style: GoogleFonts.anuphan(
                              fontSize: 14,
                              color: AppColors.baseGrey,
                            ),
                          ),
                          SizedBox(height: 24),
                          // Map
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.baseLightGrey,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: MapView(
                                key: const ValueKey('service_area_map'),
                                properties: const [],
                                height: 200,
                                initialLocation: _selectedLocation,
                                cameraTarget: _selectedLocation,
                                showCenterMarker: true,
                                onCameraIdle: _updateLocationFromLatLng,
                                onMaximizeTapped: () {
                                  _openLocationSearch(_selectedLocation);
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          SizedBox(height: 12),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: AppButton(
                                  text: AppLocalizations.of(
                                    context,
                                  ).useCurrentLocationLabel,
                                  style: AppButtonStyle.primary,
                                  onPressed: _useCurrentLocation,
                                  backgroundColor: AppColors.brandLightGreen,
                                  textColor: AppColors.brandGreen,
                                  iconPath:
                                      'assets/icons/direction-up-right.svg',
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: AppButton(
                                  text: AppLocalizations.of(
                                    context,
                                  ).clearLocationLabel,
                                  style: AppButtonStyle.outline,
                                  onPressed: () {
                                    setState(() {
                                      _selectedLocation = null;
                                      _addressController.text = '';
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 24),
                          AppTextField(
                            label: AppLocalizations.of(
                              context,
                            ).serviceRadiusHint,
                            hintText: AppLocalizations.of(
                              context,
                            ).serviceRadiusHint,
                            controller: _radiusController,
                            keyboardType: TextInputType.number,
                            suffix: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                AppLocalizations.of(context).serviceRadiusUnit,
                                style: GoogleFonts.anuphan(
                                  color: AppColors.baseGrey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomButtons(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: SvgPicture.asset(
          'assets/icons/chevron-left.svg',
          width: 18,
          height: 18,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        AppLocalizations.of(context).addServiceAreaTitle,
        style: GoogleFonts.anuphan(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              text: AppLocalizations.of(context).statusCancelled,
              style: AppButtonStyle.outline,
              onPressed: () => context.pop(),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                return AppButton(
                  text: AppLocalizations.of(context).confirmSaveLabel,
                  style: AppButtonStyle.primary,
                  isLoading: state is ProfileUpdateLoading,
                  onPressed: _onSave,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openLocationSearch(LatLng? current) async {
    final result = await PropertyLocationPickerScreen.open(
      context,
      initialLocation: current ?? _selectedLocation,
    );

    if (result != null && mounted) {
      _addressController.text = result.formattedAddressTh;
    }
  }

  Future<void> _useCurrentLocation() async {
    final pos = await LocationPermissionHelper.getCurrentPosition(context);
    if (pos == null || !mounted) return;
    // Open picker centered at current position so user can confirm
    final result = await PropertyLocationPickerScreen.open(
      context,
      initialLocation: LatLng(pos.latitude, pos.longitude),
    );
    if (result == null || !mounted) return;
    _addressController.text = result.formattedAddressTh;
  }

  Future<void> _updateLocationFromLatLng(LatLng latLng) async {
    try {
      // Base address: prefer Thai from Google when configured, else placemarks
      String fullTh = '';
      final places = DependencyInjection.googlePlacesService;
      if (places.isConfigured) {
        final r = await places.reverseGeocode(
          lat: latLng.latitude,
          lng: latLng.longitude,
          language: 'th',
        );
        if (r != null) fullTh = r.formattedAddressEn;
      }
      if (fullTh.isEmpty) {
        final placemarks = await placemarkFromCoordinates(
          latLng.latitude,
          latLng.longitude,
        );
        final p = placemarks.isNotEmpty ? placemarks.first : null;
        fullTh = p != null
            ? [
                p.street,
                p.subLocality,
                p.subAdministrativeArea,
                p.administrativeArea,
                p.postalCode,
              ].where((e) => e != null && e.isNotEmpty).join(' ')
            : '';
      }

      if (!mounted) return;
      if (fullTh.isNotEmpty) {
        _addressController.text = fullTh;
      }
    } catch (_) {
      if (!mounted) return;
    }
  }
}
