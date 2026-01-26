import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/data/mock/mock_property_data.dart';
import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/features/home/pages/home_screen.dart';
import 'package:youragent/features/property/pages/all_properties_screen.dart';
import 'package:youragent/features/property/pages/fullscreen_map_screen.dart';
import 'package:youragent/widgets/backgrounds/blue_wave_background.dart';
import '../widgets/property_list_item.dart';
import '../widgets/property_map_view.dart';

class PropertyScreen extends StatefulWidget {
  const PropertyScreen({super.key});

  @override
  State<PropertyScreen> createState() => _PropertyScreenState();
}

class _PropertyScreenState extends State<PropertyScreen> {
  late ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();

  List<Property> _properties = [];
  List<Property> _filteredProperties = [];

  // Opacity for the app bar fade effect (0.0 = transparent, 1.0 = solid blue)
  double _appBarOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _loadProperties();
    _searchController.addListener(_onSearchChanged);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Calculate opacity based on scroll offset
    // Fade in completely after scrolling 100 pixels
    final double newOpacity = (_scrollController.offset / 100).clamp(0.0, 1.0);

    // Only update if there's a significant change to avoid excessive rebuilds
    if ((newOpacity - _appBarOpacity).abs() > 0.01) {
      setState(() {
        _appBarOpacity = newOpacity;
      });
    }
  }

  void _loadProperties() {
    setState(() {
      _properties = MockPropertyData.getAllProperties();
      _filteredProperties = _properties;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    setState(() {
      if (query.isEmpty) {
        _filteredProperties = _properties;
      } else {
        _filteredProperties = _properties.where((property) {
          final normalizedQuery = _normalizeText(query);
          return _normalizeText(property.title).contains(normalizedQuery) ||
              _normalizeText(property.location).contains(normalizedQuery) ||
              _normalizeText(property.code).contains(normalizedQuery);
        }).toList();
      }
    });
  }

  String _normalizeText(String text) {
    return text.toLowerCase().trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,

      body: Stack(
        children: [
          // Layer 1 (Bottom): Fixed BlueWaveBackground with inverse opacity
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: Opacity(
              opacity: 1.0 - _appBarOpacity, // Fade out as app bar fades in
              child: const BlueWaveBackground(),
            ),
          ),

          // Layer 2 (Top): Scrollable Content
          Positioned.fill(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Sticky App Bar with fade effect
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  expandedHeight: 0,
                  toolbarHeight:
                      0, // Set to 0 since we're using bottom property
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  flexibleSpace: Stack(
                    children: [
                      // Fading blue curtain
                      Positioned.fill(
                        child: Opacity(
                          opacity: _appBarOpacity,
                          child: const BlueWaveBackground(
                            firstColor: Color(0xFF1743C7),
                            secondColor: Color(0xFF1743C7),
                          ),
                        ),
                      ),
                    ],
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(
                      132,
                    ), // Height for header + search
                    child: Stack(
                      children: [
                        // Use the actual BlueWaveBackground widget with opacity
                        Positioned.fill(
                          child: Opacity(
                            opacity: _appBarOpacity,
                            child: const BlueWaveBackground(),
                          ),
                        ),
                        // Content on top
                        Column(
                          children: [
                            // Header above search
                            _buildHeader(),
                            const SizedBox(height: 8),
                            // Search bar below header
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: const HomeSearchBar(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Content: Map and Property List
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Map with negative offset to overlap the background
                      Transform.translate(
                        offset: const Offset(0, 0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: PropertyMapView(
                                properties: _filteredProperties,
                                onMaximizeTapped: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullscreenMapScreen(
                                        properties: _filteredProperties,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Property List
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        color: AppColors.white,
                        child: _buildPropertyList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Spacer(),
          Expanded(
            flex: 3,
            child: Text(
              'อสังหาริมทรัพย์',
              textAlign: TextAlign.center,
              style: GoogleFonts.anuphan(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () {
                  debugPrint('Add property tapped');
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: ShapeDecoration(
                    color: const Color(0x19F7FAFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Icon(Icons.add, size: 24, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyList() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ทรัพย์ของคุณ',
            style: GoogleFonts.anuphan(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'อสังหาริมทรัพย์ทุกประเภททั้งหมด ${_filteredProperties.length} รายการ',
                style: GoogleFonts.anuphan(
                  color: const Color(0xFF737373),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllPropertiesScreen(),
                    ),
                  );
                },
                child: Text(
                  'ดูทั้งหมด',
                  style: GoogleFonts.anuphan(
                    color: AppColors.gray400,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _filteredProperties.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'ไม่พบทรัพย์ที่ค้นหา',
                      style: GoogleFonts.anuphan(
                        color: AppColors.gray400,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredProperties.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final property = _filteredProperties[index];
                    return PropertyListItem(
                      property: property,
                      onTap: () {
                        debugPrint('Tapped on property: ${property.title}');
                      },
                      onEdit: () {
                        debugPrint('Edit property: ${property.title}');
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }
}
