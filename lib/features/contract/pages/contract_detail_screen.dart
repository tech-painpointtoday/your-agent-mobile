import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/contract.dart';
import '../../../domain/entities/contract_status.dart';
import '../../../widgets/buttons/app_button.dart';
import '../../../widgets/dialogs/status_dialog.dart';
import '../../../widgets/badges/app_badge.dart';
import '../bloc/contract_detail_bloc.dart';
import '../widgets/contract_status_badge.dart';

class ContractDetailScreen extends StatefulWidget {
  final String contractId;

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

  void _initPdf(String path) async {
    if (_isPdfLoaded) return;
    final documentFuture = PdfDocument.openFile(path);
    _pdfController = PdfControllerPinch(document: documentFuture);

    final document = await documentFuture;
    if (mounted) {
      setState(() {
        _totalPages = document.pagesCount;
        _isPdfLoaded = true;
      });
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
          if (state is ContractDetailLoaded && state.pdfPath != null) {
            _initPdf(state.pdfPath!);
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
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(context, state),
                  const SizedBox(height: 12),
                  if (state is ContractDetailLoaded) ...[
                    _buildInfoSection(state.contract),
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ContractDetailState state) {
    String contractNumber = '-';
    String propertyName = 'กำลังโหลด...';

    if (state is ContractDetailLoaded) {
      contractNumber = state.contract.contractNumber;
      propertyName = state.contract.propertyName;
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
      );
    }

    if (!hasSellerSigned && !hasBuyerSigned) {
      return AppBadge(label: 'ยังไม่มีผู้ลงนาม', color: BadgeColor.default_);
    }

    // Individual tags if only one has signed
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasSellerSigned)
          AppBadge(
            label: 'ผู้ให้เช่าลงนามแล้ว',
            color: BadgeColor.blue,
            style: BadgeStyle.done,
          ),
        if (hasSellerSigned && hasBuyerSigned) const SizedBox(width: 4),
        if (hasBuyerSigned)
          AppBadge(
            label: 'ผู้เช่าลงนามแล้ว',
            color: BadgeColor.blue,
            style: BadgeStyle.done,
          ),
      ],
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
              onTap: () {
                // TODO: Implement download
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
                      SendContractToSeller(contract.id),
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
                      SendContractToBuyer(contract.id),
                    );
                  },
                ),
                // if (pdfPath != null) ...[
                //   const SizedBox(height: 12),
                //   AppButton(
                //     text: 'แชร์ไฟล์ PDF',
                //     style: AppButtonStyle.outline,
                //     onPressed: () {
                //       Navigator.pop(bottomSheetContext);
                //       SharePlus.instance.share(
                //         ShareParams(files: [XFile(pdfPath)]),
                //       );
                //     },
                //   ),
                // ],
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
            color: AppColors.supportGreenDark.withOpacity(0.1),
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
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.supportGreenDark,
                        size: 16,
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
                      StatusDialog.confirm(
                        context: context,
                        title: 'ส่งเอกสารอีกครั้ง?',
                        message:
                            'คุณต้องการส่งเอกสารไปยัง$label ($email) อีกครั้งใช่หรือไม่?',
                        actionLabel: 'ส่ง',
                        onAction: onSend,
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
              StatusDialog.confirm(
                context: context,
                title: 'ส่งเอกสาร?',
                message: 'คุณต้องการส่งเอกสารไปยัง$label ($email) ใช่หรือไม่?',
                actionLabel: 'ส่ง',
                onAction: onSend,
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
    if (!_isPdfLoaded) {
      return const Center(child: CircularProgressIndicator());
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
                color: Colors.black.withOpacity(0.4),
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
    if (state is! ContractDetailLoaded) return const SizedBox.shrink();

    final isDraft = state.contract.status == ContractStatus.draft;
    final buttonText = isDraft ? 'เพิ่มข้อมูลต่อ' : 'แก้ไขสัญญา';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFEAECF0)),
                borderRadius: BorderRadius.circular(12),
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
          ),
          const SizedBox(width: 12),
          // Main Action
          Expanded(
            child: AppButton(
              text: buttonText,
              style: AppButtonStyle.primary,
              height: 48,
              onPressed: () {
                // TODO: Navigate to edit/create flow
              },
            ),
          ),
          const SizedBox(width: 12),
          // Delete Button
          InkWell(
            onTap: () {
              StatusDialog.destructive(
                context: context,
                title: 'ลบสัญญา?',
                message:
                    'คุณต้องการลบสัญญานี้หรือไม่? การกระทำนี้ไม่สามารถย้อนกลับได้',
                actionLabel: 'ลบ',
                onAction: () {
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
}
