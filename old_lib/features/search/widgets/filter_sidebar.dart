import 'package:flutter/material.dart';
import 'package:youragent/core/theme/app_colors.dart';
// import 'search/advanced_filter_dialog.dart'; // TODO: Create this dialog

class FilterSidebar extends StatefulWidget {
  final Function(Map<String, dynamic>)? onSearch;
  final String? initialBedrooms;
  final String? initialBathrooms;
  final String? initialParking;
  final String? initialFloors;
  final Set<String> initialCommonFacilities;
  final Set<String> initialFurniture;
  final Set<String> initialAirConditioning;

  const FilterSidebar({
    super.key,
    this.onSearch,
    this.initialBedrooms,
    this.initialBathrooms,
    this.initialParking,
    this.initialFloors,
    this.initialCommonFacilities = const {},
    this.initialFurniture = const {},
    this.initialAirConditioning = const {},
  });

  @override
  State<FilterSidebar> createState() => _FilterSidebarState();
}

class _FilterSidebarState extends State<FilterSidebar> {
  String? _selectedBedroom;
  String? _selectedBathroom;
  String? _selectedParking;
  String? _selectedFloors;
  final Set<String> _selectedCommonFacilities = {};
  final Set<String> _selectedFurniture = {};
  final Set<String> _selectedAirConditioning = {};
  String? _sortBy;

  @override
  void initState() {
    super.initState();
    _selectedBedroom = widget.initialBedrooms;
    _selectedBathroom = widget.initialBathrooms;
    _selectedParking = widget.initialParking;
    _selectedFloors = widget.initialFloors;
    _selectedCommonFacilities.addAll(widget.initialCommonFacilities);
    _selectedFurniture.addAll(widget.initialFurniture);
    _selectedAirConditioning.addAll(widget.initialAirConditioning);
    _sortBy = 'relevance'; // Default sort
  }

