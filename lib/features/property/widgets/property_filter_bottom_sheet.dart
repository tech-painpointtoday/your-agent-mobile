import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/widgets/inputs/app_dropdown.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/domain/entities/property_filter.dart';
import 'package:youragent/features/property/bloc/property_metadata/property_metadata_bloc.dart';
import 'package:youragent/features/property/bloc/property_metadata/property_metadata_state.dart';

/// Filter bottom sheet for properties
class PropertyFilterBottomSheet extends StatefulWidget {
  final PropertyFilter? initialFilter;
  final List<Property> properties;

  const PropertyFilterBottomSheet({
    super.key,
    this.initialFilter,
    required this.properties,
  });

  @override
  State<PropertyFilterBottomSheet> createState() =>
      _PropertyFilterBottomSheetState();
}

class _PropertyFilterBottomSheetState extends State<PropertyFilterBottomSheet> {
  // Filter States
  String? selectedApprovalStatus;
  String? selectedPropertyType;
  String? selectedListingType;
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
  // Dynamic specification filters
  Map<String, String?> selectedSingleSelectSpecs = {};
  Map<String, Set<String>> selectedMultiSelectSpecs = {};

  int _matchingCount = 0;

  @override
  void initState() {
    super.initState();
    final filter = widget.initialFilter;
    if (filter != null) {
      selectedApprovalStatus = filter.approvalStatus;
      selectedPropertyType = filter.propertyType;
      selectedListingType = filter.listingType;
      selectedStatus = filter.occupancyStatus;
      selectedColor = filter.color;
      if (filter.minPrice != null) {
        _minPriceController.text = filter.minPrice!.toStringAsFixed(0);
      }
      if (filter.maxPrice != null) {
        _maxPriceController.text = filter.maxPrice!.toStringAsFixed(0);
      }
      selectedFloors = filter.floors;
      selectedBedrooms = filter.bedrooms;
      selectedBathrooms = filter.bathrooms;
      selectedParkingSpaces = filter.parkingSpaces;
      if (filter.landSize != null) {
        _landSizeController.text = filter.landSize!.toString();
      }
      if (filter.usableArea != null) {
        _usableAreaController.text = filter.usableArea!.toString();
      }
      selectedSingleSelectSpecs = Map.from(filter.singleSelectSpecs);
      selectedMultiSelectSpecs = Map.from(filter.multiSelectSpecs);

      // Ensure defaults for sections with "All" option if null
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateFilter(() {
            selectedApprovalStatus ??= AppLocalizations.of(context).all;
            selectedPropertyType ??= AppLocalizations.of(context).all;
            selectedListingType ??= AppLocalizations.of(context).all;
            selectedStatus ??= AppLocalizations.of(context).all;
            selectedColor ??= AppLocalizations.of(context).all;
          });
        }
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateFilter(() {
            selectedApprovalStatus = AppLocalizations.of(context).all;
            selectedPropertyType = AppLocalizations.of(context).all;
            selectedListingType = AppLocalizations.of(context).all;
            selectedStatus = AppLocalizations.of(context).all;
            selectedColor = AppLocalizations.of(context).all;
          });
        }
      });
    }
    _updateMatchingCount();
    _minPriceController.addListener(_updateMatchingCount);
    _maxPriceController.addListener(_updateMatchingCount);
    _landSizeController.addListener(_updateMatchingCount);
    _usableAreaController.addListener(_updateMatchingCount);
  }

  void _updateMatchingCount() {
    final filter = PropertyFilter(
      approvalStatus: selectedApprovalStatus,
      propertyType: selectedPropertyType,
      listingType: selectedListingType,
      occupancyStatus: selectedStatus,
      color: selectedColor,
      minPrice: double.tryParse(_minPriceController.text),
      maxPrice: double.tryParse(_maxPriceController.text),
      floors: selectedFloors,
      bedrooms: selectedBedrooms,
      bathrooms: selectedBathrooms,
      parkingSpaces: selectedParkingSpaces,
      landSize: double.tryParse(_landSizeController.text),
      usableArea: double.tryParse(_usableAreaController.text),
      singleSelectSpecs: selectedSingleSelectSpecs.map(
        (k, v) => MapEntry(k, v ?? ''),
      ),
      multiSelectSpecs: selectedMultiSelectSpecs,
    );

    setState(() {
      _matchingCount = widget.properties.where((p) => filter.matches(p)).length;
    });
  }

  void _updateFilter(VoidCallback update) {
    setState(update);
    _updateMatchingCount();
  }

  void _onChipTap<T>(
    T value,
    T? current,
    T? defaultValue,
    void Function(T?) updater,
  ) {
    _updateFilter(() {
      if (current == value) {
        // If clicking the default value, stay on it. Otherwise revert to default.
        if (value != defaultValue) {
          updater(defaultValue);
        }
      } else {
        updater(value);
      }
    });
  }

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
    return BlocBuilder<PropertyMetadataBloc, PropertyMetadataState>(
      builder: (context, state) {
        final screenHeight = MediaQuery.of(context).size.height;
        final specifications = state.specificationFilters;

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
                      AppBadge(
                        label: AppLocalizations.of(context).searchFilterLabel,
                        color: BadgeColor.blue,
                      ),
                      const SizedBox(height: 16),
                      // สถานะการอนุมัติ
                      _buildFilterSection(
                        title: AppLocalizations.of(context).approvalStatus,
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          runAlignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildChip(
                              AppLocalizations.of(context).all,
                              isSelected:
                                  selectedApprovalStatus ==
                                  AppLocalizations.of(context).all,
                              onTap: () => _onChipTap(
                                AppLocalizations.of(context).all,
                                selectedApprovalStatus,
                                AppLocalizations.of(context).all,
                                (v) => selectedApprovalStatus = v,
                              ),
                            ),
                            _buildChip(
                              AppLocalizations.of(context).pendingAt,
                              isSelected:
                                  selectedApprovalStatus ==
                                  AppLocalizations.of(context).pendingAt,
                              onTap: () => _onChipTap(
                                AppLocalizations.of(context).pendingAt,
                                selectedApprovalStatus,
                                AppLocalizations.of(context).all,
                                (v) => selectedApprovalStatus = v,
                              ),
                            ),
                            _buildChip(
                              AppLocalizations.of(context).approvedAt,
                              isSelected:
                                  selectedApprovalStatus ==
                                  AppLocalizations.of(context).approvedAt,
                              onTap: () => _onChipTap(
                                AppLocalizations.of(context).approvedAt,
                                selectedApprovalStatus,
                                AppLocalizations.of(context).all,
                                (v) => selectedApprovalStatus = v,
                              ),
                            ),
                            _buildChip(
                              AppLocalizations.of(context).disapprovedAt,
                              isSelected:
                                  selectedApprovalStatus ==
                                  AppLocalizations.of(context).disapprovedAt,
                              onTap: () => _onChipTap(
                                AppLocalizations.of(context).disapprovedAt,
                                selectedApprovalStatus,
                                AppLocalizations.of(context).all,
                                (v) => selectedApprovalStatus = v,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // ประเภททรัพย์สิน
                      _buildFilterSection(
                        title: AppLocalizations.of(context).property_type,
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          runAlignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildChip(
                              AppLocalizations.of(context).all,
                              isSelected:
                                  selectedPropertyType ==
                                  AppLocalizations.of(context).all,
                              onTap: () => _onChipTap(
                                AppLocalizations.of(context).all,
                                selectedPropertyType,
                                AppLocalizations.of(context).all,
                                (v) => selectedPropertyType = v,
                              ),
                            ),
                            _buildChip(
                              AppLocalizations.of(
                                context,
                              ).property_type_condominium,
                              isSelected:
                                  selectedPropertyType ==
                                  AppLocalizations.of(
                                    context,
                                  ).property_type_condominium,
                              onTap: () => _onChipTap(
                                AppLocalizations.of(
                                  context,
                                ).property_type_condominium,
                                selectedPropertyType,
                                AppLocalizations.of(context).all,
                                (v) => selectedPropertyType = v,
                              ),
                            ),
                            _buildChip(
                              AppLocalizations.of(context).property_type_house,
                              isSelected:
                                  selectedPropertyType ==
                                  AppLocalizations.of(
                                    context,
                                  ).property_type_house,
                              onTap: () => _onChipTap(
                                AppLocalizations.of(
                                  context,
                                ).property_type_house,
                                selectedPropertyType,
                                AppLocalizations.of(context).all,
                                (v) => selectedPropertyType = v,
                              ),
                            ),
                            _buildChip(
                              AppLocalizations.of(
                                context,
                              ).property_type_townhouse,
                              isSelected:
                                  selectedPropertyType ==
                                  AppLocalizations.of(
                                    context,
                                  ).property_type_townhouse,
                              onTap: () => _onChipTap(
                                AppLocalizations.of(
                                  context,
                                ).property_type_townhouse,
                                selectedPropertyType,
                                AppLocalizations.of(context).all,
                                (v) => selectedPropertyType = v,
                              ),
                            ),
                            _buildChip(
                              AppLocalizations.of(context).property_type_land,
                              isSelected:
                                  selectedPropertyType ==
                                  AppLocalizations.of(
                                    context,
                                  ).property_type_land,
                              onTap: () => _onChipTap(
                                AppLocalizations.of(context).property_type_land,
                                selectedPropertyType,
                                AppLocalizations.of(context).all,
                                (v) => selectedPropertyType = v,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // ประเภทการประกาศ
                      _buildFilterSection(
                        title: AppLocalizations.of(context).listingTypeLabel,
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          runAlignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildChip(
                              AppLocalizations.of(context).all,
                              isSelected:
                                  selectedListingType ==
                                  AppLocalizations.of(context).all,
                              onTap: () => _onChipTap(
                                AppLocalizations.of(context).all,
                                selectedListingType,
                                AppLocalizations.of(context).all,
                                (v) => selectedListingType = v,
                              ),
                            ),
                            _buildChip(
                              AppLocalizations.of(context).listingSale,
                              isSelected:
                                  selectedListingType ==
                                  AppLocalizations.of(context).listingSale,
                              onTap: () => _onChipTap(
                                AppLocalizations.of(context).listingSale,
                                selectedListingType,
                                AppLocalizations.of(context).all,
                                (v) => selectedListingType = v,
                              ),
                            ),
                            _buildChip(
                              AppLocalizations.of(context).listingRent,
                              isSelected:
                                  selectedListingType ==
                                  AppLocalizations.of(context).listingRent,
                              onTap: () => _onChipTap(
                                AppLocalizations.of(context).listingRent,
                                selectedListingType,
                                AppLocalizations.of(context).all,
                                (v) => selectedListingType = v,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // สถานะการครอบครอง
                      _buildFilterSection(
                        title: AppLocalizations.of(
                          context,
                        ).occupancyStatusLabel,
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          runAlignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildChip(
                              AppLocalizations.of(context).all,
                              isSelected:
                                  selectedStatus ==
                                  AppLocalizations.of(context).all,
                              onTap: () => _onChipTap(
                                AppLocalizations.of(context).all,
                                selectedStatus,
                                AppLocalizations.of(context).all,
                                (v) => selectedStatus = v,
                              ),
                            ),
                            _buildChip(
                              AppLocalizations.of(
                                context,
                              ).occupancyStatusVacancy,
                              isSelected:
                                  selectedStatus ==
                                  AppLocalizations.of(
                                    context,
                                  ).occupancyStatusVacancy,
                              onTap: () => _onChipTap(
                                AppLocalizations.of(
                                  context,
                                ).occupancyStatusVacancy,
                                selectedStatus,
                                AppLocalizations.of(context).all,
                                (v) => selectedStatus = v,
                              ),
                            ),
                            _buildChip(
                              AppLocalizations.of(context).occupancyOccupied,
                              isSelected:
                                  selectedStatus ==
                                  AppLocalizations.of(
                                    context,
                                  ).occupancyOccupied,
                              onTap: () => _onChipTap(
                                AppLocalizations.of(context).occupancyOccupied,
                                selectedStatus,
                                AppLocalizations.of(context).all,
                                (v) => selectedStatus = v,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Dynamic Single-Select Specifications
                      ...?specifications?.singleSelect.map((spec) {
                        final key = spec.key;
                        return Column(
                          children: [
                            _buildFilterSection(
                              title: spec.label,
                              child: Wrap(
                                alignment: WrapAlignment.start,
                                runAlignment: WrapAlignment.center,
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildChip(
                                    AppLocalizations.of(context).all,
                                    isSelected:
                                        selectedSingleSelectSpecs[key] == null,
                                    onTap: () => _updateFilter(() {
                                      selectedSingleSelectSpecs.remove(key);
                                    }),
                                  ),
                                  ...spec.options.map((option) {
                                    return _buildChip(
                                      option,
                                      isSelected:
                                          selectedSingleSelectSpecs[key] ==
                                          option,
                                      onTap: () => _updateFilter(() {
                                        selectedSingleSelectSpecs[key] = option;
                                      }),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      }),
                      // สี
                      _buildFilterSection(
                        title: AppLocalizations.of(context).propertyColorLabel,
                        child: AppDropdown<String>(
                          items: [
                            AppLocalizations.of(context).all,
                            ...PropertyColor.values.map((e) => e.name),
                          ],
                          value: selectedColor,
                          hint: AppLocalizations.of(context).propertyColorHint,
                          onChanged: (v) {
                            if (v != null) {
                              _updateFilter(() {
                                selectedColor = v;
                              });
                            }
                          },
                          itemLabel: (v) => v,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // ช่วงราคา
                      Row(
                        children: [
                          Expanded(
                            child: _buildPriceInput(
                              label: AppLocalizations.of(context).minPrice,
                              controller: _minPriceController,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildPriceInput(
                              label: AppLocalizations.of(context).maxPrice,
                              controller: _maxPriceController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // ขนาดที่ดิน / ขนาดพื้นที่ใช้สอย
                      Row(
                        children: [
                          Expanded(
                            child: _buildSizeInput(
                              label: AppLocalizations.of(context).landSizeLabel,
                              controller: _landSizeController,
                              unit: AppLocalizations.of(context).sqWahUnit,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSizeInput(
                              label: AppLocalizations.of(
                                context,
                              ).usableAreaLabel,
                              controller: _usableAreaController,
                              unit: AppLocalizations.of(context).sqmUnit,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Dynamic Multi-Select Specifications
                      ...?specifications?.multiSelect.map((spec) {
                        final key = spec.key;
                        // Initialize the set if it doesn't exist
                        selectedMultiSelectSpecs.putIfAbsent(key, () => {});

                        return Column(
                          children: [
                            _buildFilterSection(
                              title: spec.label,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: spec.options.map((opt) {
                                  return _buildMultiSelectChip(
                                    opt,
                                    isSelected: selectedMultiSelectSpecs[key]!
                                        .contains(opt),
                                    onTap: () => _updateFilter(() {
                                      if (selectedMultiSelectSpecs[key]!
                                          .contains(opt)) {
                                        selectedMultiSelectSpecs[key]!.remove(
                                          opt,
                                        );
                                      } else {
                                        selectedMultiSelectSpecs[key]!.add(opt);
                                      }
                                    }),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      }),
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
                        text: AppLocalizations.of(context).clearFilters,
                        style: AppButtonStyle.outline,
                        onPressed: _clearFilters,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: AppButton(
                        text: 'แสดงผลลัพธ์ ($_matchingCount)',
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
      },
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
                AppLocalizations.of(context).currencyUnit,
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
      selectedApprovalStatus = AppLocalizations.of(context).all;
      selectedPropertyType = AppLocalizations.of(context).all;
      selectedListingType = AppLocalizations.of(context).all;
      selectedStatus = AppLocalizations.of(context).all;
      selectedColor = AppLocalizations.of(context).all;
      _minPriceController.clear();
      _maxPriceController.clear();
      selectedFloors = null;
      selectedBedrooms = null;
      selectedBathrooms = null;
      selectedParkingSpaces = null;
      _landSizeController.clear();
      _usableAreaController.clear();
      selectedSingleSelectSpecs.clear();
      selectedMultiSelectSpecs.clear();
    });
    _updateMatchingCount();
  }

  void _applyFilters() {
    final filter = PropertyFilter(
      approvalStatus: selectedApprovalStatus == AppLocalizations.of(context).all
          ? null
          : selectedApprovalStatus,
      propertyType: selectedPropertyType == AppLocalizations.of(context).all
          ? null
          : selectedPropertyType,
      listingType: selectedListingType == AppLocalizations.of(context).all
          ? null
          : selectedListingType,
      occupancyStatus: selectedStatus == AppLocalizations.of(context).all
          ? null
          : selectedStatus,
      color: selectedColor == AppLocalizations.of(context).all
          ? null
          : selectedColor,
      minPrice: double.tryParse(_minPriceController.text),
      maxPrice: double.tryParse(_maxPriceController.text),
      floors: selectedFloors,
      bedrooms: selectedBedrooms,
      bathrooms: selectedBathrooms,
      parkingSpaces: selectedParkingSpaces,
      landSize: double.tryParse(_landSizeController.text),
      usableArea: double.tryParse(_usableAreaController.text),
      singleSelectSpecs: selectedSingleSelectSpecs.map(
        (k, v) => MapEntry(k, v ?? ''),
      ),
      multiSelectSpecs: selectedMultiSelectSpecs,
    );
    Navigator.pop(context, filter);
  }
}
