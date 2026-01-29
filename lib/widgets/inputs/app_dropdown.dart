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
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.showAbove = false,
    this.width,
    this.itemLabel,
  });

  @override
  State<AppDropdown<T>> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends State<AppDropdown<T>> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isOpen = false;

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isOpen = false;
      });
    }
  }

  void _toggleOverlay() {
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => _DropdownOverlay<T>(
        layerLink: _layerLink,
        items: widget.items,
        hint: widget.hint,
        selectedValue: widget.value,
        showAbove: widget.showAbove,
        itemLabel: widget.itemLabel,
        width: widget.width ?? size.width,
        onSelected: (value) {
          widget.onChanged(value);
          _removeOverlay();
        },
        onDismiss: _removeOverlay,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleOverlay,
        child: Container(
          constraints: BoxConstraints(minWidth: widget.width ?? 100),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE9EAEB)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  widget.value != null
                      ? (widget.itemLabel?.call(widget.value as T) ??
                            widget.value.toString())
                      : widget.hint,
                  style: GoogleFonts.anuphan(
                    fontSize: 14,
                    // Placeholder (no value) should use #A4A7AE
                    color: widget.value != null
                        ? AppColors.baseDarkGrey
                        : const Color(0xFFA4A7AE),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              SvgPicture.asset(
                'assets/icons/chevron-down.svg',
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
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

class _DropdownOverlay<T> extends StatelessWidget {
  final LayerLink layerLink;
  final List<T> items;
  final String hint;
  final T? selectedValue;
  final Function(T?) onSelected;
  final VoidCallback onDismiss;
  final bool showAbove;
  final double width;
  final String Function(T)? itemLabel;

  const _DropdownOverlay({
    required this.layerLink,
    required this.items,
    required this.hint,
    required this.selectedValue,
    required this.onSelected,
    required this.onDismiss,
    required this.width,
    this.showAbove = false,
    this.itemLabel,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate approximate dropdown height
    final itemHeight = 44.0;
    final hintExists = !showAbove && hint.isNotEmpty;
    final itemCount = items.length + (hintExists ? 1 : 0);
    final dropdownHeight = (itemCount * itemHeight).clamp(0.0, 250.0);

    final offset = showAbove
        ? Offset(0, -dropdownHeight - 4)
        : const Offset(0, 4);

    return GestureDetector(
      onTap: onDismiss,
      child: Stack(
        children: [
          Positioned.fill(child: Container(color: Colors.transparent)),
          CompositedTransformFollower(
            link: layerLink,
            showWhenUnlinked: false,
            offset: offset,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              child: Container(
                width: width,
                constraints: const BoxConstraints(maxHeight: 250),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE9EAEB)),
                ),
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: [
                    if (hintExists)
                      _DropdownItem<T>(
                        value: null,
                        text: hint,
                        isSelected: selectedValue == null,
                        onTap: () => onSelected(null),
                      ),
                    ...items.map(
                      (item) => _DropdownItem<T>(
                        value: item,
                        text: itemLabel?.call(item) ?? item.toString(),
                        isSelected: selectedValue == item,
                        onTap: () => onSelected(item),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownItem<T> extends StatelessWidget {
  final T? value;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _DropdownItem({
    required this.value,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected ? AppColors.basePaleGrey : Colors.transparent,
        child: Text(
          text,
          style: GoogleFonts.anuphan(
            fontSize: 14,
            // Hint row / placeholder uses #A4A7AE, selected options use normal text color
            color: value == null
                ? const Color(0xFFA4A7AE)
                : AppColors.baseDarkGrey,
          ),
        ),
      ),
    );
  }
}
