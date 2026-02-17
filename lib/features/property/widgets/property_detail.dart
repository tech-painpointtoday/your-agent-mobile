import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/property.dart';
import 'package:intl/intl.dart';
import 'package:youragent/features/property/pages/expandable_description.dart';
import 'package:youragent/widgets/map/fullscreen_map_screen.dart';
import 'package:youragent/utils/app_utils.dart';
import '../widgets/property_image_carousel.dart';
import '../widgets/property_detail_section.dart';
import '../widgets/property_status_badge.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/features/property/bloc/property_metadata/property_metadata_bloc.dart';
import 'package:youragent/features/property/bloc/property_metadata/property_metadata_event.dart';
import 'package:youragent/features/property/bloc/property_metadata/property_metadata_state.dart';
import 'package:youragent/widgets/map/map_view.dart';
import 'package:youragent/l10n/app_localizations.dart';

import 'package:go_router/go_router.dart';
import 'package:youragent/widgets/painters/dashed_border_painter.dart';

const double carouselHeight = 280;
const double overlap = 40;
const double contentStartTop = carouselHeight - overlap;

class PropertyDetail extends StatefulWidget {
  final bool isFullScreen;
  final Property property;

  const PropertyDetail({
    super.key,
    required this.property,
    this.isFullScreen = false,
  });

  @override
  State<PropertyDetail> createState() => _PropertyDetailState();
}

class _PropertyDetailState extends State<PropertyDetail> {
  Property get property => widget.property;
  List<String>? get imageUrls => property.imageUrls;
  List<XFile>? get imageFiles => property.imageFiles;

