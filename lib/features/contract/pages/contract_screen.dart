import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:yourhome/core/di/dependency_injection.dart';
import 'package:yourhome/core/theme/app_colors.dart';
import 'package:yourhome/domain/entities/contract.dart';
import 'package:yourhome/features/contract/widgets/contract_list_item.dart';
import 'package:yourhome/features/contract/widgets/contract_filter_bottom_sheet.dart';
import 'package:yourhome/widgets/app_search_bar.dart';
import 'package:yourhome/widgets/badges/app_badge.dart';
import 'package:yourhome/features/contract/pages/contract_detail_screen.dart';
import 'package:yourhome/core/extensions/l10n_extensions.dart';
import 'package:yourhome/widgets/modals/app_status_bottom_sheet.dart';
import 'package:yourhome/domain/entities/property.dart';
import 'package:yourhome/domain/entities/contract_status.dart';
import 'package:yourhome/widgets/dialogs/status_dialog.dart';

import '../bloc/contract_list/contract_list_bloc.dart';
import '../bloc/contract_list/contract_list_event.dart';
import '../bloc/contract_list/contract_list_state.dart';

/// Screen showing all contract documents in a list with infinite scroll
class ContractScreen extends StatefulWidget {
  const ContractScreen({super.key});

  @override
  State<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends State<ContractScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _propertyApiService = DependencyInjection.propertyApiService;
  final _contractApiService = DependencyInjection.contractApiService;

  ContractFilter _currentFilter = ContractFilter();
  late final ContractListBloc _contractListBloc;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _contractListBloc = ContractListBloc(
      contractApiService: _contractApiService,
    )..add(const ContractListFetched());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _contractListBloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      _contractListBloc.add(const ContractListFetched());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> _onRefresh() async {
    _contractListBloc.add(ContractListRefresh());
  }

  void _onSearchChanged() {
    setState(() {}); // Trigger local filtering rebuild
  }

  List<Contract> _applyLocalFilters(List<Contract> contracts) {
    var filtered = contracts;

    // Apply Search Query
    final query = _searchController.text.toLowerCase().trim();
    if (query.isNotEmpty) {
      filtered = filtered.where((contract) {
        return contract.propertyName.toLowerCase().contains(query) ||
            contract.contractNumber.toLowerCase().contains(query) ||
            contract.lessor.toLowerCase().contains(query) ||
            contract.lessee.toLowerCase().contains(query);
      }).toList();
    }

    // Apply Filter Bottom Sheet
    if (!_currentFilter.isEmpty) {
      filtered = filtered.where((contract) {
        final matchesStatus =
            _currentFilter.status == null ||
            contract.status == _currentFilter.status;
        final matchesPropertyType =
            _currentFilter.propertyType == null ||
            contract.propertyType == _currentFilter.propertyType;
        final matchesContractType =
            _currentFilter.contractType == null ||
            contract.contractType == _currentFilter.contractType;

        return matchesStatus && matchesPropertyType && matchesContractType;
      }).toList();
    }

    return filtered;
  }

  void _showFilterBottomSheet() {
    final contracts = _contractListBloc.state.contracts;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ContractFilterBottomSheet(
        allContracts: contracts,
        initialFilter: _currentFilter,
        onApply: (filter) {
          setState(() {
            _currentFilter = filter;
          });
        },
      ),
    );
  }

  Future<void> _handleCreateContract() async {
    try {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
      builder: (context) => const Center(
        child: SpinKitFadingCircle(
          color: AppColors.primary,
          size: 32,
        ),
      ),
      );

      final results = await _propertyApiService.getProperties();

      if (!mounted) return;
      Navigator.of(context).pop();

      final approvedProperties = results.properties
          .where((p) => p.approvalStatus == PropertyApprovalStatus.approved)
          .toList();

      if (!mounted) return;

      if (approvedProperties.isEmpty) {
        AppStatusBottomSheet.showWarning(
          context: context,
          iconPath: 'assets/images/YA_Illustration_ConfirmWarning.png',
          title: context.l10n.cannotCreateContractTitle,
          message: context.l10n.cannotCreateContractMessage,
          onOk: () => Navigator.of(context).pop(),
        );
      } else {
        context.push('/contract/create').then((result) {
          if (result == true) {
            _onRefresh();
          }
        });
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      if (!mounted) return;
      StatusDialog.showError(
        context: context,
        title: context.l10n.errorOccurredTitle,
        message: 'Failed to check properties: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom > 0
        ? MediaQuery.of(context).padding.bottom
        : 16.0;

    return BlocProvider.value(
      value: _contractListBloc,
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
                      context.l10n.contracts,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    // Add Button
                    InkWell(
                      onTap: _handleCreateContract,
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
                            // Contract Count
                            BlocBuilder<ContractListBloc, ContractListState>(
                              builder: (context, state) {
                                final contracts = _applyLocalFilters(
                                  state.contracts,
                                );
                                if (contracts.isNotEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      24,
                                      24,
                                      24,
                                      16,
                                    ),
                                    child: AppBadges.plain(
                                      label:
                                          '${state.totalCount} รายการ', // Alternatively use context.l10n.itemCount if available
                                      color: BadgeColor.blue,
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),

                            // Contract List
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
    return BlocBuilder<ContractListBloc, ContractListState>(
      builder: (context, state) {
        if (state.status == ContractListStatus.initial) {
          return const Center(
            child: SpinKitFadingCircle(
              color: AppColors.primary,
              size: 32,
            ),
          );
        }

        if (state.status == ContractListStatus.failure) {
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

        final filteredContracts = _applyLocalFilters(state.contracts);

        if (filteredContracts.isEmpty && state.hasReachedMax) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: _buildEmptyState(),
            ),
          );
        }

        return _buildContractList(state, filteredContracts);
      },
    );
  }

  Widget _buildContractList(
    ContractListState state,
    List<Contract> filteredContracts,
  ) {
    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      itemCount: state.hasReachedMax
          ? filteredContracts.length
          : filteredContracts.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index >= filteredContracts.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: SpinKitFadingCircle(
                color: AppColors.primary,
                size: 24,
              ),
            ),
          );
        }

        final contract = filteredContracts[index];
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
              _onRefresh();
            }
          },
          onEdit: () {
            if (contract.status == ContractStatus.draft) {
              context.push('/contract/create', extra: contract).then((result) {
                if (result == true) {
                  _onRefresh();
                }
              });
            } else {
              context.push('/contract/edit', extra: contract).then((result) {
                _onRefresh();
              });
            }
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180, maxHeight: 180),
              child: Image.asset(
                'assets/images/contract/YA_Illustration_EmptyState_NoContract.png',
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
            context.l10n.dataContract,
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
