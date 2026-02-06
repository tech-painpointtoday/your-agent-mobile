import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:youragent/features/contract/bloc/contract_form/contract_form_state.dart';
import 'package:http/http.dart' as http;
import 'package:youragent/domain/entities/person_type.dart';

class ContractPdfService {
  Future<Uint8List> generate(ContractFormState state) async {
    final pdf = pw.Document();

    // Load Thai Font
    // Using Anuphan-Regular as it is confirmed to exist in the project assets.
    // If THSarabunNew is preferred, ensure it is added to assets/fonts/ and update this path.
    final fontData = await rootBundle.load('assets/fonts/Anuphan-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);
    final boldFontData = await rootBundle.load('assets/fonts/Anuphan-Bold.ttf');
    final boldTtf = pw.Font.ttf(boldFontData);

    final theme = pw.ThemeData.withFont(base: ttf, bold: boldTtf);

    // Formatters
    final dateFormat = DateFormat('d MMMM yyyy', 'th');
    final currencyFormat = NumberFormat('#,##0.00', 'en_US');

    // Prepare Data
    final contractDate = state.contractDate != null
        ? dateFormat.format(
            DateTime(
              state.contractDate!.year + 543,
              state.contractDate!.month,
              state.contractDate!.day,
            ),
          )
        : '..........................................................';

    // Helper for null checks
    String money(double? val) => val != null ? currencyFormat.format(val) : '-';

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          theme: theme,
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
        ),
        build: (pw.Context context) {
          return [
            _buildHeader(state, contractDate, boldTtf),
            pw.SizedBox(height: 20),
            _buildParties(state, boldTtf),
            pw.SizedBox(height: 10),
            _buildSectionHeader('ข้อ 1. วัตถุประสงค์แห่งสัญญา', boldTtf),
            _buildClause1(state),
            pw.SizedBox(height: 10),
            _buildSectionHeader('ข้อ 2. ทรัพย์สินที่เช่า', boldTtf),
            _buildClause2(state),
            pw.SizedBox(height: 10),
            _buildSectionHeader('ข้อ 3. ระยะเวลาเช่า', boldTtf),
            _buildClause3(state, dateFormat),
            pw.SizedBox(height: 10),
            _buildSectionHeader('ข้อ 4. ค่าเช่าและวิธีการชำระเงิน', boldTtf),
            _buildClause4(state, money),
            pw.SizedBox(height: 10),
            _buildSectionHeader('ข้อ 5. เงินประกันและค่าเช่าล่วงหน้า', boldTtf),
            _buildClause5(state, money),
            pw.SizedBox(height: 10),
            _buildSectionHeader('ข้อ 6. ข้อมูลบัญชีธนาคารผู้ให้เช่า', boldTtf),
            _buildClause6(state),
            pw.SizedBox(height: 30),
            _buildSignatures(state, boldTtf),
          ];
        },
      ),
    );

    // Annex: Furniture
    if (state.furnitureItems.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(theme: theme, pageFormat: PdfPageFormat.a4),
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                'รายการเฟอร์นิเจอร์ (Furniture List)',
                style: pw.TextStyle(font: boldTtf, fontSize: 18),
              ),
            ),
            pw.Table.fromTextArray(
              headers: ['ลำดับ', 'รายการ', 'รายละเอียด'],
              data: state.furnitureItems.asMap().entries.map((e) {
                final item = e.value;
                return [
                  (e.key + 1).toString(),
                  item.name,
                  item.description ?? '',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(font: boldTtf),
              cellAlignments: {0: pw.Alignment.center},
            ),
          ],
        ),
      );
    }

    // Annex: Appliances
    if (state.applianceItems.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(theme: theme, pageFormat: PdfPageFormat.a4),
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                'รายการเครื่องใช้ไฟฟ้า (Appliance List)',
                style: pw.TextStyle(font: boldTtf, fontSize: 18),
              ),
            ),
            pw.Table.fromTextArray(
              headers: ['ลำดับ', 'รายการ', 'รายละเอียด'],
              data: state.applianceItems.asMap().entries.map((e) {
                final item = e.value;
                return [
                  (e.key + 1).toString(),
                  item.name,
                  item.description ?? '',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(font: boldTtf),
              cellAlignments: {0: pw.Alignment.center},
            ),
          ],
        ),
      );
    }

    // Attachments (Images)
    if (state.attachments.isNotEmpty) {
      for (final attachment in state.attachments) {
        Uint8List? imageBytes;

        try {
          if (attachment.filePath != null && attachment.filePath!.isNotEmpty) {
            // Local file
            final file = File(attachment.filePath!);
            if (await file.exists()) {
              imageBytes = await file.readAsBytes();
            }
          } else if (attachment.fileUrl != null &&
              attachment.fileUrl!.isNotEmpty) {
            // Remote file
            // Note: Accessing network in UI thread/build might be slow, but this generate is async.
            final response = await http.get(Uri.parse(attachment.fileUrl!));
            if (response.statusCode == 200) {
              imageBytes = response.bodyBytes;
            }
          }

          if (imageBytes != null && _isImage(attachment.name)) {
            final image = pw.MemoryImage(imageBytes);
            pdf.addPage(
              pw.Page(
                pageTheme: pw.PageTheme(
                  theme: theme,
                  pageFormat: PdfPageFormat.a4,
                ),
                build: (context) {
                  return pw.Center(
                    child: pw.Column(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Text(
                          'เอกสารแนบ: ${attachment.name}',
                          style: pw.TextStyle(font: boldTtf, fontSize: 16),
                        ),
                        pw.SizedBox(height: 20),
                        pw.Image(image, fit: pw.BoxFit.contain, width: 450),
                      ],
                    ),
                  );
                },
              ),
            );
          }
        } catch (e) {
          // Ignore loading errors for attachments to allow PDF generation to succeed
          print('Error loading attachment ${attachment.name}: $e');
        }
      }
    }

    return pdf.save();
  }

  bool _isImage(String name) {
    final lower = name.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
  }

  pw.Widget _buildHeader(
    ContractFormState state,
    String date,
    pw.Font boldFont,
  ) {
    return pw.Column(
      children: [
        pw.Text(
          'สัญญาเช่าคอนโดมิเนียมเพื่ออยู่อาศัย',
          style: pw.TextStyle(font: boldFont, fontSize: 20),
        ),
        pw.Text(
          '(Residential Lease Agreement)',
          style: pw.TextStyle(fontSize: 14),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text(
              'สัญญาเลขที่: ${state.contractId ?? "...................."}',
            ),
          ],
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [pw.Text('วันที่: $date')],
        ),
      ],
    );
  }

  pw.Widget _buildParties(ContractFormState state, pw.Font boldFont) {
    String ownerInfo = state.ownerName;
    if (state.ownerType == PersonType.juristic) {
      ownerInfo += ' (นิติบุคคล) โดย ${state.ownerSignatory} ผู้มีอำนาจลงนาม';
    }
    ownerInfo += ' เลขบัตรประชาชน/เลขทะเบียนนิติบุคคล: ${state.ownerIdCard}';
    ownerInfo +=
        '\nที่อยู่: ${state.ownerAddress} เบอร์โทร: ${state.ownerPhone}';

    String buyerInfo = state.buyerName;
    if (state.buyerType == PersonType.juristic) {
      // Assuming buyer signage is handled similarly or just generic
    }
    buyerInfo += ' เลขบัตรประชาชน: ${state.buyerIdCard}';
    buyerInfo +=
        '\nที่อยู่: ${state.buyerAddress} เบอร์โทร: ${state.buyerPhone}';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'สัญญาฉบับนี้ทำขึ้นระหว่าง:',
          style: pw.TextStyle(font: boldFont),
        ),
        pw.Text('1. ผู้ให้เช่า (Lessor): $ownerInfo'),
        pw.SizedBox(height: 5),
        pw.Text('2. ผู้เช่า (Lessee): $buyerInfo'),
        pw.SizedBox(height: 5),
        pw.Text('ทั้งสองฝ่ายตกลงทำสัญญากันดังมีข้อความต่อไปนี้'),
      ],
    );
  }

  pw.Widget _buildSectionHeader(String text, pw.Font boldFont) {
    return pw.Container(
      alignment: pw.Alignment.centerLeft,
      margin: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Text(text, style: pw.TextStyle(font: boldFont, fontSize: 14)),
    );
  }

  pw.Widget _buildClause1(ContractFormState state) {
    return pw.Text(
      '        ผู้ให้เช่าตกลงให้เช่าและผู้เช่าตกลงเช่าทรัพย์สินตามรายละเอียดในข้อ 2 เพื่อใช้เป็นที่อยู่อาศัยเท่านั้น',
    );
  }

  pw.Widget _buildClause2(ContractFormState state) {
    final prop = state.selectedProperty;
    String details = '';
    if (prop != null) {
      details += 'โครงการ: ${prop.name ?? state.propertyName}';
      details += ' ที่อยู่: ${prop.address ?? "-"}';
      if (prop.number != null) details += ' เลขที่ห้อง: ${prop.number}';
      // Safely access dynamic specifications
      final floor = prop.specifications['floor'];
      if (floor != null) details += ' ชั้น: $floor';
      if (prop.area > 0) details += ' ขนาด: ${prop.area} ตร.ม.';
    } else {
      details = 'ทรัพย์สิน: ${state.propertyName}';
    }

    return pw.Text('        $details (รายละเอียดตามเอกสารแนบ)');
  }

  pw.Widget _buildClause3(ContractFormState state, DateFormat fmt) {
    final start = state.leaseStartDate != null
        ? fmt.format(
            DateTime(
              state.leaseStartDate!.year + 543,
              state.leaseStartDate!.month,
              state.leaseStartDate!.day,
            ),
          )
        : '....................';
    final end = state.leaseEndDate != null
        ? fmt.format(
            DateTime(
              state.leaseEndDate!.year + 543,
              state.leaseEndDate!.month,
              state.leaseEndDate!.day,
            ),
          )
        : '....................';

    return pw.Text(
      '        มีกำหนดระยะเวลาเช่า ${state.leaseDuration} ปี/เดือน เริ่มตั้งแต่วันที่ $start ถึงวันที่ $end',
    );
  }

  pw.Widget _buildClause4(
    ContractFormState state,
    String Function(double?) money,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '        ผู้เช่าตกลงชำระค่าเช่าให้แก่ผู้ให้เช่าในอัตราเดือนละ ${money(state.price)} บาท',
        ),
        pw.Text(
          '        โดยจะชำระภายในวันที่ ${state.dueDate ?? "..."} ของทุกเดือน',
        ),
      ],
    );
  }

  pw.Widget _buildClause5(
    ContractFormState state,
    String Function(double?) money,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '        ในวันทำสัญญานี้ ผู้เช่าได้วางเงินประกันความเสียหายจำนวน ${money(state.securityDeposit)} บาท',
        ),
        pw.Text(
          '        และค่าเช่าล่วงหน้าจำนวน ${money(state.advanceRent)} บาท',
        ),
        pw.Text(
          '        รวมเป็นเงินทั้งสิ้น ${money(state.totalUpfrontPayment)} บาท แก่ผู้ให้เช่า',
        ),
      ],
    );
  }

  pw.Widget _buildClause6(ContractFormState state) {
    return pw.Text(
      '        ธนาคาร: ${state.bankBranch} เลขที่บัญชี: ${state.accountNumber} ชื่อบัญชี: ${state.accountName}',
    );
  }

  pw.Widget _buildSignatures(ContractFormState state, pw.Font boldFont) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          children: [
            pw.Text(
              'ลงชื่อ ....................................................... ผู้ให้เช่า',
            ),
            pw.Text('(${state.ownerName})'),
          ],
        ),
        pw.Column(
          children: [
            pw.Text(
              'ลงชื่อ ....................................................... ผู้เช่า',
            ),
            pw.Text('(${state.buyerName})'),
          ],
        ),
      ],
    );
  }
}
