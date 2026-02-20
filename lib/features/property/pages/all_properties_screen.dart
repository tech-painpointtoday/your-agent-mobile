import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/features/property/widgets/property_list_item.dart';
import 'package:youragent/features/property/widgets/property_filter_bottom_sheet.dart';
import 'package:youragent/widgets/app_search_bar.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import 'package:youragent/core/extensions/l10n_extensions.dart';
import 'package:youragent/domain/entities/property_filter.dart';
import 'package:youragent/features/property/bloc/property_list/property_list_bloc.dart';
import 'package:youragent/features/property/bloc/property_list/property_list_event.dart';
import 'package:youragent/features/property/bloc/property_list/property_list_state.dart';

/// Screen showing all properties in a list with infinite scroll
class AllPropertiesScreen extends StatefulWidget {
  const AllPropertiesScreen({super.key});

  @override
  State<AllPropertiesScreen> createState() => _AllPropertiesScreenState();
}

class _AllPropertiesScreenState extends State<AllPropertiesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _propertyApiService = DependencyInjection.propertyApiService;

  PropertyFilter _currentFilter = const PropertyFilter();

  late final PropertyListBloc _propertyListBloc;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _propertyListBloc = PropertyListBloc(
      propertyApiService: _propertyApiService,
    )..add(const PropertyListFetched());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _propertyListBloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      _propertyListBloc.add(const PropertyListFetched());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> _onRefresh() async {
    _propertyListBloc.add(PropertyListRefresh());
  }

  void _onSearchChanged() {
    setState(() {}); // Trigger local filtering rebuild
  }

  List<Property> _applyLocalFilters(List<Property> properties) {
    var filtered = properties;

    // Apply Search Query
    final query = _searchController.text.toLowerCase().trim();
    if (query.isNotEmpty) {
      filtered = filtered.where((property) {
        return property.title.toLowerCase().contains(query) ||
            (property.address?.toLowerCase().contains(query) ?? false) ||
            (property.code?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply Filter Bottom Sheet
    if (!_currentFilter.isEmpty) {
      filtered = filtered.where((p) => _currentFilter.matches(p)).toList();
    }

    return filtered;
  }

  void _showFilterBottomSheet(BuildContext context) async {
    final properties = _propertyListBloc.state.properties;
    final result = await PropertyFilterBottomSheet.show(
      context: context,
      initialFilter: _currentFilter,
      properties: properties,
    );
    if (result != null) {
      setState(() {
        _currentFilter = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom > 0
        ? MediaQuery.of(context).padding.bottom
        : 16.0;

    return BlocProvider.value(
      value: _propertyListBloc,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
                    Text(
                      context.l10n.myProperties,
                      style: const TextStyle(
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
                            .then((_) => _onRefresh());
                      },
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        width: 36,
                        height: 36,
                        padding: const EdgeInsets.all(8),
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
                child: Builder(
                  builder: (context) {
                    return RefreshIndicator(
                      onRefresh: () => Future.sync(() => _onRefresh()),
                      color: Colors.white,
                      backgroundColor: AppColors.primary,
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
                            // Property Count
                            BlocBuilder<PropertyListBloc, PropertyListState>(
                              builder: (context, state) {
                                final properties = _applyLocalFilters(
                                  state.properties,
                                );
                                if (properties.isNotEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      24,
                                      24,
                                      24,
                                      16,
                                    ),
                                    child: AppBadges.plain(
                                      label: context.l10n.itemCount(
                                        state.totalCount,
                                      ),
                                      color: BadgeColor.blue,
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),

                            // Property List
                            Expanded(child: _buildContent()),

                            // Search Bar at Bottom
                            Container(
                              padding: EdgeInsets.fromLTRB(
                                16,
                                16,
                                16,
                                bottomPadding,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
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
                                      hintText: context.l10n.searchHint,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Filter Button
                                  InkWell(
                                    onTap: () =>
                                        _showFilterBottomSheet(context),
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
                                        colorFilter: ColorFilter.mode(
                                          !_currentFilter.isEmpty
                                              ? AppColors.primary
                                              : AppColors.baseDarkGrey,
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<PropertyListBloc, PropertyListState>(
      builder: (context, state) {
        if (state.status == PropertyListStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == PropertyListStatus.failure) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${context.l10n.errorWithPrefix}${state.errorMessage ?? "Unknown error"}',
                    ),
                    TextButton(
                      onPressed: _onRefresh,
                      child: Text(context.l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final filteredProperties = _applyLocalFilters(state.properties);

        if (filteredProperties.isEmpty && state.hasReachedMax) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: _buildEmptyState(),
            ),
          );
        }

        return _buildPropertyList(state, filteredProperties);
      },
    );
  }

  Widget _buildPropertyList(
    PropertyListState state,
    List<Property> filteredProperties,
  ) {
    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      itemCount: state.hasReachedMax
          ? filteredProperties.length
          : filteredProperties.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index >= filteredProperties.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final property = filteredProperties[index];
        final route = property.isDraft ? '/property/create' : '/property/edit';
        return PropertyListItem(
          property: property,
          onTap: () {
            context.push('/property/${property.id}').then((_) => _onRefresh());
          },
          onEdit: () {
            context.push(route, extra: property).then((_) => _onRefresh());
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180, maxHeight: 180),
              child: Image.asset(
                'assets/images/property/YA_Illustration_EmptyState_NoProperty.png',
                fit: BoxFit.fitWidth,
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
          Text(
            context.l10n.noPropertiesInSystem,
            style: const TextStyle(
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
