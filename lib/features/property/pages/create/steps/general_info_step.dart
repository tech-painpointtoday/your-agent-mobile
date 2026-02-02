import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:youragent/data/models/developer_model.dart';
import 'package:youragent/data/models/condo_project_model.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/features/property/bloc/property_form/property_form_bloc.dart';
import 'package:youragent/features/property/pages/create/property_location_picker_screen.dart';
import 'package:youragent/features/property/widgets/property_map_view.dart';
import 'package:youragent/utils/location_permission_helper.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import 'package:youragent/widgets/form_fields/app_text_form_field.dart';
import 'package:youragent/widgets/buttons/app_button.dart';

class GeneralInfoStep extends StatefulWidget {
  final int? step;
  const GeneralInfoStep({super.key, this.step});

  @override
  State<GeneralInfoStep> createState() => _GeneralInfoStepState();
}

class _GeneralInfoStepState extends State<GeneralInfoStep> {
  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _houseNoController;
  late final TextEditingController _addressController;
  late final TextEditingController _projectController;
  late final TextEditingController _developerController;
  late final TextEditingController _buildingController;
  late final TextEditingController _floorController;
  late final TextEditingController _roomNoController;
  bool _inlineMapUpdating = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<PropertyFormBloc>().state;
    _nameController = TextEditingController(
      text: state.data['name'] as String?,
    );
    _houseNoController = TextEditingController(
      text: state.data['number'] as String?,
    );
    _addressController = TextEditingController(
      text: state.data['address'] as String?,
    );
    _projectController = TextEditingController(
      text: state.data['project'] as String?,
    );
    _developerController = TextEditingController(
      text: state.data['developer'] as String?,
    );
    _buildingController = TextEditingController(
      text: state.data['building'] as String?,
    );
    _floorController = TextEditingController(
      text: state.data['floor'] as String?,
    );
    _roomNoController = TextEditingController(
      text: state.data['unitNo'] as String?,
    );

    // Add listeners to update Bloc
    _nameController.addListener(
      () => _updateData('name', _nameController.text),
    );
    _houseNoController.addListener(
      () => _updateData('number', _houseNoController.text),
    );
    _addressController.addListener(
      () => _updateData('address', _addressController.text),
    );
    _projectController.addListener(
      () => _updateData('project', _projectController.text),
    );
    _developerController.addListener(
      () => _updateData('developer', _developerController.text),
    );
    _buildingController.addListener(
      () => _updateData('building', _buildingController.text),
    );
    _floorController.addListener(
      () => _updateData('floor', _floorController.text),
    );
    _roomNoController.addListener(
      () => _updateData('room_number', _roomNoController.text),
    );

