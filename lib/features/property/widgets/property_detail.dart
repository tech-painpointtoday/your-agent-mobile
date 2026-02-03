import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/property.dart';
import 'package:intl/intl.dart';
import 'package:youragent/features/property/pages/expandable_description.dart';
import 'package:youragent/features/property/pages/fullscreen_map_screen.dart';
import 'package:youragent/utils/app_utils.dart';
import '../widgets/property_image_carousel.dart';
import '../widgets/property_detail_section.dart';
import '../widgets/property_status_badge.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/features/property/bloc/property_metadata/property_metadata_bloc.dart';
import 'package:youragent/features/property/bloc/property_metadata/property_metadata_event.dart';
import 'package:youragent/features/property/bloc/property_metadata/property_metadata_state.dart';
import 'package:youragent/widgets/map/map_view.dart';

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
  late final Property property;
  late final List<String>? imageUrls;
  late final List<XFile>? imageFiles;

  @override
  void initState() {
    super.initState();
    property = widget.property;
    imageUrls = property.imageUrls;
    imageFiles = property.imageFiles;

    // Ensure metadata is loaded/loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PropertyMetadataBloc>().add(const LoadPropertyMetadata());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      child: Stack(
        children: [
          // Background Image Layer
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

          // Content Layer (Spacer + Card + Rest)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Spacer to push content down to the overlap point
              const SizedBox(height: contentStartTop),

              // 2. Property Header Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: AppColors.baseLightGrey,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (property.id != null)
                        Text(
                          'รหัส: ${AppUtils.generatePropertyCode(propertyId: property.id!, createdAt: property.createdAt)}',
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
                          color: const Color(0xFF181D27),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      if (property.address != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          property.address!,
                          style: GoogleFonts.anuphan(
                            color: const Color(0xFF181D27),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),
                      PropertyStatusBadge(status: property.approvalStatus),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 3. Location Section (Integrated PropertyMapView)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'สถานที่',
                      style: GoogleFonts.anuphan(
                        color: AppColors.baseDarkGrey,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (property.address != null &&
                        property.address!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        property.address!,
                        style: GoogleFonts.anuphan(
                          color: AppColors.baseBlack,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    MapView(
                      properties: [property],
                      height: 160,
                      initialLocation: LatLng(
                        property.latitude,
                        property.longitude,
                      ),
                      onMaximizeTapped: () {
                        // Open fullscreen map with current property
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
                ),
              ),

              const SizedBox(height: 32),

              // 4. Property Detail Section (Updated Icon & Logic)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: PropertyDetailSection(
                  title: 'รายละเอียดทรัพย์',
                  svgIcon: 'assets/icons/menu.svg', // Updated Icon
                  rows: [
                    if (property.propertyType != null)
                      PropertyDetailRow(
                        label: 'ประเภททรัพย์',
                        value: property.propertyType!.label,
                      ),
                    if (property.listingType?.isNotEmpty == true)
                      PropertyDetailRow(
                        label: 'ประเภทประกาศ',
                        value: property.listingType!,
                      ),
                    if (property.status?.isNotEmpty == true)
                      PropertyDetailRow(
                        label: 'สถานะ',
                        value: property.status!,
                      ),
                    if (property.totalFloors != null &&
                        property.totalFloors! > 0)
                      PropertyDetailRow(
                        label: 'จำนวนชั้น',
                        value: '${property.totalFloors} ชั้น',
                      ),
                    if (property.bedrooms > 0)
                      PropertyDetailRow(
                        label: 'จำนวนห้องนอน',
                        value: '${property.bedrooms} ห้อง',
                      ),
                    if (property.bathrooms > 0)
                      PropertyDetailRow(
                        label: 'จำนวนห้องน้ำ',
                        value: '${property.bathrooms} ห้อง',
                      ),
                    if (property.garage != null && property.garage! > 0)
                      PropertyDetailRow(
                        label: 'จำนวนที่จอดรถ',
                        value: '${property.garage} ที่',
                      ),
                    PropertyDetailRow(
                      label: 'วันที่สร้าง',
                      value: DateFormat(
                        'dd ม.ค. yyyy',
                        'th',
                      ).format(property.createdAt),
                    ),
                    if (property.houseColor != null)
                      PropertyDetailRow(
                        label: 'สีทรัพย์',
                        value: property.houseColor!.label,
                      ),
                    if (property.price > 0)
                      PropertyDetailRow(
                        label: 'ราคา',
                        value:
                            '${NumberFormat("#,##0", "en_US").format(property.price)} บาท',
                      ),
                    if (property.landSize != null && property.landSize! > 0)
                      PropertyDetailRow(
                        label: 'ขนาดที่ดิน',
                        value: '${property.landSize} ตร.ว.',
                      ),
                    if (property.area > 0)
                      PropertyDetailRow(
                        label: 'ขนาดพื้นที่ใช้สอย',
                        value: '${property.area} ตร.ม.',
                      ),
                    if (property.direction != null)
                      PropertyDetailRow(
                        label: 'ทิศบ้าน',
                        value: property.direction!.label,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 5. Additional Details Section (Updated Icon & Expandable Text)
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
                            'รายละเอียดเพิ่มเติม',
                            style: GoogleFonts.anuphan(
                              color: const Color(0xFF181D27),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Property Style
                    if (property.propertyStyle != null) ...[
                      const SizedBox(height: 24),
                      Text(
                        'สไตล์ทรัพย์',
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
                        children: [_buildTag(property.propertyStyle!.label)],
                      ),
                    ],

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

                    const SizedBox(height: 16),

                    Text(
                      'รายละเอียด',
                      style: GoogleFonts.anuphan(
                        color: AppColors.baseDarkGrey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Expandable Description
                    ExpandableDescription(text: property.description),
                  ],
                ),
              ),

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
      if (rawValue is List) {
        displayValues.addAll(rawValue.map((v) => v.toString()));
      } else {
        displayValues.add(rawValue.toString());
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
