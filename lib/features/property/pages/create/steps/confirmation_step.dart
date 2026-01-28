import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/features/property/widgets/property_detail.dart';
import 'package:youragent/features/property/bloc/create_property/create_property_bloc.dart';

class PropertyConfirmationStep extends StatelessWidget {
  const PropertyConfirmationStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreatePropertyBloc, CreatePropertyState>(
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
