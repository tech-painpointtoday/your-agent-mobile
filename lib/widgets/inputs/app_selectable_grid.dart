import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class GridItem {
  final String label;
  final String value;
  final String? imagePath;

  const GridItem({required this.label, required this.value, this.imagePath});
}

class AppSelectableGrid<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<GridItem> items;
  final ValueChanged<T> onChanged;
  final bool isRequired;

  const AppSelectableGrid({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          RichText(
            text: TextSpan(
              text: label,
              style: GoogleFonts.anuphan(
                color: AppColors.baseBlack,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              children: [
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: GoogleFonts.anuphan(
                      color: AppColors.supportRedDeep,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2, // Visual aspect ratio
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isSelected = item.value == value;

            final hasSelection = value != null;

            return GestureDetector(
              onTap: () => onChanged(item.value as T),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: hasSelection && !isSelected ? 0.5 : 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.baseGrey.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14),
                          ),
                          child: item.imagePath != null
                              ? Image.asset(
                                  item.imagePath!,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.grey[100],
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(
                            item.label,
                            style: GoogleFonts.anuphan(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.baseBlack,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