  @override
  void initState() {
    super.initState();
    // Ensure metadata is loaded/loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PropertyMetadataBloc>().add(const LoadPropertyMetadata());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTh = Localizations.localeOf(context).languageCode == 'th';
    final devName = isTh ? property.developerNameTh : property.developerNameEn;
    // Header logic: Condo info or Village Name
    String? headerDisplayInfo;
    String? displayProjectName;

    if (property.propertyType == PropertyType.condo) {
      displayProjectName = isTh
          ? property.condoProjectNameTh
          : property.condoProjectNameEn;
    } else {
      displayProjectName = property.villageName;
    }

    if (devName != null && displayProjectName != null) {
      headerDisplayInfo = '$devName • $displayProjectName';
    } else if (displayProjectName != null) {
      headerDisplayInfo = displayProjectName;
    } else if (devName != null) {
      headerDisplayInfo = devName;
    }

    // Complete Address Logic
    String completeAddress = property.address ?? '';
    if (property.propertyType == PropertyType.condo) {
      final room = property.unitNo;
      final floor = property.floor;
      final building = property.tower;
      String prefix = '';
      if (room != null && room.isNotEmpty) {
        prefix += '${AppLocalizations.of(context).roomNoLabel} $room ';
      }
      if (floor != null && floor.isNotEmpty) {
        prefix += '${AppLocalizations.of(context).floorLabel} $floor ';
      }
      if (building != null && building.isNotEmpty) {
        prefix += '${AppLocalizations.of(context).buildingLabel} $building ';
      }
      completeAddress = prefix.isNotEmpty
          ? '$prefix$completeAddress'
          : completeAddress;
    } else if (property.propertyType == PropertyType.house) {
      final houseNo = property.number;
      final village = property.villageName;
      String prefix = '';
      if (houseNo != null && houseNo.isNotEmpty) {
        prefix += '${AppLocalizations.of(context).houseNoLabel} $houseNo ';
      }
      if (village != null && village.isNotEmpty) prefix += '$village ';
      completeAddress = prefix.isNotEmpty
          ? '$prefix$completeAddress'
          : completeAddress;
    }

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      child: Stack(
        children: [
          // 1. Background Image Layer
          SizedBox(
            height: carouselHeight,
            width: double.infinity,
            child: PropertyImageCarousel(
              isFullScreen: widget.isFullScreen,
              imageUrls: imageUrls,
              imageFiles: imageFiles,
              height: carouselHeight,
            ),
          ),

          // 2. Content Layer
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: contentStartTop),

              // Property Information Card (Header Section)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                  border: Border.all(width: 1, color: AppColors.baseLightGrey),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (property.id != null)
                      Text(
                        '${AppLocalizations.of(context).labelCode}: ${AppUtils.generatePropertyCode(property)}',
                        style: GoogleFonts.anuphan(
                          color: AppColors.baseGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Text(
                      property.title,
                      style: GoogleFonts.anuphan(
                        color: AppColors.baseBlack,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (headerDisplayInfo != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        headerDisplayInfo,
                        style: GoogleFonts.anuphan(
                          color: AppColors.baseBlack,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    PropertyStatusBadge(
                      status: property.approvalStatus,
                      isDraft: property.isDraft,
                    ),
                  ],
                ),
              ),

              if (property.approvalStatus ==
                  PropertyApprovalStatus.approved) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: InkWell(
                    onTap: () {
                      context.push('/contract/create', extra: property);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: CustomPaint(
                      painter: const DashedBorderPainter(
                        color: AppColors.baseLightGrey,
                        strokeWidth: 1,
                        dashWidth: 6,
                        dashSpace: 4,
                        radius: 12,
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '+',
                              style: TextStyle(
                                color: AppColors.baseDarkGrey,
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context).createContractButton,
                              style: GoogleFonts.anuphan(
                                color: AppColors.baseDarkGrey,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // 3. Location Section (Integrated PropertyMapView)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).locationLabel,
                      style: GoogleFonts.anuphan(
                        color: AppColors.baseDarkGrey,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (completeAddress.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        completeAddress,
                        style: GoogleFonts.anuphan(
                          color: AppColors.baseBlack,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                    if (property.latitude != null &&
                        property.longitude != null) ...[
                      const SizedBox(height: 16),
                      MapView(
                        properties: [property],
                        height: 160,
                        initialLocation: LatLng(
                          property.latitude!,
                          property.longitude!,
                        ),
                        onMaximizeTapped: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullscreenMapScreen(
                                showSearch: false,
                                properties: [property],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 4. Property Detail Section (Updated Icon & Logic)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: PropertyDetailSection(
                  title: AppLocalizations.of(context).property_details_section,
                  svgIcon: 'assets/icons/menu.svg', // Updated Icon
                  rows: [
                    if (property.propertyType != null)
                      PropertyDetailRow(
                        label: AppLocalizations.of(context).propertyTypeLabel,
                        value: isTh
                            ? property.propertyType!.labelTh
                            : property.propertyType!.labelEn,
                      ),
                    if (property.listingType != null)
                      PropertyDetailRow(
                        label: AppLocalizations.of(context).listingTypeLabel,
                        value: switch (property.listingType!) {
                          PropertyListingType.sale => AppLocalizations.of(
                            context,
                          ).listingTypeValueSale,
                          PropertyListingType.rent => AppLocalizations.of(
                            context,
                          ).listingTypeValueRent,
                          PropertyListingType.saleOrRent => AppLocalizations.of(
                            context,
                          ).listingTypeValueSaleAndRent,
                        },
                      ),
                    if (property.status != null)
                      PropertyDetailRow(
                        label: AppLocalizations.of(
                          context,
                        ).occupancyStatusLabel,
                        value: switch (property.status!) {
                          PropertyAvailabilityStatus.available =>
                            AppLocalizations.of(context).statusValueAvailable,
                          PropertyAvailabilityStatus.unavailable =>
                            AppLocalizations.of(
                              context,
                            ).statusValueNotAvailable,
                        },
                      ),
                    if (property.totalFloors != null &&
                        property.totalFloors! > 0)
                      PropertyDetailRow(
                        label: AppLocalizations.of(context).totalFloorsLabel,
                        value:
                            '${property.totalFloors} ${AppLocalizations.of(context).floorUnit}',
                      ),
                    if (property.bedrooms > 0)
                      PropertyDetailRow(
                        label: AppLocalizations.of(context).bedroomsLabel,
                        value:
                            '${property.bedrooms} ${AppLocalizations.of(context).roomUnit}',
                      ),
                    if (property.bathrooms > 0)
                      PropertyDetailRow(
                        label: AppLocalizations.of(context).bathroomsLabel,
                        value:
                            '${property.bathrooms} ${AppLocalizations.of(context).roomUnit}',
                      ),
                    if (property.garage != null && property.garage! > 0)
                      PropertyDetailRow(
                        label: AppLocalizations.of(context).parkingLabel,
                        value: '${property.garage} ที่',
                      ),
                    if (property.built != null)
                      PropertyDetailRow(
                        label: AppLocalizations.of(context).builtLabel,
                        value: AppLocalizations.of(
                          context,
                        ).dateFormat(property.built!),
                      ),
                    if (property.houseColor != null)
                      PropertyDetailRow(
                        label: AppLocalizations.of(context).propertyColor,
                        value: isTh
                            ? property.houseColor!.labelTh
                            : property.houseColor!.labelEn,
                      ),
                    if (property.price > 0)
                      PropertyDetailRow(
                        label: AppLocalizations.of(context).priceLabel,
                        value:
                            '${NumberFormat("#,##0", "en_US").format(property.price)} บาท',
                      ),
                    if (property.landSize != null && property.landSize! > 0)
                      PropertyDetailRow(
                        label: AppLocalizations.of(context).landSizeLabel,
                        value:
                            '${property.landSize} ${AppLocalizations.of(context).sq_wa}',
                      ),
                    if (property.buildingSize != null &&
                        property.buildingSize! > 0)
                      PropertyDetailRow(
                        label: AppLocalizations.of(context).usableAreaSize,
                        value:
                            '${property.buildingSize} ${AppLocalizations.of(context).sq_m}',
                      ),
                    if (property.direction != null)
                      PropertyDetailRow(
                        label: AppLocalizations.of(context).direction_label,
                        value: isTh
                            ? property.direction!.labelTh
                            : property.direction!.labelEn,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 5. Additional Details Section (Updated Icon & Expandable Text)
              if (property.specificationValues.isNotEmpty ||
                  property.description.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(bottom: 8),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 1,
                              color: AppColors.baseLightGrey,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/star-moving.svg',
                              width: 18,
                              height: 18,
                              colorFilter: const ColorFilter.mode(
                                Color(0xFF181D27),
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(
                                context,
                              ).additional_details_section,
                              style: GoogleFonts.anuphan(
                                color: const Color(0xFF181D27),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // // Property Style
                      // if (property.propertyStyle != null) ...[
                      //   const SizedBox(height: 24),
                      //   Text(
                      //     AppLocalizations.of(context)!.propertyStyleLabel,
                      //     style: GoogleFonts.anuphan(
                      //       color: AppColors.baseDarkGrey,
                      //       fontSize: 16,
                      //       fontWeight: FontWeight.w400,
                      //     ),
                      //   ),
                      //   const SizedBox(height: 12),
                      //   Wrap(
                      //     spacing: 8,
                      //     runSpacing: 8,
                      //     children: [_buildTag(property.propertyStyle!.label)],
                      //   ),
                      // ],

                      // Dynamic Specification Values (Highlights, Facilities, Furniture, AirCon, etc.)
                      BlocBuilder<PropertyMetadataBloc, PropertyMetadataState>(
                        builder: (context, state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildDynamicSpecs(
                              property,
                              context,
                              state,
                            ),
                          );
                        },
                      ),

                      if (property.description.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context).descriptionLabel,
                          style: GoogleFonts.anuphan(
                            color: AppColors.baseDarkGrey,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Expandable Description
                        ExpandableDescription(text: property.description),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDynamicSpecs(
    Property property,
    BuildContext context,
    PropertyMetadataState metadataState,
  ) {
    if (metadataState.status == PropertyMetadataStatus.loading ||
        metadataState.specificationFilters == null) {
      return [
        const Padding(
          padding: EdgeInsets.only(top: 24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    final filters = metadataState.specificationFilters!;

    // Locale detection (Thai default)
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    final widgets = <Widget>[];

    // Combine all filters into one list for lookup
    final allFilters = [...filters.singleSelect, ...filters.multiSelect];

    // Current property specs and spec values
    final specValues = property.specificationValues;
    final specs = property.specifications;

    // Keys that are already shown in the main Detail Section or handled separately
    const excludedKeys = {
      'bedrooms',
      'num_bedrooms',
      'bathrooms',
      'num_bathrooms',
      'parking_spaces',
      'garage',
      'floors',
      'total_floors',
      'land_size',
      'building_size',
      'price',
      'type',
      'property_type',
      'listing_type',
      'property_style', // Handled separately in UI
    };

    for (var filter in allFilters) {
      final key = filter.key;
      if (excludedKeys.contains(key)) continue;

      // Localized Label
      final label = isEn ? filter.labelEn : filter.labelTh;
      final displayLabel = label.isNotEmpty ? label : filter.label;

      // Flexible Value Lookup
      // Values can be in specificationValues (usually lists) or specifications (scalars)
      dynamic rawValue = specValues[key] ?? specs[key];

      if (rawValue == null ||
          (rawValue is String && rawValue.isEmpty) ||
          (rawValue is List && rawValue.isEmpty)) {
        continue;
      }

      final List<String> displayValues = [];

      String getLocalizedValue(String val) {
        if (filter.optionsWithImages.isNotEmpty) {
          final opt = filter.optionsWithImages
              .where((o) => o.value == val)
              .firstOrNull;
          if (opt != null) {
            return isEn ? opt.label : opt.labelTh;
          }
        }
        return val;
      }

      if (rawValue is List) {
        displayValues.addAll(
          rawValue.map((v) => getLocalizedValue(v.toString())),
        );
      } else {
        displayValues.add(getLocalizedValue(rawValue.toString()));
      }

      if (displayValues.isNotEmpty) {
        widgets.addAll([
          const SizedBox(height: 24),
          Text(
            displayLabel,
            style: GoogleFonts.anuphan(
              color: AppColors.baseDarkGrey,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: displayValues.map((v) => _buildTag(v)).toList(),
          ),
        ]);
      }
    }

    return widgets;
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.anuphan(
          color: const Color(0xFF0056D2),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
