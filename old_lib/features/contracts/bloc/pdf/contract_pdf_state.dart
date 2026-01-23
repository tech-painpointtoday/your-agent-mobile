import 'dart:typed_data';
import 'package:equatable/equatable.dart';

class ContractPdfState extends Equatable {
  final Uint8List? pdfBytes;
  final bool isLoading;
  final String? errorMessage;
  final int? contractId;
  final int currentPage;
  final int totalPages;
  final bool fitToWidth;
  final double zoomPercentage;
  final double? baseScale;
  final bool isDownloading;

  const ContractPdfState({
    this.pdfBytes,
    this.isLoading = false,
    this.errorMessage,
    this.contractId,
    this.currentPage = 1,
    this.totalPages = 1,
    this.fitToWidth = true,
    this.zoomPercentage = 100.0,
    this.baseScale,
    this.isDownloading = false,
  });

  factory ContractPdfState.initial() {
    return const ContractPdfState();
  }

  ContractPdfState copyWith({
    Uint8List? pdfBytes,
    bool? isLoading,
    String? errorMessage,
    int? contractId,
    int? currentPage,
    int? totalPages,
    bool? fitToWidth,
    double? zoomPercentage,
    double? baseScale,
    bool? isDownloading,
  }) {
    return ContractPdfState(
      pdfBytes: pdfBytes ?? this.pdfBytes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      contractId: contractId ?? this.contractId,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      fitToWidth: fitToWidth ?? this.fitToWidth,
      zoomPercentage: zoomPercentage ?? this.zoomPercentage,
      baseScale: baseScale ?? this.baseScale,
      isDownloading: isDownloading ?? this.isDownloading,
    );
  }

  @override
  List<Object?> get props => [
    pdfBytes,
    isLoading,
    errorMessage,
    contractId,
    currentPage,
    totalPages,
    fitToWidth,
    zoomPercentage,
    baseScale,
    isDownloading,
  ];
}
