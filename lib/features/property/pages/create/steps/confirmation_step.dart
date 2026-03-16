import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yourhome/features/property/widgets/property_detail.dart';
import 'package:yourhome/features/property/bloc/property_form/property_form_bloc.dart';

class PropertyConfirmationStep extends StatelessWidget {
  const PropertyConfirmationStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertyFormBloc, PropertyFormState>(
      builder: (context, state) {
        return ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: PropertyDetail(property: state.toProperty),
        );
      },
    );
  }
}
