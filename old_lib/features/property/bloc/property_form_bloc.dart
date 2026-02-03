import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/domain/entities/property_image.dart';
import 'package:youragent/domain/entities/property_enums.dart';
import 'package:youragent/data/models/developer_model.dart';
import 'package:youragent/data/models/condo_project_model.dart';
import 'property_form_event.dart';
import 'property_form_state.dart';

/// BLoC for handling property form state management
class PropertyFormBloc extends Bloc<PropertyFormEvent, PropertyFormState> {
  PropertyFormBloc() : super(PropertyFormInitial()) {
    on<PropertyFormInitialized>(_onInitialized);
    on<PropertyFormFieldUpdated>(_onFieldUpdated);
    on<PropertyFormTypeChanged>(_onTypeChanged);
    on<PropertyFormStatusChanged>(_onStatusChanged);
    on<PropertyFormSaleTypeChanged>(_onSaleTypeChanged);
    on<PropertyFormStyleChanged>(_onStyleChanged);
    on<PropertyFormColorChanged>(_onColorChanged);
    on<PropertyFormDirectionChanged>(_onDirectionChanged);
    on<PropertyFormCountryChanged>(_onCountryChanged);
    on<PropertyFormBuiltDateChanged>(_onBuiltDateChanged);
    on<PropertyFormAvailableFromDateChanged>(_onAvailableFromDateChanged);
    on<PropertyFormHighlightsChanged>(_onHighlightsChanged);
    on<PropertyFormCommonAreasChanged>(_onCommonAreasChanged);
    on<PropertyFormFurnitureChanged>(_onFurnitureChanged);
    on<PropertyFormAirConditioningChanged>(_onAirConditioningChanged);
    on<PropertyFormLocationChanged>(_onLocationChanged);
    on<PropertyFormAddressUpdated>(_onAddressUpdated);
    on<PropertyFormPhotoAdded>(_onPhotoAdded);
    on<PropertyFormPhotoRemoved>(_onPhotoRemoved);
    on<PropertyFormExistingPhotoRemoved>(_onExistingPhotoRemoved);
    on<PropertyFormFilterOptionsLoadRequested>(_onFilterOptionsLoadRequested);
    on<PropertyFormFilterOptionsLoaded>(_onFilterOptionsLoaded);
    on<PropertyFormReset>(_onReset);
    on<PropertyFormLoadMasterData>(_onLoadMasterData);
    on<PropertyFormDeveloperChanged>(_onDeveloperChanged);
    on<PropertyFormCondoProjectChanged>(_onCondoProjectChanged);
    on<PropertyFormCondoFieldUpdated>(_onCondoFieldUpdated);
    on<PropertyFormHouseFieldUpdated>(_onHouseFieldUpdated);
  }

  final _propertyApiService = DependencyInjection.propertyApiService;

