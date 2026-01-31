import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import 'package:youragent/widgets/inputs/app_text_field.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_bloc.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_event.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_state.dart';

class AdditionalConditionsStep extends StatefulWidget {
  const AdditionalConditionsStep({super.key});

  @override
  State<AdditionalConditionsStep> createState() =>
      _AdditionalConditionsStepState();
}

class _AdditionalConditionsStepState extends State<AdditionalConditionsStep> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContractFormBloc, ContractFormState>(
      builder: (context, state) {
        return SizedBox(
          height: double.infinity,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppBadge(
                        label: 'เงื่อนไขสัญญาเพิ่มเติม',
                        fontSize: 16,
                        color: BadgeColor.blue,
                      ),
                      AppBadge(
                        color: BadgeColor.default_,
                        fontSize: 16,
                        label: '${state.step}/7',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: 'เงื่อนไขสัญญาเพิ่มเติม',
                    hintText: 'ระบุเงื่อนไข...',
                    maxLines: 15,
                    showScrollbar: true,
                    scrollController: _scrollController,
                    controller:
                        TextEditingController(text: state.additionalConditions)
                          ..selection = TextSelection.fromPosition(
                            TextPosition(
                              offset: state.additionalConditions.length,
                            ),
                          ),
                    onChanged: (value) {
                      context.read<ContractFormBloc>().add(
                        ContractFormAdditionalConditionsUpdated(value),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
