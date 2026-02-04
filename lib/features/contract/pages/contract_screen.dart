import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/contract.dart';
import 'package:youragent/features/contract/widgets/contract_list_item.dart';
import 'package:youragent/features/contract/widgets/contract_filter_bottom_sheet.dart';
import 'package:youragent/widgets/app_search_bar.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import 'package:youragent/features/contract/pages/create/add_contract_screen.dart';
import 'package:youragent/features/contract/pages/contract_detail_screen.dart';
import 'package:youragent/l10n/app_localizations.dart';

/// Screen showing all contract documents in a list
class ContractScreen extends StatefulWidget {
  const ContractScreen({super.key});

  @override
  State<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends State<ContractScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _contractApiService = DependencyInjection.contractApiService;

  List<Contract> _allContracts = [];
  List<Contract> _filteredContracts = [];
  bool _isLoading = true;
  String? _error;
  ContractFilter _currentFilter = ContractFilter();

  @override
  void initState() {
    super.initState();
    _loadContracts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContracts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final contracts = await _contractApiService.getContracts();
      if (!mounted) return;

      setState(() {
        _allContracts = contracts;
        _filteredContracts = contracts;
        _isLoading = false;
      });
      _onSearchChanged(); // Re-apply filter if any
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContracts = _allContracts.where((contract) {
        // Search query check
        final matchesSearch =
            query.isEmpty ||
            contract.propertyName.toLowerCase().contains(query) ||
            contract.contractNumber.toLowerCase().contains(query) ||
            contract.lessor.toLowerCase().contains(query) ||
            contract.lessee.toLowerCase().contains(query);

        // Status filter check
        final matchesStatus =
            _currentFilter.status == null ||
            contract.status == _currentFilter.status;

        // Property type filter check
        final matchesPropertyType =
            _currentFilter.propertyType == null ||
            contract.propertyType == _currentFilter.propertyType;

        // Contract type filter check
        final matchesContractType =
            _currentFilter.contractType == null ||
            contract.contractType == _currentFilter.contractType;

        return matchesSearch &&
            matchesStatus &&
            matchesPropertyType &&
            matchesContractType;
      }).toList();
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ContractFilterBottomSheet(
        allContracts: _allContracts,
        initialFilter: _currentFilter,
        onApply: (filter) {
          setState(() {
            _currentFilter = filter;
          });
          _onSearchChanged();
        },
      ),
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
                    AppLocalizations.of(context)!.contracts,
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
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddContractScreen(),
                        ),
                      );
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
              child: RefreshIndicator(
                onRefresh: _loadContracts,
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
                      // Contract Count
                      if (_allContracts.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                          child: AppBadges.plain(
                            label: '${_allContracts.length} รายการ',
                            color: BadgeColor.blue,
                          ),
                        )
                      else if (!_isLoading && _error == null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                          child: AppBadges.plain(
                            label: AppLocalizations.of(
                              context,
                            )!.contractDocument,
                            color: BadgeColor.default_,
                          ),
                        ),

                      // Contract List
                      Expanded(child: _buildContent()),

                      // Search Bar at Bottom
                      Container(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
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
                                hintText: AppLocalizations.of(
                                  context,
                                )!.searchHint,
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
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $_error'),
                TextButton(
                  onPressed: _loadContracts,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_filteredContracts.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: _buildEmptyState(),
        ),
      );
    }

    return _buildContractList();
  }

  Widget _buildContractList() {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredContracts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final contract = _filteredContracts[index];
        return ContractListItem(
          contract: contract,
          onTap: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    ContractDetailScreen(contractId: contract.id!),
              ),
            );
            if (result == true) {
              _loadContracts();
            }
          },
          onEdit: () {
            context.push('/contract/edit', extra: contract);
          },
          onShare: () {
            // Placeholder for share action
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
          const Icon(
            Icons.description_outlined,
            size: 60,
            color: AppColors.baseGrey,
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.dataContract,
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
