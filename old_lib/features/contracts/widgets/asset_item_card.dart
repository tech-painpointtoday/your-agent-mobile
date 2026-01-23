import 'package:flutter/material.dart';
import 'package:youragent/core/theme/app_colors.dart';

/// Asset item card for displaying appliances/furniture with images
class AssetItemCard extends StatelessWidget {
  final String itemName;
  final String? description;
  final List<String> imageUrls;
  final VoidCallback? onRemove;
  final bool isReadOnly;

  const AssetItemCard({
    super.key,
    required this.itemName,
    this.description,
    this.imageUrls = const [],
    this.onRemove,
    this.isReadOnly = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with item name and remove button
          Row(
            children: [
              Expanded(
                child: Text(
                  itemName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (!isReadOnly && onRemove != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(description!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray600)),
          ],
          if (imageUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'ตัวอย่างรูปภาพ',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.gray700, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: imageUrls.map((url) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    url,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: AppColors.gray100,
                        child: const Icon(Icons.broken_image, color: AppColors.gray400),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
