import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import '../../../domain/entities/contract.dart';
import '../../../domain/entities/contract_status.dart';
import '../../../services/contract_api_service.dart';
import '../services/contract_pdf_service.dart';

// Events
abstract class ContractDetailEvent extends Equatable {
  const ContractDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchContractDetail extends ContractDetailEvent {
  final int contractId;
  const FetchContractDetail(this.contractId);

  @override
  List<Object?> get props => [contractId];
}

class DeleteContractDetail extends ContractDetailEvent {
  final int contractId;
  const DeleteContractDetail(this.contractId);

  @override
  List<Object?> get props => [contractId];
}

class SendContractToSeller extends ContractDetailEvent {
  final int contractId;
  const SendContractToSeller(this.contractId);

  @override
  List<Object?> get props => [contractId];
}

class SendContractToBuyer extends ContractDetailEvent {
  final int contractId;
  const SendContractToBuyer(this.contractId);

  @override
  List<Object?> get props => [contractId];
}

// States
abstract class ContractDetailState extends Equatable {
  const ContractDetailState();

  @override
  List<Object?> get props => [];
}

class ContractDetailInitial extends ContractDetailState {}

class ContractDetailLoading extends ContractDetailState {}

class ContractDetailLoadedWithoutPdf extends ContractDetailState {
  final Contract contract;
  const ContractDetailLoadedWithoutPdf({required this.contract});

  @override
  List<Object?> get props => [contract];
}

class ContractDetailPdfLoading extends ContractDetailState {
  final Contract contract;
  const ContractDetailPdfLoading({required this.contract});

  @override
  List<Object?> get props => [contract];
}

class ContractDetailLoaded extends ContractDetailState {
  final Contract contract;
  final String? pdfPath;
  final Future<PdfDocument>? pdfDocument;

  const ContractDetailLoaded({
    required this.contract,
    this.pdfPath,
    this.pdfDocument,
  });

  @override
  List<Object?> get props => [contract, pdfPath, pdfDocument];
}

class ContractDeletedSuccess extends ContractDetailState {}

class ContractActionSuccess extends ContractDetailState {
  final String message;
  const ContractActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ContractDetailError extends ContractDetailState {
  final String message;
  const ContractDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

class ContractDetailBloc
    extends Bloc<ContractDetailEvent, ContractDetailState> {
  final ContractApiService _contractApiService;

  ContractDetailBloc(this._contractApiService)
    : super(ContractDetailInitial()) {
    on<FetchContractDetail>(_onFetchContractDetail);
    on<DeleteContractDetail>(_onDeleteContractDetail);
    on<SendContractToSeller>(_onSendContractToSeller);
    on<SendContractToBuyer>(_onSendContractToBuyer);
  }

  Future<void> _onFetchContractDetail(
    FetchContractDetail event,
    Emitter<ContractDetailState> emit,
  ) async {
    emit(ContractDetailLoading());
    try {
      // Fetch contract detail info first
      final contract = await _contractApiService.getContractDetail(
        contractId: event.contractId,
      );

      // Emit contract data immediately so UI can show it
      emit(ContractDetailLoadedWithoutPdf(contract: contract));

      // Now load PDF in background
      emit(ContractDetailPdfLoading(contract: contract));

      String? pdfPath;
      Future<PdfDocument>? pdfDocument;
      try {
        if (contract.status == ContractStatus.draft) {
          // For drafts, generate preview locally
          final pdfBytes = await ContractPdfService().generateFromContract(
            contract,
          );
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/contract_${event.contractId}.pdf');
          await file.writeAsBytes(pdfBytes);
          pdfPath = file.path;
        } else {
          // For other statuses, fetch from API
          final pdfBytes = await _contractApiService.getContractPdf(
            contractId: event.contractId,
          );
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/contract_${event.contractId}.pdf');
          await file.writeAsBytes(pdfBytes);
          pdfPath = file.path;
        }

        // Open the document here so it starts processing in background
        if (pdfPath != null) {
          pdfDocument = PdfDocument.openFile(pdfPath);
        }
      } catch (e) {
        // PDF fetch failed, but we still have contract info
        print('Error fetching/generating PDF: $e');
      }

      emit(
        ContractDetailLoaded(
          contract: contract,
          pdfPath: pdfPath,
          pdfDocument: pdfDocument,
        ),
      );
    } catch (e) {
      emit(ContractDetailError(e.toString()));
    }
  }

  Future<void> _onDeleteContractDetail(
    DeleteContractDetail event,
    Emitter<ContractDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is ContractDetailLoaded) {
      emit(ContractDetailLoading());
      try {
        await _contractApiService.deleteContract(contractId: event.contractId);
        emit(ContractDeletedSuccess());
      } catch (e) {
        emit(ContractDetailError(e.toString()));
        // Re-emit loaded state so user can try again
        emit(currentState);
      }
    }
  }

  Future<void> _onSendContractToSeller(
    SendContractToSeller event,
    Emitter<ContractDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is ContractDetailLoaded) {
      emit(ContractDetailLoading());
      try {
        await _contractApiService.sendToSeller(contractId: event.contractId);
        emit(
          const ContractActionSuccess(
            'ส่งเอกสารไปยังเจ้าของทรัพย์เรียบร้อยแล้ว',
          ),
        );
        emit(currentState);
      } catch (e) {
        emit(ContractDetailError(e.toString()));
        emit(currentState);
      }
    }
  }

  Future<void> _onSendContractToBuyer(
    SendContractToBuyer event,
    Emitter<ContractDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is ContractDetailLoaded) {
      emit(ContractDetailLoading());
      try {
        await _contractApiService.sendToBuyer(contractId: event.contractId);
        emit(const ContractActionSuccess('ส่งเอกสารไปยังผู้ซื้อเรียบร้อยแล้ว'));
        emit(currentState);
      } catch (e) {
        emit(ContractDetailError(e.toString()));
        emit(currentState);
      }
    }
  }
}
