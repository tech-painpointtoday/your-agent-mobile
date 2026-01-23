import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/features/contracts/bloc/contracts_bloc.dart';
import 'package:youragent/widgets/tables/app_pagination.dart';

class ContractsPagination extends StatelessWidget {
  final ContractsLoaded state;

  const ContractsPagination({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return AppPagination(
      currentPage: state.currentPage,
      totalPages: state.totalPages,
      itemsPerPage: state.itemsPerPage,
      onPageChanged: (page) {
        context.read<ContractsBloc>().add(ContractsPageChanged(page));
      },
      onItemsPerPageChanged: (limit) {
        context.read<ContractsBloc>().add(ContractsItemsPerPageChanged(limit));
      },
    );
  }
}

class ContractsPaginationPlaceholder extends StatelessWidget {
  const ContractsPaginationPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPaginationPlaceholder();
  }
}
