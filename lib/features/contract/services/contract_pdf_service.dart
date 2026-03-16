import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:yourhome/features/contract/bloc/contract_form/contract_form_state.dart';
import 'package:http/http.dart' as http;
import 'package:yourhome/domain/entities/person_type.dart';
import 'package:yourhome/domain/entities/contract.dart';
import 'package:yourhome/domain/entities/appliance_item.dart';
import 'package:yourhome/domain/entities/furniture_item.dart';
import 'package:yourhome/domain/entities/contract_attachment.dart';
import 'package:yourhome/utils/app_utils.dart';

class ContractPdfService {
  Future<Uint8List> generate(ContractFormState state) async {
    final pdf = pw.Document();

    final fonts = await _loadFonts();
    final theme = pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold);

    final dateFormat = DateFormat('d MMMM yyyy', 'th');
    final currencyFormat = NumberFormat('#,##0.00', 'en_US');

    final contractDateStr = state.contractDate != null
        ? dateFormat.format(
            DateTime(
              state.contractDate!.year + 543,
              state.contractDate!.month,
              state.contractDate!.day,
            ),
          )
        : '..........................................................';

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
            _buildHeader(
              contractId: state.contractId?.toString(),
              date: contractDateStr,
              boldFont: fonts.bold,
            ),
            pw.SizedBox(height: 20),
            _buildParties(
              ownerName: state.ownerName,
              ownerType: state.ownerType,
              ownerSignatory: state.ownerSignatory,
              ownerIdCard: state.ownerIdCard,
              ownerAddress: state.ownerAddress,
              ownerPhone: state.ownerPhone,
              buyerName: state.buyerName,
              buyerType: state.buyerType,
              buyerIdCard: state.buyerIdCard,
              buyerAddress: state.buyerAddress,
              buyerPhone: state.buyerPhone,
              boldFont: fonts.bold,
            ),
            pw.SizedBox(height: 10),
            _buildSectionHeader('ข้อ 1. วัตถุประสงค์แห่งสัญญา', fonts.bold),
            _buildClause1(),
            pw.SizedBox(height: 10),
            _buildSectionHeader('ข้อ 2. ทรัพย์สินที่เช่า', fonts.bold),
            _buildClause2(
              propertyName: state.propertyName,
              address: state.selectedProperty?.address,
              number: state.selectedProperty?.number,
              floor: state.selectedProperty?.specifications['floor'],
              area: state.selectedProperty?.buildingSize ?? 0,
            ),
            pw.SizedBox(height: 10),
            _buildSectionHeader('ข้อ 3. ระยะเวลาเช่า', fonts.bold),
            _buildClause3(
              leaseStartDate: state.leaseStartDate,
              leaseEndDate: state.leaseEndDate,
              dateFormat: dateFormat,
            ),
            pw.SizedBox(height: 10),
            _buildSectionHeader('ข้อ 4. ค่าเช่าและวิธีการชำระเงิน', fonts.bold),
            _buildClause4(
              price: state.price,
              dueDate: state.dueDate?.toString(),
              money: money,
            ),
            pw.SizedBox(height: 10),
            _buildSectionHeader(
              'ข้อ 5. เงินประกันและค่าเช่าล่วงหน้า',
              fonts.bold,
            ),
            _buildClause5(
              securityDeposit: state.securityDeposit,
              advanceRent: state.advanceRent,
              totalUpfrontPayment: state.totalUpfrontPayment,
              money: money,
            ),
            pw.SizedBox(height: 10),
            _buildSectionHeader(
              'ข้อ 6. ข้อมูลบัญชีธนาคารผู้ให้เช่า',
              fonts.bold,
            ),
            _buildClause6(
              bankBranch: state.bankBranch,
              accountNumber: state.accountNumber,
              accountName: state.accountName,
            ),
            pw.SizedBox(height: 30),
            _buildSignatures(
              ownerName: state.ownerName,
              buyerName: state.buyerName,
              boldFont: fonts.bold,
            ),
          ];
        },
      ),
    );

    // Annexes and Attachments
    await _addAnnexesAndAttachments(
      pdf: pdf,
      fonts: fonts,
      theme: theme,
      furnitureItems: state.furnitureItems,
      applianceItems: state.applianceItems,
      attachments: state.attachments,
    );

    return pdf.save();
  }

  Future<Uint8List> generateFromContract(Contract contract) async {
    final pdf = pw.Document();

    final fonts = await _loadFonts();
    final theme = pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold);

    final dateFormat = DateFormat('d MMMM yyyy', 'th');
    final currencyFormat = NumberFormat('#,##0.00', 'en_US');

    final contractDateStr = contract.contractDate != null
        ? dateFormat.format(
            DateTime(
              contract.contractDate!.year + 543,
              contract.contractDate!.month,
              contract.contractDate!.day,
            ),
          )
        : '..........................................................';

    String money(double? val) => val != null ? currencyFormat.format(val) : '-';
    double? parseMoney(String? s) =>
        s != null ? double.tryParse(s.replaceAll(',', '')) : null;

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          theme: theme,
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
        ),
        build: (pw.Context context) {
          return [
            _buildHeader(
              contractId: contract.id?.toString() ?? contract.contractNumber,
              date: contractDateStr,
              boldFont: fonts.bold,
            ),
            pw.SizedBox(height: 20),
            _buildParties(
              ownerName: contract.owner?.name ?? contract.lessor,
              ownerType: contract.owner?.type ?? PersonType.individual,
              ownerSignatory: contract.owner?.signatory ?? '',
              ownerIdCard: contract.owner?.idCard ?? '',
              ownerAddress: contract.owner?.address ?? '',
              ownerPhone: contract.owner?.phone ?? '',
              buyerName: contract.buyer?.name ?? contract.lessee,
              buyerType: contract.buyer?.type ?? PersonType.individual,
              buyerIdCard: contract.buyer?.idCard ?? '',
              buyerAddress: contract.buyer?.address ?? '',
              buyerPhone: contract.buyer?.phone ?? '',
              boldFont: fonts.bold,
            ),
            pw.SizedBox(height: 10),
            _buildSectionHeader('ข้อ 1. วัตถุประสงค์แห่งสัญญา', fonts.bold),
            _buildClause1(),
            pw.SizedBox(height: 10),
            _buildSectionHeader('ข้อ 2. ทรัพย์สินที่เช่า', fonts.bold),
            _buildClause2(
              propertyName: contract.propertyName,
              address: contract.property?.address,
              number: contract.propertyUnitNo ?? contract.property?.number,
              floor:
                  contract.propertyFloor ??
                  contract.property?.specifications['floor'],
              area: double.tryParse(contract.propertyAreaSqm ?? '0') ?? 0,
            ),
            pw.SizedBox(height: 10),
            _buildSectionHeader('ข้อ 3. ระยะเวลาเช่า', fonts.bold),
            _buildClause3(
              leaseStartDate: null, // Need to find where these are
              leaseEndDate: null,
              dateFormat: dateFormat,
            ),
            pw.SizedBox(height: 10),
            _buildSectionHeader('ข้อ 4. ค่าเช่าและวิธีการชำระเงิน', fonts.bold),
            _buildClause4(
              price: parseMoney(contract.monthlyRentalCost),
              dueDate: contract.rentalPaymentDate?.toString(),
              money: money,
            ),
            pw.SizedBox(height: 10),
            _buildSectionHeader(
              'ข้อ 5. เงินประกันและค่าเช่าล่วงหน้า',
              fonts.bold,
            ),
            _buildClause5(
              securityDeposit: parseMoney(contract.securityDeposit),
              advanceRent: parseMoney(contract.advanceRent),
              totalUpfrontPayment: parseMoney(contract.upfrontFee),
              money: money,
            ),
            pw.SizedBox(height: 10),
            _buildSectionHeader(
              'ข้อ 6. ข้อมูลบัญชีธนาคารผู้ให้เช่า',
              fonts.bold,
            ),
            _buildClause6(
              bankBranch: contract.bankAccounts.isNotEmpty
                  ? contract.bankAccounts.first.branch ?? ''
                  : '',
              accountNumber: contract.bankAccounts.isNotEmpty
                  ? contract.bankAccounts.first.accountNumber
                  : '',
              accountName: contract.bankAccounts.isNotEmpty
                  ? contract.bankAccounts.first.accountHolderName
                  : '',
            ),
            pw.SizedBox(height: 30),
            _buildSignatures(
              ownerName: contract.owner?.name ?? contract.lessor,
              buyerName: contract.buyer?.name ?? contract.lessee,
              boldFont: fonts.bold,
            ),
          ];
        },
      ),
    );

    // Annexes and Attachments
    await _addAnnexesAndAttachments(
      pdf: pdf,
      fonts: fonts,
      theme: theme,
      furnitureItems: contract.furniture,
      applianceItems: contract.appliances,
      attachments:
          [], // Contract entity doesn't have local attachments in the same way
    );

    return pdf.save();
  }

  Future<_Fonts> _loadFonts() async {
    final fontData = await rootBundle.load('assets/fonts/Anuphan-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);
    final boldFontData = await rootBundle.load('assets/fonts/Anuphan-Bold.ttf');
    final boldTtf = pw.Font.ttf(boldFontData);
    return _Fonts(regular: ttf, bold: boldTtf);
  }

  Future<void> _addAnnexesAndAttachments({
    required pw.Document pdf,
    required _Fonts fonts,
    required pw.ThemeData theme,
    required List<FurnitureItem> furnitureItems,
    required List<ApplianceItem> applianceItems,
    required List<ContractAttachment> attachments,
  }) async {
    // Annex: Furniture
    if (furnitureItems.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(theme: theme, pageFormat: PdfPageFormat.a4),
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                'รายการเฟอร์นิเจอร์ (Furniture List)',
                style: pw.TextStyle(font: fonts.bold, fontSize: 18),
              ),
            ),
            pw.Table.fromTextArray(
              headers: ['ลำดับ', 'รายการ', 'รายละเอียด'],
              data: furnitureItems.asMap().entries.map((e) {
                final item = e.value;
                return [
                  (e.key + 1).toString(),
                  item.name,
                  item.description ?? '',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(font: fonts.bold),
              cellAlignments: {0: pw.Alignment.center},
            ),
          ],
        ),
      );
    }

    // Annex: Appliances
    if (applianceItems.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(theme: theme, pageFormat: PdfPageFormat.a4),
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                'รายการเครื่องใช้ไฟฟ้า (Appliance List)',
                style: pw.TextStyle(font: fonts.bold, fontSize: 18),
              ),
            ),
            pw.Table.fromTextArray(
              headers: ['ลำดับ', 'รายการ', 'รายละเอียด'],
              data: applianceItems.asMap().entries.map((e) {
                final item = e.value;
                return [
                  (e.key + 1).toString(),
                  item.name,
                  item.description ?? '',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(font: fonts.bold),
              cellAlignments: {0: pw.Alignment.center},
            ),
          ],
        ),
      );
    }

    // Attachments (Images)
    if (attachments.isNotEmpty) {
      for (final attachment in attachments) {
        Uint8List? imageBytes;

        try {
          if (attachment.filePath != null && attachment.filePath!.isNotEmpty) {
            final file = File(attachment.filePath!);
            if (await file.exists()) {
              imageBytes = await file.readAsBytes();
            }
          } else if (attachment.fileUrl != null &&
              attachment.fileUrl!.isNotEmpty) {
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
                          style: pw.TextStyle(font: fonts.bold, fontSize: 16),
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
          print('Error loading attachment ${attachment.name}: $e');
        }
      }
    }
  }

  bool _isImage(String name) {
    final lower = name.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
  }

  pw.Widget _buildHeader({
    String? contractId,
    required String date,
    required pw.Font boldFont,
  }) {
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
            pw.Text('สัญญาเลขที่: ${contractId ?? "...................."}'),
          ],
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [pw.Text('วันที่: $date')],
        ),
      ],
    );
  }

  pw.Widget _buildParties({
    required String ownerName,
    required PersonType ownerType,
    required String ownerSignatory,
    required String ownerIdCard,
    required String ownerAddress,
    required String ownerPhone,
    required String buyerName,
    required PersonType buyerType,
    required String buyerIdCard,
    required String buyerAddress,
    required String buyerPhone,
    required pw.Font boldFont,
  }) {
    String ownerInfo = ownerName;
    if (ownerType == PersonType.juristic) {
      ownerInfo += ' (นิติบุคคล) โดย $ownerSignatory ผู้มีอำนาจลงนาม';
    }
    ownerInfo += ' เลขบัตรประชาชน/เลขทะเบียนนิติบุคคล: $ownerIdCard';
    ownerInfo += '\nที่อยู๋: $ownerAddress เบอร์โทร: $ownerPhone';

    String buyerInfo = buyerName;
    buyerInfo += ' เลขบัตรประชาชน: $buyerIdCard';
    buyerInfo += '\nที่อยู๋: $buyerAddress เบอร์โทร: $buyerPhone';

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

  pw.Widget _buildClause1() {
    return pw.Text(
      '        ผู้ให้เช่าตกลงให้เช่าและผู้เช่าตกลงเช่าทรัพย์สินตามรายละเอียดในข้อ 2 เพื่อใช้เป็นที่อยู่อาศัยเท่านั้น',
    );
  }

  pw.Widget _buildClause2({
    required String propertyName,
    String? address,
    String? number,
    String? floor,
    required double area,
  }) {
    String details = 'โครงการ: $propertyName';
    details += ' ที่อยู่: ${address ?? "-"}';
    if (number != null) details += ' เลขที่ห้อง: $number';
    if (floor != null) details += ' ชั้น: $floor';
    if (area > 0) details += ' ขนาด: $area ตร.ม.';

    return pw.Text('        $details (รายละเอียดตามเอกสารแนบ)');
  }

  pw.Widget _buildClause3({
    DateTime? leaseStartDate,
    DateTime? leaseEndDate,
    required DateFormat dateFormat,
  }) {
    final start = leaseStartDate != null
        ? dateFormat.format(
            DateTime(
              leaseStartDate.year + 543,
              leaseStartDate.month,
              leaseStartDate.day,
            ),
          )
        : '....................';
    final end = leaseEndDate != null
        ? dateFormat.format(
            DateTime(
              leaseEndDate.year + 543,
              leaseEndDate.month,
              leaseEndDate.day,
            ),
          )
        : '....................';

    final duration = AppUtils.formatLeaseDuration(leaseStartDate, leaseEndDate);

    return pw.Text(
      '        มีกำหนดระยะเวลาเช่า $duration เริ่มตั้งแต่วันที่ $start ถึงวันที่ $end',
    );
  }

  pw.Widget _buildClause4({
    double? price,
    String? dueDate,
    required String Function(double?) money,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '        ผู้เช่าตกลงชำระค่าเช่าให้แก่ผู้ให้เช่าในอัตราเดือนละ ${money(price)} บาท',
        ),
        pw.Text('        โดยจะชำระภายในวันที่ ${dueDate ?? "..."} ของทุกเดือน'),
      ],
    );
  }

  pw.Widget _buildClause5({
    double? securityDeposit,
    double? advanceRent,
    double? totalUpfrontPayment,
    required String Function(double?) money,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '        ในวันทำสัญญานี้ ผู้เช่าได้วางเงินประกันความเสียหายจำนวน ${money(securityDeposit)} บาท',
        ),
        pw.Text('        และค่าเช่าล่วงหน้าจำนวน ${money(advanceRent)} บาท'),
        pw.Text(
          '        รวมเป็นเงินทั้งสิ้น ${money(totalUpfrontPayment)} บาท แก่ผู้ให้เช่า',
        ),
      ],
    );
  }

  pw.Widget _buildClause6({
    required String bankBranch,
    required String accountNumber,
    required String accountName,
  }) {
    return pw.Text(
      '        ธนาคาร: $bankBranch เลขที่บัญชี: $accountNumber ชื่อบัญชี: $accountName',
    );
  }

  pw.Widget _buildSignatures({
    required String ownerName,
    required String buyerName,
    required pw.Font boldFont,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          children: [
            pw.Text(
              'ลงชื่อ ....................................................... ผู้ให้เช่า',
            ),
            pw.Text('($ownerName)'),
          ],
        ),
        pw.Column(
          children: [
            pw.Text(
              'ลงชื่อ ....................................................... ผู้เช่า',
            ),
            pw.Text('($buyerName)'),
          ],
        ),
      ],
    );
  }
}

class _Fonts {
  final pw.Font regular;
  final pw.Font bold;
  _Fonts({required this.regular, required this.bold});
}
