import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yourhome/core/theme/app_colors.dart';
import 'package:yourhome/domain/entities/property.dart';
import 'package:yourhome/features/property/bloc/property_form/property_form_bloc.dart';
import 'package:yourhome/widgets/badges/app_badge.dart';
import 'package:yourhome/l10n/app_localizations.dart';

class PropertyTypeStep extends StatelessWidget {
  final int? step;
  const PropertyTypeStep({super.key, this.step});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  AppLocalizations.of(context).propertyTypeLabel,
                  style: GoogleFonts.anuphan(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (step != null)
                AppBadge(color: BadgeColor.default_, label: '$step/5'),
            ],
          ),
          const SizedBox(height: 24),
          const _PropertyTypeGrid(),
          const SizedBox(height: 16),
          BlocBuilder<PropertyFormBloc, PropertyFormState>(
            buildWhen: (prev, curr) =>
                prev.showErrors != curr.showErrors ||
                prev.selectedPropertyType != curr.selectedPropertyType,
            builder: (context, state) {
              if (state.showErrors && state.selectedPropertyType == null) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    AppLocalizations.of(context).this_field_required,
                    style: GoogleFonts.anuphan(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

class _PropertyTypeGrid extends StatelessWidget {
  const _PropertyTypeGrid();

  static final List<Map<String, dynamic>> _propertyTypes = [
    {
      'type': PropertyType.house,
      'image': 'assets/images/property_types/house.jpg',
    },
    {
      'type': PropertyType.condo,
      'image': 'assets/images/property_types/condo.jpg',
    },
    {
      'type': PropertyType.townhome,
      'image': 'assets/images/property_types/townhome.jpg',
    },
    {
      'type': PropertyType.apartment,
      'image': 'assets/images/property_types/apartment.jpg',
    },
    {
      'type': PropertyType.homeOffice,
      'image': 'assets/images/property_types/home_office.jpg',
    },
    {
      'type': PropertyType.poolVilla,
      'image': 'assets/images/property_types/pool_villa.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertyFormBloc, PropertyFormState>(
      buildWhen: (previous, current) {
        final bool hasDifferentSelection =
            previous.selectedPropertyType != current.selectedPropertyType;
        if (hasDifferentSelection) {
          context.read<PropertyFormBloc>().add(
            PropertyFormDeveloperChanged(null),
          );
          context.read<PropertyFormBloc>().add(
            PropertyFormDeveloperChanged(null),
          );
        }
        return hasDifferentSelection;
      },
      builder: (context, state) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: _propertyTypes.length,
          itemBuilder: (context, index) {
            final typeData = _propertyTypes[index];
            final typeEnum = typeData['type'] as PropertyType;
            final hasSelection = state.selectedPropertyType != null;
            final isSelected = state.selectedPropertyType == typeEnum;

            return _PropertyTypeCard(
              name: typeEnum.label,
              imagePath: typeData['image']!,
              isSelected: isSelected,
              hasSelection: hasSelection,
              onTap: () {
                context.read<PropertyFormBloc>().add(
                  PropertyFormTypeSelected(typeEnum),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _PropertyTypeCard extends StatelessWidget {
  final String name;
  final String imagePath;
  final bool isSelected;
  final bool hasSelection;
  final VoidCallback onTap;

  const _PropertyTypeCard({
    required this.name,
    required this.imagePath,
    required this.isSelected,
    required this.hasSelection,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: hasSelection && !isSelected ? 0.5 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.baseLightGrey,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              else
                const BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 4,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                  child: Image.asset(imagePath, fit: BoxFit.cover),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.anuphan(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.baseDarkGrey,
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
