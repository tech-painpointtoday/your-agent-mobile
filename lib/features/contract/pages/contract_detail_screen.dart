import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/contract.dart';
import '../../../domain/entities/contract_status.dart';
import '../../../widgets/badges/app_badge.dart';
import '../../../widgets/buttons/app_button.dart';
import '../../../widgets/dialogs/status_dialog.dart';
import '../../../widgets/modals/app_confirmation_bottom_sheet.dart';
import '../bloc/contract_detail_bloc.dart';
import '../widgets/contract_status_badge.dart';

class ContractDetailScreen extends StatefulWidget {
  final int contractId;

  const ContractDetailScreen({super.key, required this.contractId});

  @override
  State<ContractDetailScreen> createState() => _ContractDetailScreenState();
}

class _ContractDetailScreenState extends State<ContractDetailScreen> {
  late PdfControllerPinch _pdfController;
  bool _isPdfLoaded = false;
  int _currentPage = 1;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (_isPdfLoaded) {
      _pdfController.dispose();
    }
    super.dispose();
  }

  void _initPdf(Future<PdfDocument> documentFuture) async {
    if (_isPdfLoaded) return;

    try {
      // Wait for the document to fully load first
      final document = await documentFuture;

      if (!mounted) return;

      // Create the controller only after document is fully loaded
      _pdfController = PdfControllerPinch(document: Future.value(document));

      if (mounted) {
        setState(() {
          _totalPages = document.pagesCount;
          _isPdfLoaded = true;
        });
      }
    } catch (e) {
      print('Error initializing PDF: $e');
      if (mounted) {
        setState(() {
          _isPdfLoaded = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ContractDetailBloc(DependencyInjection.contractApiService)
            ..add(FetchContractDetail(widget.contractId)),
      child: BlocConsumer<ContractDetailBloc, ContractDetailState>(
        listener: (context, state) {
          if (state is ContractDetailLoaded && state.pdfDocument != null) {
            _initPdf(state.pdfDocument!);
          } else if (state is ContractDetailError) {
            StatusDialog.showError(
              context: context,
              title: 'เกิดข้อผิดพลาด',
              message: state.message,
            );
          } else if (state is ContractDeletedSuccess) {
            StatusDialog.showSuccessDialog(
              context: context,
              title: 'ลบสัญญาสำเร็จ',
              onOk: () => Navigator.pop(context, true),
            );
          } else if (state is ContractActionSuccess) {
            StatusDialog.showSuccess(
              context: context,
              title: 'สำเร็จ',
              message: state.message,
            );
          }
        },
        builder: (context, state) {
          final isLoaded =
              state is ContractDetailLoadedWithoutPdf ||
              state is ContractDetailPdfLoading ||
              state is ContractDetailLoaded;
          final isCompleted =
              isLoaded &&
              (_getContract(state).status == ContractStatus.signed ||
                  _getContract(state).status == ContractStatus.completed);

          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildHeader(context, state),
                      const SizedBox(height: 12),
                      if (state is ContractDetailLoadedWithoutPdf ||
                          state is ContractDetailPdfLoading ||
                          state is ContractDetailLoaded) ...[
                        _buildInfoSection(_getContract(state)),
                        _buildDocumentActions(state),
                        const SizedBox(height: 24),
                        const Divider(color: AppColors.baseLightGrey),
                        Expanded(child: _buildPdfViewer(state)),
                        _buildBottomActions(context, state),
                      ] else if (state is ContractDetailLoading)
                        const Expanded(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else
                        const Expanded(child: SizedBox.shrink()),
                    ],
                  ),
                  if (isCompleted)
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: _backButton(context),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Contract _getContract(ContractDetailState state) {
    if (state is ContractDetailLoadedWithoutPdf) {
      return state.contract;
    } else if (state is ContractDetailPdfLoading) {
      return state.contract;
    } else if (state is ContractDetailLoaded) {
      return state.contract;
    }
    throw StateError('Cannot get contract from state: $state');
  }

  Widget _buildHeader(BuildContext context, ContractDetailState state) {
    String contractNumber = '-';
    String propertyName = 'กำลังโหลด...';

    if (state is ContractDetailLoadedWithoutPdf ||
        state is ContractDetailPdfLoading ||
        state is ContractDetailLoaded) {
      final contract = _getContract(state);
      contractNumber = contract.contractNumber;
      propertyName = contract.propertyName;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'เลขที่สัญญา: $contractNumber',
            style: GoogleFonts.anuphan(
              color: AppColors.baseGrey,
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            propertyName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.anuphan(
              color: AppColors.baseBlack,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(Contract contract) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          ContractStatusBadge(status: contract.status),
          const SizedBox(width: 8),
          _buildSignatureBadge(contract),
        ],
      ),
    );
  }

  Widget _buildSignatureBadge(Contract contract) {
    final hasSellerSigned = contract.sellerSignedAt != null;
    final hasBuyerSigned = contract.buyerSignedAt != null;

    if (hasSellerSigned && hasBuyerSigned) {
      return AppBadge(
        label: 'ทั้งสองฝ่ายลงนามแล้ว',
        color: BadgeColor.blue,
        style: BadgeStyle.dot,
        fontSize: 12,
      );
    }
    if (hasSellerSigned) {
      return AppBadge(
        label: 'ผู้ให้เช่าลงนามแล้ว',
        color: BadgeColor.default_,
        style: BadgeStyle.done,
        fontSize: 12,
      );
    } else if (hasBuyerSigned) {
      return AppBadge(
        label: 'ผู้เช่าลงนามแล้ว',
        color: BadgeColor.default_,
        style: BadgeStyle.done,
        fontSize: 12,
      );
    }

    return AppBadge(
      label: 'ยังไม่มีผู้ลงนาม',
      color: BadgeColor.default_,
      fontSize: 12,
    );
  }

  Widget _buildDocumentActions(ContractDetailState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: _buildDocumentActionButton(
              label: 'ดาวน์โหลด PDF',
              onTap: state is ContractDetailLoaded && state.pdfPath != null
                  ? () => _downloadPdf(context, state)
                  : () {
                      StatusDialog.showWarning(
                        context: context,
                        title: 'กรุณารอสักครู่',
                        message: 'กำลังโหลดเอกสาร PDF...',
                      );
                    },
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: _buildDocumentActionButton(
              label: 'แชร์เอกสาร',
              iconPath: 'assets/icons/arrow-up-right.svg',
              onTap: () {
                if (state is ContractDetailLoaded) {
                  _showShareBottomSheet(context, state);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showShareBottomSheet(BuildContext context, ContractDetailLoaded state) {
    final contract = state.contract;
    final sellerEmail = contract.owner?.email;
    final buyerEmail = contract.buyer?.email;
    final pdfPath = state.pdfPath;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9EAEB),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildResendOrSendAction(
                  context: context,
                  bottomSheetContext: bottomSheetContext,
                  label: 'เจ้าของทรัพย์',
                  email: sellerEmail,
                  isSigned: contract.sellerSignedAt != null,
                  onSend: () {
                    context.read<ContractDetailBloc>().add(
                      SendContractToSeller(contract.id!),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildResendOrSendAction(
                  context: context,
                  bottomSheetContext: bottomSheetContext,
                  label: 'ผู้เช่า',
                  email: buyerEmail,
                  isSigned: contract.buyerSignedAt != null,
                  onSend: () {
                    context.read<ContractDetailBloc>().add(
                      SendContractToBuyer(contract.id!),
                    );
                  },
                ),
                if (pdfPath != null) ...[
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'แชร์ไฟล์ PDF',
                    style: AppButtonStyle.outline,
                    onPressed: () {
                      Navigator.pop(bottomSheetContext);
                      _downloadPdf(context, state);
                    },
                  ),
                ],
                const SizedBox(height: 12),
                AppButton(
                  text: 'ยกเลิก',
                  style: AppButtonStyle.ghost,
                  textColor: AppColors.supportRedDeep,
                  onPressed: () => Navigator.pop(bottomSheetContext),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResendOrSendAction({
    required BuildContext context,
    required BuildContext bottomSheetContext,
    required String label,
    required String? email,
    required bool isSigned,
    required VoidCallback onSend,
  }) {
    final bool emailExists = email != null && email.isNotEmpty;

    if (isSigned) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.supportGreenLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.supportGreenDark.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/plus.svg',
                        width: 16,
                        height: 16,
                        fit: BoxFit.scaleDown,
                        colorFilter: ColorFilter.mode(
                          AppColors.supportGreenDark,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$labelลงนามแล้ว',
                        style: GoogleFonts.anuphan(
                          color: AppColors.supportGreenDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (emailExists)
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: Text(
                        email,
                        style: GoogleFonts.anuphan(
                          color: AppColors.baseGrey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            AppButton(
              text: 'ส่งอีกครั้ง',
              style: AppButtonStyle.outline,
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              onPressed: !emailExists
                  ? null
                  : () {
                      Navigator.pop(bottomSheetContext);
                      AppConfirmationBottomSheet.show(
                        context: context,
                        title: 'ส่งเอกสารอีกครั้ง?',
                        description:
                            'คุณต้องการส่งเอกสารไปยัง$label ($email) อีกครั้งใช่หรือไม่?',
                        confirmLabel: 'ส่ง',
                        cancelLabel: 'ยกเลิก',
                        style: ConfirmationStyle.normal,
                        onConfirm: onSend,
                      );
                    },
            ),
          ],
        ),
      );
    }

    return AppButton(
      text: 'ส่งเอกสารไปยัง $label',
      style: AppButtonStyle.primary,
      onPressed: !emailExists
          ? null
          : () {
              Navigator.pop(bottomSheetContext);
              AppConfirmationBottomSheet.show(
                context: context,
                title: 'ส่งเอกสาร?',
                description:
                    'คุณต้องการส่งเอกสารไปยัง$label ($email) ใช่หรือไม่?',
                confirmLabel: 'ส่ง',
                cancelLabel: 'ยกเลิก',
                style: ConfirmationStyle.normal,
                onConfirm: onSend,
              );
            },
    );
  }

  Widget _buildDocumentActionButton({
    required String label,
    String? iconPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFE9EAEB)),
            borderRadius: BorderRadius.circular(12),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 2,
              offset: Offset(0, 1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.anuphan(
                  color: const Color(0xFF717680),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (iconPath != null) ...[
              SvgPicture.asset(
                iconPath,
                width: 12,
                height: 12,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF717680),
                  BlendMode.srcIn,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPdfViewer(ContractDetailState state) {
    // Show loading indicator for states before PDF is ready
    if (state is ContractDetailLoadedWithoutPdf ||
        state is ContractDetailPdfLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'กำลังโหลด PDF...',
              style: GoogleFonts.anuphan(
                fontSize: 14,
                color: AppColors.baseGrey,
              ),
            ),
          ],
        ),
      );
    }

    // Show loading while PDF controller initializes
    if (!_isPdfLoaded) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'กำลังเตรียม PDF...',
              style: GoogleFonts.anuphan(
                fontSize: 14,
                color: AppColors.baseGrey,
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        PdfViewPinch(
          padding: 0,
          controller: _pdfController,
          onPageChanged: (page) {
            setState(() {
              _currentPage = page;
            });
          },
        ),
        if (_totalPages > 0)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$_currentPage/$_totalPages',
                style: GoogleFonts.anuphan(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context, ContractDetailState state) {
    if (state is! ContractDetailLoadedWithoutPdf &&
        state is! ContractDetailPdfLoading &&
        state is! ContractDetailLoaded) {
      return const SizedBox.shrink();
    }

    final contract = _getContract(state);

    const buttonText = 'แก้ไขสัญญา';

    final isCompleted =
        contract.status == ContractStatus.signed ||
        contract.status == ContractStatus.completed;

    if (isCompleted) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          _backButton(context),
          const SizedBox(width: 12),
          // Main Action
          Expanded(
            child: AppButton(
              text: buttonText,
              style: AppButtonStyle.primary,
              height: 44,
              onPressed: () {
                context.push('/contract/edit', extra: contract);
              },
            ),
          ),
          const SizedBox(width: 12),
          // Delete Button
          InkWell(
            onTap: () {
              AppConfirmationBottomSheet.show(
                context: context,
                title: 'ลบสัญญา?',
                description:
                    'คุณต้องการลบสัญญานี้หรือไม่? การกระทำนี้ไม่สามารถย้อนกลับได้',
                confirmLabel: 'ลบ',
                cancelLabel: 'ยกเลิก',
                style: ConfirmationStyle.destructive,
                onConfirm: () {
                  context.read<ContractDetailBloc>().add(
                    DeleteContractDetail(widget.contractId),
                  );
                },
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.supportRedDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.supportRedDeep),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/trash.svg',
                  width: 16,
                  height: 16,
                  fit: BoxFit.scaleDown,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return InkWell(
      onTap: () => context.pop(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.baseLightGrey),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/chevron-left.svg',
            width: 16,
            height: 16,
            fit: BoxFit.scaleDown,
            colorFilter: const ColorFilter.mode(
              AppColors.baseDarkGrey,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  void _downloadPdf(BuildContext context, ContractDetailLoaded state) {
    if (state.pdfPath != null) {
      SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(
              state.pdfPath!,
              name:
                  'สัญญา_${state.contract.contractNumber}_${state.contract.contractDate!.toIso8601String()}.pdf',
              mimeType: 'application/pdf',
            ),
          ],
          subject: 'สัญญาเลขที่ ${state.contract.contractNumber}',
        ),
      );
    }
  }
}
