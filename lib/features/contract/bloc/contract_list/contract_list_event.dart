import 'package:equatable/equatable.dart';

abstract class ContractListEvent extends Equatable {
  const ContractListEvent();

  @override
  List<Object> get props => [];
}

class ContractListFetched extends ContractListEvent {
  final bool isRefresh;
  const ContractListFetched({this.isRefresh = false});

  @override
  List<Object> get props => [isRefresh];
}

class ContractListRefresh extends ContractListEvent {}
