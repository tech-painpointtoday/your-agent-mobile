import 'package:flutter/material.dart';

/// Configuration for a field in the form grid
class FormGridField {
  final Widget child;
  final int colSpan; // 1, 2, 3, or 4 columns

  const FormGridField({required this.child, this.colSpan = 1});
}

/// A responsive 4-column grid layout for form fields
class ContractFormGrid extends StatelessWidget {
  final List<FormGridField> fields;
  final double spacing;
  final double runSpacing;

  const ContractFormGrid({super.key, required this.fields, this.spacing = 16, this.runSpacing = 16});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final columnWidth = (availableWidth - spacing * 3) / 4;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: fields.map((field) {
            final fieldWidth = (columnWidth * field.colSpan) + (spacing * (field.colSpan - 1));
            return SizedBox(width: fieldWidth, child: field.child);
          }).toList(),
        );
      },
    );
  }
}