    // Initial fetch for developers and all condo projects if empty
    if (state.developers.isEmpty) {
      context.read<PropertyFormBloc>().add(
        const PropertyFormDevelopersFetched(),
      );
    }
    if (state.condoProjects.isEmpty) {
      context.read<PropertyFormBloc>().add(
        const PropertyFormCondoProjectsFetched(),
      );
    }
  }

  void _updateData(String key, String value) {
    context.read<PropertyFormBloc>().add(
      PropertyFormDataUpdated(key: key, value: value),
    );
  }

  Future<void> _openLocationSearch() async {
    final state = context.read<PropertyFormBloc>().state;
    LatLng? current;
    if (state.data['latitude'] != null && state.data['longitude'] != null) {
      current = LatLng(
        state.data['latitude'] as double,
        state.data['longitude'] as double,
      );
    }

    final result = await PropertyLocationPickerScreen.open(
      context,
      initialLocation: current,
    );

    if (result != null && mounted) {
      _addressController.text = result.formattedAddressTh;

      context.read<PropertyFormBloc>().add(
        PropertyFormLocationUpdated({
          'latitude': result.latLng.latitude,
          'longitude': result.latLng.longitude,
          'location_set': true,
          'formatted_address_th': result.formattedAddressTh,
          'formatted_address_en': result.formattedAddressEn,
          'road': result.components['road'] ?? '',
          'soi': result.components['soi'] ?? '',
          'subdistrict': result.components['subdistrict'] ?? '',
          'district': result.components['district'] ?? '',
          'province': result.components['province'] ?? '',
          'postal_code': result.components['postal_code'] ?? '',
          'city': result.components['city'] ?? '',
          'state':
              result.components['state'] ?? result.components['province'] ?? '',
          'country': 'Thailand',
        }),
      );
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

    context.read<PropertyFormBloc>().add(
      PropertyFormLocationUpdated({
        'latitude': result.latLng.latitude,
        'longitude': result.latLng.longitude,
        'location_set': true,
        'formatted_address_th': result.formattedAddressTh,
        'formatted_address_en': result.formattedAddressEn,
        'number': result.components['number'] ?? '',
        'road': result.components['road'] ?? '',
        'soi': result.components['soi'] ?? '',
        'subdistrict': result.components['subdistrict'] ?? '',
        'district': result.components['district'] ?? '',
        'province': result.components['province'] ?? '',
        'postal_code': result.components['postal_code'] ?? '',
        'city': result.components['city'] ?? '',
        'state':
            result.components['state'] ?? result.components['province'] ?? '',
        'country': 'Thailand',
      }),
    );
  }

  void _clearLocation() {
    context.read<PropertyFormBloc>().add(
      const PropertyFormLocationUpdated({
        'address': null,
        'latitude': null,
        'longitude': null,
        'location_set': false,
        'formatted_address_th': null,
        'formatted_address_en': null,
        'number': null,
        'road': null,
        'soi': null,
        'subdistrict': null,
        'district': null,
        'province': null,
        'postal_code': null,
        'city': null,
        'state': null,
        'country': null,
      }),
    );
    _addressController.clear();
  }

  Future<void> _updateLocationFromLatLng(LatLng latLng) async {
    if (_inlineMapUpdating) return;
    _inlineMapUpdating = true;
    try {
      // Thai formatted string (geocoding)
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      final p = placemarks.isNotEmpty ? placemarks.first : null;
      final fullTh = p != null
          ? [
              p.street,
              p.subLocality,
              p.subAdministrativeArea,
              p.administrativeArea,
              p.postalCode,
            ].where((e) => e != null && e.isNotEmpty).join(' ')
          : '';

      // English + components (Google reverse geocode if configured)
      String formattedEn = fullTh;
      Map<String, String> components = const {};
      if (DependencyInjection.googlePlacesService.isConfigured) {
        final r = await DependencyInjection.googlePlacesService.reverseGeocode(
          lat: latLng.latitude,
          lng: latLng.longitude,
          language: 'en',
        );
        if (r != null) {
          formattedEn = r.formattedAddressEn;
          components = r.components;
        }
      }

      if (!mounted) return;
      if (fullTh.isNotEmpty) {
        _addressController.text = fullTh;
      }
      context.read<PropertyFormBloc>().add(
        PropertyFormLocationUpdated({
          'latitude': latLng.latitude,
          'longitude': latLng.longitude,
          'location_set': true,
          'formatted_address_th': fullTh,
          'formatted_address_en': formattedEn,
          'number': components['number'] ?? '',
          'road': components['road'] ?? '',
          'soi': components['soi'] ?? '',
          'subdistrict': components['subdistrict'] ?? '',
          'district': components['district'] ?? '',
          'province': components['province'] ?? '',
          'postal_code': components['postal_code'] ?? '',
          'city': components['city'] ?? '',
          'state': components['state'] ?? components['province'] ?? '',
          'country': 'Thailand',
        }),
      );
    } finally {
      _inlineMapUpdating = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _projectController.dispose();
    _developerController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    _roomNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PropertyFormBloc, PropertyFormState>(
      listenWhen: (prev, curr) =>
          prev.selectedDeveloperId != curr.selectedDeveloperId ||
          prev.selectedCondoProjectId != curr.selectedCondoProjectId,
      listener: (context, state) {
        // Sync Developer Controller
        if (state.selectedDeveloperId != null) {
          final developer = state.developers
              .where((d) => d.id == state.selectedDeveloperId)
              .firstOrNull;
          if (developer != null &&
              _developerController.text != developer.nameTh) {
            _developerController.text = developer.nameTh;
            // Also notify listener to update Bloc data key
            _updateData('developer', developer.nameTh);
          }
        }

        // Sync Project Controller if needed (optional, mainly for when clearing)
        if (state.selectedCondoProjectId != null) {
          final project = state.condoProjects
              .where((p) => p.id == state.selectedCondoProjectId)
              .firstOrNull;
          if (project != null && _projectController.text != project.name) {
            _projectController.text = project.name;
            _updateData('project', project.name);
          }
        }
      },
      builder: (context, state) {
        final isCondoOrApt = state.isCondoOrApt;

        LatLng? currentLatLng;
        if (state.address?.isNotEmpty == true &&
            state.data['latitude'] != null &&
            state.data['longitude'] != null) {
          currentLatLng = LatLng(
            state.data['latitude'] as double,
            state.data['longitude'] as double,
          );
        }

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'ข้อมูลทั่วไป',
                      style: GoogleFonts.anuphan(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (widget.step != null)
                    AppBadge(
                      color: BadgeColor.default_,
                      label: '${widget.step}/5',
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Title
              AppTextFormField(
                label: 'ชื่ออสังหาฯ',
                controller: _nameController,
                isRequired: true,
                hintText: 'ชื่ออสังหาฯ',
              ),
              const SizedBox(height: 8),
              Text(
                'ชื่ออสังหาฯ นี้จะปรากฏบนหัวข้อประกาศของคุณ',
                style: GoogleFonts.anuphan(
                  color: AppColors.baseGrey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),

              if (!isCondoOrApt) ...[
                // Developer
                AppTextFormField(
                  label: 'ผู้พัฒนาโครงการ',
                  controller: _developerController,
                  hintText: 'ผู้พัฒนาโครงการ',
                ),
                const SizedBox(height: 16),

                // Project Name
                AppTextFormField(
                  label: 'ชื่อโครงการ',
                  controller: _projectController,
                  hintText: 'ชื่อโครงการ',
                ),
                const SizedBox(height: 16),
              ],

              if (isCondoOrApt) ...[
                // Developer
                BlocBuilder<PropertyFormBloc, PropertyFormState>(
                  builder: (context, state) {
                    return TypeAheadField<Developer>(
                      controller: _developerController,
                      builder: (context, controller, focusNode) =>
                          AppTextFormField(
                            label: 'ผู้พัฒนาโครงการ',
                            controller: controller,
                            focusNode: focusNode,
                            hintText: 'ค้นหาผู้พัฒนาโครงการ',
                            isRequired: isCondoOrApt,
                            suffix: Padding(
                              padding: const EdgeInsets.all(16),
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
                      suggestionsCallback: (pattern) {
                        final developers = state.developers;
                        if (pattern.isEmpty) return developers;
                        final lower = pattern.toLowerCase();
                        return developers.where((dev) {
                          return dev.nameTh.toLowerCase().contains(lower) ||
                              dev.nameEn.toLowerCase().contains(lower);
                        }).toList();
                      },
                      itemBuilder: (context, developer) {
                        return ListTile(
                          title: Text(developer.nameTh),
                          subtitle: Text(developer.nameEn),
                        );
                      },
                      onSelected: (developer) {
                        _developerController.text = developer.nameTh;
                        _projectController.clear();
                        context.read<PropertyFormBloc>().add(
                          PropertyFormDeveloperChanged(developer.id),
                        );
                        FocusScope.of(context).unfocus();
                      },
                      emptyBuilder: (context) => const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('ไม่พบข้อมูล'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Project Name
                BlocBuilder<PropertyFormBloc, PropertyFormState>(
                  builder: (context, state) {
                    return TypeAheadField<CondoProject>(
                      controller: _projectController,
                      builder: (context, controller, focusNode) =>
                          AppTextFormField(
                            label: 'ชื่อโครงการ',
                            controller: controller,
                            focusNode: focusNode,
                            hintText: 'ชื่อโครงการ',
                            isRequired: isCondoOrApt,
                            suffix: Padding(
                              padding: const EdgeInsets.all(16),
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
                      suggestionsCallback: (pattern) {
                        final projects = state.condoProjects;
                        final devId = state.selectedDeveloperId;

                        Iterable<CondoProject> filtered = projects;
                        if (devId != null) {
                          filtered = projects.where(
                            (p) => p.developerId == devId,
                          );
                        }

                        if (pattern.isEmpty) return filtered.toList();
                        final lower = pattern.toLowerCase();
                        return filtered.where((p) {
                          return p.name.toLowerCase().contains(lower);
                        }).toList();
                      },
                      itemBuilder: (context, project) {
                        return ListTile(title: Text(project.name));
                      },
                      onSelected: (project) {
                        _projectController.text = project.name;

                        // Auto-fill developer if currently empty OR if we want to force match
                        // Checking empty is safer to avoid overwriting user's specific choice if they made one
                        // asking for "still empty" implies we only fill if it's blank.
                        if (_developerController.text.isEmpty) {
                          final dev = state.developers
                              .where((d) => d.id == project.developerId)
                              .firstOrNull;
                          if (dev != null) {
                            _developerController.text = dev.nameTh;
                            // Trigger update data to ensure state is consistent
                            _updateData('developer', dev.nameTh);
                          }
                        }

                        context.read<PropertyFormBloc>().add(
                          PropertyFormCondoProjectChanged(project.id),
                        );

                        // Unfocus to hide keyboard
                        FocusScope.of(context).unfocus();
                      },
                      emptyBuilder: (context) => const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('ไม่พบข้อมูล'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Building Info
                AppTextFormField(
                  label: 'ตึก/อาคาร',
                  controller: _buildingController,
                  hintText: 'ตึก/อาคาร',
                ),
                const SizedBox(height: 16),
                AppTextFormField(
                  label: 'ชั้น',
                  controller: _floorController,
                  hintText: 'ชั้น',
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                AppTextFormField(
                  label: 'เลขที่ห้อง',
                  controller: _roomNoController,
                  hintText: 'เลขที่ห้อง',
                  isRequired: true,
                ),
                const SizedBox(height: 16),
              ],

              // Address
              if (!isCondoOrApt)
                AppTextFormField(
                  label: 'เลขที่บ้าน',
                  controller: _houseNoController,
                  isRequired: true,
                  hintText: 'เลขที่บ้าน',
                ),
              const SizedBox(height: 16),

              // Location Section
              AppTextFormField(
                label: 'ตำแหน่งที่ตั้ง',
                controller: _addressController,
                hintText: 'ตำแหน่งที่ตั้ง',
                isRequired: true,
                readOnly: true,
                showCursor: false,
                onTap: _openLocationSearch,
                suffix: Padding(
                  padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 8),
              Text(
                'เลือกตำแหน่งบนแผนที่หรือใช้ตำแหน่งปัจจุบันของคุณเพื่อกำหนดที่ตั้งอสังหาริมทรัพย์',
                style: GoogleFonts.anuphan(
                  color: AppColors.baseGrey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),

              // Map
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.baseLightGrey),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: PropertyMapView(
                    key: const ValueKey('general_info_map'),
                    properties: const [],
                    height: 200,
                    initialLocation: currentLatLng,
                    cameraTarget: currentLatLng,
                    showCenterMarker: true,
                    onCameraIdle: _updateLocationFromLatLng,
                    onMaximizeTapped: _openLocationSearch,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: AppButton(
                      text: 'ใช้ตำแหน่งปัจจุบัน',
                      style: AppButtonStyle.primary,
                      onPressed: _useCurrentLocation,
                      backgroundColor: AppColors.brandLightGreen,
                      textColor: AppColors.brandGreen,
                      iconPath: 'assets/icons/direction-up-right.svg',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      text: 'ล้างตำแหน่ง',
                      style: AppButtonStyle.outline,
                      onPressed: _clearLocation,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
