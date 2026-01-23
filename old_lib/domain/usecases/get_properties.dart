import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:youragent/core/errors/failures.dart';
import '../entities/property.dart';
import '../repositories/property_repository.dart';

class GetProperties {
  final PropertyRepository repository;

  GetProperties(this.repository);

  Future<Either<Failure, List<Property>>> call(Params params) async {
    return await repository.getProperties(
      location: params.location,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
    );
  }
}

class Params extends Equatable {
  final String? location;
  final int? minPrice;
  final int? maxPrice;

  const Params({this.location, this.minPrice, this.maxPrice});

  @override
  List<Object?> get props => [location, minPrice, maxPrice];
}