  Future<void> _onInitialized(
    PropertyFormInitialized event,
    Emitter<PropertyFormState> emit,
  ) async {
    // Load Thai addresses
    List<Map<String, dynamic>> thaiAddresses = [];
    try {
      final String response = await rootBundle.loadString(
        'assets/etc/thai_address.json',
      );
      final List<dynamic> data = json.decode(response);
      thaiAddresses = data.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error loading Thai addresses: $e');
    }

    // Initialize state with property data if available
    PropertyFormData initialState = PropertyFormData(
      thaiAddresses: thaiAddresses,
      isLoadingAddress: false,
    );

    if (event.property != null) {
      final property = event.property!;
      final specs = property.specs;
      final location = property.propertyLocation;

      // Load enum values
      PropertyType? selectedType;
      PropertyStatus? selectedStatus;
      SaleType? selectedSaleType;
      PropertyStyle? selectedPropertyStyle;
      PropertyColor? selectedPropertyColor;
      Direction? selectedDirection;
      Country? selectedCountry;

      if (specs != null) {
        selectedType = PropertyType.fromApiValue(specs.type);
        selectedStatus = PropertyStatus.fromApiValue(specs.status);
        selectedPropertyColor = PropertyColor.fromApiValue(specs.houseColor);
      }

      // Load location
      LatLng? selectedLocation;
      String? address;
      String? district;
      String? subdistrict;
      String? state;
      String? province;
      String? country;
      String? postalCode;
      String? soi;
      String? road;

      if (location != null) {
        if (location.latitude != null && location.longitude != null) {
          selectedLocation = LatLng(location.latitude!, location.longitude!);
        }
        address = specs?.address;
        // Prefer dedicated district/subdistrict fields when available
        district = location.district ?? location.city;
        subdistrict = location.subdistrict;
        // Load province from location.province, fallback to location.state
        province = location.province ?? location.state;
        state = location.state;
        country = location.country;
        postalCode = location.postalCode;
        // Load soi and road from location object directly
        soi = location.soi;
        road = location.road;
        selectedCountry = Country.fromApiValue(location.country);
        // Load direction from location
        if (location.direction != null) {
          selectedDirection = Direction.fromApiValue(location.direction);
        }
      }

      // Load specification values
      List<String> selectedHighlights = [];
      List<String> selectedCommonAreas = [];
      List<String> selectedFurniture = [];
      List<String> selectedAirConditioning = [];

      if (specs?.specificationValues != null) {
        final valuesMap = specs!.specificationValues!;
        if (valuesMap['good_points'] is List) {
          selectedHighlights = (valuesMap['good_points'] as List)
              .map((e) => e.toString())
              .toList();
        } else if (valuesMap['highlight'] is List) {
          selectedHighlights = (valuesMap['highlight'] as List)
              .map((e) => e.toString())
              .toList();
        }
        if (valuesMap['common_facilities'] is List) {
          selectedCommonAreas = (valuesMap['common_facilities'] as List)
              .map((e) => e.toString())
              .toList();
        } else if (valuesMap['common_facility'] is List) {
          selectedCommonAreas = (valuesMap['common_facility'] as List)
              .map((e) => e.toString())
              .toList();
        }
        if (valuesMap['furniture'] is List) {
          selectedFurniture = (valuesMap['furniture'] as List)
              .map((e) => e.toString())
              .toList();
        }
        if (valuesMap['air_conditioning'] is List) {
          selectedAirConditioning = (valuesMap['air_conditioning'] as List)
              .map((e) => e.toString())
              .toList();
        }
      }

      // Load dates
      DateTime? builtDate;
      if (property.built != null) {
        final builtValue = property.built!.trim();
        if (builtValue.length == 4 && int.tryParse(builtValue) != null) {
          builtDate = DateTime(int.parse(builtValue), 1, 1);
        } else {
          try {
            builtDate = DateTime.parse(builtValue);
          } catch (_) {
            final yearMatch = RegExp(r'\d{4}').firstMatch(builtValue);
            if (yearMatch != null) {
              builtDate = DateTime(int.parse(yearMatch.group(0)!), 1, 1);
            }
          }
        }
      }

      DateTime? availableFromDate;
      if (specs?.availableFrom != null) {
        try {
          availableFromDate = DateTime.parse(specs!.availableFrom!);
        } catch (_) {
          // Ignore parse errors
        }
      }

      // Load listing_type (maps to SaleType)
      if (property.listingType != null) {
        selectedSaleType = SaleType.fromApiValue(property.listingType);
      }

      // Load from specifications map
      if (specs?.specifications != null) {
        final specMap = specs!.specifications!;
        if (specMap['sale_type'] != null) {
          selectedSaleType = SaleType.fromApiValue(
            specMap['sale_type'].toString(),
          );
        }
        if (specMap['style'] != null) {
          selectedPropertyStyle = PropertyStyle.fromApiValue(
            specMap['style'].toString(),
          );
        }
      }

      // Load existing photos
      List<PropertyImage> existingPhotos = [];
      if (property.images != null) {
        existingPhotos = property.images!;
      }

      // Load condo details
      CondoProject? selectedCondoProject;
      String? tower;
      String? condoFloor;
      String? unitNo;
      Developer? selectedDeveloper;
      int? pendingCondoProjectId; // Store ID to match after master data loads
      if (property.condoDetails != null) {
        final condo = property.condoDetails!;
        tower = condo.tower;
        condoFloor = condo.floor;
        unitNo = condo.unitNo;
        pendingCondoProjectId = condo.condoProjectId;
        // Also try to load developer from nested condo_project if available
        if (property.condoDetails != null &&
            property.condoDetails!.condoProjectId != null) {
          // Developer will be loaded from condo project after master data loads
        }
      }

      // Load house details
      String? villageName;
      String? moo;
      String? houseSubtype;
      String? parkingType;
      bool? isCornerPlot;
      String? houseNotes;
      if (property.houseDetails != null) {
        final house = property.houseDetails!;
        villageName = house.villageName;
        moo = house.moo;
        houseSubtype = house.houseSubtype;
        parkingType = house.parkingType;
        isCornerPlot = house.isCornerPlot;
        houseNotes = house.notes;
      }

      // Load text field values
      String? propertyName;
      String? propertyCode;
      String? floors;
      String? bedrooms;
      String? bathrooms;
      String? garage;
      String? price;
      String? landSize;
      String? buildingSize;
      String? description;
      String? additionalDetails;
      String? houseNumber;
      // soi and road are already loaded from location above
      String? availableFrom;

      if (specs != null) {
        propertyName = specs.name;
        description = specs.description;
        price = specs.price;
        if (specs.landSize != null) {
          landSize = NumberFormat('#,##0.00').format(specs.landSize!);
        }
        if (specs.buildingSize != null) {
          buildingSize = NumberFormat('#,##0.00').format(specs.buildingSize!);
        }
        availableFrom = specs.availableFrom;
      }

      // Load floors - check property first, then specifications map
      if (property.floors != null) {
        floors = property.floors.toString();
      }
      // Also check specifications map for floors
      if (specs?.specifications != null) {
        final specMap = specs!.specifications!;
        if (specMap['floors'] != null && floors == null) {
          floors = specMap['floors'].toString();
        }
      }

      // Load bedrooms, bathrooms, garage from specs
      if (specs != null) {
        bedrooms = specs.bedrooms.toString();
        bathrooms = specs.bathrooms.toString();
        garage = specs.garage.toString();
      }

      // Also check specifications map for these values (they might override)
      if (specs?.specifications != null) {
        final specMap = specs!.specifications!;
        if (specMap['bedrooms'] != null) {
          bedrooms = specMap['bedrooms'].toString();
        }
        if (specMap['bathrooms'] != null) {
          bathrooms = specMap['bathrooms'].toString();
        }
        if (specMap['parking_spaces'] != null) {
          garage = specMap['parking_spaces'].toString();
        }
      }

      // Generate property code: YH + 2-digit year + 6-digit property ID
      if (property.id != null) {
        final year = property.createdAt?.year ?? DateTime.now().year;
        final yearSuffix = (year % 100).toString().padLeft(2, '0');
        final propertyIdFormatted = property.id!.toString().padLeft(6, '0');
        propertyCode = 'YH$yearSuffix$propertyIdFormatted';
      }

      if (location != null) {
        houseNumber = location.number;
        // soi and road are already loaded from location above
        // Only use specifications map as fallback if location values are null
      }

      initialState = initialState.copyWith(
        selectedType: selectedType,
        selectedStatus: selectedStatus,
        selectedSaleType: selectedSaleType,
        selectedPropertyStyle: selectedPropertyStyle,
        selectedPropertyColor: selectedPropertyColor,
        selectedDirection: selectedDirection,
        selectedCountry: selectedCountry,
        builtDate: builtDate,
        availableFromDate: availableFromDate,
        selectedLocation: selectedLocation,
        address: address,
        district: district,
        subdistrict: subdistrict,
        state: state ?? province, // Use province as fallback for state
        country: country,
        postalCode: postalCode,
        selectedHighlights: selectedHighlights,
        selectedCommonAreas: selectedCommonAreas,
        selectedFurniture: selectedFurniture,
        selectedAirConditioning: selectedAirConditioning,
        existingPhotos: existingPhotos,
        propertyName: propertyName,
        propertyCode: propertyCode,
        floors: floors,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        garage: garage,
        price: price,
        landSize: landSize,
        buildingSize: buildingSize,
        description: description,
        additionalDetails: additionalDetails,
        houseNumber: houseNumber,
        soi: soi,
        road: road,
        availableFrom: availableFrom,
        selectedDeveloper: selectedDeveloper,
        selectedCondoProject: selectedCondoProject,
        pendingCondoProjectId: pendingCondoProjectId,
        tower: tower,
        condoFloor: condoFloor,
        unitNo: unitNo,
        villageName: villageName,
        moo: moo,
        houseSubtype: houseSubtype,
        parkingType: parkingType,
        isCornerPlot: isCornerPlot,
        houseNotes: houseNotes,
      );
    } else {
      // Set defaults for create mode
      initialState = initialState.copyWith(
        selectedType: PropertyType.house,
        selectedStatus: PropertyStatus.available,
        selectedPropertyColor: PropertyColor.white,
        selectedDirection: Direction.north,
        selectedCountry: Country.thailand,
      );
    }

    emit(initialState);

    // Load filter options
    add(PropertyFormFilterOptionsLoadRequested());

    // Load master data (developers)
    add(PropertyFormLoadMasterData());
  }

