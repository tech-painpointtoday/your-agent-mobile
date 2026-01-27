import 'dart:async';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/features/contracts/bloc/pdf/contract_pdf_bloc.dart';
import 'package:youragent/features/contracts/bloc/pdf/contract_pdf_event.dart';
import 'package:youragent/features/contracts/bloc/pdf/contract_pdf_state.dart';
import 'package:youragent/features/contracts/utils/pdf_web.dart';
import 'package:youragent/domain/entities/contract_status.dart';
import 'package:youragent/data/models/contract_model.dart';
import 'package:youragent/services/api_response_service.dart';
import 'package:youragent/widgets/contract_status_chip.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:youragent/features/contracts/widgets/contract_pdf_toolbar.dart';

class ContractPdfViewer extends StatefulWidget {
  final int contractId;
  final ContractModel? contract;

  const ContractPdfViewer({super.key, required this.contractId, this.contract});

  @override
  State<ContractPdfViewer> createState() => _ContractPdfViewerState();
}

class _ContractPdfViewerState extends State<ContractPdfViewer> {
  PdfController? _pdfController;
  // Keep a reference to the bloc-provided bytes to avoid recreating the controller
  // on every state change (we still create a copy for the controller).
  Uint8List? _pdfBytesRefFromBloc;
  final PhotoViewController _photoViewController = PhotoViewController();
  StreamSubscription<PhotoViewControllerValue>? _photoViewSub;

  // Local UI state (no BLoC) — BLoC is only for loading pdf bytes.
  int _currentPage = 1; // 1-based (matches pdfx callbacks)
  int _totalPages = 1;
  double _zoomPercentage = 100.0;
  bool _fitToWidth = true;
  double? _baseScale;
  bool _hasCapturedBaseScale = false;
  int _rotationAngle = 0; // 0, 90, 180, 270 degrees

  int get _safeRotationAngle {
    // Ensure rotation angle is always a valid integer between 0 and 360
    final angle = _rotationAngle;
    if (angle < 0 || angle > 360) {
      return 0;
    }
    return angle;
  }

  void _applyZoomPercentage(double zoomPercentage) {
    final nextZoom = zoomPercentage.clamp(50.0, 400.0);
    final base = _baseScale;
    final current = _photoViewController.scale;

    final double targetScale;
    if (base != null && base > 0) {
      targetScale = base * (nextZoom / 100.0);
    } else if (current != null && current > 0) {
      // Fallback: scale relative to current zoom step
      final ratio = nextZoom / (_zoomPercentage == 0 ? 100.0 : _zoomPercentage);
      targetScale = current * ratio;
    } else {
      // Last resort: at least make the buttons visibly do something.
      targetScale = nextZoom / 100.0;
    }

    setState(() {
      _zoomPercentage = nextZoom;
      _fitToWidth = _zoomPercentage == 100.0;
      _photoViewController.scale = targetScale;
    });
  }

  void _initPdfControllerFromBytes(Uint8List bytesFromBloc) {
    if (bytesFromBloc.isEmpty) return;

    _pdfController?.dispose();
    _pdfBytesRefFromBloc = bytesFromBloc;

    // Create a copy of bytes to prevent detached ArrayBuffer issues on Web
    final bytesCopy = Uint8List.fromList(bytesFromBloc);
    _pdfController = PdfController(document: PdfDocument.openData(bytesCopy));

    // Reset local UI state for a fresh document
    _hasCapturedBaseScale = false;
    _baseScale = null;
    _currentPage = 1;
    _totalPages = 1;
    _zoomPercentage = 100.0;
    _fitToWidth = true;
    _rotationAngle = 0;
  }

  @override
  void initState() {
    super.initState();
    final bloc = context.read<ContractPdfBloc>();

    // Capture base scale as soon as PhotoView reports a valid scale.
    _photoViewSub = _photoViewController.outputStateStream.listen((value) {
      final scale = value.scale;
      if (scale == null || scale <= 0) return;
      if (_hasCapturedBaseScale) return;
      if (!mounted) return;
      setState(() {
        _hasCapturedBaseScale = true;
        _baseScale = scale;
        // At base scale, we consider this 100% (fit-to-width).
        _zoomPercentage = 100.0;
        _fitToWidth = true;
      });
    });

    // IMPORTANT: If the bloc already has cached bytes for this contract, we must
    // initialize the controller immediately (otherwise we'd be stuck showing
    // loading because no state change will occur).
    final cachedBytes = bloc.state.pdfBytes;
    final cachedContractId = bloc.state.contractId;
    if (cachedContractId == widget.contractId &&
        cachedBytes != null &&
        cachedBytes.isNotEmpty) {
      _initPdfControllerFromBytes(cachedBytes);
    }

    bloc.add(ContractPdfLoad(widget.contractId));
  }

