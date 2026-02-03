import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/contract_attachment.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_bloc.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_event.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_state.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import 'package:youragent/widgets/inputs/app_text_field.dart';
import 'package:youragent/widgets/modals/app_confirmation_bottom_sheet.dart';
import 'package:youragent/widgets/painters/dashed_border_painter.dart';

class AttachmentStep extends StatefulWidget {
  final bool hideHeader;

  const AttachmentStep({super.key, this.hideHeader = false});

  @override
  State<AttachmentStep> createState() => _AttachmentStepState();
}

class _AttachmentStepState extends State<AttachmentStep> {
  Future<void> _pickFile(String attachmentId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
    );

    if (result != null && result.files.single.path != null) {
      final file = result.files.single;
      if (mounted) {
        context.read<ContractFormBloc>().add(
          ContractFormAttachmentFileUpdated(
            id: attachmentId,
            filePath: file.path!,
            fileSize: file.size,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContractFormBloc, ContractFormState>(
      builder: (context, state) {
        return SizedBox(
          height: double.infinity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                if (!widget.hideHeader)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppBadge(
                        label: 'ไฟล์แนบสัญญา',
                        fontSize: 16,
                        color: BadgeColor.blue,
                      ),
                      AppBadge(
                        color: BadgeColor.default_,
                        fontSize: 16,
                        label: '${state.step}/8',
                      ),
                    ],
                  ),
                if (!widget.hideHeader) const SizedBox(height: 24),

                if (state.attachments.isEmpty)
                  _buildAddItemButton(context)
                else ...[
                  ...state.attachments.asMap().entries.map((entry) {
                    final index = entry.key;
                    final attachment = entry.value;
                    return Column(
                      children: [
                        _AttachmentItemCard(
                          index: index + 1,
                          attachment: attachment,
                          onDelete: () {
                            void performDelete() {
                              if (attachment.isRemote) {
                                context.read<ContractFormBloc>().add(
                                  ContractFormRemoteAttachmentDeleted(
                                    contractId: state.contractId!,
                                    documentId: attachment.remoteId!,
                                    attachmentId: attachment.id,
                                  ),
                                );
                              } else {
                                context.read<ContractFormBloc>().add(
                                  ContractFormAttachmentRemoved(attachment.id),
                                );
                              }
                            }

                            if (attachment.name.isNotEmpty ||
                                attachment.filePath != null ||
                                attachment.isRemote) {
                              AppConfirmationBottomSheet.show(
                                context: context,
                                title: 'ลบรายการนี้?',
                                description:
                                    'หากคุณลบแล้ว จะไม่สามารถย้อนกลับได้',
                                confirmLabel: 'ลบ',
                                cancelLabel: 'ยกเลิก',
                                style: ConfirmationStyle.destructive,
                                onConfirm: performDelete,
                              );
                              return;
                            }
                            performDelete();
                          },
                          onNameChanged: (val) =>
                              context.read<ContractFormBloc>().add(
                                ContractFormAttachmentNameUpdated(
                                  attachment.id,
                                  val,
                                ),
                              ),
                          onPickFile: () => _pickFile(attachment.id),
                        ),
                        if (index < state.attachments.length - 1)
                          const SizedBox(height: 24),
                      ],
                    );
                  }),
                  const SizedBox(height: 24),
                  _buildAddItemButton(context),
                ],
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddItemButton(BuildContext context) {
    return InkWell(
      onTap: () => context.read<ContractFormBloc>().add(
        const ContractFormAttachmentAdded(),
      ),
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: AppColors.baseLightGrey,
          strokeWidth: 1,
          dashWidth: 6,
          dashSpace: 4,
          radius: 12,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/plus.svg',
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  AppColors.baseDarkGrey,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'เพิ่มรายการ',
                style: GoogleFonts.anuphan(
                  color: AppColors.baseDarkGrey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttachmentItemCard extends StatelessWidget {
  final int index;
  final ContractAttachment attachment;
  final VoidCallback onDelete;
  final Function(String) onNameChanged;
  final VoidCallback onPickFile;

  const _AttachmentItemCard({
    required this.index,
    required this.attachment,
    required this.onDelete,
    required this.onNameChanged,
    required this.onPickFile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'รายการที่ $index',
              style: GoogleFonts.anuphan(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.baseBlack,
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minHeight: 0, minWidth: 0),
              onPressed: onDelete,
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: SvgPicture.asset(
                'assets/icons/x-circle-filled.svg',
                colorFilter: const ColorFilter.mode(
                  AppColors.baseGrey,
                  BlendMode.srcIn,
                ),
                fit: BoxFit.scaleDown,
                width: 20,
                height: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(height: 0),
        const SizedBox(height: 24),
        // Manual Label for Name
        RichText(
          text: TextSpan(
            text: 'ชื่อไฟล์',
            style: GoogleFonts.anuphan(
              color: AppColors.baseBlack,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: GoogleFonts.anuphan(
                  color: AppColors.supportRedDeep,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: AppTextField(
                label: '',
                isRequired: false,
                hintText: 'ชื่อไฟล์ เช่น สำเนาบัตรประชาชน',
                controller: TextEditingController(text: attachment.name)
                  ..selection = TextSelection.fromPosition(
                    TextPosition(offset: attachment.name.length),
                  ),
                onChanged: onNameChanged,
                readOnly: attachment.isRemote,
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: attachment.isRemote ? null : onPickFile,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: attachment.isRemote
                      ? AppColors.baseOffWhite
                      : Colors.white,
                  border: Border.all(color: AppColors.baseLightGrey),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: SvgPicture.asset(
                  'assets/icons/attachment.svg',
                  width: 16,
                  height: 16,
                  fit: BoxFit.scaleDown,
                  colorFilter: ColorFilter.mode(
                    attachment.isRemote
                        ? AppColors.baseLightGrey
                        : AppColors.baseDarkGrey,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'อัปโหลดไฟล์ PDF อย่างน้อย 1 ไฟล์',
          style: GoogleFonts.anuphan(fontSize: 14, color: AppColors.baseGrey),
        ),
        if (attachment.filePath != null || attachment.fileUrl != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.baseLightGrey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.supportRedLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/file-2.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      AppColors.supportRedDeep,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attachment.isRemote
                            ? attachment.name
                            : attachment.filePath!.split('/').last,
                        style: GoogleFonts.anuphan(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.baseBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (attachment.fileSize != null)
                        Text(
                          attachment.isRemote
                              ? '${(attachment.fileSize! / 1024 / 1024).toStringAsFixed(2)} MB'
                              : '${(attachment.fileSize! / 1024).toStringAsFixed(0)} KB',
                          style: GoogleFonts.anuphan(
                            fontSize: 12,
                            color: AppColors.baseGrey,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minHeight: 0, minWidth: 0),
                  onPressed: attachment.isRemote
                      ? null
                      : () {
                          context.read<ContractFormBloc>().add(
                            ContractFormAttachmentFileUpdated(
                              id: attachment.id,
                              filePath: null,
                              fileSize: null,
                            ),
                          );
                        },
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: SvgPicture.asset(
                    'assets/icons/x.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      attachment.isRemote
                          ? AppColors.baseLightGrey
                          : AppColors.baseGrey,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
