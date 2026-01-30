import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/badges/app_badge.dart';
import '../../../widgets/buttons/app_button.dart';
import '../../../domain/entities/contract_status.dart';
import '../../../domain/entities/contract_type.dart';
import '../../../domain/entities/contract.dart';

class ContractFilter {
  final ContractStatus? status;
  final String? propertyType;
  final ContractType? contractType;

  ContractFilter({this.status, this.propertyType, this.contractType});

  @override
  String toString() {
    return 'ContractFilter(status: $status, propertyType: $propertyType, contractType: $contractType)';
  }
}

class ContractFilterBottomSheet extends StatefulWidget {
  final List<Contract> allContracts;
  final ContractFilter? initialFilter;
  final Function(ContractFilter) onApply;

  const ContractFilterBottomSheet({
    super.key,
    required this.allContracts,
    this.initialFilter,
    required this.onApply,
  });

  @override
  State<ContractFilterBottomSheet> createState() =>
      _ContractFilterBottomSheetState();
}

class _ContractFilterBottomSheetState extends State<ContractFilterBottomSheet> {
  ContractStatus? _selectedStatus;
  String? _selectedPropertyType;
  ContractType? _selectedContractType;

  @override
  void initState() {
    super.initState();
    if (widget.initialFilter != null) {
      _selectedStatus = widget.initialFilter!.status;
      _selectedPropertyType = widget.initialFilter!.propertyType;
      _selectedContractType = widget.initialFilter!.contractType;
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedPropertyType = null;
      _selectedContractType = null;
    });
  }

  int get _filteredCount {
    return widget.allContracts
        .where((Contract contract) {
          final matchesStatus =
              _selectedStatus == null || contract.status == _selectedStatus;
          final matchesPropertyType =
              _selectedPropertyType == null ||
              contract.propertyType == _selectedPropertyType;
          final matchesContractType =
              _selectedContractType == null ||
              contract.contractType == _selectedContractType;

          return matchesStatus && matchesPropertyType && matchesContractType;
        })
        .toList()
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: (screenHeight - kToolbarHeight) * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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

          // Content
          Flexible(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppBadge(
                      label: 'ตัวกรองการค้นหา',
                      color: BadgeColor.blue,
                    ),
                    const SizedBox(height: 24),

                    // สถานะการอนุมัติ
                    _buildFilterSection(
                      title: 'สถานะการอนุมัติ',
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.start,
                        alignment: WrapAlignment.start,
                        runAlignment: WrapAlignment.start,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildChip(
                            'ทั้งหมด',
                            isSelected: _selectedStatus == null,
                            onTap: () => setState(() => _selectedStatus = null),
                          ),
                          _buildChip(
                            'ฉบับร่าง',
                            isSelected: _selectedStatus == ContractStatus.draft,
                            onTap: () => setState(
                              () => _selectedStatus = ContractStatus.draft,
                            ),
                          ),
                          _buildChip(
                            'ยังไม่สมบูรณ์',
                            isSelected:
                                _selectedStatus ==
                                ContractStatus.pendingSignature,
                            onTap: () => setState(
                              () => _selectedStatus =
                                  ContractStatus.pendingSignature,
                            ),
                          ),
                          _buildChip(
                            'สมบูรณ์',
                            isSelected:
                                _selectedStatus == ContractStatus.completed,
                            onTap: () => setState(
                              () => _selectedStatus = ContractStatus.completed,
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
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildChip(
                            'ทั้งหมด',
                            isSelected: _selectedPropertyType == null,
                            onTap: () =>
                                setState(() => _selectedPropertyType = null),
                          ),
                          _buildChip(
                            'บ้าน',
                            isSelected: _selectedPropertyType == 'บ้าน',
                            onTap: () =>
                                setState(() => _selectedPropertyType = 'บ้าน'),
                          ),
                          _buildChip(
                            'คอนโดมิเนียม',
                            isSelected: _selectedPropertyType == 'คอนโดมิเนียม',
                            onTap: () => setState(
                              () => _selectedPropertyType = 'คอนโดมิเนียม',
                            ),
                          ),
                          _buildChip(
                            'ทาวน์เฮ้าส์/ทาวน์โฮม',
                            isSelected:
                                _selectedPropertyType == 'ทาวน์เฮ้าส์/ทาวน์โฮม',
                            onTap: () => setState(
                              () => _selectedPropertyType =
                                  'ทาวน์เฮ้าส์/ทาวน์โฮม',
                            ),
                          ),
                          _buildChip(
                            'อพาร์ตเมนต์',
                            isSelected: _selectedPropertyType == 'อพาร์ตเมนต์',
                            onTap: () => setState(
                              () => _selectedPropertyType = 'อพาร์ตเมนต์',
                            ),
                          ),
                          _buildChip(
                            'โฮมออฟฟิศ',
                            isSelected: _selectedPropertyType == 'โฮมออฟฟิศ',
                            onTap: () => setState(
                              () => _selectedPropertyType = 'โฮมออฟฟิศ',
                            ),
                          ),
                          _buildChip(
                            'พูลวิลล่า',
                            isSelected: _selectedPropertyType == 'พูลวิลล่า',
                            onTap: () => setState(
                              () => _selectedPropertyType = 'พูลวิลล่า',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ประเภทสัญญา
                    _buildFilterSection(
                      title: 'ประเภทสัญญา',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildChip(
                            'ทั้งหมด',
                            isSelected: _selectedContractType == null,
                            onTap: () =>
                                setState(() => _selectedContractType = null),
                          ),
                          _buildChip(
                            'สัญญาขาย',
                            isSelected:
                                _selectedContractType == ContractType.buy,
                            onTap: () => setState(
                              () => _selectedContractType = ContractType.buy,
                            ),
                          ),
                          _buildChip(
                            'สัญญาเช่า',
                            isSelected:
                                _selectedContractType == ContractType.rent,
                            onTap: () => setState(
                              () => _selectedContractType = ContractType.rent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Buttons
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'ล้างค่า',
                    style: AppButtonStyle.outline,
                    onPressed: _clearFilters,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    text: 'แสดงผลลัพธ์ ($_filteredCount)',
                    style: AppButtonStyle.primary,
                    onPressed: () {
                      widget.onApply(
                        ContractFilter(
                          status: _selectedStatus,
                          propertyType: _selectedPropertyType,
                          contractType: _selectedContractType,
                        ),
                      );
                      Navigator.pop(context);
                    },
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: ShapeDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: isSelected
                  ? const Color(0xFF3B82F6)
                  : const Color(0xFFE9EAEB),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.anuphan(
            color: isSelected
                ? const Color(0xFF3B82F6)
                : const Color(0xFF717680),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
