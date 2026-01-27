import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/data/models/condo_project_model.dart';
import 'package:youragent/data/models/developer_model.dart';
import 'package:youragent/domain/entities/property_enums.dart';
import 'package:youragent/features/property/bloc/property_form_bloc.dart';
import 'package:youragent/features/property/bloc/property_form_event.dart';
import 'package:youragent/features/property/bloc/property_form_state.dart';
import 'package:youragent/features/property/widgets/property_form_inputs.dart';
import 'package:youragent/widgets/form_fields/app_form_text_field.dart';
import 'package:youragent/l10n/app_localizations.dart';

/// Property Type Details Section Widget
/// Displays Condo or House specific input fields based on selected property type
class PropertyTypeDetailsSection extends StatelessWidget {
  final bool isReadOnly;
  final AppLocalizations l10n;

  const PropertyTypeDetailsSection({
    super.key,
    required this.isReadOnly,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertyFormBloc, PropertyFormState>(
      builder: (context, state) {
        if (state is! PropertyFormData) {
          return const SizedBox.shrink();
        }

        final selectedType = state.selectedType;
        if (selectedType == PropertyType.condominium ||
            selectedType == PropertyType.penthouse ||
            selectedType == PropertyType.studio) {
          return _buildCondoInputs(context, state);
        } else if (selectedType == PropertyType.house ||
            selectedType == PropertyType.townhouse ||
            selectedType == PropertyType.villa ||
            selectedType == PropertyType.duplex) {
          return _buildHouseInputs(context, state);
        }

        return const SizedBox.shrink(); // Hide for Land/Commercial/etc.
      },
    );
  }

  /// Build Condo-specific input fields
  Widget _buildCondoInputs(BuildContext context, PropertyFormData state) {
    // Controllers for condo fields
    final towerController = TextEditingController(text: state.tower ?? '');
    final floorController = TextEditingController(text: state.condoFloor ?? '');
    final unitNoController = TextEditingController(text: state.unitNo ?? '');
    final projectController = TextEditingController(
      text: state.selectedCondoProject?.name ?? '',
    );

    return PropertyFormSection(
      title: 'รายละเอียดคอนโด',
      icon: 'assets/icons/form/info.svg',
      iconColor: const Color(0xFF1743C7),
      l10n: l10n,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Developer Search (TypeAhead) - Optional
          FormFieldLabel(label: 'ผู้พัฒนาโครงการ', isRequired: false),
          const SizedBox(height: 8),
          TypeAheadField<Developer>(
            key: ValueKey('developer_${state.selectedDeveloper?.id ?? 'none'}'),
            builder: (context, controller, focusNode) {
              // Initialize controller with selected developer name
              final initialText = state.selectedDeveloper?.nameTh ?? '';
              if (controller.text != initialText) {
                controller.text = initialText;
              }
              return TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: !isReadOnly,
                decoration: InputDecoration(
                  hintText: 'ค้นหาผู้พัฒนาโครงการ',
                  hintStyle: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.baseGrey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.baseGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.baseGrey),
                  ),
                  suffixIcon: isReadOnly
                      ? const Icon(
                          Icons.search,
                          size: 20,
                          color: Color(0xFFA4A7AE),
                        )
                      : const Icon(
                          Icons.search,
                          size: 20,
                          color: AppColors.baseDarkGrey,
                        ),
                  filled: isReadOnly,
                  fillColor: isReadOnly ? const Color(0xFFFFFFFF) : null,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
              );
            },
            suggestionsCallback: (pattern) async {
              if (isReadOnly) return [];
              try {
                // Use already loaded developers from state, or fetch if needed
                final developers = state.developers.isNotEmpty
                    ? state.developers
                    : await DependencyInjection.propertyApiService
                          .getDevelopers();

                List<Developer> results;
                if (pattern.isEmpty) {
                  // Show all developers sorted by name when focused
                  results = List<Developer>.from(developers);
                } else {
                  // Filter developers by pattern (search in both Thai and English names)
                  final patternLower = pattern.toLowerCase();
                  results = developers.where((dev) {
                    return dev.nameTh.toLowerCase().contains(patternLower) ||
                        dev.nameEn.toLowerCase().contains(patternLower) ||
                        dev.slug.toLowerCase().contains(patternLower);
                  }).toList();
                }

                // Sort A-Z by English name when available, otherwise Thai name
                results.sort((a, b) {
                  final aKey = (a.nameEn.isNotEmpty ? a.nameEn : a.nameTh)
                      .toLowerCase();
                  final bKey = (b.nameEn.isNotEmpty ? b.nameEn : b.nameTh)
                      .toLowerCase();
                  return aKey.compareTo(bKey);
                });

                return results;
              } catch (e) {
                debugPrint('Error searching developers: $e');
                return [];
              }
            },
            itemBuilder: (context, developer) {
              return ListTile(
                dense: true,
                title: Text(
                  developer.nameTh,
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: developer.nameEn.isNotEmpty
                    ? Text(
                        developer.nameEn,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.shadyLady,
                        ),
                      )
                    : null,
              );
            },
            onSelected: isReadOnly
                ? null
                : (Developer developer) {
                    context.read<PropertyFormBloc>().add(
                      PropertyFormDeveloperChanged(developer),
                    );
                  },
            emptyBuilder: (context) => Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'ไม่พบผู้พัฒนาโครงการ',
                style: TextStyle(fontSize: 12, color: AppColors.shadyLady),
              ),
            ),
            loadingBuilder: (context) => Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'กำลังค้นหา...',
                style: TextStyle(fontSize: 12, color: AppColors.shadyLady),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Condo Project Search (TypeAhead) - Optional
          FormFieldLabel(label: 'โครงการคอนโด', isRequired: false),
          const SizedBox(height: 8),
          TypeAheadField<CondoProject>(
            controller: projectController,
            builder: (context, controller, focusNode) => TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: !isReadOnly,
              decoration: InputDecoration(
                hintText: 'ค้นหาโครงการคอนโด',
                hintStyle: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.baseGrey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.baseGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.baseGrey),
                ),
                suffixIcon: isReadOnly
                    ? const Icon(
                        Icons.search,
                        size: 20,
                        color: Color(0xFFA4A7AE),
                      )
                    : const Icon(
                        Icons.search,
                        size: 20,
                        color: AppColors.baseDarkGrey,
                      ),
                filled: isReadOnly,
                fillColor: isReadOnly ? const Color(0xFFFFFFFF) : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
            ),
            suggestionsCallback: (pattern) async {
              if (isReadOnly) return [];

              // Use condo projects already loaded into BLoC state.
              // Do not call API again within the widget lifecycle.
              var projects = List<CondoProject>.from(state.condoProjects);

              // Filter by selected developer if any
              if (state.selectedDeveloper != null) {
                projects = projects
                    .where((p) => p.developerId == state.selectedDeveloper!.id)
                    .toList();
              }

              // Filter by text pattern if provided
              if (pattern.isNotEmpty) {
                final lower = pattern.toLowerCase();
                projects = projects
                    .where((p) => p.name.toLowerCase().contains(lower))
                    .toList();
              }

              // Sort by name A–Z
              projects.sort((a, b) => a.name.compareTo(b.name));
              return projects;
            },
            itemBuilder: (context, project) {
              return ListTile(
                dense: true,
                title: Text(project.name, style: const TextStyle(fontSize: 14)),
              );
            },
            onSelected: isReadOnly
                ? null
                : (CondoProject project) {
                    context.read<PropertyFormBloc>().add(
                      PropertyFormCondoProjectChanged(project),
                    );
                  },
            emptyBuilder: (context) => Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'ไม่พบโครงการ',
                style: TextStyle(fontSize: 12, color: AppColors.shadyLady),
              ),
            ),
            loadingBuilder: (context) => Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'กำลังค้นหา...',
                style: TextStyle(fontSize: 12, color: AppColors.shadyLady),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tower, Floor, Unit No Row
          Row(
            children: [
              Expanded(
                child: AppFormTextField(
                  controller: towerController,
                  label: 'ตึก/อาคาร',
                  l10n: l10n,
                  isReadOnly: isReadOnly,
                  isRequired: false,
                  onChanged: isReadOnly
                      ? null
                      : (value) {
                          context.read<PropertyFormBloc>().add(
                            PropertyFormCondoFieldUpdated(
                              field: 'tower',
                              value: value,
                            ),
                          );
                        },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppFormTextField(
                  controller: floorController,
                  label: 'ชั้น',
                  l10n: l10n,
                  isReadOnly: isReadOnly,
                  isRequired: false,
                  onChanged: isReadOnly
                      ? null
                      : (value) {
                          context.read<PropertyFormBloc>().add(
                            PropertyFormCondoFieldUpdated(
                              field: 'floor',
                              value: value,
                            ),
                          );
                        },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppFormTextField(
                  controller: unitNoController,
                  label: 'เลขที่ห้อง',
                  l10n: l10n,
                  isReadOnly: isReadOnly,
                  isRequired: false,
                  onChanged: isReadOnly
                      ? null
                      : (value) {
                          context.read<PropertyFormBloc>().add(
                            PropertyFormCondoFieldUpdated(
                              field: 'unitNo',
                              value: value,
                            ),
                          );
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build House-specific input fields
  Widget _buildHouseInputs(BuildContext context, PropertyFormData state) {
    // Controllers for house fields
    final villageNameController = TextEditingController(
      text: state.villageName ?? '',
    );
    final mooController = TextEditingController(text: state.moo ?? '');
    final notesController = TextEditingController(text: state.houseNotes ?? '');

    return PropertyFormSection(
      title: 'รายละเอียดบ้าน',
      icon: 'assets/icons/form/info.svg',
      iconColor: const Color(0xFF1743C7),
      l10n: l10n,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Village Name
              Expanded(
                child: AppFormTextField(
                  controller: villageNameController,
                  label: 'ชื่อหมู่บ้าน/โครงการ',
                  l10n: l10n,
                  isReadOnly: isReadOnly,
                  isRequired: false,
                  onChanged: isReadOnly
                      ? null
                      : (value) {
                          context.read<PropertyFormBloc>().add(
                            PropertyFormHouseFieldUpdated(
                              field: 'villageName',
                              value: value,
                            ),
                          );
                        },
                ),
              ),

              SizedBox(width: 16),
              // Corner Plot Switch
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormFieldLabel(label: 'มุมถนน', isRequired: false),
                  const SizedBox(height: 8),
                  Switch(
                    value: state.isCornerPlot ?? false,
                    onChanged: isReadOnly
                        ? null
                        : (value) {
                            context.read<PropertyFormBloc>().add(
                              PropertyFormHouseFieldUpdated(
                                field: 'isCornerPlot',
                                value: value,
                              ),
                            );
                          },
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                    inactiveThumbColor: const Color(0xFFA4A7AE),
                    inactiveTrackColor: const Color(0xFFE9EAEB),
                    trackOutlineColor: WidgetStateProperty.all(
                      const Color(0xFFE9EAEB),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Moo, House Subtype, Parking Type Row
          Row(
            children: [
              Expanded(
                child: AppFormTextField(
                  controller: mooController,
                  label: 'หมู่',
                  l10n: l10n,
                  isReadOnly: isReadOnly,
                  isRequired: false,
                  onChanged: isReadOnly
                      ? null
                      : (value) {
                          context.read<PropertyFormBloc>().add(
                            PropertyFormHouseFieldUpdated(
                              field: 'moo',
                              value: value,
                            ),
                          );
                        },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PropertyDropdownField<String>(
                  label: 'ประเภทบ้าน',
                  value: state.houseSubtype,
                  l10n: l10n,
                  isReadOnly: isReadOnly,
                  isRequired: false,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('เลือกประเภท'),
                    ),
                    const DropdownMenuItem<String>(
                      value: 'detached',
                      child: Text('บ้านเดี่ยว'),
                    ),
                    const DropdownMenuItem<String>(
                      value: 'semi',
                      child: Text('บ้านครึ่งหลัง'),
                    ),
                    const DropdownMenuItem<String>(
                      value: 'townhouse',
                      child: Text('ทาวน์เฮาส์'),
                    ),
                  ],
                  onChanged: isReadOnly
                      ? (_) {}
                      : (value) {
                          context.read<PropertyFormBloc>().add(
                            PropertyFormHouseFieldUpdated(
                              field: 'houseSubtype',
                              value: value,
                            ),
                          );
                        },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PropertyDropdownField<String>(
                  label: 'ประเภทที่จอดรถ',
                  value: state.parkingType,
                  l10n: l10n,
                  isReadOnly: isReadOnly,
                  isRequired: false,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('เลือกประเภท'),
                    ),
                    const DropdownMenuItem<String>(
                      value: 'covered',
                      child: Text('มีหลังคา'),
                    ),
                    const DropdownMenuItem<String>(
                      value: 'open',
                      child: Text('ไม่มีหลังคา'),
                    ),
                    const DropdownMenuItem<String>(
                      value: 'garage',
                      child: Text('โรงรถ'),
                    ),
                  ],
                  onChanged: isReadOnly
                      ? (_) {}
                      : (value) {
                          context.read<PropertyFormBloc>().add(
                            PropertyFormHouseFieldUpdated(
                              field: 'parkingType',
                              value: value,
                            ),
                          );
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Notes (Multiline)
          AppFormTextField(
            controller: notesController,
            label: 'หมายเหตุ',
            l10n: l10n,
            maxLines: 3,
            isReadOnly: isReadOnly,
            isRequired: false,
            onChanged: isReadOnly
                ? null
                : (value) {
                    context.read<PropertyFormBloc>().add(
                      PropertyFormHouseFieldUpdated(
                        field: 'notes',
                        value: value,
                      ),
                    );
                  },
          ),
        ],
      ),
    );
  }
}
