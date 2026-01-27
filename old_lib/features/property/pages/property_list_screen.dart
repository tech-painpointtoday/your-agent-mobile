import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/data/models/property_model.dart';
import 'package:youragent/services/role_service.dart';
import 'package:youragent/widgets/custom_header.dart';
import 'package:youragent/widgets/app_sidebar.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import 'package:youragent/features/auth/bloc/auth_bloc.dart';
import 'package:youragent/features/auth/bloc/auth_state.dart';
import 'package:youragent/features/property/bloc/properties_bloc.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:youragent/widgets/buttons/action_icon_button.dart';
import 'package:youragent/widgets/tables/app_generic_table.dart';
import 'package:youragent/widgets/inputs/app_dropdown.dart';
import 'package:youragent/widgets/tables/app_pagination.dart';

/// Property List Screen - shows all properties in a table format with filters
class PropertyListScreen extends StatefulWidget {
  final Function(Locale)? changeLocale;
  final UserRole? role;

  const PropertyListScreen({super.key, this.changeLocale, this.role});

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  bool _isMapView = false;
  final ScrollController _scrollController = ScrollController();
  bool _hasInitialized = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh properties when screen comes back into view (after initial load)
    // This handles the case when returning from create/edit screens
    if (_hasInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final bloc = context.read<PropertiesBloc>();
          final currentState = bloc.state;
          // Only refresh if we have loaded data and not already loading
          if (currentState is PropertiesLoaded && mounted) {
            // Refresh to get latest data
            bloc.add(const PropertiesLoadRequested());
          }
        }
      });
    } else {
      _hasInitialized = true;
    }
  }

  void _toggleMapView() {
    setState(() {
      _isMapView = !_isMapView;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.path;
    final authState = context.watch<AuthBloc>().state;
    final roleService = RoleService();
    final userRole =
        widget.role ??
        (authState is Authenticated ? authState.user.role : null) ??
        roleService.currentRole ??
        UserRole.agent;

    return BlocListener<PropertiesBloc, PropertiesState>(
      listener: (context, state) async {
        if (state is PropertiesDeleteSuccess && mounted) {
          final l10n = AppLocalizations.of(context)!;
          await StatusDialog.showSuccess(
            context: context,
            title: l10n.success,
            message: state.message,
          );
          if (context.mounted) {
            context.read<PropertiesBloc>().add(const PropertiesLoadRequested());
          }
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;
          final scaffoldKey = GlobalKey<ScaffoldState>();

          return Scaffold(
            key: scaffoldKey,
            backgroundColor: AppColors.basePaleGrey,
            drawer: isMobile
                ? Drawer(
                    child: AppSidebar(
                      role: userRole,
                      currentRoute: currentRoute,
                    ),
                  )
                : null,
            body: SafeArea(
              child: Column(
                children: [
                  CustomHeader(
                    changeLocale: widget.changeLocale,
                    onMenuTap: isMobile
                        ? () => scaffoldKey.currentState?.openDrawer()
                        : null,
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sidebar (hidden on mobile, shown as drawer)
                        if (!isMobile)
                          AppSidebar(
                            role: userRole,
                            currentRoute: currentRoute,
                          ),
                        // Main Content
                        Expanded(
                          child: BlocBuilder<PropertiesBloc, PropertiesState>(
                            builder: (context, state) {
                              return SingleChildScrollView(
                                controller: _scrollController,
                                key: const PageStorageKey(
                                  'property_list_scroll',
                                ),
                                padding: EdgeInsets.all(isMobile ? 16 : 24),
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'อสังหาริมทรัพย์',
                                        style: GoogleFonts.anuphan(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.baseDarkGrey,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    // Main Card - Contains Filter, Table/Map, and Pagination
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFE9EAEB),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          // Filter Section
                                          _FilterSection(),
                                          const SizedBox(height: 24),
                                          Divider(
                                            color: AppColors.baseLightGrey,
                                            height: 1,
                                          ),
                                          const SizedBox(height: 24),
                                          // Summary Row with Buttons
                                          _buildSummaryRow(context, state),
                                          const SizedBox(height: 16),
                                          // Table or Map based on view mode
                                          _isMapView
                                              ? _buildMapContent(context, state)
                                              : _buildTableContent(
                                                  context,
                                                  state,
                                                ),
                                          const SizedBox(height: 24),
                                          // Pagination (only show in table view)
                                          if (!_isMapView)
                                            _buildPagination(context, state),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, PropertiesState state) {
    final filteredCount = state is PropertiesLoaded
        ? state.filteredProperties.length
        : 0;
    final userRole =
        widget.role ??
        UserRole
            .agent; // Fallback to agent if null, but should be handled by logic above

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'รายการทั้งหมด $filteredCount รายการ',
          style: GoogleFonts.anuphan(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.baseDarkGrey,
          ),
        ),
        Row(
          children: [
            // Map/Table View Toggle Button
            AppButtons.outlined(
              label: _isMapView ? 'มุมมองตาราง' : 'มุมมองแผนที่',
              icon: _isMapView
                  ? const Icon(
                      Icons.table_chart_outlined,
                      size: 20,
                      color: Color(0xFF717680),
                    )
                  : SvgPicture.asset(
                      'assets/icons/map.svg',
                      width: 20,
                      height: 20,
                    ),
              iconPosition: IconPosition.start,
              color: ButtonColor.gray,
              onPressed: _toggleMapView,
            ),
            const SizedBox(width: 12),
            // Create Property Button
            AppButtons.primary(
              label: 'สร้างอสังหาริมทรัพย์',
              icon: const Icon(Icons.add, size: 20),
              iconPosition: IconPosition.start,
              onPressed: () async {
                final result = await context.push(
                  '/${userRole.name}/properties/create',
                );
                // If create was successful, refresh the property list
                if (result == true && mounted) {
                  context.read<PropertiesBloc>().add(
                    const PropertiesLoadRequested(),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTableContent(BuildContext context, PropertiesState state) {
    if (state is PropertiesLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (state is PropertiesError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            children: [
              Text(
                state.message,
                style: GoogleFonts.anuphan(color: AppColors.ruby500),
              ),
              const SizedBox(height: 16),
              AppButtons.primary(
                label: 'Retry',
                onPressed: () {
                  context.read<PropertiesBloc>().add(
                    const PropertiesLoadRequested(),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }
    if (state is PropertiesLoaded) {
      final userRole = widget.role ?? UserRole.agent;
      return _TableContent(
        properties: state.paginatedProperties,
        role: userRole,
      );
    }
    return const SizedBox.shrink();
  }

  /// Build map content showing all filtered properties on Google Maps
  Widget _buildMapContent(BuildContext context, PropertiesState state) {
    if (state is PropertiesLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (state is PropertiesError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            children: [
              Text(
                state.message,
                style: GoogleFonts.anuphan(color: AppColors.ruby500),
              ),
              const SizedBox(height: 16),
              AppButtons.primary(
                label: 'Retry',
                onPressed: () {
                  context.read<PropertiesBloc>().add(
                    const PropertiesLoadRequested(),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }
    if (state is PropertiesLoaded) {
      // Get all filtered properties (not just paginated for map view)
      final properties = state.filteredProperties;

      // Create markers for properties with valid coordinates
      final Set<Marker> markers = {};
      LatLng? centerPosition;

      for (final property in properties) {
        final lat = property.propertyLocation?.latitude;
        final lng = property.propertyLocation?.longitude;

        if (lat != null && lng != null) {
          // Set center to first valid property location
          centerPosition ??= LatLng(lat, lng);

          markers.add(
            Marker(
              markerId: MarkerId('property_${property.id}'),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(
                title: property.name,
                snippet: '฿${_formatPrice(property.price)}',
                onTap: () {
                  final userRole = widget.role ?? UserRole.agent;
                  context.push('/${userRole.name}/properties/${property.id}');
                },
              ),
            ),
          );
        }
      }

      // Default to Bangkok if no properties have coordinates
      final initialPosition = centerPosition ?? const LatLng(13.7563, 100.5018);
      final initialZoom = centerPosition != null ? 12.0 : 6.0;

      return Container(
        height: 500,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE9EAEB)),
        ),
        clipBehavior: Clip.antiAlias,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Listener(
            onPointerSignal: (PointerSignalEvent event) {
              // Capture scroll events to prevent page scrolling when zooming map
              if (event is PointerScrollEvent) {
                GestureBinding.instance.pointerSignalResolver.register(
                  event,
                  (PointerSignalEvent e) {},
                );
              }
            },
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: initialPosition,
                zoom: initialZoom,
              ),
              markers: markers,
              mapType: MapType.normal,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              mapToolbarEnabled: true,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  /// Format price for display
  String _formatPrice(int price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K';
    }
    return price.toString();
  }

  Widget _buildPagination(BuildContext context, PropertiesState state) {
    if (state is! PropertiesLoaded) {
      return const AppPaginationPlaceholder();
    }

    return AppPagination(
      currentPage: state.currentPage,
      totalPages: state.totalPages,
      itemsPerPage: state.itemsPerPage,
      onPageChanged: (page) {
        context.read<PropertiesBloc>().add(PropertiesPageChanged(page));
      },
      onItemsPerPageChanged: (limit) {
        context.read<PropertiesBloc>().add(
          PropertiesItemsPerPageChanged(limit),
        );
      },
    );
  }
}

// Filter Section Widget
class _FilterSection extends StatefulWidget {
  @override
  State<_FilterSection> createState() => _FilterSectionState();
}

class _FilterSectionState extends State<_FilterSection> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertiesBloc, PropertiesState>(
      builder: (context, state) {
        final loadedState = state is PropertiesLoaded ? state : null;
        final selectedStatus = loadedState?.selectedStatus;
        final selectedPropertyType = loadedState?.selectedPropertyType;
        final selectedOwnership = loadedState?.selectedOwnership;
        final selectedProvince = loadedState?.selectedProvince;
        final allProperties = loadedState?.allProperties ?? [];

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 1200;
            final isMedium = constraints.maxWidth > 800;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isWide)
                  // Wide layout: All in one row
                  Row(
                    children: [
                      // Search field
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'ค้นหาชื่ออสังหาฯ',
                            hintStyle: GoogleFonts.anuphan(
                              color: AppColors.baseDarkGrey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFE9EAEB),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFE9EAEB),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Status dropdown
                      Expanded(
                        child: _buildDropdown(
                          value: selectedStatus,
                          hint: 'เลือกสถานะ',
                          items: ['Available', 'Pending', 'Sold'],
                          onChanged: (value) {
                            context.read<PropertiesBloc>().add(
                              PropertiesFilterChanged(selectedStatus: value),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Property type dropdown
                      Expanded(
                        child: _buildDropdown(
                          value: selectedPropertyType,
                          hint: 'เลือกประเภทอสังหาฯ',
                          items: ['บ้าน', 'คอนโด', 'ทาวน์เฮาส์', 'อื่นๆ'],
                          onChanged: (value) {
                            context.read<PropertiesBloc>().add(
                              PropertiesFilterChanged(
                                selectedPropertyType: value,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Ownership dropdown
                      Expanded(
                        child: _buildDropdown(
                          value: selectedOwnership,
                          hint: 'เลือกความเป็นเจ้าของ',
                          items: ['Freehold', 'Leasehold'],
                          onChanged: (value) {
                            context.read<PropertiesBloc>().add(
                              PropertiesFilterChanged(selectedOwnership: value),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Province dropdown
                      Expanded(
                        child: _buildDropdown(
                          value: selectedProvince,
                          hint: 'เลือกจังหวัด',
                          items: _getUniqueProvinces(allProperties),
                          onChanged: (value) {
                            context.read<PropertiesBloc>().add(
                              PropertiesFilterChanged(selectedProvince: value),
                            );
                          },
                        ),
                      ),
                    ],
                  )
                else if (isMedium)
                  // Medium layout: Two rows
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'ค้นหาชื่ออสังหาฯ',
                                hintStyle: GoogleFonts.anuphan(
                                  color: AppColors.baseDarkGrey,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE9EAEB),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE9EAEB),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDropdown(
                              value: selectedStatus,
                              hint: 'เลือกสถานะ',
                              items: ['Available', 'Pending', 'Sold'],
                              onChanged: (value) {
                                context.read<PropertiesBloc>().add(
                                  PropertiesFilterChanged(
                                    selectedStatus: value,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDropdown(
                              value: selectedPropertyType,
                              hint: 'เลือกประเภทอสังหาฯ',
                              items: ['บ้าน', 'คอนโด', 'ทาวน์เฮาส์', 'อื่นๆ'],
                              onChanged: (value) {
                                context.read<PropertiesBloc>().add(
                                  PropertiesFilterChanged(
                                    selectedPropertyType: value,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              value: selectedOwnership,
                              hint: 'เลือกความเป็นเจ้าของ',
                              items: ['Freehold', 'Leasehold'],
                              onChanged: (value) {
                                context.read<PropertiesBloc>().add(
                                  PropertiesFilterChanged(
                                    selectedOwnership: value,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDropdown(
                              value: selectedProvince,
                              hint: 'เลือกจังหวัด',
                              items: _getUniqueProvinces(allProperties),
                              onChanged: (value) {
                                context.read<PropertiesBloc>().add(
                                  PropertiesFilterChanged(
                                    selectedProvince: value,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  // Narrow layout: Stacked vertically
                  Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'ค้นหาชื่ออสังหาฯ',
                          hintStyle: GoogleFonts.anuphan(
                            color: AppColors.baseDarkGrey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFE9EAEB),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFE9EAEB),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDropdown(
                        value: selectedStatus,
                        hint: 'เลือกสถานะ',
                        items: ['Available', 'Pending', 'Sold'],
                        onChanged: (value) {
                          context.read<PropertiesBloc>().add(
                            PropertiesFilterChanged(selectedStatus: value),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildDropdown(
                        value: selectedPropertyType,
                        hint: 'เลือกประเภทอสังหาฯ',
                        items: ['บ้าน', 'คอนโด', 'ทาวน์เฮาส์', 'อื่นๆ'],
                        onChanged: (value) {
                          context.read<PropertiesBloc>().add(
                            PropertiesFilterChanged(
                              selectedPropertyType: value,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildDropdown(
                        value: selectedOwnership,
                        hint: 'เลือกความเป็นเจ้าของ',
                        items: ['Freehold', 'Leasehold'],
                        onChanged: (value) {
                          context.read<PropertiesBloc>().add(
                            PropertiesFilterChanged(selectedOwnership: value),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildDropdown(
                        value: selectedProvince,
                        hint: 'เลือกจังหวัด',
                        items: _getUniqueProvinces(allProperties),
                        onChanged: (value) {
                          context.read<PropertiesBloc>().add(
                            PropertiesFilterChanged(selectedProvince: value),
                          );
                        },
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                // Buttons row - responsive
                isMedium || isWide
                    ? Row(
                        children: [
                          // Search button
                          AppButtons.secondary(
                            label: 'ค้นหา',
                            icon: const Icon(
                              Icons.search,
                              size: 20,
                              color: AppColors.white,
                            ),
                            iconPosition: IconPosition.start,
                            onPressed: () {
                              context.read<PropertiesBloc>().add(
                                PropertiesFilterChanged(
                                  searchQuery: _searchController.text,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          // Clear button
                          AppButtons.outlined(
                            label: 'ล้างข้อมูล',
                            icon: const Icon(
                              Icons.clear,
                              size: 20,
                              color: AppColors.baseDarkGrey,
                            ),
                            iconPosition: IconPosition.start,
                            color: ButtonColor.gray,
                            onPressed: () {
                              _searchController.clear();
                              context.read<PropertiesBloc>().add(
                                const PropertiesFilterChanged(
                                  searchQuery: '',
                                  selectedStatus: null,
                                  selectedPropertyType: null,
                                  selectedOwnership: null,
                                  selectedProvince: null,
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppButtons.secondary(
                            label: 'ค้นหา',
                            icon: const Icon(
                              Icons.search,
                              size: 20,
                              color: AppColors.white,
                            ),
                            iconPosition: IconPosition.start,
                            onPressed: () {
                              context.read<PropertiesBloc>().add(
                                PropertiesFilterChanged(
                                  searchQuery: _searchController.text,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: AppButtons.outlined(
                                  label: 'ล้างข้อมูล',
                                  icon: const Icon(
                                    Icons.clear,
                                    size: 20,
                                    color: AppColors.baseDarkGrey,
                                  ),
                                  iconPosition: IconPosition.start,
                                  color: ButtonColor.gray,
                                  onPressed: () {
                                    _searchController.clear();
                                    context.read<PropertiesBloc>().add(
                                      const PropertiesFilterChanged(
                                        searchQuery: '',
                                        selectedStatus: null,
                                        selectedPropertyType: null,
                                        selectedOwnership: null,
                                        selectedProvince: null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return AppDropdown<String>(
      value: value,
      hint: hint,
      items: items,
      onChanged: onChanged,
    );
  }

  List<String> _getUniqueProvinces(List<PropertyModel> allProperties) {
    final provinces = allProperties
        .map((p) => p.propertyLocation?.state)
        .whereType<String>()
        .toSet()
        .toList();
    provinces.sort();
    return provinces;
  }
}

// Separate widget for property actions to avoid closure issues
class _PropertyActionsRow extends StatelessWidget {
  final int? propertyId;
  final UserRole role;

  const _PropertyActionsRow({
    super.key,
    required this.propertyId,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    // Use final fields directly in closures - accessing widget.propertyId and widget.role
    // ensures each widget instance captures its own values correctly
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ActionIconButton(
          svgAsset: 'assets/icons/form/eye.svg',
          onPressed: propertyId != null
              ? () {
                  debugPrint(
                    'PropertyActionsRow: Navigating to property detail with ID: $propertyId',
                  );
                  context.push('/${role.name}/properties/$propertyId');
                }
              : null,
        ),
        const SizedBox(width: 2),
        ActionIconButton(
          svgAsset: 'assets/icons/form/edit-2.svg',
          onPressed: propertyId != null
              ? () async {
                  debugPrint(
                    'PropertyActionsRow: Navigating to property edit with ID: $propertyId',
                  );
                  final result = await context.push(
                    '/${role.name}/properties/$propertyId/edit',
                  );
                  // If edit was successful, refresh the property list
                  if (result == true && context.mounted) {
                    context.read<PropertiesBloc>().add(
                      const PropertiesLoadRequested(),
                    );
                  }
                }
              : null,
        ),
        const SizedBox(width: 2),
        ActionIconButton(
          svgAsset: 'assets/icons/form/file-plus.svg',
          onPressed: propertyId != null
              ? () {
                  debugPrint(
                    'PropertyActionsRow: Navigating to contract create with propertyId: $propertyId',
                  );
                  context.go(
                    '/${role.name}/contracts/create?propertyId=$propertyId',
                  );
                }
              : null,
        ),
      ],
    );
  }
}

// Table Content Widget
class _TableContent extends StatelessWidget {
  final List<PropertyModel> properties;
  final UserRole role;

  const _TableContent({required this.properties, required this.role});

  String _formatThaiDate(DateTime? date) {
    if (date == null) return '-';
    final thaiMonths = [
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.',
    ];
    final thaiYear = date.year + 543;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${thaiMonths[date.month - 1]} $thaiYear, $hour:$minute';
  }

  /// Generate property code in format: YH + 2-digit year + 6-digit property ID
  /// Example: YH26000001 (YH + 26 (year 2026) + 000001 (property ID))
  String _generatePropertyCodeForProperty(PropertyModel property) {
    if (property.id == null) return 'N/A';
    // Get year from createdAt or use current year
    final year = property.createdAt?.year ?? DateTime.now().year;
    // Get last 2 digits of year
    final yearSuffix = (year % 100).toString().padLeft(2, '0');
    // Format property ID to 6 digits with leading zeros
    final propertyIdFormatted = property.id!.toString().padLeft(6, '0');
    return 'YH$yearSuffix$propertyIdFormatted';
  }

  @override
  Widget build(BuildContext context) {
    return AppGenericTable<PropertyModel>(
      items: properties,
      columns: [
        DataColumn(label: _buildHeader('รหัส')),
        DataColumn(label: _buildHeader('ชื่ออสังหาฯ')),
        DataColumn(label: _buildHeader('สถานะการอนุมัติ')),
        DataColumn(label: _buildHeader('สถานะ')),
        DataColumn(label: _buildHeader('ประเภทอสังหาฯ')),
        DataColumn(label: _buildHeader('ความเป็นเจ้าของ')),
        DataColumn(label: _buildHeader('เขต/อำเภอ')),
        DataColumn(label: _buildHeader('จังหวัด')),
        DataColumn(label: _buildHeaderWithSort('สร้างเมื่อ')),
      ],
      rowBuilder: (property, index) {
        final ownershipText = property.hasAgent ? 'เป็นตัวแทน' : 'เป็นเจ้าของ';
        final ownershipBadge = AppBadge(
          label: ownershipText,
          style: BadgeStyle.plain,
          color: property.hasAgent ? BadgeColor.blue : BadgeColor.green,
        );

        final district = property.propertyLocation?.city ?? '-';
        final province = property.propertyLocation?.state ?? '-';

        // Get approval status badge
        final approvalStatusBadge = _buildApprovalStatusBadge(
          property.approvalStatus,
        );

        // Get availability status badge (ว่าง/Available)
        final availabilityStatus = property.status ?? 'available';
        final availabilityStatusBadge = AppBadges.status(
          label: availabilityStatus == 'available'
              ? 'ว่าง'
              : availabilityStatus,
        );

        // Get property type in Thai
        final propertyTypeThai = _getPropertyTypeThai(property.propertyType);

        // Use createdAt for the created date column
        final createdDate = property.createdAt ?? DateTime.now();

        return [
          DataCell(
            Text(
              property.id != null
                  ? _generatePropertyCodeForProperty(property)
                  : 'N/A',
              style: GoogleFonts.anuphan(
                fontSize: 14,
                color: AppColors.baseDarkGrey,
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 200,
              child: Text(
                property.name,
                style: GoogleFonts.anuphan(
                  fontSize: 14,
                  color: AppColors.baseDarkGrey,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
          DataCell(approvalStatusBadge),
          DataCell(availabilityStatusBadge),
          DataCell(
            Text(
              propertyTypeThai,
              style: GoogleFonts.anuphan(
                fontSize: 14,
                color: AppColors.baseDarkGrey,
              ),
            ),
          ),
          DataCell(ownershipBadge),
          DataCell(
            Text(
              district,
              style: GoogleFonts.anuphan(
                fontSize: 14,
                color: AppColors.baseDarkGrey,
              ),
            ),
          ),
          DataCell(
            Text(
              province,
              style: GoogleFonts.anuphan(
                fontSize: 14,
                color: AppColors.baseDarkGrey,
              ),
            ),
          ),
          DataCell(
            Text(
              _formatThaiDate(createdDate),
              style: GoogleFonts.anuphan(
                fontSize: 14,
                color: AppColors.baseDarkGrey,
              ),
            ),
          ),
        ];
      },
      actionsBuilder: (property, index) {
        // Capture property ID immediately in the builder to avoid closure issues
        final capturedPropertyId = property.id;

        // Create a separate widget instance for each row to avoid closure issues
        // Use a key based on property ID to ensure each row gets its own widget instance
        // Pass propertyId directly instead of the whole property object
        return _PropertyActionsRow(
          key: ValueKey('property_actions_${capturedPropertyId}_$index'),
          propertyId: capturedPropertyId,
          role: role,
        );
      },
    );
  }

  Widget _buildHeader(String label) {
    return Text(
      label,
      style: GoogleFonts.anuphan(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.baseDarkGrey,
      ),
    );
  }

  Widget _buildHeaderWithSort(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(label),
        const SizedBox(width: 4),
        Icon(Icons.swap_vert, size: 16, color: AppColors.baseDarkGrey),
      ],
    );
  }

  /// Build approval status badge with consistent styling
  Widget _buildApprovalStatusBadge(String? approvalStatus) {
    final status = (approvalStatus ?? 'pending').toLowerCase();

    if (status == 'approved' || status == 'อนุมัติแล้ว') {
      return AppBadge(
        label: 'อนุมัติแล้ว',
        style: BadgeStyle.dot,
        customBackgroundColor: AppColors.statusConfirmedBg,
        customTextColor: AppColors.statusConfirmedText,
        customDotColor: AppColors.statusConfirmedText,
      );
    } else if (status == 'rejected' || status == 'ไม่ผ่าน') {
      return AppBadge(
        label: 'ไม่ผ่าน',
        style: BadgeStyle.dismissibleLeading,
        customBackgroundColor: AppColors.statusCancelledBg,
        customTextColor: AppColors.statusCancelledText,
        customDotColor: AppColors.statusCancelledText,
      );
    } else {
      // pending or default
      return AppBadge(
        label: 'รอการอนุมัติ',
        style: BadgeStyle.dot,
        customBackgroundColor: AppColors.statusPendingBg,
        customTextColor: AppColors.statusPendingText,
        customDotColor: AppColors.statusPendingText,
      );
    }
  }

  /// Convert property type to Thai
  String _getPropertyTypeThai(String? propertyType) {
    if (propertyType == null || propertyType.isEmpty) return '-';

    final type = propertyType.toLowerCase();
    switch (type) {
      case 'house':
      case 'บ้าน':
        return 'บ้าน';
      case 'condo':
      case 'condominium':
      case 'คอนโด':
        return 'คอนโด';
      case 'apartment':
      case 'อพาร์ตเมนต์':
        return 'อพาร์ตเมนต์';
      case 'townhouse':
      case 'ทาวน์เฮาส์':
        return 'ทาวน์เฮาส์';
      case 'villa':
      case 'วิลล่า':
        return 'วิลล่า';
      default:
        return propertyType;
    }
  }
}
