import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/features/property/pages/property_detail_screen.dart';
import 'package:youragent/features/property/widgets/property_list_item.dart';
import 'package:youragent/features/property/widgets/property_filter_bottom_sheet.dart';
import 'package:youragent/widgets/app_search_bar.dart';
import 'package:youragent/widgets/badges/app_badge.dart';

/// Screen showing all properties in a list
class AllPropertiesScreen extends StatefulWidget {
  const AllPropertiesScreen({super.key});

  @override
  State<AllPropertiesScreen> createState() => _AllPropertiesScreenState();
}

class _AllPropertiesScreenState extends State<AllPropertiesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _propertyApiService = DependencyInjection.propertyApiService;

  List<Property> _allProperties = [];
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
      if (!mounted) return;

      setState(() {
        _allProperties = properties;
        _filteredProperties = properties;
        _isLoading = false;
      });
      _onSearchChanged(); // Re-apply filter if any
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredProperties = _allProperties;
      } else {
        _filteredProperties = _allProperties.where((property) {
          return property.title.toLowerCase().contains(query) ||
              property.code!.toLowerCase().contains(query) ||
              property.address!.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => const PropertyFilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom > 0
        ? MediaQuery.of(context).padding.bottom
        : 16;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Back Button
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: SvgPicture.asset(
                        'assets/icons/chevron-left.svg',
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                        width: 18,
                        height: 18,
                      ),
                    ),
                  ),
                  // Title
                  const Text(
                    'ทรัพย์ของคุณ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  // Add Button
                  InkWell(
                    onTap: () {
                      context
                          .push('/property/create')
                          .then((_) => _loadProperties());
                    },
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      width: 36,
                      height: 36,
                      padding: EdgeInsets.all(8),
                      decoration: ShapeDecoration(
                        color: const Color(0x19F7FAFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/plus.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Property Count or Empty State Title
                    if (_allProperties.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: AppBadges.plain(
                          label: '${_allProperties.length} รายการ',
                          color: BadgeColor.blue,
                        ),
                      )
                    else if (!_isLoading && _error == null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: AppBadges.plain(
                          label: 'ไม่พบรายการทรัพย์',
                          color: BadgeColor.default_,
                        ),
                      ),

                    // Property List or Empty State
                    Expanded(child: _buildContent()),

                    // Search Bar at Bottom
                    Container(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppSearchBar(
                              controller: _searchController,
                              hintText: 'ค้นหา...',
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Filter Button
                          InkWell(
                            onTap: _showFilterBottomSheet,
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x14000000),
                                    blurRadius: 12,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: SvgPicture.asset(
                                'assets/icons/filter.svg',
                                width: 16,
                                height: 16,
                                fit: BoxFit.scaleDown,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.baseDarkGrey,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            TextButton(onPressed: _loadProperties, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_filteredProperties.isEmpty) {
      return _buildEmptyState();
    }

    return _buildPropertyList();
  }

  Widget _buildPropertyList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredProperties.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
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
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty State Illustration (placeholder)
          Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140, maxHeight: 140),
              child: Image.asset(
                'assets/images/property/empty_state.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_not_supported,
                    size: 60,
                    color: AppColors.baseGrey,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'ขณะนี้ยังไม่มีข้อมูลทรัพย์ในระบบ',
            style: TextStyle(
              color: AppColors.baseDarkGrey,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