  void _onFieldUpdated(
    PropertyFormFieldUpdated event,
    Emitter<PropertyFormState> emit,
  ) {
    if (state is PropertyFormData) {
      final currentState = state as PropertyFormData;
      switch (event.field) {
        case 'name':
          emit(currentState.copyWith(propertyName: event.value as String?));
          break;
        case 'price':
          emit(currentState.copyWith(price: event.value as String?));
          break;
        case 'land_size':
          emit(currentState.copyWith(landSize: event.value as String?));
          break;
        case 'building_size':
          emit(currentState.copyWith(buildingSize: event.value as String?));
          break;
        case 'description':
          emit(currentState.copyWith(description: event.value as String?));
          break;
        case 'additional_details':
          emit(
            currentState.copyWith(additionalDetails: event.value as String?),
          );
          break;
        case 'bedrooms':
          emit(currentState.copyWith(bedrooms: event.value as String?));
          break;
        case 'bathrooms':
          emit(currentState.copyWith(bathrooms: event.value as String?));
          break;
        case 'garage':
          emit(currentState.copyWith(garage: event.value as String?));
          break;
        case 'floors':
          emit(currentState.copyWith(floors: event.value as String?));
          break;
        case 'number':
          emit(currentState.copyWith(houseNumber: event.value as String?));
          break;
        case 'soi':
          emit(currentState.copyWith(soi: event.value as String?));
          break;
        case 'road':
          emit(currentState.copyWith(road: event.value as String?));
          break;
      }
    }
  }

