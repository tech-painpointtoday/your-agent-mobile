import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/features/home/pages/home_screen.dart';
import 'package:youragent/features/property/pages/all_properties_screen.dart';
import 'package:youragent/features/property/pages/create/create_property_screen.dart';
import 'package:youragent/features/property/pages/fullscreen_map_screen.dart';
import 'package:youragent/features/property/pages/property_detail_screen.dart';
import 'package:youragent/features/property/widgets/property_list_item.dart';
import 'package:youragent/features/property/widgets/property_map_view.dart';
import 'package:youragent/widgets/app_bars/silver_app_bar.dart';

/// Main Property screen used in navigation tabs
class PropertyScreen extends StatefulWidget {
  const PropertyScreen({super.key});

  @override
  State<PropertyScreen> createState() => _PropertyScreenState();
}

class _PropertyScreenState extends State<PropertyScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _propertyApiService = DependencyInjection.propertyApiService;

  List<Property> _properties = [];
  List<Property> _filteredProperties = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProperties();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProperties() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final properties = await _propertyApiService.getProperties();

      setState(() {
        _properties = properties;
        _filteredProperties = properties;
        _isLoading = false;
      });
      // Trigger search filter in case there was text
      _onSearchChanged();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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
              _normalizeText(property.address!).contains(normalizedQuery) ||
              _normalizeText(property.code!).contains(normalizedQuery);
        }).toList();
      }
    });
  }

  String _normalizeText(String text) {
    return text.toLowerCase().trim();
  }

  @override
  Widget build(BuildContext context) {
    return SilverAppBarScreen(
      title: 'อสังหาริมทรัพย์',
      actionWidget: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreatePropertyScreen(),
            ),
          );
          if (result == true) {
            _loadProperties();
          }
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
      searchBar: HomeSearchBar(controller: _searchController),
      preferredHeight: 132.0,
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
    );
  }

  Widget _buildPropertyList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          children: [
            Text('Error: $_error'),
            TextButton(onPressed: _loadProperties, child: const Text('Retry')),
          ],
        ),
      );
    }

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
                    color: AppColors.baseGrey,
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
                        color: AppColors.baseGrey,
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PropertyDetailScreen(
                              propertyId: property.id,
                              property: property,
                            ),
                          ),
                        ).then((_) => _loadProperties());
                      },
                      onEdit: () {
                        // Navigate to edit screen and reload on return
                        // Navigator.push(...).then((_) => _loadProperties());
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }
}
