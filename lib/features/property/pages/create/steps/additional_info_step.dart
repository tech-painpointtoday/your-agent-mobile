import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../features/property/bloc/property_form/property_form_bloc.dart';
import '../../../../../widgets/form_fields/app_text_form_field.dart';
import '../../../../../widgets/inputs/app_selectable_grid.dart';
import '../../../../../widgets/inputs/app_multi_select_chips.dart';
import 'package:youragent/l10n/app_localizations.dart';

class AdditionalInfoStep extends StatefulWidget {
  final int? step;
  const AdditionalInfoStep({super.key, this.step});

  @override
  State<AdditionalInfoStep> createState() => _AdditionalInfoStepState();
}

class _AdditionalInfoStepState extends State<AdditionalInfoStep> {
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final state = context.read<PropertyFormBloc>().state;
    _descriptionController = TextEditingController(
      text: state.description ?? '',
    );

    if (state.specificationFilters.multiSelect.isEmpty) {
      context.read<PropertyFormBloc>().add(PropertyFormFiltersFetched());
    }

    _descriptionController.addListener(() {
      context.read<PropertyFormBloc>().add(
        PropertyFormDataUpdated(
          key: 'description',
          value: _descriptionController.text,
        ),
      );
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PropertyFormBloc, PropertyFormState>(
      listenWhen: (previous, current) =>
          previous.description != current.description,
      listener: (context, state) {
        if (state.description != _descriptionController.text) {
          _descriptionController.text = state.description ?? '';
        }
      },
      builder: (context, state) {
        return Form(
          autovalidateMode: state.showErrors
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ... (lines 67-137)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        AppLocalizations.of(context).additional_info_section,
                        style: GoogleFonts.anuphan(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (widget.step != null)
                      AppBadge(
                        color: BadgeColor.default_,
                        label: '${widget.step}/5',
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Property Style
                Builder(
                  builder: (context) {
                    final styleFilter = state.specificationFilters.singleSelect
                        .where((f) => f.key == 'style')
                        .firstOrNull;

                    if (styleFilter == null ||
                        styleFilter.optionsWithImages.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    final styles = styleFilter.optionsWithImages.map((opt) {
                      return StyleProperty(
                        id: opt.value,
                        nameEn: opt.value,
                        nameTh: opt.labelTh,
                        imageUrl: opt.imageUrl,
                        value: opt.value,
                      );
                    }).toList();

                    return AppSelectableGrid<StyleProperty>(
                      label: AppLocalizations.of(context).propertyStyleLabel,
                      value: state.propertyStyle,
                      items: styles.map((style) {
                        return GridItem(
                          label:
                              Localizations.localeOf(context).languageCode ==
                                  'th'
                              ? style.nameTh
                              : style.nameEn,
                          value: style,
                          imagePath: style.imagePath,
                          imageUrl: style.imageUrl,
                        );
                      }).toList(),
                      onChanged: (val) => context.read<PropertyFormBloc>().add(
                        PropertyFormStyleChanged(val),
                      ),
                      isSelected: (itemValue, currentValue) {
                        if (currentValue == null) return false;
                        return itemValue.id == currentValue.id ||
                            itemValue.value == currentValue.value;
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Dynamic Multi-Select Filters or Fallback
                if (state.specificationFilters.multiSelect.isNotEmpty)
                  ...state.specificationFilters.multiSelect.map((filter) {
                    return Column(
                      children: [
                        AppMultiSelectChips<String>(
                          label: filter.label,
                          values: state.specificationValues[filter.key] ?? [],
                          options: filter.options,
                          onSelected: (val) =>
                              context.read<PropertyFormBloc>().add(
                                PropertyFormDynamicMultiSelectToggled(
                                  filter.key,
                                  val,
                                ),
                              ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  }),

                // Description
                AppTextFormField(
                  label: AppLocalizations.of(
                    context,
                  ).additional_details_section,
                  controller: _descriptionController,
                  maxLines: 5,
                  isRequired: true,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return AppLocalizations.of(context).this_field_required;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }
}
