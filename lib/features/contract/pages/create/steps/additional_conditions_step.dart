import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yourhome/widgets/badges/app_badge.dart';
import 'package:yourhome/widgets/inputs/app_text_field.dart';
import 'package:yourhome/features/contract/bloc/contract_form/contract_form_bloc.dart';
import 'package:yourhome/features/contract/bloc/contract_form/contract_form_event.dart';
import 'package:yourhome/features/contract/bloc/contract_form/contract_form_state.dart';
import 'package:yourhome/core/extensions/l10n_extensions.dart';

class AdditionalConditionsStep extends StatefulWidget {
  final bool hideHeader;

  const AdditionalConditionsStep({super.key, this.hideHeader = false});

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
                  if (!widget.hideHeader)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppBadge(
                          color: BadgeColor.blue,
                          label: context.l10n.additional_conditions,
                          fontSize: 16,
                        ),
                        AppBadge(
                          color: BadgeColor.default_,
                          label: '${state.step}/8',
                          fontSize: 16,
                        ),
                      ],
                    ),
                  if (!widget.hideHeader) const SizedBox(height: 24),
                  AppTextField(
                    label: context.l10n.additional_conditions,
                    hintText: context.l10n.additionalConditionsHint,
                    maxLines: 8,
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
