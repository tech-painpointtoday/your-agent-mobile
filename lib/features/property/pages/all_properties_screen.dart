import 'package:flutter/material.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/data/mock/mock_property_data.dart';
import 'package:youragent/domain/entities/property.dart';
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
  List<Property> _allProperties = [];
  List<Property> _filteredProperties = [];

  @override
  void initState() {
    super.initState();
    _allProperties = MockPropertyData.mockProperties;
    _filteredProperties = MockPropertyData.mockProperties;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredProperties = _allProperties;
      } else {
        _filteredProperties = _allProperties.where((property) {
          return property.title.toLowerCase().contains(query) ||
              property.code.toLowerCase().contains(query) ||
              property.location.toLowerCase().contains(query);
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
                children: [
                  // Back Button
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                      // TODO: Navigate to add property screen
                    },
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: ShapeDecoration(
                        color: const Color(0x19F7FAFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 24,
                        color: Colors.white,
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
                    else
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: AppBadges.plain(
                          label: 'ไม่พบรายการทรัพย์',
                          color: BadgeColor.default_,
                        ),
                      ),

                    // Property List or Empty State
                    Expanded(
                      child: _filteredProperties.isEmpty
                          ? _buildEmptyState()
                          : _buildPropertyList(),
                    ),

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
                              child: const Icon(
                                Icons.tune,
                                color: AppColors.gray500,
                                size: 20,
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

  Widget _buildPropertyList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredProperties.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return PropertyListItem(property: _filteredProperties[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty State Illustration (placeholder)
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'ขณะนี้ยังไม่มีข้อมูลทรัพย์ในระบบ',
            style: TextStyle(
              color: AppColors.gray500,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
