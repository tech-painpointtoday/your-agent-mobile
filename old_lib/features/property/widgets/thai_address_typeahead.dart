import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/widgets/form_fields/app_form_text_field.dart';

/// Thai Address TypeAhead Widget
/// Provides autocomplete functionality for Thai address fields (province, amphoe, district, zipcode)
class ThaiAddressTypeAhead extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String searchKey;
  final List<Map<String, dynamic>> thaiAddresses;
  final Function(Map<String, dynamic>) onSelected;
  final bool isReadOnly;
  final bool isRequired;
  final bool isLoadingAddress;
  final String? currentPostalCode; // For filtering by postal code

  const ThaiAddressTypeAhead({
    super.key,
    required this.controller,
    required this.label,
    required this.searchKey,
    required this.thaiAddresses,
    required this.onSelected,
    this.isReadOnly = false,
    this.isRequired = false,
    this.isLoadingAddress = false,
    this.currentPostalCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormFieldLabel(label: label, isRequired: isRequired),
        const SizedBox(height: 8),
        TypeAheadField<Map<String, dynamic>>(
          controller: controller,
          builder: (context, controller, focusNode) {
            return Theme(
              data: Theme.of(context).copyWith(
                textSelectionTheme: isReadOnly
                    ? const TextSelectionThemeData(
                        selectionColor: AppColors.gray800,
                        cursorColor: AppColors.gray800,
                      )
                    : null,
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: !isReadOnly,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: label,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFA4A7AE),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grayBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grayBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isReadOnly ? AppColors.grayBorder : Colors.blue,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grayBorder),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  filled: isReadOnly,
                  fillColor: isReadOnly ? const Color(0xFFFFFFFF) : null,
                ),
              ),
            );
          },
          suggestionsCallback: (pattern) {
            if (isLoadingAddress) return const [];

            // Filter by pattern if not empty
            Iterable<Map<String, dynamic>> filtered;
            if (pattern.isEmpty) {
              // หาก focus field: แสดงเรียงจากข้อมูลแรก
              if (searchKey == 'zipcode') {
                // Show suggestions starting from 11000 when first focused
                filtered = thaiAddresses.where((address) {
                  final zip = num.tryParse(address['zipcode'].toString()) ?? 0;
                  return zip >= 11000;
                });
              } else {
                filtered = thaiAddresses;
              }
            } else {
              // หากพิมพ์ตัวอักษร: แสดงข้อมูลที่ขึ้นต้นด้วยตัวนั้น เรียงตามหลัก
              // หากพิมพ์ตัวเลข: แสดงตัวเลขนั้นก่อน (เช่น ไปรษณีย์ พิมพ์ 7 ควรจะขึ้น 7..... ก่อน)
              final searchPattern = pattern.toLowerCase();
              final isNumeric = RegExp(r'^\d').hasMatch(pattern);

              filtered = thaiAddresses.where((address) {
                final value = address[searchKey]?.toString() ?? '';
                final valueLower = value.toLowerCase();

                if (searchKey == 'zipcode' && isNumeric) {
                  // สำหรับไปรษณีย์: ถ้าพิมพ์ตัวเลข ให้แสดงที่ขึ้นต้นด้วยตัวเลขนั้นก่อน
                  return value.startsWith(pattern);
                } else if (isNumeric) {
                  // สำหรับฟิลด์อื่นที่พิมพ์ตัวเลข: แสดงที่ขึ้นต้นด้วยตัวเลขนั้น
                  return valueLower.startsWith(searchPattern);
                } else {
                  // สำหรับตัวอักษร: แสดงที่ขึ้นต้นด้วยตัวอักษรนั้น
                  return valueLower.startsWith(searchPattern);
                }
              });
            }

            // Create a list for sorting to avoid multi-field side effects
            final resultList = filtered.toList();

            // Sort by the search key (numeric for zipcode, string for others)
            resultList.sort((a, b) {
              final aVal = a[searchKey];
              final bVal = b[searchKey];

              if (searchKey == 'zipcode') {
                final aNum = num.tryParse(aVal.toString()) ?? 0;
                final bNum = num.tryParse(bVal.toString()) ?? 0;
                return aNum.compareTo(bNum);
              }

              // Sort alphabetically for text fields
              return aVal.toString().compareTo(bVal.toString());
            });

            // STRICT Deduplication: Use the same composite key for ALL fields
            // Rule: A row is considered "Duplicate" ONLY IF District + Amphoe + Province + Zipcode are ALL identical
            // This applies to ALL 4 address fields (Province, Amphoe, District, Zipcode)
            // Result: If 3 subdistricts have the exact same name, amphoe, province, and zipcode -> Show ONLY 1 row
            final Set<String> seenKeys = {};
            final List<Map<String, dynamic>> deduplicatedList = [];

            for (final item in resultList) {
              if (item[searchKey] == null) continue;

              // Generate STRICT composite key: district|amphoe|province|zipcode
              // This is the same for ALL fields to ensure no duplicates
              final district = (item['district']?.toString() ?? '')
                  .toLowerCase();
              final amphoe = (item['amphoe']?.toString() ?? '').toLowerCase();
              final province = (item['province']?.toString() ?? '')
                  .toLowerCase();
              final zipcode = (item['zipcode']?.toString() ?? '').toLowerCase();
              final uniqueKey = '$district|$amphoe|$province|$zipcode';

              // Only add if we haven't seen this composite key before
              // This ensures that identical address combinations appear only once
              if (!seenKeys.contains(uniqueKey)) {
                seenKeys.add(uniqueKey);
                deduplicatedList.add(item);
              }
            }

            // Group by postal code: if user has selected a postal code, show ALL items in that group
            // Otherwise show all matching items (no limit)
            if (currentPostalCode != null &&
                currentPostalCode!.isNotEmpty &&
                searchKey != 'zipcode') {
              // Filter to only show items with the same postal code
              final grouped = deduplicatedList.where((item) {
                final itemPostal = item['zipcode']?.toString().trim() ?? '';
                return itemPostal == currentPostalCode!.trim();
              }).toList();

              // If we have grouped results, return all of them
              if (grouped.isNotEmpty) {
                return grouped;
              }
            }

            // Return deduplicated list when no postal code filter
            return deduplicatedList;
          },
          itemBuilder: (context, suggestion) {
            // Build subtitle showing all address data EXCEPT the search field itself
            final List<String> subtitleParts = [];

            // Add province if not searching for it
            if (searchKey != 'province') {
              final province = suggestion['province']?.toString() ?? '';
              if (province.isNotEmpty) subtitleParts.add(province);
            }

            // Add amphoe if not searching for it
            if (searchKey != 'amphoe') {
              final amphoe = suggestion['amphoe']?.toString() ?? '';
              if (amphoe.isNotEmpty) subtitleParts.add(amphoe);
            }

            // Add district if not searching for it
            if (searchKey != 'district') {
              final district = suggestion['district']?.toString() ?? '';
              if (district.isNotEmpty) subtitleParts.add(district);
            }

            // Add zipcode if not searching for it
            if (searchKey != 'zipcode') {
              final zipcode = suggestion['zipcode']?.toString() ?? '';
              if (zipcode.isNotEmpty) subtitleParts.add(zipcode);
            }

            final subtitle = subtitleParts.join(' › ');

            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.gray200, width: 0.5),
                ),
              ),
              child: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                title: Text(
                  suggestion[searchKey].toString(),
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: subtitle.isNotEmpty
                    ? Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.shadyLady,
                        ),
                      )
                    : null,
              ),
            );
          },
          onSelected: onSelected,
          decorationBuilder: (context, child) {
            return Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: child,
              ),
            );
          },
          loadingBuilder: (context) => Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'กำลังโหลด...',
              style: TextStyle(fontSize: 12, color: AppColors.shadyLady),
            ),
          ),
          emptyBuilder: (context) => Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'ไม่พบข้อมูล',
              style: TextStyle(fontSize: 12, color: AppColors.shadyLady),
            ),
          ),
        ),
      ],
    );
  }
}
