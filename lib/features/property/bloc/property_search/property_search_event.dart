import 'package:equatable/equatable.dart';

abstract class PropertySearchEvent extends Equatable {
  const PropertySearchEvent();

  @override
  List<Object?> get props => [];
}

class PropertySearchOpened extends PropertySearchEvent {
  const PropertySearchOpened();
}

class PropertySearchSubmitted extends PropertySearchEvent {
  final String query;
  final String? listingType;

  const PropertySearchSubmitted({required this.query, this.listingType});

  @override
  List<Object?> get props => [query, listingType];
}

class PropertySearchLoadMore extends PropertySearchEvent {
  const PropertySearchLoadMore();
}

class PropertySearchCleared extends PropertySearchEvent {
  const PropertySearchCleared();
}

class PropertySearchRecentLoaded extends PropertySearchEvent {
  final List<String> recent;

  const PropertySearchRecentLoaded(this.recent);

  @override
  List<Object?> get props => [recent];
}
