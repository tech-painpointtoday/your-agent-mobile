import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:youragent/core/theme/app_colors.dart';

/// Reusable search bar widget for the app
class AppSearchBar extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;

  const AppSearchBar({
    super.key,
    this.hintText = 'ค้นหา...',
    this.controller,
    this.focusNode,
    this.onChanged,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late TextEditingController _searchController;
  late FocusNode _focusNode;
  bool _isInternalController = false;
  bool _isInternalFocusNode = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _searchController = TextEditingController();
      _isInternalController = true;
    } else {
      _searchController = widget.controller!;
    }

    if (widget.focusNode == null) {
      _focusNode = FocusNode();
      _isInternalFocusNode = true;
    } else {
      _focusNode = widget.focusNode!;
    }

    _searchController.addListener(_handleSearchChanged);
    _focusNode.addListener(_handleFocusChanged);
  }

  void _handleSearchChanged() {
    if (!mounted) return;
    setState(() {});
    widget.onChanged?.call(_searchController.text);
  }

  void _handleFocusChanged() {
    if (!mounted) return;
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    _focusNode.removeListener(_handleFocusChanged);

    if (_isInternalController) {
      _searchController.dispose();
    }
    if (_isInternalFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isFocused ? AppColors.primary : AppColors.baseLightGrey,
          width: _isFocused ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/search.svg',
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
              AppColors.baseDarkGrey,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              style: const TextStyle(
                color: AppColors.baseDarkGrey,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: const TextStyle(
                  color: AppColors.baseDarkGrey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            InkWell(
              onTap: () {
                setState(() {
                  _searchController.clear();
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: SvgPicture.asset(
                'assets/icons/x.svg',
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  AppColors.baseGrey,
                  BlendMode.srcIn,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
