import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/services/property_api_service.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/domain/entities/user.dart';
import 'property_create_event.dart';
import 'property_create_state.dart';

/// BLoC for handling property creation flow
class PropertyCreateBloc
    extends Bloc<PropertyCreateEvent, PropertyCreateState> {
  final PropertyApiService _propertyApiService;

  PropertyCreateBloc({required PropertyApiService propertyApiService})
    : _propertyApiService = propertyApiService,
      super(PropertyCreateInitial()) {
    on<PropertyCreateSubmitted>(_onSubmitted);
    on<PropertyCreateReset>(_onReset);
  }

  Future<void> _onSubmitted(
    PropertyCreateSubmitted event,
    Emitter<PropertyCreateState> emit,
  ) async {
    emit(PropertyCreateSubmitting());

    try {
      final formData = event.formData;

      // Validate required fields before calling API
      final name = formData['name'] as String?;
      if (name == null || name.trim().isEmpty) {
        emit(PropertyCreateInitial()); // Reset to initial state
        throw Exception('The name field is required.');
      }

      // Get current role
      final role =
          DependencyInjection.authRepository.currentRole ?? UserRole.agent;
      final roleName = role.name;

      // Generate formatted addresses
      final formattedAddressTh = _generateFormattedAddressTh(formData);
      final formattedAddressEn = _generateFormattedAddressEn(formData);

      // Build unified payload
      final payload = <String, dynamic>{
        'built': formData['built'] as String? ?? '',
        'name': name,
        'type': formData['type'] as String?,
        'status': formData['status'] as String?,
        'bedrooms': formData['bedrooms'] as int?,
        'bathrooms': formData['bathrooms'] as int?,
        'garage': formData['garage'] as int?,
        'address': formData['address'] as String?,
        'price': formData['price'] as double?,
        'description': formData['description'] as String?,
        'land_size': formData['land_size'] as double?,
        'building_size': formData['building_size'] as double?,
        'available_from': formData['available_from'] as String?,
        'house_color': formData['house_color'] as String?,
        'direction': formData['direction'] as String?,
        'number': formData['number'] as String?,
        'city': formData['city'] as String?,
        'state': formData['state'] as String?,
        'country': formData['country'] as String?,
        'district': formData['specifications']?['district'] as String?,
        'province': formData['state'] as String?,
        'subdistrict': formData['specifications']?['subdistrict'] as String?,
        'road': formData['specifications']?['road'] as String?,
        'soi': formData['specifications']?['soi'] as String?,
        'postal_code': formData['postal_code'] as String?,
        'latitude': formData['latitude'] as double?,
        'longitude': formData['longitude'] as double?,
        'formatted_address_th': formattedAddressTh,
        'formatted_address_en': formattedAddressEn,
        'specifications': formData['specifications'] as Map<String, dynamic>?,
        'specification_values':
            formData['specification_values'] as Map<String, List<String>>?,
      };

      // Step 1: Create property using unified endpoint
      final createResponse = await _propertyApiService.saveProperty(
        role: roleName,
        data: payload,
      );
      final propertyId = createResponse.id;

      if (propertyId == null) {
        throw Exception('Failed to create property: No property ID returned');
      }

      // Step 2: Set type-specific details (Condo or House)
      final propertyType = formData['type'] as String?;
      if (propertyType == 'condominium' ||
          propertyType == 'penthouse' ||
          propertyType == 'studio') {
        // Set condo details
        final condoProjectId = formData['condo_project_id'] as int?;
        if (condoProjectId != null) {
          await _propertyApiService.setCondoDetails(
            propertyId: propertyId,
            condoProjectId: condoProjectId,
            tower: formData['tower'] as String?,
            floor: formData['condo_floor'] as String?,
            unitNo: formData['unit_no'] as String?,
          );
        }
      } else if (propertyType == 'house' ||
          propertyType == 'townhouse' ||
          propertyType == 'villa' ||
          propertyType == 'duplex') {
        // Set house details
        await _propertyApiService.setHouseDetails(
          propertyId: propertyId,
          villageName: formData['village_name'] as String?,
          moo: formData['moo'] as String?,
          houseSubtype: formData['house_subtype'] as String?,
          parkingType: formData['parking_type'] as String?,
          isCornerPlot: formData['is_corner_plot'] as bool?,
          notes: formData['house_notes'] as String?,
        );
      }

      // Step 3: Upload photos if any
      if (event.photos.isNotEmpty) {
        await _propertyApiService.uploadPhotosSimple(
          role: roleName,
          propertyId: propertyId,
          photos: event.photos,
          tag: 'gallery',
        );
      }

      emit(PropertyCreateSuccess(propertyId: propertyId));
    } catch (e) {
      // Emit failure state with error message
      // Screen will show StatusDialog and reset state immediately
      emit(PropertyCreateFailure(e.toString()));
    }
  }

  /// Add label prefix if not already present, preventing duplicate prefixes
  String _addLabelIfNotExists(String text, String label) {
    if (text.isEmpty) return text;
    final trimmed = text.trim();

    // Check if text starts with label (case insensitive for English, direct for Thai)
    final textLower = trimmed.toLowerCase();
    final labelLower = label.toLowerCase();

    // For Thai labels, check direct match first (more reliable)
    if (trimmed.startsWith(label)) {
      return trimmed;
    }

    // For English labels, check case-insensitive match
    if (textLower.startsWith(labelLower)) {
      return trimmed;
    }

    return '$label $trimmed';
  }

  /// Generate formatted address in Thai
  String? _generateFormattedAddressTh(Map<String, dynamic> formData) {
    final parts = <String>[];

    final address = formData['address'] as String?;
    final number = formData['number'] as String?;
    final soi = formData['specifications']?['soi'] as String?;
    final road = formData['specifications']?['road'] as String?;
    final subdistrict = formData['specifications']?['subdistrict'] as String?;
    final district = formData['specifications']?['district'] as String?;
    final province = formData['state'] as String?;
    final postalCode = formData['postal_code'] as String?;

    if (number != null && number.isNotEmpty) parts.add(number);
    if (soi != null && soi.isNotEmpty) {
      parts.add(_addLabelIfNotExists(soi, 'ซอย'));
    }
    if (road != null && road.isNotEmpty) {
      parts.add(_addLabelIfNotExists(road, 'ถนน'));
    }
    if (subdistrict != null && subdistrict.isNotEmpty) {
      parts.add(_addLabelIfNotExists(subdistrict, 'แขวง/ตำบล'));
    }
    if (district != null && district.isNotEmpty) {
      parts.add(_addLabelIfNotExists(district, 'เขต/อำเภอ'));
    }
    if (province != null && province.isNotEmpty) {
      parts.add(_addLabelIfNotExists(province, 'จังหวัด'));
    }
    if (postalCode != null && postalCode.isNotEmpty) parts.add(postalCode);

    if (parts.isEmpty && address != null && address.isNotEmpty) {
      return address;
    }

    return parts.isNotEmpty ? parts.join(' ') : null;
  }

  /// Generate formatted address in English
  String? _generateFormattedAddressEn(Map<String, dynamic> formData) {
    final parts = <String>[];

    final address = formData['address'] as String?;
    final number = formData['number'] as String?;
    final soi = formData['specifications']?['soi'] as String?;
    final road = formData['specifications']?['road'] as String?;
    final subdistrict = formData['specifications']?['subdistrict'] as String?;
    final district = formData['specifications']?['district'] as String?;
    final province = formData['state'] as String?;
    final postalCode = formData['postal_code'] as String?;

    if (number != null && number.isNotEmpty) parts.add(number);
    if (soi != null && soi.isNotEmpty) {
      // Strip Thai prefix if present, then add English prefix
      final soiCleaned = soi.replaceAll(RegExp(r'^ซอย\s*'), '').trim();
      parts.add(_addLabelIfNotExists(soiCleaned, 'Soi'));
    }
    if (road != null && road.isNotEmpty) {
      // Strip Thai prefix if present
      final roadCleaned = road.replaceAll(RegExp(r'^ถนน\s*'), '').trim();
      parts.add(roadCleaned);
    }
    if (subdistrict != null && subdistrict.isNotEmpty) {
      // Strip Thai prefix if present
      final subdistrictCleaned = subdistrict
          .replaceAll(RegExp(r'^(แขวง/ตำบล|ตำบล|แขวง)\s*'), '')
          .trim();
      parts.add(_addLabelIfNotExists(subdistrictCleaned, 'Sub-district'));
    }
    if (district != null && district.isNotEmpty) {
      // Strip Thai prefix if present
      final districtCleaned = district
          .replaceAll(RegExp(r'^(เขต/อำเภอ|เขต|อำเภอ)\s*'), '')
          .trim();
      parts.add(_addLabelIfNotExists(districtCleaned, 'District'));
    }
    if (province != null && province.isNotEmpty) {
      // Strip Thai prefix if present
      final provinceCleaned = province
          .replaceAll(RegExp(r'^จังหวัด\s*'), '')
          .trim();
      parts.add(provinceCleaned);
    }
    if (postalCode != null && postalCode.isNotEmpty) parts.add(postalCode);

    if (parts.isEmpty && address != null && address.isNotEmpty) {
      return address;
    }

    return parts.isNotEmpty ? parts.join(', ') : null;
  }

  void _onReset(PropertyCreateReset event, Emitter<PropertyCreateState> emit) {
    emit(PropertyCreateInitial());
  }
}
