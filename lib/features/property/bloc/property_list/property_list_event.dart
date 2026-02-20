import 'package:equatable/equatable.dart';

abstract class PropertyListEvent extends Equatable {
  const PropertyListEvent();

  @override
  List<Object?> get props => [];
}

class PropertyListFetched extends PropertyListEvent {
  final bool isRefresh;

  const PropertyListFetched({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class PropertyListRefresh extends PropertyListEvent {}
