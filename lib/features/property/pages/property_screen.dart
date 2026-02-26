import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/features/home/pages/home_screen.dart';
import 'package:youragent/features/property/pages/all_properties_screen.dart';
import 'package:youragent/widgets/map/fullscreen_map_screen.dart';
import 'package:youragent/features/property/widgets/property_list_item.dart';
import 'package:youragent/widgets/app_bars/silver_app_bar.dart';
import 'package:youragent/widgets/map/map_view.dart';
import 'package:youragent/core/extensions/l10n_extensions.dart';
import 'package:youragent/features/property/bloc/property_list/property_list_bloc.dart';
import 'package:youragent/features/property/bloc/property_list/property_list_event.dart';
import 'package:youragent/features/property/bloc/property_list/property_list_state.dart';

/// Main Property screen used in navigation tabs
class PropertyScreen extends StatefulWidget {
  const PropertyScreen({super.key});

  @override
  State<PropertyScreen> createState() => _PropertyScreenState();
}

class _PropertyScreenState extends State<PropertyScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _propertyApiService = DependencyInjection.propertyApiService;

  late final PropertyListBloc _propertyListBloc;

  @override
  void initState() {
    super.initState();
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

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _propertyListBloc,
      child: BlocBuilder<PropertyListBloc, PropertyListState>(
        builder: (context, state) {
          final filteredProperties = _applyLocalFilters(state.properties);

          return SilverAppBarScreen(
            onRefresh: _onRefresh,
            controller: _scrollController,
            hasFilter: true,
            title: context.l10n.propertiesTitle,
            actionWidget: InkWell(
              onTap: () async {
                context
                    .push('/property/create')
                    .then((_) => _propertyListBloc.add(PropertyListRefresh()));
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
            // searchBar: HomeSearchBar(controller: _searchController),
            preferredHeight: 84.0,
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
                        child: MapView(
                          properties: filteredProperties,
                          onMaximizeTapped: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullscreenMapScreen(
                                  properties: filteredProperties,
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
                  child: _buildPropertyList(state, filteredProperties),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPropertyList(
    PropertyListState state,
    List<Property> filteredProperties,
  ) {
    if (state.status == PropertyListStatus.initial) {
      return const Center(
        child: SpinKitFadingCircle(color: AppColors.primary, size: 32),
      );
    }

    if (state.status == PropertyListStatus.failure) {
      return Center(
        child: Column(
          children: [
            Text(
              '${context.l10n.errorWithPrefix}${state.errorMessage ?? "Unknown error"}',
            ),
            TextButton(onPressed: _onRefresh, child: Text(context.l10n.retry)),
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
            context.l10n.myProperties,
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
                context.l10n.allPropertiesCount(state.totalCount),
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
                  context.l10n.viewAll,
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
          filteredProperties.isEmpty && state.hasReachedMax
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      context.l10n.noPropertiesFoundSearch,
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
                  itemCount: filteredProperties.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final property = filteredProperties[index];
                    final route = property.isDraft
                        ? '/property/create'
                        : '/property/edit';

                    return PropertyListItem(
                      property: property,
                      onTap: () {
                        context
                            .push('/property/${property.id}')
                            .then(
                              (_) =>
                                  _propertyListBloc.add(PropertyListRefresh()),
                            );
                      },
                      onEdit: () {
                        context
                            .push(route, extra: property)
                            .then(
                              (_) =>
                                  _propertyListBloc.add(PropertyListRefresh()),
                            );
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }
}