  void _onTypeChanged(
    PropertyFormTypeChanged event,
    Emitter<PropertyFormState> emit,
  ) {
    if (state is PropertyFormData) {
      final currentState = state as PropertyFormData;
      emit(currentState.copyWith(selectedType: event.type));

      // Load master data when selecting condominium types
      if (event.type == PropertyType.condominium) {
        if (currentState.developers.isEmpty &&
            !currentState.isLoadingMasterData) {
          add(const PropertyFormLoadMasterData());
        }
      }
    }
  }

  void _onStatusChanged(
    PropertyFormStatusChanged event,
    Emitter<PropertyFormState> emit,
  ) {
    if (state is PropertyFormData) {
      emit((state as PropertyFormData).copyWith(selectedStatus: event.status));
    }
  }

  void _onSaleTypeChanged(
    PropertyFormSaleTypeChanged event,
    Emitter<PropertyFormState> emit,
  ) {
    if (state is PropertyFormData) {
      emit(
        (state as PropertyFormData).copyWith(selectedSaleType: event.saleType),
      );
    }
  }

  void _onStyleChanged(
    PropertyFormStyleChanged event,
    Emitter<PropertyFormState> emit,
  ) {
    if (state is PropertyFormData) {
      emit(
        (state as PropertyFormData).copyWith(
          selectedPropertyStyle: event.style,
        ),
      );
    }
  }

