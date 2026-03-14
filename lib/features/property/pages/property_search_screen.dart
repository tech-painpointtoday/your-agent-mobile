import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/property_search/property_search_bloc.dart';
import '../bloc/property_search/property_search_event.dart';
import '../bloc/property_search/property_search_state.dart';
import '../../../domain/entities/property.dart';
import '../../home/pages/home_screen.dart';
import '../widgets/property_list_item.dart';
import '../../../widgets/modals/app_confirmation_bottom_sheet.dart';

/// Full-screen property search: recent searches, API results, empty state, pagination.
class PropertySearchScreen extends StatefulWidget {
  const PropertySearchScreen({super.key});

  @override
  State<PropertySearchScreen> createState() => _PropertySearchScreenState();
}

class _PropertySearchScreenState extends State<PropertySearchScreen> {
  late final TextEditingController _queryController;
  late final ScrollController _scrollController;
  late final PropertySearchBloc _searchBloc;
  Timer? _debounceTimer;
  bool _skipNextDebounce = false;
  String? _lastSubmittedQuery;
  static const _debounceDuration = Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController();
    _scrollController = ScrollController();
    _searchBloc = PropertySearchBloc()..add(const PropertySearchOpened());
    _scrollController.addListener(_onScroll);
    _queryController.addListener(_onQueryChanged);
  }

  void _onQueryChanged() {
    if (_skipNextDebounce) {
      _skipNextDebounce = false;
      return;
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      if (!mounted) return;
      final q = _queryController.text.trim();
      if (q == _lastSubmittedQuery) return;
      _lastSubmittedQuery = q;
      _searchBloc.add(PropertySearchSubmitted(query: q));
    });
  }

  void _onScroll() {
    if (_searchBloc.state.hasReachedMax) return;
    if (_searchBloc.state.status != PropertySearchStatus.success) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      _searchBloc.add(const PropertySearchLoadMore());
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _queryController.removeListener(_onQueryChanged);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _queryController.dispose();
    _searchBloc.close();
    super.dispose();
  }

  void _submitQuery() {
    final q = _queryController.text.trim();
    if (q == _lastSubmittedQuery) return;
    _lastSubmittedQuery = q;
    _searchBloc.add(PropertySearchSubmitted(query: q));
  }

  Future<void> _clearRecent() async {
    await AppConfirmationBottomSheet.show(
      context: context,
      title: AppLocalizations.of(context).propertySearchClearRecentTitle,
      description: AppLocalizations.of(context).propertySearchClearRecentDesc,
      confirmLabel: AppLocalizations.of(context).propertySearchClear,
      style: ConfirmationStyle.normal,
      onConfirm: () async {
        Navigator.of(context).pop();
        await DependencyInjection.propertySearchRecentService
            .clearRecentSearches();
        final recent = await DependencyInjection.propertySearchRecentService
            .getRecentSearches();
        _searchBloc.add(PropertySearchRecentLoaded(recent));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _searchBloc,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          surfaceTintColor: AppColors.white,
          backgroundColor: AppColors.white,
          elevation: 0,
          leadingWidth: 64,
          leading: InkWell(
            onTap: () => context.pop(),
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 6, 4, 6),
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.baseLightGrey, width: 1),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/chevron-left.svg',
                  width: 18,
                  height: 18,
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(
                    AppColors.baseDarkGrey,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          title: Padding(
            padding: EdgeInsets.only(right: 16),
            child: HomeSearchBar(
              controller: _queryController,
              navigateOnTap: false,
              onSubmitted: _submitQuery,
            ),
          ),
          titleSpacing: 4,
        ),
        body: BlocBuilder<PropertySearchBloc, PropertySearchState>(
          builder: (context, state) {
            // When we have no results yet (initial or loading): always show recent section, never full-screen spinner
            final showRecentOnly =
                state.status == PropertySearchStatus.initial ||
                (state.status == PropertySearchStatus.loading &&
                    state.properties.isEmpty);
            if (showRecentOnly) {
              return Stack(
                children: [
                  _RecentSection(
                    recent: state.recentSearches,
                    onTapRecent: (text) {
                      _debounceTimer?.cancel();
                      _skipNextDebounce = true;
                      _queryController.text = text;
                      if (text != _lastSubmittedQuery) {
                        _lastSubmittedQuery = text;
                        _searchBloc.add(PropertySearchSubmitted(query: text));
                      }
                    },
                    onClear: _clearRecent,
                  ),
                  if (state.status == PropertySearchStatus.loading)
                    Container(
                      color: Colors.white.withOpacity(0.7),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              );
            }
            if (state.status == PropertySearchStatus.failure &&
                state.properties.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.errorMessage ?? 'Error',
                    style: GoogleFonts.anuphan(
                      color: AppColors.error,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            if (state.isEmptyResult) {
              return _EmptyState(
                message: AppLocalizations.of(context).propertySearchEmptyHint,
              );
            }
            if (state.status == PropertySearchStatus.success &&
                state.properties.isNotEmpty) {
              return _ResultsList(
                scrollController: _scrollController,
                properties: state.properties,
                hasReachedMax: state.hasReachedMax,
                totalCount: state.totalCount,
              );
            }
            // Fallback: show recent section
            return _RecentSection(
              recent: state.recentSearches,
              onTapRecent: (text) {
                _debounceTimer?.cancel();
                _skipNextDebounce = true;
                _queryController.text = text;
                if (text != _lastSubmittedQuery) {
                  _lastSubmittedQuery = text;
                  _searchBloc.add(PropertySearchSubmitted(query: text));
                }
              },
              onClear: _clearRecent,
            );
          },
        ),
      ),
    );
  }
}

class _RecentSection extends StatelessWidget {
  final List<String> recent;
  final ValueChanged<String> onTapRecent;
  final VoidCallback onClear;

  const _RecentSection({
    required this.recent,
    required this.onTapRecent,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pill-shaped "Recent searches" header with clear (x) on the right
          if (recent.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.basePaleGrey,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    AppLocalizations.of(context).propertySearchRecentSearches,
                    style: GoogleFonts.anuphan(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.baseDarkGrey,
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: onClear,
                  child: SvgPicture.asset(
                    'assets/icons/x-circle-filled.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      AppColors.baseGrey,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          if (recent.isNotEmpty) const SizedBox(height: 16),

          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                AppLocalizations.of(context).propertySearchNoRecent,
                style: GoogleFonts.anuphan(
                  fontSize: 14,
                  color: AppColors.baseGrey,
                ),
              ),
            )
          else
            ...recent.map(
              (text) => _RecentChip(text: text, onTap: () => onTapRecent(text)),
            ),
        ],
      ),
    );
  }
}

class _RecentChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _RecentChip({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          width: double.infinity,
          child: Text(
            text,
            style: GoogleFonts.anuphan(
              fontSize: 16,
              color: AppColors.black,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/YA_Illustration_EmptyState_NoRecentSearch.png',
              fit: BoxFit.contain,
              height: 200,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.anuphan(
                  fontSize: 14,
                  color: AppColors.baseGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  final ScrollController scrollController;
  final List<Property> properties;
  final bool hasReachedMax;
  final int totalCount;

  const _ResultsList({
    required this.scrollController,
    required this.properties,
    required this.hasReachedMax,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              AppLocalizations.of(context).allPropertiesCount(totalCount),
              style: GoogleFonts.anuphan(
                fontSize: 14,
                color: AppColors.baseGrey,
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index < properties.length) {
              final property = properties[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: PropertyListItem(property: property),
              );
            }
            if (!hasReachedMax) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }, childCount: properties.length + (hasReachedMax ? 0 : 1)),
        ),
      ],
    );
  }
}
