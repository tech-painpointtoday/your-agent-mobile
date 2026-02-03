import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import 'package:youragent/widgets/buttons/app_button.dart';

/// Filter bottom sheet for properties
class PropertyFilterBottomSheet extends StatefulWidget {
  const PropertyFilterBottomSheet({super.key});

  @override
  State<PropertyFilterBottomSheet> createState() =>
      _PropertyFilterBottomSheetState();
}

class _PropertyFilterBottomSheetState extends State<PropertyFilterBottomSheet> {
  // Filter States
  String? selectedApprovalStatus = 'ทั้งหมด';
  String? selectedPropertyType = 'ทั้งหมด';
  String? selectedListingType = 'ทั้งหมด';
  String? selectedStatus;
  String? selectedColor;
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  int? selectedFloors;
  int? selectedBedrooms;
  int? selectedBathrooms;
  int? selectedParkingSpaces;
  final TextEditingController _landSizeController = TextEditingController();
  final TextEditingController _usableAreaController = TextEditingController();
  Set<String> selectedPropertyStyles = {};
  Set<String> selectedPropertyHighlights = {};
  Set<String> selectedCommonFacilities = {};

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _landSizeController.dispose();
    _usableAreaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: (screenHeight - kToolbarHeight) * 0.93,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            width: 32,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 16),
            decoration: ShapeDecoration(
              color: const Color(0xFFD9D9D9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Scrollable Filter Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppBadge(label: 'ตัวกรองการค้นหา', color: BadgeColor.blue),
                  const SizedBox(height: 16),
                  // สถานะการอนุมัติ
                  _buildFilterSection(
                    title: 'สถานะการอนุมัติ',
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      runAlignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChip(
                          'ทั้งหมด',
                          isSelected: selectedApprovalStatus == 'ทั้งหมด',
                          onTap: () => setState(
                            () => selectedApprovalStatus = 'ทั้งหมด',
                          ),
                        ),
                        _buildChip(
                          'รอการอนุมัติ',
                          isSelected: selectedApprovalStatus == 'รอการอนุมัติ',
                          onTap: () => setState(
                            () => selectedApprovalStatus = 'รอการอนุมัติ',
                          ),
                        ),
                        _buildChip(
                          'อนุมัติแล้ว',
                          isSelected: selectedApprovalStatus == 'อนุมัติแล้ว',
                          onTap: () => setState(
                            () => selectedApprovalStatus = 'อนุมัติแล้ว',
                          ),
                        ),
                        _buildChip(
                          'ไม่อนุมัติ',
                          isSelected: selectedApprovalStatus == 'ไม่อนุมัติ',
                          onTap: () => setState(
                            () => selectedApprovalStatus = 'ไม่อนุมัติ',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ประเภททรัพย์
                  _buildFilterSection(
                    title: 'ประเภททรัพย์',
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      runAlignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChip(
                          'ทั้งหมด',
                          isSelected: selectedPropertyType == 'ทั้งหมด',
                          onTap: () =>
                              setState(() => selectedPropertyType = 'ทั้งหมด'),
                        ),
                        _buildChip(
                          'บ้าน',
                          isSelected: selectedPropertyType == 'บ้าน',
                          onTap: () =>
                              setState(() => selectedPropertyType = 'บ้าน'),
                        ),
                        _buildChip(
                          'คอนโด',
                          isSelected: selectedPropertyType == 'คอนโด',
                          onTap: () =>
                              setState(() => selectedPropertyType = 'คอนโด'),
                        ),
                        _buildChip(
                          'ทาวน์โฮม',
                          isSelected: selectedPropertyType == 'ทาวน์โฮม',
                          onTap: () =>
                              setState(() => selectedPropertyType = 'ทาวน์โฮม'),
                        ),
                        _buildChip(
                          'อพาร์ตเมนต์',
                          isSelected: selectedPropertyType == 'อพาร์ตเมนต์',
                          onTap: () => setState(
                            () => selectedPropertyType = 'อพาร์ตเมนต์',
                          ),
                        ),
                        _buildChip(
                          'พูลวิลล่า',
                          isSelected: selectedPropertyType == 'พูลวิลล่า',
                          onTap: () => setState(
                            () => selectedPropertyType = 'พูลวิลล่า',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ประเภทประกาศ
                  _buildFilterSection(
                    title: 'ประเภทประกาศ',
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      runAlignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChip(
                          'ทั้งหมด',
                          isSelected: selectedListingType == 'ทั้งหมด',
                          onTap: () =>
                              setState(() => selectedListingType = 'ทั้งหมด'),
                        ),
                        _buildChip(
                          'ขาย',
                          isSelected: selectedListingType == 'ขาย',
                          onTap: () =>
                              setState(() => selectedListingType = 'ขาย'),
                        ),
                        _buildChip(
                          'เช่า',
                          isSelected: selectedListingType == 'เช่า',
                          onTap: () =>
                              setState(() => selectedListingType = 'เช่า'),
                        ),
                        _buildChip(
                          'ขายและเช่า',
                          isSelected: selectedListingType == 'ขายและเช่า',
                          onTap: () => setState(
                            () => selectedListingType = 'ขายและเช่า',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // สถานะ
                  _buildFilterSection(
                    title: 'สถานะ',
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      runAlignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChip(
                          'ว่าง',
                          isSelected: selectedStatus == 'ว่าง',
                          onTap: () => setState(() => selectedStatus = 'ว่าง'),
                        ),
                        _buildChip(
                          'ไม่ว่าง',
                          isSelected: selectedStatus == 'ไม่ว่าง',
                          onTap: () =>
                              setState(() => selectedStatus = 'ไม่ว่าง'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // สีทรัพย์
                  _buildFilterSection(
                    title: 'สีทรัพย์',
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      runAlignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChip(
                          'ขาว',
                          isSelected: selectedColor == 'ขาว',
                          onTap: () => setState(() => selectedColor = 'ขาว'),
                        ),
                        _buildChip(
                          'เทา',
                          isSelected: selectedColor == 'เทา',
                          onTap: () => setState(() => selectedColor = 'เทา'),
                        ),
                        _buildChip(
                          'ดำ',
                          isSelected: selectedColor == 'ดำ',
                          onTap: () => setState(() => selectedColor = 'ดำ'),
                        ),
                        _buildChip(
                          'ครีม',
                          isSelected: selectedColor == 'ครีม',
                          onTap: () => setState(() => selectedColor = 'ครีม'),
                        ),
                        _buildChip(
                          'น้ำตาล',
                          isSelected: selectedColor == 'น้ำตาล',
                          onTap: () => setState(() => selectedColor = 'น้ำตาล'),
                        ),
                        _buildChip(
                          'น้ำเงิน',
                          isSelected: selectedColor == 'น้ำเงิน',
                          onTap: () =>
                              setState(() => selectedColor = 'น้ำเงิน'),
                        ),
                        _buildChip(
                          'ฟ้า',
                          isSelected: selectedColor == 'ฟ้า',
                          onTap: () => setState(() => selectedColor = 'ฟ้า'),
                        ),
                        _buildChip(
                          'ชมพู',
                          isSelected: selectedColor == 'ชมพู',
                          onTap: () => setState(() => selectedColor = 'ชมพู'),
                        ),
                        _buildChip(
                          'เขียว',
                          isSelected: selectedColor == 'เขียว',
                          onTap: () => setState(() => selectedColor = 'เขียว'),
                        ),
                        _buildChip(
                          'เหลือง',
                          isSelected: selectedColor == 'เหลือง',
                          onTap: () => setState(() => selectedColor = 'เหลือง'),
                        ),
                        _buildChip(
                          'แดง',
                          isSelected: selectedColor == 'แดง',
                          onTap: () => setState(() => selectedColor = 'แดง'),
                        ),
                        _buildChip(
                          'ส้ม',
                          isSelected: selectedColor == 'ส้ม',
                          onTap: () => setState(() => selectedColor = 'ส้ม'),
                        ),
                        _buildChip(
                          'ม่วง',
                          isSelected: selectedColor == 'ม่วง',
                          onTap: () => setState(() => selectedColor = 'ม่วง'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Price Range
                  Row(
                    children: [
                      Expanded(
                        child: _buildPriceInput(
                          label: 'ราคาเริ่มต้น',
                          controller: _minPriceController,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildPriceInput(
                          label: 'ราคาสูงสุด',
                          controller: _maxPriceController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // จำนวนชั้น
                  _buildFilterSection(
                    title: 'จำนวนชั้น',
                    child: Row(
                      children: [
                        for (int i = 1; i <= 5; i++)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: i < 5 ? 8 : 0),
                              child: _buildChip(
                                '$i',
                                isSelected: selectedFloors == i,
                                onTap: () => setState(() => selectedFloors = i),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // จำนวนห้องนอน
                  _buildFilterSection(
                    title: 'จำนวนห้องนอน',
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      runAlignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (int i = 1; i <= 7; i++)
                          _buildChip(
                            '$i',
                            isSelected: selectedBedrooms == i,
                            onTap: () => setState(() => selectedBedrooms = i),
                          ),
                        _buildChip(
                          'Studio',
                          isSelected: selectedBedrooms == 0,
                          onTap: () => setState(() => selectedBedrooms = 0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // จำนวนห้องน้ำ
                  _buildFilterSection(
                    title: 'จำนวนห้องน้ำ',
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      runAlignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (int i = 1; i <= 7; i++)
                          _buildChip(
                            '$i',
                            isSelected: selectedBathrooms == i,
                            onTap: () => setState(() => selectedBathrooms = i),
                          ),
                        _buildChip(
                          '8+',
                          isSelected: selectedBathrooms == 8,
                          onTap: () => setState(() => selectedBathrooms = 8),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // จำนวนที่จอดรถ
                  _buildFilterSection(
                    title: 'จำนวนที่จอดรถ',
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      runAlignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (int i = 1; i <= 8; i++)
                          _buildChip(
                            '$i',
                            isSelected: selectedParkingSpaces == i,
                            onTap: () =>
                                setState(() => selectedParkingSpaces = i),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ขนาดที่ดิน / ขนาดพื้นที่ใช้สอย
                  Row(
                    children: [
                      Expanded(
                        child: _buildSizeInput(
                          label: 'ขนาดที่ดิน',
                          controller: _landSizeController,
                          unit: 'ตร.ว.',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSizeInput(
                          label: 'ขนาดพื้นที่ใช้สอย',
                          controller: _usableAreaController,
                          unit: 'ตร.ม.',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // สไตล์ทรัพย์
                  _buildFilterSection(
                    title: 'สไตล์ทรัพย์',
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      runAlignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildMultiSelectChip(
                          'หรูหรา',
                          isSelected: selectedPropertyStyles.contains('หรูหรา'),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyStyles.contains('หรูหรา')) {
                                selectedPropertyStyles.remove('หรูหรา');
                              } else {
                                selectedPropertyStyles.add('หรูหรา');
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          'คลาสสิค',
                          isSelected: selectedPropertyStyles.contains(
                            'คลาสสิค',
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyStyles.contains('คลาสสิค')) {
                                selectedPropertyStyles.remove('คลาสสิค');
                              } else {
                                selectedPropertyStyles.add('คลาสสิค');
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          'โมเดิร์น',
                          isSelected: selectedPropertyStyles.contains(
                            'โมเดิร์น',
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyStyles.contains('โมเดิร์น')) {
                                selectedPropertyStyles.remove('โมเดิร์น');
                              } else {
                                selectedPropertyStyles.add('โมเดิร์น');
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          'เนเชอรัล',
                          isSelected: selectedPropertyStyles.contains(
                            'เนเชอรัล',
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyStyles.contains('เนเชอรัล')) {
                                selectedPropertyStyles.remove('เนเชอรัล');
                              } else {
                                selectedPropertyStyles.add('เนเชอรัล');
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          'ลอฟท์',
                          isSelected: selectedPropertyStyles.contains('ลอฟท์'),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyStyles.contains('ลอฟท์')) {
                                selectedPropertyStyles.remove('ลอฟท์');
                              } else {
                                selectedPropertyStyles.add('ลอฟท์');
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          'มินิมอล',
                          isSelected: selectedPropertyStyles.contains(
                            'มินิมอล',
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyStyles.contains('มินิมอล')) {
                                selectedPropertyStyles.remove('มินิมอล');
                              } else {
                                selectedPropertyStyles.add('มินิมอล');
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          'วินเทจ',
                          isSelected: selectedPropertyStyles.contains('วินเทจ'),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyStyles.contains('วินเทจ')) {
                                selectedPropertyStyles.remove('วินเทจ');
                              } else {
                                selectedPropertyStyles.add('วินเทจ');
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          'ร่วมสมัย',
                          isSelected: selectedPropertyStyles.contains(
                            'ร่วมสมัย',
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyStyles.contains('ร่วมสมัย')) {
                                selectedPropertyStyles.remove('ร่วมสมัย');
                              } else {
                                selectedPropertyStyles.add('ร่วมสมัย');
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          'โคโลเนียล',
                          isSelected: selectedPropertyStyles.contains(
                            'โคโลเนียล',
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyStyles.contains(
                                'โคโลเนียล',
                              )) {
                                selectedPropertyStyles.remove('โคโลเนียล');
                              } else {
                                selectedPropertyStyles.add('โคโลเนียล');
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          'ไทยร่วมสมัย',
                          isSelected: selectedPropertyStyles.contains(
                            'ไทยร่วมสมัย',
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyStyles.contains(
                                'ไทยร่วมสมัย',
                              )) {
                                selectedPropertyStyles.remove('ไทยร่วมสมัย');
                              } else {
                                selectedPropertyStyles.add('ไทยร่วมสมัย');
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          'บอร์ดิก',
                          isSelected: selectedPropertyStyles.contains(
                            'บอร์ดิก',
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyStyles.contains('บอร์ดิก')) {
                                selectedPropertyStyles.remove('บอร์ดิก');
                              } else {
                                selectedPropertyStyles.add('บอร์ดิก');
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // จุดเด่นทรัพย์
                  _buildFilterSection(
                    title: 'จุดเด่นทรัพย์',
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      runAlignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildMultiSelectChip(
                          'Pet-friendly',
                          isSelected: selectedPropertyHighlights.contains(
                            'Pet-friendly',
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyHighlights.contains(
                                'Pet-friendly',
                              )) {
                                selectedPropertyHighlights.remove(
                                  'Pet-friendly',
                                );
                              } else {
                                selectedPropertyHighlights.add('Pet-friendly');
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          'Elderly-Friendly',
                          isSelected: selectedPropertyHighlights.contains(
                            'Elderly-Friendly',
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyHighlights.contains(
                                'Elderly-Friendly',
                              )) {
                                selectedPropertyHighlights.remove(
                                  'Elderly-Friendly',
                                );
                              } else {
                                selectedPropertyHighlights.add(
                                  'Elderly-Friendly',
                                );
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          'ใกล้ทางด่วน',
                          isSelected: selectedPropertyHighlights.contains(
                            'ใกล้ทางด่วน',
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyHighlights.contains(
                                'ใกล้ทางด่วน',
                              )) {
                                selectedPropertyHighlights.remove(
                                  'ใกล้ทางด่วน',
                                );
                              } else {
                                selectedPropertyHighlights.add('ใกล้ทางด่วน');
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          'ใกล้รถไฟฟ้า',
                          isSelected: selectedPropertyHighlights.contains(
                            'ใกล้รถไฟฟ้า',
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyHighlights.contains(
                                'ใกล้รถไฟฟ้า',
                              )) {
                                selectedPropertyHighlights.remove(
                                  'ใกล้รถไฟฟ้า',
                                );
                              } else {
                                selectedPropertyHighlights.add('ใกล้รถไฟฟ้า');
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          'ใกล้โรงพยาบาล',
                          isSelected: selectedPropertyHighlights.contains(
                            'ใกล้โรงพยาบาล',
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyHighlights.contains(
                                'ใกล้โรงพยาบาล',
                              )) {
                                selectedPropertyHighlights.remove(
                                  'ใกล้โรงพยาบาล',
                                );
                              } else {
                                selectedPropertyHighlights.add('ใกล้โรงพยาบาล');
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          'โครงการใหม่',
                          isSelected: selectedPropertyHighlights.contains(
                            'โครงการใหม่',
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyHighlights.contains(
                                'โครงการใหม่',
                              )) {
                                selectedPropertyHighlights.remove(
                                  'โครงการใหม่',
                                );
                              } else {
                                selectedPropertyHighlights.add('โครงการใหม่');
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ส่วนกลาง
                  _buildFilterSection(
                    title: 'ส่วนกลาง',
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      runAlignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildMultiSelectChip(
                          'ฟิตเนส',
                          isSelected: selectedCommonFacilities.contains(
                            'ฟิตเนส',
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedCommonFacilities.contains('ฟิตเนส')) {
                                selectedCommonFacilities.remove('ฟิตเนส');
                              } else {
                                selectedCommonFacilities.add('ฟิตเนส');
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          'สระว่ายน้ำ',
                          isSelected: selectedCommonFacilities.contains(
                            'สระว่ายน้ำ',
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedCommonFacilities.contains(
                                'สระว่ายน้ำ',
                              )) {
                                selectedCommonFacilities.remove('สระว่ายน้ำ');
                              } else {
                                selectedCommonFacilities.add('สระว่ายน้ำ');
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          'สนามหญ้า',
                          isSelected: selectedCommonFacilities.contains(
                            'สนามหญ้า',
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedCommonFacilities.contains(
                                'สนามหญ้า',
                              )) {
                                selectedCommonFacilities.remove('สนามหญ้า');
                              } else {
                                selectedCommonFacilities.add('สนามหญ้า');
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          'Co-working space',
                          isSelected: selectedCommonFacilities.contains(
                            'Co-working space',
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedCommonFacilities.contains(
                                'Co-working space',
                              )) {
                                selectedCommonFacilities.remove(
                                  'Co-working space',
                                );
                              } else {
                                selectedCommonFacilities.add(
                                  'Co-working space',
                                );
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          'สนามเด็กเล่น',
                          isSelected: selectedCommonFacilities.contains(
                            'สนามเด็กเล่น',
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedCommonFacilities.contains(
                                'สนามเด็กเล่น',
                              )) {
                                selectedCommonFacilities.remove('สนามเด็กเล่น');
                              } else {
                                selectedCommonFacilities.add('สนามเด็กเล่น');
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          'สนามกีฬา',
                          isSelected: selectedCommonFacilities.contains(
                            'สนามกีฬา',
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedCommonFacilities.contains(
                                'สนามกีฬา',
                              )) {
                                selectedCommonFacilities.remove('สนามกีฬา');
                              } else {
                                selectedCommonFacilities.add('สนามกีฬา');
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          'เจ้าหน้าที่ รปภ.',
                          isSelected: selectedCommonFacilities.contains(
                            'เจ้าหน้าที่ รปภ.',
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedCommonFacilities.contains(
                                'เจ้าหน้าที่ รปภ.',
                              )) {
                                selectedCommonFacilities.remove(
                                  'เจ้าหน้าที่ รปภ.',
                                );
                              } else {
                                selectedCommonFacilities.add(
                                  'เจ้าหน้าที่ รปภ.',
                                );
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sticky Action Buttons
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              MediaQuery.of(context).padding.bottom > 0
                  ? MediaQuery.of(context).padding.bottom
                  : 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: AppButton(
                    text: 'ล้างค่า',
                    style: AppButtonStyle.outline,
                    onPressed: _clearFilters,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: AppButton(
                    text: 'แสดงผลลัพธ์ (100)',
                    style: AppButtonStyle.primary,
                    onPressed: _applyFilters,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({required String title, required Widget child}) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
            child: Row(
              children: [
                Text(
                  title,
                  style: GoogleFonts.anuphan(
                    color: const Color(0xFF181D27),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildChip(
    String label, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: ShapeDecoration(
          color: isSelected ? const Color(0xFFEFF8FF) : Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: isSelected
                  ? const Color(0xFF2E90FA)
                  : const Color(0xFFE9EAEB),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.anuphan(
                color: isSelected
                    ? const Color(0xFF2E90FA)
                    : const Color(0xFF717680),
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceInput({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.anuphan(
                color: const Color(0xFF181D27),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.43,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFE9E9EB)),
              borderRadius: BorderRadius.circular(12),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x0C0A0C12),
                blurRadius: 2,
                offset: Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.anuphan(
                    color: const Color(0xFF181D27),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: GoogleFonts.anuphan(
                      color: const Color(0xFFA4A7AE),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'บาท',
                textAlign: TextAlign.right,
                style: GoogleFonts.anuphan(
                  color: const Color(0xFFA4A7AE),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSizeInput({
    required String label,
    required TextEditingController controller,
    required String unit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.anuphan(
                color: const Color(0xFF181D27),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.43,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFE9E9EB)),
              borderRadius: BorderRadius.circular(12),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x0C0A0C12),
                blurRadius: 2,
                offset: Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.anuphan(
                    color: const Color(0xFF181D27),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: GoogleFonts.anuphan(
                      color: const Color(0xFFA4A7AE),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                unit,
                textAlign: TextAlign.right,
                style: GoogleFonts.anuphan(
                  color: const Color(0xFFA4A7AE),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectChip(
    String label, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: ShapeDecoration(
          color: isSelected ? const Color(0xFFEFF8FF) : Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: isSelected
                  ? const Color(0xFF2E90FA)
                  : const Color(0xFFE9EAEB),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.anuphan(
                color: isSelected
                    ? const Color(0xFF2E90FA)
                    : const Color(0xFF717680),
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      selectedApprovalStatus = 'ทั้งหมด';
      selectedPropertyType = 'ทั้งหมด';
      selectedListingType = 'ทั้งหมด';
      selectedStatus = null;
      selectedColor = null;
      _minPriceController.clear();
      _maxPriceController.clear();
      selectedFloors = null;
      selectedBedrooms = null;
      selectedBathrooms = null;
      selectedParkingSpaces = null;
      _landSizeController.clear();
      _usableAreaController.clear();
      selectedPropertyStyles.clear();
      selectedPropertyHighlights.clear();
      selectedCommonFacilities.clear();
    });
  }

  void _applyFilters() {
    // TODO: Apply filters to property list
    Navigator.pop(context);
  }
}
