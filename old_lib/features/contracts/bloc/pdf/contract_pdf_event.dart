import 'package:equatable/equatable.dart';

abstract class ContractPdfEvent extends Equatable {
  const ContractPdfEvent();

  @override
  List<Object?> get props => [];
}

class ContractPdfLoad extends ContractPdfEvent {
  final int contractId;

  const ContractPdfLoad(this.contractId);

  @override
  List<Object?> get props => [contractId];
}

class ContractPdfPageChanged extends ContractPdfEvent {
  final int page;

  const ContractPdfPageChanged(this.page);

  @override
  List<Object?> get props => [page];
}

class ContractPdfPreviousPage extends ContractPdfEvent {
  const ContractPdfPreviousPage();
}

class ContractPdfNextPage extends ContractPdfEvent {
  const ContractPdfNextPage();
}

class ContractPdfDocumentLoaded extends ContractPdfEvent {
  final int totalPages;

  const ContractPdfDocumentLoaded(this.totalPages);

  @override
  List<Object?> get props => [totalPages];
}

class ContractPdfZoomOut extends ContractPdfEvent {
  const ContractPdfZoomOut();
}

class ContractPdfZoomIn extends ContractPdfEvent {
  const ContractPdfZoomIn();
}

class ContractPdfToggleFit extends ContractPdfEvent {
  const ContractPdfToggleFit();
}

class ContractPdfBaseScaleSet extends ContractPdfEvent {
  final double baseScale;

  const ContractPdfBaseScaleSet(this.baseScale);

  @override
  List<Object?> get props => [baseScale];
}

class ContractPdfResetZoom extends ContractPdfEvent {
  const ContractPdfResetZoom();
}

class ContractPdfDownloadStarted extends ContractPdfEvent {
  const ContractPdfDownloadStarted();
}

class ContractPdfDownloadFinished extends ContractPdfEvent {
  const ContractPdfDownloadFinished();
}

class ContractPdfInitialized extends ContractPdfEvent {
  final int totalPages;

  const ContractPdfInitialized(this.totalPages);

  @override
  List<Object?> get props => [totalPages];
}