  @override
  void didUpdateWidget(covariant FilterSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialBedrooms != oldWidget.initialBedrooms) {
      _selectedBedroom = widget.initialBedrooms;
    }
    if (widget.initialBathrooms != oldWidget.initialBathrooms) {
      _selectedBathroom = widget.initialBathrooms;
    }
    if (widget.initialParking != oldWidget.initialParking) {
      _selectedParking = widget.initialParking;
    }
    if (widget.initialFloors != oldWidget.initialFloors) {
      _selectedFloors = widget.initialFloors;
    }
    if (widget.initialCommonFacilities != oldWidget.initialCommonFacilities) {
      _selectedCommonFacilities.clear();
      _selectedCommonFacilities.addAll(widget.initialCommonFacilities);
    }
    if (widget.initialFurniture != oldWidget.initialFurniture) {
      _selectedFurniture.clear();
      _selectedFurniture.addAll(widget.initialFurniture);
    }
    if (widget.initialAirConditioning != oldWidget.initialAirConditioning) {
      _selectedAirConditioning.clear();
      _selectedAirConditioning.addAll(widget.initialAirConditioning);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;

    const sortOptions = [
      'relevance',
      'price_low_to_high',
      'price_high_to_low',
      'newest',
    ];

    String labelForSort(String key) {
      switch (key) {
        case 'relevance':
          return localeCode == 'th'
              ? 'เรียงจากความเข้ากันมากไปน้อย'
              : 'Sort by compatibility high to low';
        case 'price_low_to_high':
          return localeCode == 'th'
              ? 'เรียงจากราคาน้อยไปมาก'
              : 'Sort by price low to high';
        case 'price_high_to_low':
          return localeCode == 'th'
              ? 'เรียงจากราคามากไปน้อย'
              : 'Sort by price high to low';
        case 'newest':
          return localeCode == 'th'
              ? 'เรียงจากประกาศใหม่ไปเก่า'
              : 'Sort by newest listings';
        default:
          return localeCode == 'th'
              ? 'เรียงจากความเข้ากันมากไปน้อย'
              : 'Sort by compatibility high to low';
      }
    }

    final currentSortKey = _sortBy ?? 'relevance';

    return Container(
      width: 268,
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Filter Header
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localeCode == 'th' ? 'ตัวกรองการค้นหา' : 'Search Filters',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: const Color(0xFF181D27),
                  ),
                ),
                const SizedBox(height: 8),
                // Sort Dropdown
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE9E9EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currentSortKey,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: Color(0xFF181D27),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 14,
                        color: const Color(0xFF181D27),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _sortBy = value;
                        });
                      },
                      items: sortOptions.map((key) {
                        return DropdownMenuItem<String>(
                          value: key,
                          child: Text(labelForSort(key)),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter Container
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFE9E9EB), width: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Floors Section
                _buildSingleSelectSection(
                  context,
                  title: localeCode == 'th' ? 'จำนวนชั้น' : 'Floors',
                  options: ['1+', '2+', '3+', '4+', '5+'],
                  selectedValue: _selectedFloors,
                  onSelect: (value) {
                    setState(() {
                      _selectedFloors = value;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Bedrooms Section
                _buildSingleSelectSection(
                  context,
                  title: localeCode == 'th' ? 'ห้องนอน' : 'Bedrooms',
                  options: [
                    '1+',
                    '2+',
                    '3+',
                    '4+',
                    '5+',
                    '6+',
                    '7+',
                    '8+',
                    localeCode == 'th' ? 'สตูดิโอ+' : 'Studio+',
                  ],
                  selectedValue: _selectedBedroom,
                  onSelect: (value) {
                    setState(() {
                      _selectedBedroom = value;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Bathrooms Section
                _buildSingleSelectSection(
                  context,
                  title: localeCode == 'th' ? 'ห้องน้ำ' : 'Bathrooms',
                  options: ['1+', '2+', '3+', '4+', '5+', '6+', '7+', '8+'],
                  selectedValue: _selectedBathroom,
                  onSelect: (value) {
                    setState(() {
                      _selectedBathroom = value;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Parking Section
                _buildSingleSelectSection(
                  context,
                  title: localeCode == 'th' ? 'ที่จอดรถ' : 'Parking',
                  options: ['1+', '2+', '3+', '4+', '5+', '6+', '7+', '8+'],
                  selectedValue: _selectedParking,
                  onSelect: (value) {
                    setState(() {
                      _selectedParking = value;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Common Facilities Section (Multi-select)
                _buildMultiSelectSection(
                  context,
                  title: localeCode == 'th' ? 'ส่วนกลาง' : 'Common Facilities',
                  subtitle: localeCode == 'th'
                      ? '(เลือกได้มากกว่า 1)'
                      : '(Multiple selection)',
                  options: [
                    {
                      'key': 'fitness',
                      'label': localeCode == 'th' ? 'ฟิตเนส' : 'Fitness',
                    },
                    {
                      'key': 'pool',
                      'label': localeCode == 'th'
                          ? 'สระว่ายน้ำ'
                          : 'Swimming Pool',
                    },
                    {
                      'key': 'lawn',
                      'label': localeCode == 'th' ? 'สนามหญ้า' : 'Lawn',
                    },
                    {
                      'key': 'coworking',
                      'label': localeCode == 'th'
                          ? 'Co-working space'
                          : 'Co-working space',
                    },
                    {
                      'key': 'playground',
                      'label': localeCode == 'th'
                          ? 'สนามเด็กเล่น'
                          : 'Playground',
                    },
                    {
                      'key': 'sports',
                      'label': localeCode == 'th' ? 'สนามกีฬา' : 'Sports Field',
                    },
                    {
                      'key': 'security',
                      'label': localeCode == 'th'
                          ? 'เจ้าหน้าที่ รปภ.'
                          : 'Security Guard',
                    },
                  ],
                  selectedValues: _selectedCommonFacilities,
                  onToggle: (key) {
                    setState(() {
                      if (_selectedCommonFacilities.contains(key)) {
                        _selectedCommonFacilities.remove(key);
                      } else {
                        _selectedCommonFacilities.add(key);
                      }
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Furniture Section (Multi-select)
                _buildMultiSelectSection(
                  context,
                  title: localeCode == 'th' ? 'เฟอร์นิเจอร์' : 'Furniture',
                  subtitle: localeCode == 'th'
                      ? '(เลือกได้มากกว่า 1)'
                      : '(Multiple selection)',
                  options: [
                    {
                      'key': 'none',
                      'label': localeCode == 'th' ? 'ไม่มี' : 'None',
                    },
                    {
                      'key': 'partial',
                      'label': localeCode == 'th' ? 'มีบางส่วน' : 'Partial',
                    },
                    {
                      'key': 'full',
                      'label': localeCode == 'th'
                          ? 'ตกแต่งครบ'
                          : 'Fully Furnished',
                    },
                  ],
                  selectedValues: _selectedFurniture,
                  onToggle: (key) {
                    setState(() {
                      if (_selectedFurniture.contains(key)) {
                        _selectedFurniture.remove(key);
                      } else {
                        _selectedFurniture.add(key);
                      }
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Air Conditioning Section (Multi-select)
                _buildMultiSelectSection(
                  context,
                  title: localeCode == 'th'
                      ? 'เครื่องปรับอากาศ'
                      : 'Air Conditioning',
                  subtitle: localeCode == 'th'
                      ? '(เลือกได้มากกว่า 1)'
                      : '(Multiple selection)',
                  options: [
                    {
                      'key': 'none',
                      'label': localeCode == 'th' ? 'ไม่มี' : 'None',
                    },
                    {
                      'key': 'some',
                      'label': localeCode == 'th'
                          ? 'ติดตั้งบางห้อง'
                          : 'Some Rooms',
                    },
                    {
                      'key': 'most',
                      'label': localeCode == 'th'
                          ? 'ติดตั้งเกือบทุกห้อง'
                          : 'Most Rooms',
                    },
                    {
                      'key': 'all',
                      'label': localeCode == 'th'
                          ? 'ติดตั้งครบทุกห้อง'
                          : 'All Rooms',
                    },
                  ],
                  selectedValues: _selectedAirConditioning,
                  onToggle: (key) {
                    setState(() {
                      if (_selectedAirConditioning.contains(key)) {
                        _selectedAirConditioning.remove(key);
                      } else {
                        _selectedAirConditioning.add(key);
                      }
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Advanced Filters Link
                Center(
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement AdvancedFilterDialog
                      /*
                      showDialog(
                        context: context,
                        builder: (context) => AdvancedFilterDialog(
                          onApply: (filter) {
                            // Sync with current filters
                            // You can update the state here if needed
                            Navigator.of(context).pop();
                          },
                        ),
                      );
                      */
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      localeCode == 'th' ? 'ตัวกรองทั้งหมด' : 'All Filters',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 14,
                        color: const Color(0xFF717680),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Button
          SizedBox(
            width: 268,
            child: OutlinedButton(
              onPressed: () {
                widget.onSearch?.call({
                  'bedrooms': _selectedBedroom,
                  'bathrooms': _selectedBathroom,
                  'parking': _selectedParking,
                  'floors': _selectedFloors,
                  'commonFacilities': _selectedCommonFacilities.toList(),
                  'furniture': _selectedFurniture.toList(),
                  'airConditioning': _selectedAirConditioning.toList(),
                  'sortBy': _sortBy,
                });
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.white,
                side: const BorderSide(color: Color(0xFFE9E9EB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text(
                localeCode == 'th' ? 'ค้นหา' : 'Search',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF717680),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleSelectSection(
    BuildContext context, {
    required String title,
    required List<String> options,
    String? selectedValue,
    required ValueChanged<String?> onSelect,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1C1C1C),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValue == option;
            // Use 36x36 for short options (like '1+', '2+'), flexible for longer text (like 'สตูดิโอ+')
            final chip = ChoiceChip(
              label: Text(
                option,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: isSelected ? AppColors.white : const Color(0xFF181D27),
                ),
              ),
              selected: isSelected,
              onSelected: (_) {
                // Toggle: if already selected, deselect (pass null), otherwise select
                onSelect(isSelected ? null : option);
              },
              showCheckmark: false,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
              selectedColor: const Color(0xFFE03121),
              backgroundColor: AppColors.white,
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFFE03121)
                    : const Color(0xFFE9E9EB),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            );

            return chip;
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMultiSelectSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<Map<String, String>> options,
    required Set<String> selectedValues,
    required ValueChanged<String> onToggle,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF181D27),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.baseGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final key = option['key']!;
            final label = option['label']!;
            final isSelected = selectedValues.contains(key);
            return FilterChip(
              label: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: isSelected ? AppColors.white : const Color(0xFF181D27),
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onToggle(key),
              showCheckmark: false,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
              selectedColor: const Color(0xFFE03121),
              backgroundColor: AppColors.white,
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFFE03121)
                    : const Color(0xFFE9E9EB),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
