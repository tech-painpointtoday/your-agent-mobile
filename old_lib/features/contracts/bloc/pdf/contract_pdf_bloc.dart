import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/services/contract_api_service.dart';
import 'contract_pdf_event.dart';
import 'contract_pdf_state.dart';

class ContractPdfBloc extends Bloc<ContractPdfEvent, ContractPdfState> {
  final ContractApiService _contractApiService =
      DependencyInjection.contractApiService;

  ContractPdfBloc() : super(ContractPdfState.initial()) {
    on<ContractPdfLoad>(_onLoadPdf);
    on<ContractPdfPageChanged>(_onPageChanged);
    on<ContractPdfPreviousPage>(_onPreviousPage);
    on<ContractPdfNextPage>(_onNextPage);
    on<ContractPdfDocumentLoaded>(_onDocumentLoaded);
    on<ContractPdfZoomOut>(_onZoomOut);
    on<ContractPdfZoomIn>(_onZoomIn);
    on<ContractPdfToggleFit>(_onToggleFit);
    on<ContractPdfBaseScaleSet>(_onBaseScaleSet);
    on<ContractPdfResetZoom>(_onResetZoom);
    on<ContractPdfDownloadStarted>(_onDownloadStarted);
    on<ContractPdfDownloadFinished>(_onDownloadFinished);
    on<ContractPdfInitialized>(_onInitialized);
  }

  Future<void> _onLoadPdf(
    ContractPdfLoad event,
    Emitter<ContractPdfState> emit,
  ) async {
    // Cache check: if we already have bytes for the SAME contract, DO NOT reload.
    if (state.pdfBytes != null &&
        state.pdfBytes!.isNotEmpty &&
        state.contractId == event.contractId) {
      return;
    }

    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: null,
        contractId: event.contractId,
        // Clear bytes if switching to a different contract
        pdfBytes: state.contractId == event.contractId ? state.pdfBytes : null,
      ),
    );

    try {
      final bytes = await _contractApiService.getContractPdf(
        contractId: event.contractId,
      );

      if (bytes.isEmpty) {
        throw Exception('Received empty PDF file');
      }

      // Validate PDF signature
      final isPdf =
          bytes.length >= 4 &&
          bytes[0] == 0x25 && // %
          bytes[1] == 0x50 && // P
          bytes[2] == 0x44 && // D
          bytes[3] == 0x46; // F
      if (!isPdf) {
        final preview = utf8.decode(bytes, allowMalformed: true).trim();
        throw Exception(preview.isEmpty ? 'Invalid PDF response' : preview);
      }

      emit(
        state.copyWith(pdfBytes: bytes, isLoading: false, errorMessage: null),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void _onPageChanged(
    ContractPdfPageChanged event,
    Emitter<ContractPdfState> emit,
  ) {
    emit(state.copyWith(currentPage: event.page));
  }

  void _onPreviousPage(
    ContractPdfPreviousPage event,
    Emitter<ContractPdfState> emit,
  ) {
    final newPage = (state.currentPage - 1).clamp(1, state.totalPages);
    if (newPage != state.currentPage) {
      emit(state.copyWith(currentPage: newPage));
    }
  }

  void _onNextPage(ContractPdfNextPage event, Emitter<ContractPdfState> emit) {
    final newPage = (state.currentPage + 1).clamp(1, state.totalPages);
    if (newPage != state.currentPage) {
      emit(state.copyWith(currentPage: newPage));
    }
  }

  void _onDocumentLoaded(
    ContractPdfDocumentLoaded event,
    Emitter<ContractPdfState> emit,
  ) {
    emit(
      state.copyWith(
        totalPages: event.totalPages,
        isLoading: false,
        currentPage: state.currentPage.clamp(1, event.totalPages),
      ),
    );
  }

  void _onZoomOut(ContractPdfZoomOut event, Emitter<ContractPdfState> emit) {
    final newZoom = (state.zoomPercentage - 10).clamp(50.0, 400.0);
    emit(state.copyWith(zoomPercentage: newZoom));
  }

  void _onZoomIn(ContractPdfZoomIn event, Emitter<ContractPdfState> emit) {
    final newZoom = (state.zoomPercentage + 10).clamp(50.0, 400.0);
    emit(state.copyWith(zoomPercentage: newZoom));
  }

  void _onToggleFit(
    ContractPdfToggleFit event,
    Emitter<ContractPdfState> emit,
  ) {
    if (state.fitToWidth) {
      emit(state.copyWith(fitToWidth: false, zoomPercentage: 80.0));
    } else {
      emit(state.copyWith(fitToWidth: true, zoomPercentage: 100.0));
    }
  }

  void _onBaseScaleSet(
    ContractPdfBaseScaleSet event,
    Emitter<ContractPdfState> emit,
  ) {
    emit(state.copyWith(baseScale: event.baseScale));
  }

  void _onResetZoom(
    ContractPdfResetZoom event,
    Emitter<ContractPdfState> emit,
  ) {
    emit(state.copyWith(zoomPercentage: 100.0, fitToWidth: true));
  }

  void _onDownloadStarted(
    ContractPdfDownloadStarted event,
    Emitter<ContractPdfState> emit,
  ) {
    emit(state.copyWith(isDownloading: true));
  }

  void _onDownloadFinished(
    ContractPdfDownloadFinished event,
    Emitter<ContractPdfState> emit,
  ) {
    emit(state.copyWith(isDownloading: false));
  }

  void _onInitialized(
    ContractPdfInitialized event,
    Emitter<ContractPdfState> emit,
  ) {
    emit(
      state.copyWith(
        currentPage: 1,
        totalPages: event.totalPages,
        zoomPercentage: 100.0,
        fitToWidth: true,
        baseScale: null,
      ),
    );
  }
}
