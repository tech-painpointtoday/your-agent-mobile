import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';

/// Custom dropdown widget that uses Overlay instead of Navigator routes
/// to avoid conflicts with go_router.
/// Based on the design in PropertyListScreen but extracted for general use.
class AppDropdown<T> extends StatefulWidget {
  final T? value;
  final String hint;
  final List<T> items;
  final Function(T?) onChanged;
  final bool showAbove;
  final double? width;
  final String Function(T)? itemLabel;

  const AppDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint = '',
    this.showAbove = false,
    this.width,
    this.itemLabel,
  });

  @override
  State<AppDropdown<T>> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends State<AppDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen = false;
  }

  String _getLabel(T item) {
    if (widget.itemLabel != null) {
      return widget.itemLabel!(item);
    }
    return item.toString();
  }

  void _showOverlay() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    // final offset = renderBox.localToGlobal(Offset.zero); // Not used directly in this approach

    // Calculate position
    // If showAbove is true, we verify if there is enough space.
    // Ideally we would check window size but for now we trust the flag/logic provided.

    // We'll fix the height of dropdown items to standard 48 * items.length + padding
    // Max height constraint
    final double maxHeight = 200.0;

    // For simplicity using the same width as the input

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Modal barrier to close on tap outside
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                _removeOverlay();
                setState(() {});
              },
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),
          // Dropdown content
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: widget.showAbove
                ? const Offset(
                    0,
                    0,
                  ) // We will handle Y translation in the child alignment if needed or use simple offset
                // Actually specific offset for 'above' needs calculation of dropdown height.
                // Since content height is dynamic, using CompositedTransformFollower with `followerAnchor` is better?
                // But standard Overlay usage:
                : Offset(0, size.height + 4),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              child: Container(
                width:
                    widget.width ??
                    size.width, // Use widget.width if provided, else use parent width
                constraints: BoxConstraints(maxHeight: maxHeight),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.baseLightGrey),
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    final isSelected = item == widget.value;
                    return InkWell(
                      onTap: () {
                        widget.onChanged(item);
                        _removeOverlay();
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.05)
                              : null,
                          border: index != widget.items.length - 1
                              ? Border(
                                  bottom: BorderSide(
                                    color: AppColors.baseLightGrey.withOpacity(
                                      0.5,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        child: Text(
                          _getLabel(item),
                          style: GoogleFonts.anuphan(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.baseBlack,
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: _toggleDropdown,
        child: Container(
          width:
              widget.width ??
              double
                  .infinity, // Use widget.width if provided, else use double.infinity
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.baseLightGrey, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.value != null
                      ? _getLabel(widget.value as T)
                      : widget.hint,
                  style: GoogleFonts.anuphan(
                    color: widget.value != null
                        ? AppColors.baseBlack
                        : AppColors.baseGrey,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SvgPicture.asset(
                'assets/icons/chevron-down.svg',
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  AppColors.baseGrey,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