  @override
  void didUpdateWidget(covariant ContractPdfViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contractId == widget.contractId) return;

    // Contract changed: reset and load new bytes.
    _pdfController?.dispose();
    _pdfController = null;
    _pdfBytesRefFromBloc = null;
    _hasCapturedBaseScale = false;
    _baseScale = null;
    _currentPage = 1;
    _totalPages = 1;
    _zoomPercentage = 100.0;
    _fitToWidth = true;

    context.read<ContractPdfBloc>().add(ContractPdfLoad(widget.contractId));
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    _photoViewSub?.cancel();
    _photoViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContractPdfBloc, ContractPdfState>(
      // Listener is ONLY for controller creation when bytes change.
      listenWhen: (prev, cur) => prev.pdfBytes != cur.pdfBytes,
      listener: (context, state) {
        // Handle PDF bytes change - create controller (per pdfx docs)
        final bytes = state.pdfBytes;
        if (bytes != null && bytes.isNotEmpty) {
          // IMPORTANT: compare against the bloc bytes reference, not our copied buffer.
          if (_pdfBytesRefFromBloc != bytes || _pdfController == null) {
            _initPdfControllerFromBytes(bytes);

            // Force rebuild to show PDF view
            if (mounted) setState(() {});
          }
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: AppColors.white,
              padding: const EdgeInsets.all(40),
              child: ClipRRect(
                child: Column(
                  children: [
                    ContractPdfToolbar(
                      currentPage: _currentPage,
                      totalPages: _totalPages,
                      zoom: _zoomPercentage,
                      fitToWidth: _fitToWidth,
                      onPrev: _pdfController == null
                          ? null
                          : () => _pdfController!.previousPage(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                            ),
                      onNext: _pdfController == null
                          ? null
                          : () => _pdfController!.nextPage(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                            ),
                      onZoomOut: () {
                        _applyZoomPercentage(_zoomPercentage - 10);
                      },
                      onZoomIn: () {
                        _applyZoomPercentage(_zoomPercentage + 10);
                      },
                      onToggleFit: () {
                        // Toggle between fit (100%) and a readable zoom-out preset.
                        final nextZoom = _fitToWidth ? 80.0 : 100.0;
                        _applyZoomPercentage(nextZoom);
                      },
                      onPrint: () {
                        final bytes = context
                            .read<ContractPdfBloc>()
                            .state
                            .pdfBytes;
                        if (bytes != null && bytes.isNotEmpty) _printPdf(bytes);
                      },
                      onDownload: () {
                        final bytes = context
                            .read<ContractPdfBloc>()
                            .state
                            .pdfBytes;
                        if (bytes != null && bytes.isNotEmpty) {
                          _downloadPdf(
                            bytes,
                            fileName: 'contract_${widget.contractId}.pdf',
                          );
                        }
                      },
                      onFullScreen: () {
                        // This callback is not used when fullScreenMenuItemsBuilder is provided
                        // but is required by the toolbar interface
                      },
                      fullScreenMenuItemsBuilder: (context) => [
                        PopupMenuItem(
                          value: 'fullscreen',
                          child: const Text('เต็มหน้าจอ'),
                          onTap: () {
                            final bytes = context
                                .read<ContractPdfBloc>()
                                .state
                                .pdfBytes;
                            if (bytes != null && bytes.isNotEmpty) {
                              _openFullScreenPdf(bytes);
                            }
                          },
                        ),
                      ],
                      onRotate: () {
                        setState(() {
                          final currentAngle = _safeRotationAngle;
                          _rotationAngle = (currentAngle + 90) % 360;
                        });
                      },
                      onMenu: () {
                        // Try to open drawer if available
                        try {
                          final scaffold = Scaffold.of(context);
                          if (scaffold.hasDrawer) {
                            scaffold.openDrawer();
                          }
                        } catch (e) {
                          // If no scaffold context, do nothing
                          debugPrint('No scaffold found for menu: $e');
                        }
                      },
                      menuItemsBuilder: (context) {
                        // Show popup menu as fallback when drawer is not available
                        try {
                          final scaffold = Scaffold.of(context);
                          if (scaffold.hasDrawer) {
                            // Return empty list so PopupMenuButton won't show
                            return [];
                          }
                        } catch (e) {
                          // Continue to show menu items
                        }
                        return [
                          const PopupMenuItem(
                            value: 'fullscreen',
                            child: Text('เต็มหน้าจอ'),
                          ),
                        ];
                      },
                      fileName: 'Contract ${widget.contractId}',
                    ),

                    // PDF Layer - Rebuilds RARELY (only on file load)
                    Expanded(
                      child: Container(
                        color: const Color(0xFF525659),
                        child: BlocBuilder<ContractPdfBloc, ContractPdfState>(
                          buildWhen: (prev, cur) =>
                              prev.pdfBytes != cur.pdfBytes ||
                              prev.isLoading != cur.isLoading ||
                              prev.errorMessage != cur.errorMessage,
                          builder: (context, state) {
                            final pdfBytes = state.pdfBytes;
                            final isLoading = state.isLoading;
                            final error = state.errorMessage;

                            if (isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (error != null && error.isNotEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'ไม่สามารถโหลดไฟล์ PDF ได้',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      error,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: Colors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: () =>
                                          context.read<ContractPdfBloc>().add(
                                            ContractPdfLoad(widget.contractId),
                                          ),
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              );
                            }

                            // Critical: if bytes exist but controller isn't ready yet, keep loading.
                            if (pdfBytes == null ||
                                pdfBytes.isEmpty ||
                                _pdfController == null) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            return Center(
                              child: RotatedBox(
                                quarterTurns: _safeRotationAngle ~/ 90,
                                child: PdfView(
                                  controller: _pdfController!,
                                  scrollDirection: Axis.vertical,
                                  builders: PdfViewBuilders<DefaultBuilderOptions>(
                                    options: const DefaultBuilderOptions(),
                                    documentLoaderBuilder: (_) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    pageLoaderBuilder: (_) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorBuilder: (_, error) =>
                                        Center(child: Text(error.toString())),
                                    pageBuilder:
                                        (context, pageImage, index, document) {
                                          final containedScale =
                                              PhotoViewComputedScale.contained;
                                          return PhotoViewGalleryPageOptions(
                                            imageProvider: PdfPageImageProvider(
                                              pageImage,
                                              index,
                                              document.id,
                                            ),
                                            controller: _photoViewController,
                                            initialScale: containedScale,
                                            minScale:
                                                PhotoViewComputedScale
                                                    .contained *
                                                0.5,
                                            maxScale:
                                                PhotoViewComputedScale
                                                    .contained *
                                                4.0,
                                            heroAttributes:
                                                PhotoViewHeroAttributes(
                                                  tag: '${document.id}-$index',
                                                ),
                                          );
                                        },
                                  ),
                                  onDocumentLoaded: (details) {
                                    if (!mounted) return;
                                    setState(() {
                                      _totalPages = details.pagesCount;
                                      _currentPage = _currentPage.clamp(
                                        1,
                                        _totalPages,
                                      );
                                    });
                                  },
                                  onPageChanged: (page) {
                                    if (!mounted) return;
                                    setState(() {
                                      _currentPage = page; // pdfx is 1-based
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          BlocBuilder<ContractPdfBloc, ContractPdfState>(
            buildWhen: (prev, cur) =>
                prev.pdfBytes != cur.pdfBytes ||
                prev.isDownloading != cur.isDownloading,
            builder: (context, state) {
              return SizedBox(
                width: 350,
                child: _Sidebar(
                  contract: widget.contract,
                  contractIdText: widget.contractId.toString(),
                  onDownload: state.pdfBytes == null || state.isDownloading
                      ? null
                      : () => _downloadPdf(
                          state.pdfBytes!,
                          fileName: 'contract_${widget.contractId}.pdf',
                        ),
                  onSendLessor: () => _handleSendToSeller(context),
                  onSendLessee: () => _handleSendToBuyer(context),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPdf(Uint8List bytes, {required String fileName}) async {
    final bloc = context.read<ContractPdfBloc>();
    final state = bloc.state;

    if (state.isDownloading) return;

    // Use bytes from state if available, otherwise use provided bytes
    final pdfBytes = state.pdfBytes ?? bytes;

    if (pdfBytes.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ไม่สามารถดาวน์โหลดได้: ไฟล์ PDF ว่างเปล่า'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Validate PDF signature
    if (pdfBytes.length < 4 ||
        pdfBytes[0] != 0x25 ||
        pdfBytes[1] != 0x50 ||
        pdfBytes[2] != 0x44 ||
        pdfBytes[3] != 0x46) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ไม่สามารถดาวน์โหลดได้: ไฟล์ PDF ไม่ถูกต้อง'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    bloc.add(const ContractPdfDownloadStarted());
    try {
      if (!kIsWeb) {
        final tempDir = await getTemporaryDirectory();
        await tempDir.create(recursive: true); // best effort
      }
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: pdfBytes,
        ext: 'pdf',
        mimeType: MimeType.pdf,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ดาวน์โหลดสำเร็จ')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ไม่สามารถดาวน์โหลดได้: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        bloc.add(const ContractPdfDownloadFinished());
      }
    }
  }

  Future<void> _printPdf(Uint8List bytes) async {
    if (kIsWeb) {
      await openPdfInNewTab(
        bytes,
        fileName: 'contract_${widget.contractId}.pdf',
        autoPrint: true,
      );
      return;
    }
    await _downloadPdf(bytes, fileName: 'contract_${widget.contractId}.pdf');
  }

  Future<void> _openFullScreenPdf(Uint8List bytes) async {
    if (!mounted) return;

    // Quick validation before opening dialog
    if (bytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ไม่สามารถเปิด PDF ได้: ไฟล์ PDF ว่างเปล่า'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (bytes.length < 4 ||
        bytes[0] != 0x25 ||
        bytes[1] != 0x50 ||
        bytes[2] != 0x44 ||
        bytes[3] != 0x46) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ไม่สามารถเปิด PDF ได้: ไฟล์ PDF ไม่ถูกต้อง'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) => _FullScreenPdfDialog(
        pdfBytes: bytes,
        contractId: widget.contractId,
        onDownload: () =>
            _downloadPdf(bytes, fileName: 'contract_${widget.contractId}.pdf'),
      ),
    );
  }

  Future<void> _handleSendToSeller(BuildContext context) async {
    if (!mounted) return;

    final confirmed = await StatusDialog.showConfirmation(
      context: context,
      title: 'ส่งเอกสารไปยัง ผู้ให้เช่า',
      message: 'คุณต้องการส่งเอกสารสัญญาไปยังผู้ให้เช่าหรือไม่?',
      confirmText: 'ส่ง',
      cancelText: 'ยกเลิก',
    );

    if (!confirmed || !mounted) return;

    try {
      await StatusDialog.showLoadingWhile(
        context: context,
        message: 'กำลังส่งเอกสาร...',
        operation: () async {
          return await DependencyInjection.contractApiService
              .sendContractToSeller(contractId: widget.contractId);
        },
      );

      if (!mounted) return;

      await StatusDialog.showSuccess(
        context: context,
        title: 'สำเร็จ',
        message: 'ส่งเอกสารไปยังผู้ให้เช่าสำเร็จ',
      );
    } catch (e) {
      if (!mounted) return;

      final errorMessage = ApiResponseService.getErrorMessage(e);

      await StatusDialog.showError(
        context: context,
        title: 'เกิดข้อผิดพลาด',
        message: errorMessage,
      );
    }
  }

  Future<void> _handleSendToBuyer(BuildContext context) async {
    if (!mounted) return;

    final confirmed = await StatusDialog.showConfirmation(
      context: context,
      title: 'ส่งเอกสารไปยัง ผู้เช่า',
      message: 'คุณต้องการส่งเอกสารสัญญาไปยังผู้เช่าหรือไม่?',
      confirmText: 'ส่ง',
      cancelText: 'ยกเลิก',
    );

    if (!confirmed || !mounted) return;

    try {
      await StatusDialog.showLoadingWhile(
        context: context,
        message: 'กำลังส่งเอกสาร...',
        operation: () async {
          return await DependencyInjection.contractApiService
              .sendContractToBuyer(contractId: widget.contractId);
        },
      );

      if (!mounted) return;

      await StatusDialog.showSuccess(
        context: context,
        title: 'สำเร็จ',
        message: 'ส่งเอกสารไปยังผู้เช่าสำเร็จ',
      );
    } catch (e) {
      if (!mounted) return;

      final errorMessage = ApiResponseService.getErrorMessage(e);

      await StatusDialog.showError(
        context: context,
        title: 'เกิดข้อผิดพลาด',
        message: errorMessage,
      );
    }
  }
}

class _Sidebar extends StatelessWidget {
  final ContractModel? contract;
  final String contractIdText;
  final VoidCallback? onDownload;
  final VoidCallback onSendLessor;
  final VoidCallback onSendLessee;

  const _Sidebar({
    required this.contract,
    required this.contractIdText,
    required this.onDownload,
    required this.onSendLessor,
    required this.onSendLessee,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.only(left: 0, right: 40, top: 40, bottom: 40),
      decoration: BoxDecoration(color: Colors.white),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'เอกสารสัญญา',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.baseDarkGrey,
              ),
            ),
            const SizedBox(height: 24),
            _row(context, 'เลขที่สัญญา:', contractIdText),
            const SizedBox(height: 12),
            _statusRow(context, 'สถานะสัญญา:', contract?.status),
            const SizedBox(height: 12),
            _statusNoteRow(
              context,
              'การลงนาม (ผู้ให้เช่า):',
              contract?.sellerSignedAt != null,
            ),
            const SizedBox(height: 8),
            _statusNoteRow(
              context,
              'การลงนาม (ผู้เช่า):',
              contract?.buyerSignedAt != null,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onDownload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'ดาวน์โหลด PDF',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildSendButtonSection(
              context: context,
              theme: theme,
              isSigned: contract?.sellerSignedContractUrl != null,
              signedContractUrl: contract?.sellerSignedContractUrl,
              buttonLabel: 'ส่งเอกสารไปยัง ผู้ให้เช่า',
              onSend: onSendLessor,
            ),
            const SizedBox(height: 12),
            _buildSendButtonSection(
              context: context,
              theme: theme,
              isSigned: contract?.buyerSignedContractUrl != null,
              signedContractUrl: contract?.buyerSignedContractUrl,
              buttonLabel: 'ส่งเอกสารไปยัง ผู้เช่า',
              onSend: onSendLessee,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.baseGrey),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.gray800,
          ),
        ),
      ],
    );
  }

  Widget _statusRow(
    BuildContext context,
    String label,
    ContractStatus? status,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.baseGrey),
          ),
        ),
        ContractStatusChip(status: status),
      ],
    );
  }

  Widget _statusNoteRow(BuildContext context, String label, bool isSigned) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.baseGrey),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isSigned ? AppColors.success600 : AppColors.basePaleGrey,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            isSigned ? 'ลงนามแล้ว' : 'ยังไม่ได้ลงนาม',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isSigned ? Colors.white : AppColors.baseDarkGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendButtonSection({
    required BuildContext context,
    required ThemeData theme,
    required bool isSigned,
    required String? signedContractUrl,
    required String buttonLabel,
    required VoidCallback onSend,
  }) {
    if (isSigned && signedContractUrl != null) {
      // Show View Signed Contract + Resend buttons
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  final uri = Uri.parse(signedContractUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('ไม่สามารถเปิด URL ได้'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'View Signed Contract',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 48,
            height: 48,
            child: OutlinedButton(
              onPressed: onSend,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Icon(Icons.refresh, color: Colors.white),
            ),
          ),
        ],
      );
    } else {
      // Show regular Send button
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: onSend,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            buttonLabel,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
  }
}

class _FullScreenPdfDialog extends StatefulWidget {
  final Uint8List pdfBytes;
  final int contractId;
  final VoidCallback onDownload;

  const _FullScreenPdfDialog({
    required this.pdfBytes,
    required this.contractId,
    required this.onDownload,
  });

  @override
  State<_FullScreenPdfDialog> createState() => _FullScreenPdfDialogState();
}

class _FullScreenPdfDialogState extends State<_FullScreenPdfDialog> {
  PdfController? _pdfController;
  final PhotoViewController _photoViewController = PhotoViewController();
  double _zoomPercentage = 100.0;
  double? _baseScale;
  int _currentPage = 1;
  int _totalPages = 1;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePdf();
  }

  Future<void> _initializePdf() async {
    // Validate PDF bytes
    if (widget.pdfBytes.isEmpty) {
      if (mounted) {
        setState(() {
          _errorMessage = 'ไม่สามารถโหลดไฟล์ PDF ได้: ไฟล์ PDF ว่างเปล่า';
        });
      }
      return;
    }

    // Validate PDF signature
    if (widget.pdfBytes.length < 4 ||
        widget.pdfBytes[0] != 0x25 ||
        widget.pdfBytes[1] != 0x50 ||
        widget.pdfBytes[2] != 0x44 ||
        widget.pdfBytes[3] != 0x46) {
      if (mounted) {
        setState(() {
          _errorMessage = 'ไม่สามารถโหลดไฟล์ PDF ได้: ไฟล์ PDF ไม่ถูกต้อง';
        });
      }
      return;
    }

    try {
      // Create a copy of bytes to prevent detached ArrayBuffer issues on Web
      final bytesCopy = Uint8List.fromList(widget.pdfBytes);
      // PdfController accepts Future<PdfDocument>, not PdfDocument
      _pdfController = PdfController(document: PdfDocument.openData(bytesCopy));
      if (mounted) {
        // Wait a bit for the document to load, then get page count
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && _pdfController != null) {
            setState(() {
              _totalPages = _pdfController?.pagesCount ?? 1;
              _errorMessage = null;
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'ไม่สามารถโหลดไฟล์ PDF ได้: ${e.toString()}';
        });
      }
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    _photoViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('ปิด'),
                    ),
                  ],
                ),
              ),
            )
          else if (_pdfController == null)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else
            PdfView(
              controller: _pdfController!,
              scrollDirection: Axis.vertical,
              builders: PdfViewBuilders<DefaultBuilderOptions>(
                options: const DefaultBuilderOptions(),
                pageBuilder: (context, pageImage, index, document) {
                  final containedScale = PhotoViewComputedScale.contained;

                  // Capture base scale on first page render
                  if (_baseScale == null && index == 0) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (mounted) {
                          final currentScale = _photoViewController.scale;
                          if (currentScale != null && currentScale > 0) {
                            setState(() {
                              _baseScale = currentScale;
                              _photoViewController.scale =
                                  currentScale * (_zoomPercentage / 100.0);
                            });
                          }
                        }
                      });
                    });
                  }

                  // Apply zoom if base scale is known
                  if (_baseScale != null) {
                    final targetScale = _baseScale! * (_zoomPercentage / 100.0);
                    _photoViewController.scale = targetScale;
                  }

                  return PhotoViewGalleryPageOptions(
                    imageProvider: PdfPageImageProvider(
                      pageImage,
                      index,
                      document.id,
                    ),
                    controller: _photoViewController,
                    initialScale: containedScale,
                    minScale: PhotoViewComputedScale.contained * 0.5,
                    maxScale: PhotoViewComputedScale.contained * 4.0,
                    heroAttributes: PhotoViewHeroAttributes(
                      tag: 'fullscreen-${document.id}-$index',
                    ),
                  );
                },
              ),
              onDocumentLoaded: (details) {
                setState(() {
                  _totalPages = details.pagesCount;
                  _currentPage = _currentPage.clamp(1, _totalPages);
                });
              },
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              onDocumentError: (error) {
                if (mounted) {
                  setState(() {
                    _errorMessage = 'เกิดข้อผิดพลาดในการโหลด PDF: $error';
                  });
                }
              },
            ),
          // Top toolbar with controls (only show when PDF is loaded)
          if (_errorMessage == null && _pdfController != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Zoom controls
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _zoomPercentage = (_zoomPercentage - 10).clamp(
                            50.0,
                            400.0,
                          );
                          if (_baseScale != null) {
                            _photoViewController.scale =
                                _baseScale! * (_zoomPercentage / 100.0);
                          } else {
                            final current = _photoViewController.scale;
                            if (current != null && current > 0) {
                              _photoViewController.scale = current * 0.9;
                            }
                          }
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_zoomPercentage.round()}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _zoomPercentage = (_zoomPercentage + 10).clamp(
                            50.0,
                            400.0,
                          );
                          if (_baseScale != null) {
                            _photoViewController.scale =
                                _baseScale! * (_zoomPercentage / 100.0);
                          } else {
                            final current = _photoViewController.scale;
                            if (current != null && current > 0) {
                              _photoViewController.scale = current * 1.1;
                            }
                          }
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '$_currentPage / $_totalPages',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    // Download button
                    IconButton(
                      icon: const Icon(Icons.download, color: Colors.white),
                      onPressed: widget.onDownload,
                      tooltip: 'Download',
                    ),
                    const SizedBox(width: 8),
                    // Close button
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