  void _onColorChanged(
    PropertyFormColorChanged event,
    Emitter<PropertyFormState> emit,
  ) {
    if (state is PropertyFormData) {
      emit(
        (state as PropertyFormData).copyWith(
          selectedPropertyColor: event.color,
        ),
      );
    }
  }

  void _onDirectionChanged(
    PropertyFormDirectionChanged event,
    Emitter<PropertyFormState> emit,
  ) {
    if (state is PropertyFormData) {
      emit(
        (state as PropertyFormData).copyWith(
          selectedDirection: event.direction,
        ),
      );
    }
  }

  void _onCountryChanged(
    PropertyFormCountryChanged event,
    Emitter<PropertyFormState> emit,
  ) {
    if (state is PropertyFormData) {
      emit(
        (state as PropertyFormData).copyWith(selectedCountry: event.country),
      );
    }
  }

  void _onBuiltDateChanged(
    PropertyFormBuiltDateChanged event,
    Emitter<PropertyFormState> emit,
  ) {
    if (state is PropertyFormData) {
      emit((state as PropertyFormData).copyWith(builtDate: event.date));
    }
  }

  void _onAvailableFromDateChanged(
    PropertyFormAvailableFromDateChanged event,
    Emitter<PropertyFormState> emit,
  ) {
    if (state is PropertyFormData) {
      emit((state as PropertyFormData).copyWith(availableFromDate: event.date));
    }
  }

  void _onHighlightsChanged(
    PropertyFormHighlightsChanged event,
    Emitter<PropertyFormState> emit,
  ) {
    if (state is PropertyFormData) {
      emit(
        (state as PropertyFormData).copyWith(
          selectedHighlights: event.highlights,
        ),
      );
    }
  }

  void _onCommonAreasChanged(
    PropertyFormCommonAreasChanged event,
    Emitter<PropertyFormState> emit,
  ) {
    if (state is PropertyFormData) {
      emit(
        (state as PropertyFormData).copyWith(
          selectedCommonAreas: event.commonAreas,
        ),
      );
    }
  }

  void _onFurnitureChanged(
    PropertyFormFurnitureChanged event,
    Emitter<PropertyFormState> emit,
  ) {
    if (state is PropertyFormData) {
      emit(
        (state as PropertyFormData).copyWith(
          selectedFurniture: event.furniture,
        ),
      );
    }
  }

  void _onAirConditioningChanged(
    PropertyFormAirConditioningChanged event,
    Emitter<PropertyFormState> emit,
  ) {
    if (state is PropertyFormData) {
      emit(
        (state as PropertyFormData).copyWith(
          selectedAirConditioning: event.airConditioning,
        ),
      );
    }
  }

  void _onLocationChanged(
    PropertyFormLocationChanged event,
    Emitter<PropertyFormState> emit,
  ) {
    if (state is PropertyFormData) {
      emit(
        (state as PropertyFormData).copyWith(selectedLocation: event.location),
      );
    }
  }

  void _onAddressUpdated(
    PropertyFormAddressUpdated event,
    Emitter<PropertyFormState> emit,
  ) {
    if (state is PropertyFormData) {
      emit(
        (state as PropertyFormData).copyWith(
          address: event.address,
          district: event.district,
          subdistrict: event.subdistrict,
          state: event.state,
          country: event.country,
          postalCode: event.postalCode,
          houseNumber: event.houseNumber,
          number: event.number,
          soi: event.soi,
          road: event.road,
        ),
      );
    }
  }

