import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/l10n/app_localizations.dart';

/// Filter bottom sheet for properties
class PropertyFilterBottomSheet extends StatefulWidget {
  const PropertyFilterBottomSheet({super.key});

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
  Set<String> selectedPropertyStyles = {};
  Set<String> selectedPropertyHighlights = {};
  Set<String> selectedCommonFacilities = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          selectedApprovalStatus = AppLocalizations.of(context).all;
          selectedPropertyType = AppLocalizations.of(context).all;
          selectedListingType = AppLocalizations.of(context).all;
        });
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
                  AppBadge(
                    label: AppLocalizations.of(context).searchFilterLabel,
                    color: BadgeColor.blue,
                  ),
                  const SizedBox(height: 16),
                  // สถานะการอนุมัติ
                  _buildFilterSection(
                    title: AppLocalizations.of(context).approvalStatusTitle,
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
                          onTap: () => setState(
                            () => selectedApprovalStatus = AppLocalizations.of(
                              context,
                            ).all,
                          ),
                        ),
                        _buildChip(
                          AppLocalizations.of(context).pendingAt,
                          isSelected:
                              selectedApprovalStatus ==
                              AppLocalizations.of(context).pendingAt,
                          onTap: () => setState(
                            () => selectedApprovalStatus = AppLocalizations.of(
                              context,
                            ).pendingAt,
                          ),
                        ),
                        _buildChip(
                          AppLocalizations.of(context).approvedAt,
                          isSelected:
                              selectedApprovalStatus ==
                              AppLocalizations.of(context).approvedAt,
                          onTap: () => setState(
                            () => selectedApprovalStatus = AppLocalizations.of(
                              context,
                            ).approvedAt,
                          ),
                        ),
                        _buildChip(
                          AppLocalizations.of(context).disapprovedAt,
                          isSelected:
                              selectedApprovalStatus ==
                              AppLocalizations.of(context).disapprovedAt,
                          onTap: () => setState(
                            () => selectedApprovalStatus = AppLocalizations.of(
                              context,
                            ).disapprovedAt,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ประเภททรัพย์
                  _buildFilterSection(
                    title: AppLocalizations.of(context).propertyTypeLabel,
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
                          onTap: () => setState(
                            () => selectedPropertyType = AppLocalizations.of(
                              context,
                            ).all,
                          ),
                        ),
                        _buildChip(
                          AppLocalizations.of(context).houseType,
                          isSelected:
                              selectedPropertyType ==
                              AppLocalizations.of(context).houseType,
                          onTap: () => setState(
                            () => selectedPropertyType = AppLocalizations.of(
                              context,
                            ).houseType,
                          ),
                        ),
                        _buildChip(
                          AppLocalizations.of(context).condoType,
                          isSelected:
                              selectedPropertyType ==
                              AppLocalizations.of(context).condoType,
                          onTap: () => setState(
                            () => selectedPropertyType = AppLocalizations.of(
                              context,
                            ).condoType,
                          ),
                        ),
                        _buildChip(
                          AppLocalizations.of(context).townhomeType,
                          isSelected:
                              selectedPropertyType ==
                              AppLocalizations.of(context).townhomeType,
                          onTap: () => setState(
                            () => selectedPropertyType = AppLocalizations.of(
                              context,
                            ).townhomeType,
                          ),
                        ),
                        _buildChip(
                          AppLocalizations.of(context).apartmentType,
                          isSelected:
                              selectedPropertyType ==
                              AppLocalizations.of(context).apartmentType,
                          onTap: () => setState(
                            () => selectedPropertyType = AppLocalizations.of(
                              context,
                            ).apartmentType,
                          ),
                        ),
                        _buildChip(
                          AppLocalizations.of(context).poolVillaType,
                          isSelected:
                              selectedPropertyType ==
                              AppLocalizations.of(context).poolVillaType,
                          onTap: () => setState(
                            () => selectedPropertyType = AppLocalizations.of(
                              context,
                            ).poolVillaType,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ประเภทประกาศ
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
                          onTap: () => setState(
                            () => selectedListingType = AppLocalizations.of(
                              context,
                            ).all,
                          ),
                        ),
                        _buildChip(
                          AppLocalizations.of(context).listingTypeValueSale,
                          isSelected:
                              selectedListingType ==
                              AppLocalizations.of(context).listingTypeValueSale,
                          onTap: () => setState(
                            () => selectedListingType = AppLocalizations.of(
                              context,
                            ).listingTypeValueSale,
                          ),
                        ),
                        _buildChip(
                          AppLocalizations.of(context).listingTypeValueRent,
                          isSelected:
                              selectedListingType ==
                              AppLocalizations.of(context).listingTypeValueRent,
                          onTap: () => setState(
                            () => selectedListingType = AppLocalizations.of(
                              context,
                            ).listingTypeValueRent,
                          ),
                        ),
                        _buildChip(
                          AppLocalizations.of(
                            context,
                          ).listingTypeValueSaleAndRent,
                          isSelected:
                              selectedListingType ==
                              AppLocalizations.of(
                                context,
                              ).listingTypeValueSaleAndRent,
                          onTap: () => setState(
                            () => selectedListingType = AppLocalizations.of(
                              context,
                            ).listingTypeValueSaleAndRent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // สถานะ
                  _buildFilterSection(
                    title: AppLocalizations.of(context).occupancyStatusLabel,
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      runAlignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChip(
                          AppLocalizations.of(context).statusValueAvailable,
                          isSelected:
                              selectedStatus ==
                              AppLocalizations.of(context).statusValueAvailable,
                          onTap: () => setState(
                            () => selectedStatus = AppLocalizations.of(
                              context,
                            ).statusValueAvailable,
                          ),
                        ),
                        _buildChip(
                          AppLocalizations.of(context).statusValueNotAvailable,
                          isSelected:
                              selectedStatus ==
                              AppLocalizations.of(
                                context,
                              ).statusValueNotAvailable,
                          onTap: () => setState(
                            () => selectedStatus = AppLocalizations.of(
                              context,
                            ).statusValueNotAvailable,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // สีทรัพย์
                  _buildFilterSection(
                    title: AppLocalizations.of(context).propertyColor,
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      runAlignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChip(
                          AppLocalizations.of(context).colorWhite,
                          isSelected:
                              selectedColor ==
                              AppLocalizations.of(context).colorWhite,
                          onTap: () => setState(
                            () => selectedColor = AppLocalizations.of(
                              context,
                            ).colorWhite,
                          ),
                        ),
                        _buildChip(
                          AppLocalizations.of(context).colorGrey,
                          isSelected:
                              selectedColor ==
                              AppLocalizations.of(context).colorGrey,
                          onTap: () => setState(
                            () => selectedColor = AppLocalizations.of(
                              context,
                            ).colorGrey,
                          ),
                        ),
                        _buildChip(
                          AppLocalizations.of(context).colorBlack,
                          isSelected:
                              selectedColor ==
                              AppLocalizations.of(context).colorBlack,
                          onTap: () => setState(
                            () => selectedColor = AppLocalizations.of(
                              context,
                            ).colorBlack,
                          ),
                        ),
                        _buildChip(
                          AppLocalizations.of(context).colorCream,
                          isSelected:
                              selectedColor ==
                              AppLocalizations.of(context).colorCream,
                          onTap: () => setState(
                            () => selectedColor = AppLocalizations.of(
                              context,
                            ).colorCream,
                          ),
                        ),
                        _buildChip(
                          AppLocalizations.of(context).colorBrown,
                          isSelected:
                              selectedColor ==
                              AppLocalizations.of(context).colorBrown,
                          onTap: () => setState(
                            () => selectedColor = AppLocalizations.of(
                              context,
                            ).colorBrown,
                          ),
                        ),
                        _buildChip(
                          AppLocalizations.of(context).color_blue,
                          isSelected:
                              selectedColor ==
                              AppLocalizations.of(context).color_blue,
                          onTap: () => setState(
                            () => selectedColor = AppLocalizations.of(
                              context,
                            ).color_blue,
                          ),
                        ),
                        _buildChip(
                          AppLocalizations.of(context).colorCyan,
                          isSelected:
                              selectedColor ==
                              AppLocalizations.of(context).colorCyan,
                          onTap: () => setState(
                            () => selectedColor = AppLocalizations.of(
                              context,
                            ).colorCyan,
                          ),
                        ),
                        _buildChip(
                          AppLocalizations.of(context).colorPink,
                          isSelected:
                              selectedColor ==
                              AppLocalizations.of(context).colorPink,
                          onTap: () => setState(
                            () => selectedColor = AppLocalizations.of(
                              context,
                            ).colorPink,
                          ),
                        ),
                        _buildChip(
                          AppLocalizations.of(context).colorGreen,
                          isSelected:
                              selectedColor ==
                              AppLocalizations.of(context).colorGreen,
                          onTap: () => setState(
                            () => selectedColor = AppLocalizations.of(
                              context,
                            ).colorGreen,
                          ),
                        ),
                        _buildChip(
                          AppLocalizations.of(context).colorYellow,
                          isSelected:
                              selectedColor ==
                              AppLocalizations.of(context).colorYellow,
                          onTap: () => setState(
                            () => selectedColor = AppLocalizations.of(
                              context,
                            ).colorYellow,
                          ),
                        ),
                        _buildChip(
                          AppLocalizations.of(context).colorRed,
                          isSelected:
                              selectedColor ==
                              AppLocalizations.of(context).colorRed,
                          onTap: () => setState(
                            () => selectedColor = AppLocalizations.of(
                              context,
                            ).colorRed,
                          ),
                        ),
                        _buildChip(
                          AppLocalizations.of(context).colorOrange,
                          isSelected:
                              selectedColor ==
                              AppLocalizations.of(context).colorOrange,
                          onTap: () => setState(
                            () => selectedColor = AppLocalizations.of(
                              context,
                            ).colorOrange,
                          ),
                        ),
                        _buildChip(
                          AppLocalizations.of(context).colorPurple,
                          isSelected:
                              selectedColor ==
                              AppLocalizations.of(context).colorPurple,
                          onTap: () => setState(
                            () => selectedColor = AppLocalizations.of(
                              context,
                            ).colorPurple,
                          ),
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
                          label: AppLocalizations.of(context).startingPrice,
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
                  const SizedBox(height: 24),

                  // จำนวนชั้น
                  _buildFilterSection(
                    title: AppLocalizations.of(context).totalFloorsLabel,
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
                    title: AppLocalizations.of(context).bedroomsLabel,
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
                    title: AppLocalizations.of(context).bathroomsLabel,
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
                    title: AppLocalizations.of(context).parkingLabel,
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
                          label: AppLocalizations.of(context).landSizeLabel,
                          controller: _landSizeController,
                          unit: AppLocalizations.of(context).sqWahUnit,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSizeInput(
                          label: AppLocalizations.of(context).usableAreaSize,
                          controller: _usableAreaController,
                          unit: AppLocalizations.of(context).sqmUnit,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // สไตล์ทรัพย์
                  _buildFilterSection(
                    title: AppLocalizations.of(context).propertyStyleLabel,
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      runAlignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildMultiSelectChip(
                          AppLocalizations.of(context).luxury,
                          isSelected: selectedPropertyStyles.contains(
                            AppLocalizations.of(context).luxury,
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyStyles.contains(
                                AppLocalizations.of(context).luxury,
                              )) {
                                selectedPropertyStyles.remove(
                                  AppLocalizations.of(context).luxury,
                                );
                              } else {
                                selectedPropertyStyles.add(
                                  AppLocalizations.of(context).luxury,
                                );
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          AppLocalizations.of(context).classicStyle,
                          isSelected: selectedPropertyStyles.contains(
                            AppLocalizations.of(context).classicStyle,
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyStyles.contains(
                                AppLocalizations.of(context).classicStyle,
                              )) {
                                selectedPropertyStyles.remove(
                                  AppLocalizations.of(context).classicStyle,
                                );
                              } else {
                                selectedPropertyStyles.add(
                                  AppLocalizations.of(context).classicStyle,
                                );
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          AppLocalizations.of(context).modern,
                          isSelected: selectedPropertyStyles.contains(
                            AppLocalizations.of(context).modern,
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyStyles.contains(
                                AppLocalizations.of(context).modern,
                              )) {
                                selectedPropertyStyles.remove(
                                  AppLocalizations.of(context).modern,
                                );
                              } else {
                                selectedPropertyStyles.add(
                                  AppLocalizations.of(context).modern,
                                );
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          AppLocalizations.of(context).natural,
                          isSelected: selectedPropertyStyles.contains(
                            AppLocalizations.of(context).natural,
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyStyles.contains(
                                AppLocalizations.of(context).natural,
                              )) {
                                selectedPropertyStyles.remove(
                                  AppLocalizations.of(context).natural,
                                );
                              } else {
                                selectedPropertyStyles.add(
                                  AppLocalizations.of(context).natural,
                                );
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          AppLocalizations.of(context).loft,
                          isSelected: selectedPropertyStyles.contains(
                            AppLocalizations.of(context).loft,
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyStyles.contains(
                                AppLocalizations.of(context).loft,
                              )) {
                                selectedPropertyStyles.remove(
                                  AppLocalizations.of(context).loft,
                                );
                              } else {
                                selectedPropertyStyles.add(
                                  AppLocalizations.of(context).loft,
                                );
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          AppLocalizations.of(context).minimal,
                          isSelected: selectedPropertyStyles.contains(
                            AppLocalizations.of(context).minimal,
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyStyles.contains(
                                AppLocalizations.of(context).minimal,
                              )) {
                                selectedPropertyStyles.remove(
                                  AppLocalizations.of(context).minimal,
                                );
                              } else {
                                selectedPropertyStyles.add(
                                  AppLocalizations.of(context).minimal,
                                );
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          AppLocalizations.of(context).vintage,
                          isSelected: selectedPropertyStyles.contains(
                            AppLocalizations.of(context).vintage,
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyStyles.contains(
                                AppLocalizations.of(context).vintage,
                              )) {
                                selectedPropertyStyles.remove(
                                  AppLocalizations.of(context).vintage,
                                );
                              } else {
                                selectedPropertyStyles.add(
                                  AppLocalizations.of(context).vintage,
                                );
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          AppLocalizations.of(context).contemporary,
                          isSelected: selectedPropertyStyles.contains(
                            AppLocalizations.of(context).contemporary,
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyStyles.contains(
                                AppLocalizations.of(context).contemporary,
                              )) {
                                selectedPropertyStyles.remove(
                                  AppLocalizations.of(context).contemporary,
                                );
                              } else {
                                selectedPropertyStyles.add(
                                  AppLocalizations.of(context).contemporary,
                                );
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          AppLocalizations.of(context).colonialStyle,
                          isSelected: selectedPropertyStyles.contains(
                            AppLocalizations.of(context).colonialStyle,
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyStyles.contains(
                                AppLocalizations.of(context).colonialStyle,
                              )) {
                                selectedPropertyStyles.remove(
                                  AppLocalizations.of(context).colonialStyle,
                                );
                              } else {
                                selectedPropertyStyles.add(
                                  AppLocalizations.of(context).colonialStyle,
                                );
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          AppLocalizations.of(context).thaiContemporary,
                          isSelected: selectedPropertyStyles.contains(
                            AppLocalizations.of(context).thaiContemporary,
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyStyles.contains(
                                AppLocalizations.of(context).thaiContemporary,
                              )) {
                                selectedPropertyStyles.remove(
                                  AppLocalizations.of(context).thaiContemporary,
                                );
                              } else {
                                selectedPropertyStyles.add(
                                  AppLocalizations.of(context).thaiContemporary,
                                );
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          AppLocalizations.of(context).nordicStyle,
                          isSelected: selectedPropertyStyles.contains(
                            AppLocalizations.of(context).nordicStyle,
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyStyles.contains(
                                AppLocalizations.of(context).nordicStyle,
                              )) {
                                selectedPropertyStyles.remove(
                                  AppLocalizations.of(context).nordicStyle,
                                );
                              } else {
                                selectedPropertyStyles.add(
                                  AppLocalizations.of(context).nordicStyle,
                                );
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
                    title: AppLocalizations.of(context).propertyHighlightsLabel,
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
                          AppLocalizations.of(context).nearExpressway,
                          isSelected: selectedPropertyHighlights.contains(
                            AppLocalizations.of(context).nearExpressway,
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyHighlights.contains(
                                AppLocalizations.of(context).nearExpressway,
                              )) {
                                selectedPropertyHighlights.remove(
                                  AppLocalizations.of(context).nearExpressway,
                                );
                              } else {
                                selectedPropertyHighlights.add(
                                  AppLocalizations.of(context).nearExpressway,
                                );
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          AppLocalizations.of(context).nearStation,
                          isSelected: selectedPropertyHighlights.contains(
                            AppLocalizations.of(context).nearStation,
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyHighlights.contains(
                                AppLocalizations.of(context).nearStation,
                              )) {
                                selectedPropertyHighlights.remove(
                                  AppLocalizations.of(context).nearStation,
                                );
                              } else {
                                selectedPropertyHighlights.add(
                                  AppLocalizations.of(context).nearStation,
                                );
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          AppLocalizations.of(context).nearHospital,
                          isSelected: selectedPropertyHighlights.contains(
                            AppLocalizations.of(context).nearHospital,
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyHighlights.contains(
                                AppLocalizations.of(context).nearHospital,
                              )) {
                                selectedPropertyHighlights.remove(
                                  AppLocalizations.of(context).nearHospital,
                                );
                              } else {
                                selectedPropertyHighlights.add(
                                  AppLocalizations.of(context).nearHospital,
                                );
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          AppLocalizations.of(context).newProject,
                          isSelected: selectedPropertyHighlights.contains(
                            AppLocalizations.of(context).newProject,
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedPropertyHighlights.contains(
                                AppLocalizations.of(context).newProject,
                              )) {
                                selectedPropertyHighlights.remove(
                                  AppLocalizations.of(context).newProject,
                                );
                              } else {
                                selectedPropertyHighlights.add(
                                  AppLocalizations.of(context).newProject,
                                );
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
                    title: AppLocalizations.of(context).commonFacilities,
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      runAlignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildMultiSelectChip(
                          AppLocalizations.of(context).fitness,
                          isSelected: selectedCommonFacilities.contains(
                            AppLocalizations.of(context).fitness,
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedCommonFacilities.contains(
                                AppLocalizations.of(context).fitness,
                              )) {
                                selectedCommonFacilities.remove(
                                  AppLocalizations.of(context).fitness,
                                );
                              } else {
                                selectedCommonFacilities.add(
                                  AppLocalizations.of(context).fitness,
                                );
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          AppLocalizations.of(context).swimmingPool,
                          isSelected: selectedCommonFacilities.contains(
                            AppLocalizations.of(context).swimmingPool,
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedCommonFacilities.contains(
                                AppLocalizations.of(context).swimmingPool,
                              )) {
                                selectedCommonFacilities.remove(
                                  AppLocalizations.of(context).swimmingPool,
                                );
                              } else {
                                selectedCommonFacilities.add(
                                  AppLocalizations.of(context).swimmingPool,
                                );
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          AppLocalizations.of(context).garden,
                          isSelected: selectedCommonFacilities.contains(
                            AppLocalizations.of(context).garden,
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedCommonFacilities.contains(
                                AppLocalizations.of(context).garden,
                              )) {
                                selectedCommonFacilities.remove(
                                  AppLocalizations.of(context).garden,
                                );
                              } else {
                                selectedCommonFacilities.add(
                                  AppLocalizations.of(context).garden,
                                );
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
                          AppLocalizations.of(context).playground,
                          isSelected: selectedCommonFacilities.contains(
                            AppLocalizations.of(context).playground,
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedCommonFacilities.contains(
                                AppLocalizations.of(context).playground,
                              )) {
                                selectedCommonFacilities.remove(
                                  AppLocalizations.of(context).playground,
                                );
                              } else {
                                selectedCommonFacilities.add(
                                  AppLocalizations.of(context).playground,
                                );
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          AppLocalizations.of(context).sportsField,
                          isSelected: selectedCommonFacilities.contains(
                            AppLocalizations.of(context).sportsField,
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedCommonFacilities.contains(
                                AppLocalizations.of(context).sportsField,
                              )) {
                                selectedCommonFacilities.remove(
                                  AppLocalizations.of(context).sportsField,
                                );
                              } else {
                                selectedCommonFacilities.add(
                                  AppLocalizations.of(context).sportsField,
                                );
                              }
                            });
                          },
                        ),
                        _buildMultiSelectChip(
                          AppLocalizations.of(context).securityGuardLabel,
                          isSelected: selectedCommonFacilities.contains(
                            AppLocalizations.of(context).securityGuardLabel,
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedCommonFacilities.contains(
                                AppLocalizations.of(context).securityGuardLabel,
                              )) {
                                selectedCommonFacilities.remove(
                                  AppLocalizations.of(
                                    context,
                                  ).securityGuardLabel,
                                );
                              } else {
                                selectedCommonFacilities.add(
                                  AppLocalizations.of(
                                    context,
                                  ).securityGuardLabel,
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
                    text: AppLocalizations.of(context).clearFiltersButton,
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
