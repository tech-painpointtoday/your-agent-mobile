import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:youragent/data/models/developer_model.dart';
import 'package:youragent/data/models/condo_project_model.dart';
import 'package:youragent/data/models/house_project_model.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/features/property/bloc/property_form/property_form_bloc.dart';
import 'package:youragent/features/property/pages/create/property_location_picker_screen.dart';
import 'package:youragent/utils/permission_helper.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import 'package:youragent/widgets/form_fields/app_text_form_field.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/widgets/map/map_view.dart';
import 'package:youragent/features/property/widgets/add_property_info_bottom_sheets.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/widgets/modals/app_confirmation_bottom_sheet.dart';

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
  late final TextEditingController _juristicPhoneController;
  late final TextEditingController _juristicEmailController;
  late final FocusNode _projectFocusNode;
  late final FocusNode _developerFocusNode;
  bool _inlineMapUpdating = false;
  final SuggestionsController<CondoProject> _projectSuggestionsController =
      SuggestionsController<CondoProject>();
  final SuggestionsController<HouseProject> _houseProjectSuggestionsController =
      SuggestionsController<HouseProject>();
  int _lastCondoProjectsLength = -1;
  int _lastHouseProjectsLength = -1;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _projectFocusNode = FocusNode();
    _developerFocusNode = FocusNode();
    super.initState();
    final state = context.read<PropertyFormBloc>().state;
    _nameController = TextEditingController(text: state.name);
    _houseNoController = TextEditingController(text: state.number);

    // ตำแหน่งที่ตั้ง: แสดงค่าก็ต่อเมื่อมี lat/lng แล้ว (เช่น เลือกจากแผนที่แล้ว)
    _addressController = TextEditingController(
      text: (state.latitude != null && state.longitude != null)
          ? (state.address ?? '')
          : '',
    );

    // Initial project/developer name restoration
    String? projectName = state.villageName;
    String? developerName;

    if (state.selectedCondoProjectId != null) {
      projectName = state.condoProjects
          .where((p) => p.id == state.selectedCondoProjectId)
          .firstOrNull
          ?.name;
    }
    developerName = state.developers
        .where((d) => d.id == state.selectedDeveloperId)
        .firstOrNull
        ?.nameTh;

    _projectController = TextEditingController(text: projectName);
    _developerController = TextEditingController(text: developerName);
    _buildingController = TextEditingController(text: state.tower);
    _floorController = TextEditingController(text: state.condoFloor);
    _roomNoController = TextEditingController(text: state.number);
    _juristicPhoneController = TextEditingController();
    _juristicEmailController = TextEditingController();

    // Set initial juristic info if project exists
    if (state.selectedCondoProjectId != null) {
      final project = state.condoProjects
          .where((p) => p.id == state.selectedCondoProjectId)
          .firstOrNull;
      if (project != null) {
        _juristicPhoneController.text = project.juristicContactPhone ?? '';
        _juristicEmailController.text = project.juristicContactEmail ?? '';
      }
    }

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
    _developerController.addListener(() {
      final text = _developerController.text;
      _updateData('developer', text);
      if (text.isEmpty &&
          context.read<PropertyFormBloc>().state.selectedDeveloperId != null) {
        context.read<PropertyFormBloc>().add(
          const PropertyFormDeveloperChanged(null),
        );
      }
    });
    _buildingController.addListener(
      () => _updateData('building', _buildingController.text),
    );
    _floorController.addListener(
      () => _updateData('floor', _floorController.text),
    );
    _roomNoController.addListener(
      () => _updateData('number', _roomNoController.text),
    );

    // Initial fetch for developers (always refresh to ensure full list)
    context.read<PropertyFormBloc>().add(
      const PropertyFormDevelopersFetched(refresh: true),
    );
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
    final pos = await PermissionHelper.getCurrentPosition(context);
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
        //number': result.components['number'] ?? '',
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
      // Base address: prefer Thai from Google when configured, else placemarks
      String fullTh = '';
      Map<String, String> components = const {};
      String formattedEn = '';

      if (DependencyInjection.googlePlacesService.isConfigured) {
        final r = await DependencyInjection.googlePlacesService.reverseGeocode(
          lat: latLng.latitude,
          lng: latLng.longitude,
          language: 'th',
        );
        if (r != null) {
          fullTh = r.formattedAddressEn;
          components = r.components;
        }
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

      if (DependencyInjection.googlePlacesService.isConfigured &&
          formattedEn.isEmpty) {
        final rEn = await DependencyInjection.googlePlacesService
            .reverseGeocode(
              lat: latLng.latitude,
              lng: latLng.longitude,
              language: 'en',
            );
        if (rEn != null) formattedEn = rEn.formattedAddressEn;
      }
      if (formattedEn.isEmpty) formattedEn = fullTh;

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
          //'number': components['number'] ?? '',
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

  Future<void> _addDeveloper() async {
    final result = await AddDeveloperBottomSheet.show(context);
    if (result != null && mounted) {
      if (result['developer'] != null) {
        // Show success dialog
        if (mounted) {
          StatusDialog.showSuccess(
            context: context,
            title: AppLocalizations.of(context).success,
            message: AppLocalizations.of(context).add_developer_success,
          );
          // Refresh developers list
          context.read<PropertyFormBloc>().add(
            const PropertyFormDevelopersFetched(refresh: true),
          );

          final developer = result['developer'] as Map<String, dynamic>;
          final isTh = Localizations.localeOf(context).languageCode == 'th';
          final developerId = developer['id'];

          _developerController.text = isTh
              ? developer['name_th']
              : developer['name_en'];
          _updateData(
            'developer',
            isTh ? developer['name_th'] : developer['name_en'],
          );

          // Update BLoC state with the new developer ID
          if (developerId != null) {
            context.read<PropertyFormBloc>().add(
              PropertyFormDeveloperChanged(developerId as int),
            );
          }
        }
      }
    }
  }

  Future<void> _addProject() async {
    final bloc = context.read<PropertyFormBloc>();
    final state = bloc.state;
    final developerId = state.selectedDeveloperId;

    if (developerId == null) {
      await AppConfirmationBottomSheet.show(
        context: context,
        icon: 'assets/images/YA_Illustration_ConfirmWarning.png',
        title: 'ไม่สามารถเพิ่มโครงการได้',
        description: 'กรุณาเลือกผู้พัฒนาก่อน',
        confirmLabel: AppLocalizations.of(context).select,
        cancelLabel: '',
        style: ConfirmationStyle.warning,
        onConfirm: () {
          _developerFocusNode.requestFocus();
        },
      );
      return;
    }

    final isCondoOrApt =
        state.selectedPropertyType == PropertyType.condo ||
        state.selectedPropertyType == PropertyType.apartment;

    final result = await AddProjectBottomSheet.show(
      context,
      developerId: developerId,
      developerName: _developerController.text,
      isCondoOrApt: isCondoOrApt,
    );

    if (result != null && mounted) {
      // Result structure varies: condo_project or house_project
      final projectKey = isCondoOrApt ? 'condo_project' : 'house_project';
      final project = result[projectKey] as Map<String, dynamic>?;

      if (project != null && mounted) {
        StatusDialog.showSuccess(
          context: context,
          title: AppLocalizations.of(context).success,
          message: AppLocalizations.of(context).add_project_success,
        );

        final nameTh = project['name_th'] ?? project['name'] ?? '';
        final projectId = project['id'];
        final isTh = Localizations.localeOf(context).languageCode == 'th';
        final nameEn = project['name_en'] ?? '';

        _projectController.text = isTh ? nameTh : nameEn;
        _updateData('project', isTh ? nameTh : nameEn);

        // Trigger refresh based on type
        if (isCondoOrApt) {
          context.read<PropertyFormBloc>().add(
            PropertyFormCondoProjectsFetched(
              developerId: developerId,
              refresh: true,
            ),
          );
        } else {
          context.read<PropertyFormBloc>().add(
            PropertyFormHouseProjectsFetched(
              developerId: developerId,
              refresh: true,
            ),
          );
        }

        // Update BLoC state with the new project ID
        if (projectId != null) {
          if (isCondoOrApt) {
            context.read<PropertyFormBloc>().add(
              PropertyFormCondoProjectChanged(projectId as int),
            );
          } else {
            context.read<PropertyFormBloc>().add(
              PropertyFormHouseProjectChanged(projectId as int),
            );
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _projectFocusNode.dispose();
    _developerFocusNode.dispose();
    _projectSuggestionsController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _projectController.dispose();
    _developerController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    _roomNoController.dispose();
    _juristicPhoneController.dispose();
    _juristicEmailController.dispose();
    super.dispose();
  }

  Widget _buildMasterDataTypeAhead<T>({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hintText,
    required List<T> items,
    List<T> Function()? itemsGetter,
    required String Function(T) nameSelector,
    required void Function(T) onSelected,
    String Function(T)? subtitleSelector,
    SuggestionsController<T>? suggestionsController,
    bool isRequired = false,
    String? Function(String?)? validator,
    VoidCallback? onFetchNeeded,
    required bool Function(PropertyFormState) fetchingSelector,
    String? emptyMessage,
  }) {
    return TypeAheadField<T>(
      controller: controller,
      focusNode: focusNode,
      suggestionsController: suggestionsController,
      builder: (context, controller, focusNode) => AppTextFormField(
        label: label,
        controller: controller,
        focusNode: focusNode,
        hintText: hintText,
        isRequired: isRequired,
        validator: validator,
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
      suggestionsCallback: (pattern) async {
        List<T> currentItems() => itemsGetter?.call() ?? items;

        if (currentItems().isEmpty &&
            onFetchNeeded != null &&
            context.mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) onFetchNeeded();
          });
          int retries = 0;
          while (retries < 15 && mounted) {
            final currentState = context.read<PropertyFormBloc>().state;
            if (!fetchingSelector(currentState)) break;
            await Future.delayed(const Duration(milliseconds: 200));
            retries++;
          }
          if (!context.mounted) return <T>[];
          // Use fresh list from bloc after fetch (avoids "has data but show empty")
          final fresh = currentItems();
          if (pattern.isEmpty) return fresh;
          final lower = pattern.toLowerCase();
          return fresh.where((item) {
            final name = nameSelector(item).toLowerCase();
            final sub = subtitleSelector?.call(item).toLowerCase() ?? '';
            return name.contains(lower) || sub.contains(lower);
          }).toList();
        }

        final list = currentItems();
        if (pattern.isEmpty) return list;
        final lower = pattern.toLowerCase();
        return list.where((item) {
          final name = nameSelector(item).toLowerCase();
          final sub = subtitleSelector?.call(item).toLowerCase() ?? '';
          return name.contains(lower) || sub.contains(lower);
        }).toList();
      },
      itemBuilder: (context, item) {
        return ListTile(
          title: Text(nameSelector(item)),
          subtitle: subtitleSelector != null
              ? Text(subtitleSelector(item))
              : null,
        );
      },
      onSelected: onSelected,
      loadingBuilder: (context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SpinKitFadingCircle(color: AppColors.primary, size: 24),
        ),
      ),
      emptyBuilder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Text(emptyMessage ?? AppLocalizations.of(context).noDataFound),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PropertyFormBloc, PropertyFormState>(
      listenWhen: (prev, curr) =>
          prev.selectedDeveloperId != curr.selectedDeveloperId ||
          prev.selectedCondoProjectId != curr.selectedCondoProjectId ||
          prev.selectedHouseProjectId != curr.selectedHouseProjectId ||
          // When developers list is loaded/updated (e.g. after metadata fetch),
          // we also want to resync the developer text field for edit flows.
          prev.developers != curr.developers,
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

          // Sync Juristic Controllers
          if (project != null) {
            _juristicPhoneController.text = project.juristicContactPhone ?? '';
            _juristicEmailController.text = project.juristicContactEmail ?? '';
          } else {
            _juristicPhoneController.clear();
            _juristicEmailController.clear();
          }
        } else {
          _juristicPhoneController.clear();
          _juristicEmailController.clear();
        }
      },
      builder: (context, state) {
        final isTh = Localizations.localeOf(context).languageCode == 'th';
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

        return Form(
          key: _formKey,
          autovalidateMode: state.showErrors
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          child: SingleChildScrollView(
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
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        AppLocalizations.of(context).general_information,
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
                  label: AppLocalizations.of(context).propertyNameHint,
                  controller: _nameController,
                  isRequired: true,
                  hintText: AppLocalizations.of(context).propertyNameHint,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context).this_field_required;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).propertyNameDescription,
                  style: GoogleFonts.anuphan(
                    color: AppColors.baseGrey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),

                // Developer
                BlocBuilder<PropertyFormBloc, PropertyFormState>(
                  builder: (context, state) {
                    return _buildMasterDataTypeAhead<Developer>(
                      controller: _developerController,
                      focusNode: _developerFocusNode,
                      label: AppLocalizations.of(context).developerHint,
                      hintText: AppLocalizations.of(context).searchDeveloper,
                      items: state.developers,
                      itemsGetter: () =>
                          context.read<PropertyFormBloc>().state.developers,
                      isRequired: isCondoOrApt,
                      fetchingSelector: (s) => s.isFetchingDevelopers,
                      validator: isCondoOrApt
                          ? (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(
                                  context,
                                ).this_field_required;
                              }
                              if (state.selectedDeveloperId == null) {
                                return AppLocalizations.of(
                                  context,
                                ).please_select;
                              }
                              return null;
                            }
                          : null,
                      nameSelector: (d) => isTh ? d.nameTh : d.nameEn,
                      subtitleSelector: (d) => isTh ? d.nameEn : d.nameTh,
                      onSelected: (developer) {
                        _developerController.text = isTh
                            ? developer.nameTh
                            : developer.nameEn;
                        final bloc = context.read<PropertyFormBloc>();
                        final pState = bloc.state;
                        final currentDevId = pState.selectedDeveloperId;

                        if (developer.id != currentDevId) {
                          _projectController.clear();
                          bloc.add(PropertyFormDeveloperChanged(developer.id));

                          // If Condo/Apt, clear project and show suggestions again
                          if (pState.isCondoOrApt) {
                            FocusScope.of(context).unfocus();
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                _projectController.clear();
                                _updateData('project', '');
                                _projectFocusNode.requestFocus();
                                _projectSuggestionsController.refresh();
                              }
                            });
                            return;
                          } else {
                            // For houses, also clear project text
                            _projectController.clear();
                            _updateData('project', '');
                          }
                        } else {
                          bloc.add(PropertyFormDeveloperChanged(developer.id));
                        }

                        // Unfocus to hide keyboard
                        FocusScope.of(context).unfocus();
                      },
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).searchDeveloperDescription,
                  style: GoogleFonts.anuphan(
                    color: AppColors.baseGrey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  width: double.infinity,
                  text: AppLocalizations.of(context).addDeveloperTitle,
                  style: AppButtonStyle.outline,
                  backgroundColor: AppColors.brandLightGreen,
                  textColor: AppColors.brandGreen,
                  borderColor: AppColors.brandGreen.withValues(alpha: 0.16),
                  iconPath: 'assets/icons/plus.svg',
                  onPressed: _addDeveloper,
                ),
                const SizedBox(height: 16),

                // Project Name
                BlocBuilder<PropertyFormBloc, PropertyFormState>(
                  builder: (context, state) {
                    // When condo projects load (e.g. after API returns), refresh typeahead so overlay shows data
                    if (isCondoOrApt &&
                        state.condoProjects.isNotEmpty &&
                        state.condoProjects.length !=
                            _lastCondoProjectsLength) {
                      _lastCondoProjectsLength = state.condoProjects.length;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _projectSuggestionsController.refresh();
                      });
                    } else if (state.condoProjects.isEmpty) {
                      _lastCondoProjectsLength = 0;
                    }

                    // Show condo project for condos/apartments, simple text field for houses
                    // Show condo project for condos/apartments, simple text field for houses
                    if (isCondoOrApt) {
                      return _buildMasterDataTypeAhead<CondoProject>(
                        controller: _projectController,
                        focusNode: _projectFocusNode,
                        suggestionsController: _projectSuggestionsController,
                        emptyMessage: 'ไม่พบรายการ',
                        label: AppLocalizations.of(context).projectNameHint,
                        hintText: AppLocalizations.of(context).projectNameHint,
                        items: state.condoProjects,
                        itemsGetter: () => context
                            .read<PropertyFormBloc>()
                            .state
                            .condoProjects,
                        isRequired: isCondoOrApt,
                        fetchingSelector: (s) => s.isFetchingProjects,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(
                              context,
                            ).this_field_required;
                          }
                          if (state.selectedCondoProjectId == null) {
                            return AppLocalizations.of(context).please_select;
                          }
                          return null;
                        },
                        nameSelector: (p) => isTh ? p.nameTh : p.nameEn,
                        subtitleSelector: (p) => isTh ? p.nameEn : p.nameTh,
                        onSelected: (project) {
                          _projectController.text = isTh
                              ? project.nameTh
                              : project.nameEn;
                          final bloc = context.read<PropertyFormBloc>();

                          // Auto-fill developer if empty or mismatch
                          final dev = state.developers
                              .where((d) => d.id == project.developerId)
                              .firstOrNull;
                          if (dev != null &&
                              (_developerController.text.isEmpty ||
                                  state.selectedDeveloperId != dev.id)) {
                            _developerController.text = isTh
                                ? dev.nameTh
                                : dev.nameEn;
                            // Update name for consistency
                            _updateData(
                              'developer',
                              isTh ? dev.nameTh : dev.nameEn,
                            );
                            bloc.add(PropertyFormDeveloperChanged(dev.id));
                          }

                          bloc.add(PropertyFormCondoProjectChanged(project.id));

                          _projectFocusNode.unfocus();
                          FocusScope.of(context).unfocus();
                        },
                        onFetchNeeded: () {
                          context.read<PropertyFormBloc>().add(
                            PropertyFormCondoProjectsFetched(
                              developerId: state.selectedDeveloperId,
                              refresh: true,
                            ),
                          );
                        },
                      );
                    } else {
                      // Refresh logic for House Projects
                      if (state.houseProjects.isNotEmpty &&
                          state.houseProjects.length !=
                              _lastHouseProjectsLength) {
                        _lastHouseProjectsLength = state.houseProjects.length;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            _houseProjectSuggestionsController.refresh();
                          }
                        });
                      } else if (state.houseProjects.isEmpty) {
                        _lastHouseProjectsLength = 0;
                      }

                      return _buildMasterDataTypeAhead<HouseProject>(
                        controller: _projectController,
                        focusNode: _projectFocusNode,
                        suggestionsController:
                            _houseProjectSuggestionsController,
                        emptyMessage: 'ไม่พบรายการ',
                        label: AppLocalizations.of(context).projectNameHint,
                        hintText: AppLocalizations.of(context).projectNameHint,
                        items: state.houseProjects,
                        itemsGetter: () => context
                            .read<PropertyFormBloc>()
                            .state
                            .houseProjects,
                        isRequired: false,
                        fetchingSelector: (s) => s.isFetchingProjects,
                        nameSelector: (p) => isTh ? p.nameTh : p.nameEn,
                        subtitleSelector: (p) => isTh ? p.nameEn : p.nameTh,
                        onSelected: (project) {
                          _projectController.text = isTh
                              ? project.nameTh
                              : project.nameEn;
                          // Update village name string
                          _updateData(
                            'project',
                            isTh ? project.nameTh : project.nameEn,
                          );

                          final bloc = context.read<PropertyFormBloc>();
                          // Auto-fill developer if empty or mismatch
                          final dev = state.developers
                              .where((d) => d.id == project.developerId)
                              .firstOrNull;
                          if (dev != null &&
                              (_developerController.text.isEmpty ||
                                  state.selectedDeveloperId != dev.id)) {
                            _developerController.text = isTh
                                ? dev.nameTh
                                : dev.nameEn;
                            _updateData(
                              'developer',
                              isTh ? dev.nameTh : dev.nameEn,
                            );
                            bloc.add(PropertyFormDeveloperChanged(dev.id));
                          }

                          bloc.add(PropertyFormHouseProjectChanged(project.id));

                          _projectFocusNode.unfocus();
                          FocusScope.of(context).unfocus();
                        },
                        onFetchNeeded: () {
                          context.read<PropertyFormBloc>().add(
                            PropertyFormHouseProjectsFetched(
                              developerId: state.selectedDeveloperId,
                              refresh: true,
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).searchProjectDescription,
                  style: GoogleFonts.anuphan(
                    color: AppColors.baseGrey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  width: double.infinity,
                  text: AppLocalizations.of(context).addProjectNameTitle,
                  style: AppButtonStyle.outline,
                  backgroundColor: AppColors.brandLightGreen,
                  textColor: AppColors.brandGreen,
                  borderColor: AppColors.brandGreen.withValues(alpha: 0.16),
                  iconPath: 'assets/icons/plus.svg',
                  onPressed: _addProject,
                ),
                const SizedBox(height: 16),

                if (isCondoOrApt && state.selectedCondoProjectId != null) ...[
                  if (_juristicPhoneController.text.isNotEmpty) ...[
                    AppTextFormField(
                      label: AppLocalizations.of(
                        context,
                      ).juristicContactPhoneLabel,
                      controller: _juristicPhoneController,
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_juristicEmailController.text.isNotEmpty) ...[
                    AppTextFormField(
                      label: AppLocalizations.of(
                        context,
                      ).juristicContactEmailLabel,
                      controller: _juristicEmailController,
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                  ],
                ],

                // Building Info
                AppTextFormField(
                  label: AppLocalizations.of(context).buildingHint,
                  controller: _buildingController,
                  hintText: AppLocalizations.of(context).buildingHint,
                ),
                const SizedBox(height: 16),
                if (isCondoOrApt) ...[
                  AppTextFormField(
                    label: AppLocalizations.of(context).floorUnit,
                    controller: _floorController,
                    hintText: AppLocalizations.of(context).floorUnit,
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context).this_field_required;
                      }
                      return null;
                    },
                    suffix: Tooltip(
                      triggerMode: TooltipTriggerMode.tap,
                      preferBelow: false,
                      message: AppLocalizations.of(context).roomUnitTooltip,
                      decoration: BoxDecoration(
                        color: AppColors.baseBlack,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: GoogleFonts.anuphan(
                        color: AppColors.baseWhite,
                        fontSize: 12,
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/info.svg',
                        width: 16,
                        height: 16,
                        colorFilter: ColorFilter.mode(
                          AppColors.baseGrey,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextFormField(
                    label: AppLocalizations.of(context).roomNoHint,
                    controller: _roomNoController,
                    hintText: AppLocalizations.of(context).roomNoHint,
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context).this_field_required;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                // Address
                if (!isCondoOrApt)
                  AppTextFormField(
                    label: AppLocalizations.of(context).houseNoHint,
                    controller: _houseNoController,
                    isRequired: true,
                    hintText: AppLocalizations.of(context).houseNoHint,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return AppLocalizations.of(context).this_field_required;
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 16),

                // Location Section
                AppTextFormField(
                  label: AppLocalizations.of(context).locationTitle,
                  controller: _addressController,
                  hintText: AppLocalizations.of(context).locationTitle,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context).this_field_required;
                    }
                    return null;
                  },
                  readOnly: false,
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
                  AppLocalizations.of(context).locationDescription,
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
                    child: MapView(
                      key: const ValueKey('general_info_map'),
                      properties: const [],
                      height: 200,
                      initialLocation: currentLatLng,
                      cameraTarget: currentLatLng,
                      showCenterMarker: currentLatLng != null,
                      // เมื่อยังไม่มีตำแหน่ง อย่าส่ง onCameraIdle เพื่อไม่ให้การแสดง center ของแผนที่ไปตั้งที่อยู่/หมุด
                      onCameraIdle: currentLatLng != null
                          ? _updateLocationFromLatLng
                          : null,
                      onMaximizeTapped: _openLocationSearch,
                    ),
                  ),
                ),
                if (state.showErrors && currentLatLng == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child: Text(
                      AppLocalizations.of(context).this_field_required,
                      style: GoogleFonts.anuphan(
                        color: AppColors.error,
                        fontSize: 12,
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
                        text: AppLocalizations.of(
                          context,
                        ).useCurrentLocationLabel,
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
                        text: AppLocalizations.of(context).clearLocationLabel,
                        style: AppButtonStyle.outline,
                        onPressed: _clearLocation,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