  void _onPhotoAdded(
    PropertyFormPhotoAdded event,
    Emitter<PropertyFormState> emit,
  ) {
    if (state is PropertyFormData) {
      final currentPhotos = (state as PropertyFormData).newPhotos;
      emit(
        (state as PropertyFormData).copyWith(
          newPhotos: [...currentPhotos, event.photo],
        ),
      );
    }
  }

  void _onPhotoRemoved(
    PropertyFormPhotoRemoved event,
    Emitter<PropertyFormState> emit,
  ) {
    if (state is PropertyFormData) {
      final currentPhotos = (state as PropertyFormData).newPhotos;
      final updatedPhotos = List<XFile>.from(currentPhotos)
        ..removeAt(event.index);
      emit((state as PropertyFormData).copyWith(newPhotos: updatedPhotos));
    }
  }

  void _onExistingPhotoRemoved(
    PropertyFormExistingPhotoRemoved event,
    Emitter<PropertyFormState> emit,
  ) {
    if (state is PropertyFormData) {
      final currentPhotos = (state as PropertyFormData).existingPhotos;
      final updatedPhotos = List<PropertyImage>.from(currentPhotos)
        ..removeAt(event.index);
      emit((state as PropertyFormData).copyWith(existingPhotos: updatedPhotos));
    }
  }

  Future<void> _onFilterOptionsLoadRequested(
    PropertyFormFilterOptionsLoadRequested event,
    Emitter<PropertyFormState> emit,
  ) async {
    if (state is PropertyFormData) {
      emit((state as PropertyFormData).copyWith(isLoadingFilterOptions: true));
    }

    try {
      final filterInfo = await DependencyInjection.propertyApiService
          .getPublicFilterInfo();

      final Map<String, List<String>> options = {};

      // Map single select filters
      for (final filter in filterInfo.singleSelect) {
        options[filter.key] = filter.options;
      }

      // Map multi select filters
      for (final filter in filterInfo.multiSelect) {
        options[filter.key] = filter.options;
      }

      add(PropertyFormFilterOptionsLoaded(options));
    } catch (e) {
      debugPrint('Error loading filter options: $e');
      if (state is PropertyFormData) {
        emit(
          (state as PropertyFormData).copyWith(isLoadingFilterOptions: false),
        );
      }
    }
  }

  void _onFilterOptionsLoaded(
    PropertyFormFilterOptionsLoaded event,
    Emitter<PropertyFormState> emit,
  ) {
    if (state is PropertyFormData) {
      emit(
        (state as PropertyFormData).copyWith(
          filterOptions: event.options,
          isLoadingFilterOptions: false,
        ),
      );
    }
  }

  void _onReset(PropertyFormReset event, Emitter<PropertyFormState> emit) {
    emit(PropertyFormInitial());
  }

  Future<void> _onLoadMasterData(
    PropertyFormLoadMasterData event,
    Emitter<PropertyFormState> emit,
  ) async {
    if (state is PropertyFormData) {
      emit((state as PropertyFormData).copyWith(isLoadingMasterData: true));

      try {
        // Load developers and condo projects in parallel
        final developers = await _propertyApiService.getDevelopers();
        final condoProjects = await _propertyApiService.getCondoProjects();

        final currentState = state as PropertyFormData;

        // Match pending condo project if we have one
        CondoProject? matchedCondoProject;
        Developer? matchedDeveloper;
        if (currentState.pendingCondoProjectId != null) {
          try {
            matchedCondoProject = condoProjects.firstWhere(
              (project) => project.id == currentState.pendingCondoProjectId,
            );
            // Also match developer from condo project
            if (matchedCondoProject.developerId != null) {
              try {
                matchedDeveloper = developers.firstWhere(
                  (dev) => dev.id == matchedCondoProject!.developerId,
                );
              } catch (e) {
                debugPrint(
                  'Developer not found for condo project: ${matchedCondoProject.developerId}',
                );
              }
            }
          } catch (e) {
            debugPrint(
              'Condo project not found: ${currentState.pendingCondoProjectId}',
            );
          }
        }

        emit(
          currentState.copyWith(
            developers: developers,
            condoProjects: condoProjects,
            isLoadingMasterData: false,
            selectedCondoProject:
                matchedCondoProject ?? currentState.selectedCondoProject,
            selectedDeveloper:
                matchedDeveloper ?? currentState.selectedDeveloper,
            pendingCondoProjectId: null, // Clear after matching
          ),
        );
      } catch (e) {
        debugPrint('Error loading master data: $e');
        emit((state as PropertyFormData).copyWith(isLoadingMasterData: false));
      }
    }
  }

