import 'package:dartz/dartz.dart';
import '../entities/property.dart';
import 'package:youragent/core/errors/failures.dart';
import '../entities/user.dart';

abstract class PropertyRepository {
  /// Get all properties (approved only)
  Future<Either<Failure, List<Property>>> getProperties({
    String? location,
    int? minPrice,
    int? maxPrice,
    UserRole? role, // For authenticated requests
  });

  /// Search properties by birthday and location
  Future<Either<Failure, List<Property>>> searchProperties({
    String? birthday, // Format: 'DD MM YYYY'
    String? place, // Location string
    UserRole? role,
  });

  /// Get property by ID
  Future<Either<Failure, Property>> getPropertyById(String id);

  /// Get property status
  Future<Either<Failure, Property>> getPropertyStatus({required UserRole role, required int propertyId});

  /// Track property click
  Future<Either<Failure, void>> trackClick({required int propertyId});

  /// Track property view
  Future<Either<Failure, void>> trackView({required int propertyId});
}
