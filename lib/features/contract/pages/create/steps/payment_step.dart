import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/contract_type.dart';
import 'package:youragent/domain/entities/contract_create_data.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_bloc.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_event.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_state.dart';
import 'package:youragent/utils/currency_input_formatter.dart';
import 'package:youragent/widgets/inputs/app_text_field.dart';
import 'package:youragent/widgets/inputs/app_dropdown.dart';
import 'package:youragent/widgets/badges/app_badge.dart';

class PaymentStep extends StatefulWidget {
  final bool hideHeader;

  const PaymentStep({super.key, this.hideHeader = false});

  @override
  State<PaymentStep> createState() => _PaymentStepState();
}

class _PaymentStepState extends State<PaymentStep> {
  final _currencyFormatter = CurrencyInputFormatter();
  late final TextEditingController _bankBranchController;

  @override
  void initState() {
    super.initState();
    final state = context.read<ContractFormBloc>().state;
    _bankBranchController = TextEditingController(text: state.bankBranch);
  }

  @override
  void dispose() {
    _bankBranchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContractFormBloc, ContractFormState>(
      builder: (context, state) {
        final isBuy = state.contractType == ContractType.buy;
        final isRent = state.contractType == ContractType.rent;

        return SizedBox(
          height: double.infinity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                if (!widget.hideHeader)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppBadge(
                        label: 'การชำระเงิน',
                        fontSize: 16,
                        color: BadgeColor.blue,
                      ),
                      AppBadge(
                        color: BadgeColor.default_,
                        label: '${state.step}/7',
                        fontSize: 16,
                      ),
                    ],
                  ),
                if (!widget.hideHeader) const SizedBox(height: 32),

                if (isBuy) _buildBuyFields(context, state),
                if (isRent) _buildRentFields(context, state),

                const SizedBox(height: 24),
                _buildPaymentMethodFields(context, state),

                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBuyFields(BuildContext context, ContractFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'ราคาขาย',
          isRequired: true,
          hintText: '0',
          suffix: _buildSuffix('บาท'),
          keyboardType: TextInputType.number,
          inputFormatters: [_currencyFormatter],
          controller:
              TextEditingController(
                  text: state.price > 0 ? _formatCurrency(state.price) : '',
                )
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: _formatCurrency(state.price).length),
                ),
          onChanged: (val) {
            final price = double.tryParse(val.replaceAll(',', '')) ?? 0;
            context.read<ContractFormBloc>().add(
              ContractFormPriceUpdated(price),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRentFields(BuildContext context, ContractFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                label: 'ราคาเช่า',
                isRequired: true,
                hintText: '0',
                suffix: _buildSuffix('บาท'),
                keyboardType: TextInputType.number,
                inputFormatters: [_currencyFormatter],
                controller:
                    TextEditingController(
                        text: state.price > 0
                            ? _formatCurrency(state.price)
                            : '',
                      )
                      ..selection = TextSelection.fromPosition(
                        TextPosition(
                          offset: _formatCurrency(state.price).length,
                        ),
                      ),
                onChanged: (val) {
                  final price = double.tryParse(val.replaceAll(',', '')) ?? 0;
                  context.read<ContractFormBloc>().add(
                    ContractFormPriceUpdated(price),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppTextField(
                label: 'ค่าส่วนกลาง',
                isRequired: true,
                hintText: '0',
                suffix: _buildSuffix('บาท'),
                keyboardType: TextInputType.number,
                inputFormatters: [_currencyFormatter],
                controller:
                    TextEditingController(
                        text: state.commonFee > 0
                            ? _formatCurrency(state.commonFee)
                            : '',
                      )
                      ..selection = TextSelection.fromPosition(
                        TextPosition(
                          offset: _formatCurrency(state.commonFee).length,
                        ),
                      ),
                onChanged: (val) {
                  final fee = double.tryParse(val.replaceAll(',', '')) ?? 0;
                  context.read<ContractFormBloc>().add(
                    ContractFormCommonFeeUpdated(fee),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                label: 'ค่าบริการอื่น',
                isRequired: true,
                hintText: '0',
                suffix: _buildSuffix('บาท'),
                keyboardType: TextInputType.number,
                inputFormatters: [_currencyFormatter],
                controller:
                    TextEditingController(
                        text: state.otherServiceFee > 0
                            ? _formatCurrency(state.otherServiceFee)
                            : '',
                      )
                      ..selection = TextSelection.fromPosition(
                        TextPosition(
                          offset: _formatCurrency(state.otherServiceFee).length,
                        ),
                      ),
                onChanged: (val) {
                  final fee = double.tryParse(val.replaceAll(',', '')) ?? 0;
                  context.read<ContractFormBloc>().add(
                    ContractFormOtherServiceFeeUpdated(fee),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppTextField(
                label: 'รวมยอดชำระรายเดือน',
                readOnly: true,
                hintText: '0',
                suffix: _buildSuffix('บาท'),
                controller: TextEditingController(
                  text: state.totalMonthlyPayment > 0
                      ? _formatCurrency(state.totalMonthlyPayment)
                      : '0',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                label: 'ค่าเช่าล่วงหน้า',
                isRequired: true,
                hintText: '0',
                suffix: _buildSuffix('บาท'),
                keyboardType: TextInputType.number,
                inputFormatters: [_currencyFormatter],
                controller:
                    TextEditingController(
                        text: state.advanceRent > 0
                            ? _formatCurrency(state.advanceRent)
                            : '',
                      )
                      ..selection = TextSelection.fromPosition(
                        TextPosition(
                          offset: _formatCurrency(state.advanceRent).length,
                        ),
                      ),
                onChanged: (val) {
                  final rent = double.tryParse(val.replaceAll(',', '')) ?? 0;
                  context.read<ContractFormBloc>().add(
                    ContractFormAdvanceRentUpdated(rent),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppTextField(
                label: 'เงินประกันความเสียหาย',
                isRequired: true,
                hintText: '0',
                suffix: _buildSuffix('บาท'),
                keyboardType: TextInputType.number,
                inputFormatters: [_currencyFormatter],
                controller:
                    TextEditingController(
                        text: state.securityDeposit > 0
                            ? _formatCurrency(state.securityDeposit)
                            : '',
                      )
                      ..selection = TextSelection.fromPosition(
                        TextPosition(
                          offset: _formatCurrency(state.securityDeposit).length,
                        ),
                      ),
                onChanged: (val) {
                  final deposit = double.tryParse(val.replaceAll(',', '')) ?? 0;
                  context.read<ContractFormBloc>().add(
                    ContractFormSecurityDepositUpdated(deposit),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        AppTextField(
          label: 'รวมยอดชำระก่อนเข้าอยู่',
          readOnly: true,
          hintText: '0',
          suffix: _buildSuffix('บาท'),
          controller: TextEditingController(
            text: state.totalUpfrontPayment > 0
                ? _formatCurrency(state.totalUpfrontPayment)
                : '0',
          ),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                label: 'วันที่ครบกำหนดชำระ',
                isRequired: true,
                hintText: 'ระบุวันที่ 1-31',
                suffix: _buildSuffix('ของทุกเดือน'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                  FilteringTextInputFormatter.allow(RegExp(r'[1-31]')),
                ],
                controller:
                    TextEditingController(text: state.dueDate?.toString() ?? '')
                      ..selection = TextSelection.fromPosition(
                        TextPosition(
                          offset: (state.dueDate?.toString() ?? '').length,
                        ),
                      ),
                onChanged: (val) {
                  final day = int.tryParse(val);
                  if (day != null && day >= 1 && day <= 31) {
                    context.read<ContractFormBloc>().add(
                      ContractFormDueDateUpdated(day),
                    );
                  } else if (val.isEmpty) {
                    context.read<ContractFormBloc>().add(
                      const ContractFormDueDateUpdated(null),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppTextField(
                label: 'ค่าปรับล่าช้า',
                isRequired: true,
                hintText: '0',
                suffix: _buildSuffix('บาท/วัน'),
                keyboardType: TextInputType.number,
                inputFormatters: [_currencyFormatter],
                controller:
                    TextEditingController(
                        text: state.lateFee > 0
                            ? _formatCurrency(state.lateFee)
                            : '',
                      )
                      ..selection = TextSelection.fromPosition(
                        TextPosition(
                          offset: _formatCurrency(state.lateFee).length,
                        ),
                      ),
                onChanged: (val) {
                  final fee = double.tryParse(val.replaceAll(',', '')) ?? 0;
                  context.read<ContractFormBloc>().add(
                    ContractFormLateFeeUpdated(fee),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodFields(
    BuildContext context,
    ContractFormState state,
  ) {
    final paymentMethods = ['Credit card', 'Promptpay', 'Bank'];
    final banks = state.contractCreateData?.banks ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('ช่องทางการชำระเงิน', isRequired: true),
        const SizedBox(height: 8),
        AppDropdown<String>(
          value: state.paymentMethod.isEmpty ? null : state.paymentMethod,
          hint: 'เลือกช่องทางการชำระเงิน',
          items: paymentMethods,
          onChanged: (val) {
            context.read<ContractFormBloc>().add(
              ContractFormPaymentMethodUpdated(val ?? ''),
            );
          },
        ),
        const SizedBox(height: 20),

        // สาขา Field with TypeAhead
        TypeAheadField<Bank>(
          controller: _bankBranchController,
          hideOnEmpty: true,
          builder: (context, controller, focusNode) => AppTextField(
            label: 'สาขา',
            controller: controller,
            focusNode: focusNode,
            isRequired: true,
            hintText: 'ระบุสาขา',
            onChanged: (value) {
              context.read<ContractFormBloc>().add(
                ContractFormBankBranchUpdated(value),
              );
            },
          ),
          suggestionsCallback: (pattern) {
            if (pattern.isEmpty) return banks;

            final query = pattern.toLowerCase();
            return banks.where((p) {
              final nameMatch = p.name.toLowerCase().contains(query);
              return nameMatch;
            }).toList();
          },
          itemBuilder: (context, suggestion) {
            return ListTile(title: Text(suggestion.name));
          },
          onSelected: (suggestion) {
            _bankBranchController.text = suggestion.name;
            context.read<ContractFormBloc>().add(
              ContractFormBankBranchUpdated(suggestion.name),
            );

            FocusScope.of(context).unfocus();
          },
        ),
        const SizedBox(height: 20),
        AppTextField(
          label: 'ชื่อบัญชี',
          isRequired: true,
          hintText: 'ระบุชื่อบัญชี',
          controller: TextEditingController(text: state.accountName)
            ..selection = TextSelection.fromPosition(
              TextPosition(offset: state.accountName.length),
            ),
          onChanged: (val) => context.read<ContractFormBloc>().add(
            ContractFormAccountNameUpdated(val),
          ),
        ),
        const SizedBox(height: 20),
        AppTextField(
          label: 'เลขบัญชี',
          isRequired: true,
          hintText: 'ระบุเลขบัญชี',
          controller: TextEditingController(text: state.accountNumber)
            ..selection = TextSelection.fromPosition(
              TextPosition(offset: state.accountNumber.length),
            ),
          onChanged: (val) => context.read<ContractFormBloc>().add(
            ContractFormAccountNumberUpdated(val),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.anuphan(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.baseBlack,
          ),
        ),
        if (isRequired)
          Text(
            ' *',
            style: GoogleFonts.anuphan(color: AppColors.error, fontSize: 14),
          ),
      ],
    );
  }

  Widget _buildSuffix(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Text(
        text,
        style: GoogleFonts.anuphan(color: AppColors.baseGrey, fontSize: 14),
      ),
    );
  }

  String _formatCurrency(double value) {
    if (value == 0) return '';
    final formatter = NumberFormat.decimalPattern();
    return formatter.format(value);
  }
}