  Future<void> _onDeveloperChanged(
    PropertyFormDeveloperChanged event,
    Emitter<PropertyFormState> emit,
  ) async {
    if (state is PropertyFormData) {
      final currentState = state as PropertyFormData;

      // If developer actually changed (different id or null), clear condo project.
      final bool isSameDeveloper =
          event.developer?.id == currentState.selectedDeveloper?.id;

      emit(
        currentState.copyWith(
          selectedDeveloper: event.developer,
          clearSelectedCondoProject: !isSameDeveloper,
        ),
      );

      print(
        'currentState.selectedCondoProject: ${currentState.selectedCondoProject?.name}',
      );
    }
  }

  void _onCondoProjectChanged(
    PropertyFormCondoProjectChanged event,
    Emitter<PropertyFormState> emit,
  ) {
    if (state is PropertyFormData) {
      final currentState = state as PropertyFormData;
      Developer? autoSelectedDeveloper;

      // Auto-select developer if project is selected first (before developer)
      if (event.project != null &&
          event.project!.developerId != null &&
          currentState.selectedDeveloper == null) {
        try {
          autoSelectedDeveloper = currentState.developers.firstWhere(
            (dev) => dev.id == event.project!.developerId,
          );
        } catch (e) {
          debugPrint(
            'Developer not found for project: ${event.project!.developerId}',
          );
        }
      }

      emit(
        currentState.copyWith(
          selectedCondoProject: event.project,
          selectedDeveloper:
              autoSelectedDeveloper ?? currentState.selectedDeveloper,
        ),
      );
    }
  }

  void _onCondoFieldUpdated(
    PropertyFormCondoFieldUpdated event,
    Emitter<PropertyFormState> emit,
  ) {
    if (state is PropertyFormData) {
      final currentState = state as PropertyFormData;
      switch (event.field) {
        case 'tower':
          emit(currentState.copyWith(tower: event.value as String?));
          break;
        case 'floor':
          emit(currentState.copyWith(condoFloor: event.value as String?));
          break;
        case 'unitNo':
          emit(currentState.copyWith(unitNo: event.value as String?));
          break;
      }
    }
  }

  void _onHouseFieldUpdated(
    PropertyFormHouseFieldUpdated event,
    Emitter<PropertyFormState> emit,
  ) {
    if (state is PropertyFormData) {
      final currentState = state as PropertyFormData;
      switch (event.field) {
        case 'villageName':
          emit(currentState.copyWith(villageName: event.value as String?));
          break;
        case 'moo':
          emit(currentState.copyWith(moo: event.value as String?));
          break;
        case 'houseSubtype':
          emit(currentState.copyWith(houseSubtype: event.value as String?));
          break;
        case 'parkingType':
          emit(currentState.copyWith(parkingType: event.value as String?));
          break;
        case 'isCornerPlot':
          emit(currentState.copyWith(isCornerPlot: event.value as bool?));
          break;
        case 'notes':
          emit(currentState.copyWith(houseNotes: event.value as String?));
          break;
      }
    }
  }
}
