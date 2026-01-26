import 'package:flutter/material.dart';
import 'package:youragent/core/theme/app_colors.dart';

/// Reusable search bar widget for the app
class AppSearchBar extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const AppSearchBar({
    super.key,
    this.hintText = 'ค้นหา...',
    this.controller,
    this.onChanged,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late TextEditingController _searchController;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _searchController = TextEditingController();
      _isInternalController = true;
    } else {
      _searchController = widget.controller!;
    }
    _searchController.addListener(() {
      setState(() {}); // Update UI when text changes
      widget.onChanged?.call(_searchController.text);
    });
  }

  @override
  void dispose() {
    if (_isInternalController) {
      _searchController.dispose();
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 20, color: AppColors.gray500),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                color: AppColors.gray700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: const TextStyle(
                  color: AppColors.gray500,
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
              child: Icon(
                Icons.clear,
                size: 18,
                color: AppColors.gray400.withOpacity(0.6),
              ),
            ),
        ],
      ),
    );
  }
}
