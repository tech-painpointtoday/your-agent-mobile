import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';

/// A generic table widget with a sticky management column on the right.
/// Supports custom columns, rows, and action buttons.
class AppGenericTable<T> extends StatefulWidget {
  final List<T> items;
  final List<DataColumn> columns;
  final List<DataCell> Function(T item, int index) rowBuilder;
  final Widget Function(T item, int index) actionsBuilder;
  final String stickyHeaderLabel;
  final double stickyColumnWidth;
  final double headerHeight;
  final double rowHeight;
  final String emptyMessage;
  final bool isLoading;

  const AppGenericTable({
    super.key,
    required this.items,
    required this.columns,
    required this.rowBuilder,
    required this.actionsBuilder,
    this.stickyHeaderLabel = 'จัดการ',
    this.stickyColumnWidth = 164.0,
    this.headerHeight = 56.0,
    this.rowHeight = 72.0,
    this.emptyMessage = 'ไม่พบข้อมูล',
    this.isLoading = false,
  });

  @override
  State<AppGenericTable<T>> createState() => _AppGenericTableState<T>();
}

class _AppGenericTableState<T> extends State<AppGenericTable<T>> {
  late final ScrollController _horizontalScrollController;

  @override
  void initState() {
    super.initState();
    _horizontalScrollController = ScrollController();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (widget.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Text(
            widget.emptyMessage,
            style: GoogleFonts.anuphan(
              fontSize: 16,
              color: AppColors.baseDarkGrey,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // 1. Scrollable Main Table Content with Scrollbar
              Scrollbar(
                controller: _horizontalScrollController,
                thumbVisibility: true,
                thickness: 8,
                radius: const Radius.circular(4),
                child: SingleChildScrollView(
                  controller: _horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth - widget.stickyColumnWidth,
                    ),
                    child: DataTable(
                      columnSpacing: 24,
                      headingRowHeight: widget.headerHeight,
                      dataRowMinHeight: widget.rowHeight,
                      dataRowMaxHeight: widget.rowHeight,
                      headingRowColor: const WidgetStatePropertyAll(
                        Color(0xFFF5F5F5),
                      ),
                      border: const TableBorder(
                        horizontalInside: BorderSide(color: Color(0xFFE9EAEB)),
                      ),
                      columns: [
                        ...widget.columns,
                        // Spacer column for the sticky section
                        DataColumn(
                          label: SizedBox(width: widget.stickyColumnWidth),
                        ),
                      ],
                      rows: widget.items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return DataRow(
                          cells: [
                            ...widget.rowBuilder(item, index),
                            // Spacer cell for the sticky section
                            DataCell(
                              SizedBox(
                                width: widget.stickyColumnWidth,
                                height: widget.rowHeight,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              // 2. Sticky Management Column on the right
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Left shadow gradient for depth
                    Container(
                      width: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [
                            const Color(0xFF000000).withValues(alpha: 0.06),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    // Sticky column content
                    Container(
                      width: widget.stickyColumnWidth,
                      color: AppColors.white,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Sticky Header
                          Container(
                            height: widget.headerHeight,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF5F5F5),
                              border: Border(
                                bottom: BorderSide(color: Color(0xFFE9EAEB)),
                              ),
                            ),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.stickyHeaderLabel,
                              style: GoogleFonts.anuphan(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.baseDarkGrey,
                              ),
                            ),
                          ),
                          // Sticky Row Actions
                          ...widget.items.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            final isLastRow = index == widget.items.length - 1;
                            return Container(
                              height: widget.rowHeight,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                border: isLastRow
                                    ? null
                                    : const Border(
                                        bottom: BorderSide(
                                          color: Color(0xFFE9EAEB),
                                        ),
                                      ),
                              ),
                              child: widget.actionsBuilder(item, index),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
