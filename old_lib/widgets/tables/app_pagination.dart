import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/widgets/inputs/app_dropdown.dart';
import 'package:youragent/l10n/app_localizations.dart';

/// A generic pagination widget used in both Property and Contract list tables.
class AppPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onItemsPerPageChanged;
  final List<int> itemsPerPageOptions;

  const AppPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.itemsPerPage,
    required this.onPageChanged,
    required this.onItemsPerPageChanged,
    this.itemsPerPageOptions = const [10, 25, 50, 100],
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Items per page dropdown
          Row(
            children: [
              Text(
                l10n.items_per_page,
                style: GoogleFonts.anuphan(
                  fontSize: 14,
                  color: AppColors.baseDarkGrey,
                ),
              ),
              const SizedBox(width: 8),
              AppDropdown<int>(
                value: itemsPerPage,
                hint: itemsPerPage.toString(),
                items: itemsPerPageOptions,
                showAbove: true,
                onChanged: (value) {
                  if (value != null) {
                    onItemsPerPageChanged(value);
                  }
                },
              ),
            ],
          ),
          // Page navigation
          Row(
            children: [
              // Previous button
              _PaginationArrowButton(
                icon: Icons.chevron_left,
                onPressed: currentPage > 1
                    ? () => onPageChanged(currentPage - 1)
                    : null,
              ),
              const SizedBox(width: 8),
              // Page numbers with ellipsis for many pages
              ..._buildPageNumbers(currentPage, totalPages),
              const SizedBox(width: 8),
              // Next button
              _PaginationArrowButton(
                icon: Icons.chevron_right,
                onPressed: currentPage < totalPages
                    ? () => onPageChanged(currentPage + 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(int currentPage, int totalPages) {
    final List<Widget> pageWidgets = [];

    if (totalPages <= 5) {
      // Show all pages if 5 or fewer
      for (int i = 1; i <= totalPages; i++) {
        pageWidgets.add(_buildPageButton(i, currentPage));
      }
    } else {
      // Always show first page
      pageWidgets.add(_buildPageButton(1, currentPage));

      if (currentPage > 3) {
        pageWidgets.add(_buildEllipsis());
      }

      // Show pages around current
      for (int i = currentPage - 1; i <= currentPage + 1; i++) {
        if (i > 1 && i < totalPages) {
          pageWidgets.add(_buildPageButton(i, currentPage));
        }
      }

      if (currentPage < totalPages - 2) {
        pageWidgets.add(_buildEllipsis());
      }

      // Always show last page
      pageWidgets.add(_buildPageButton(totalPages, currentPage));
    }

    return pageWidgets;
  }

  Widget _buildEllipsis() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '...',
        style: GoogleFonts.anuphan(fontSize: 14, color: AppColors.baseDarkGrey),
      ),
    );
  }

  Widget _buildPageButton(int page, int currentPage) {
    final isSelected = page == currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: () => onPageChanged(page),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF5F5F5) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            '$page',
            style: GoogleFonts.anuphan(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? AppColors.baseDarkGrey
                  : AppColors.baseDarkGrey,
            ),
          ),
        ),
      ),
    );
  }
}

/// A generic placeholder for pagination when data is loading or empty.
class AppPaginationPlaceholder extends StatelessWidget {
  final int itemsPerPage;
  final List<int> itemsPerPageOptions;

  const AppPaginationPlaceholder({
    super.key,
    this.itemsPerPage = 10,
    this.itemsPerPageOptions = const [10, 25, 50, 100],
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                l10n.items_per_page,
                style: GoogleFonts.anuphan(
                  fontSize: 14,
                  color: AppColors.baseDarkGrey,
                ),
              ),
              const SizedBox(width: 8),
              AppDropdown<int>(
                value: itemsPerPage,
                hint: itemsPerPage.toString(),
                items: itemsPerPageOptions,
                onChanged: (_) {},
              ),
            ],
          ),
          const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _PaginationArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _PaginationArrowButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 20,
          color: isEnabled ? const Color(0xFF717680) : const Color(0xFFD5D6D9),
        ),
      ),
    );
  }
}
