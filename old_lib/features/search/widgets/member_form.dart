import 'package:flutter/material.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/member.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

/// Form widget for a single family member entry
class MemberForm extends StatefulWidget {
  final Member member;
  final VoidCallback? onDelete;
  final VoidCallback? onChange;
  final void Function(int weight)? onWeightChanged;
  final void Function(bool locked)? onLockChanged;
  final bool canDelete;

  const MemberForm({
    super.key,
    required this.member,
    this.onDelete,
    this.onChange,
    this.onWeightChanged,
    this.onLockChanged,
    this.canDelete = true,
  });

  @override
  State<MemberForm> createState() => _MemberFormState();
}

class _MemberFormState extends State<MemberForm> {
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member.name);
    _dobController = TextEditingController(
      text: widget.member.dob != null
          ? DateFormat('dd/MM/yyyy').format(widget.member.dob!)
          : '',
    );
    _selectedGender = widget.member.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: widget.member.dob ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(date);
      });
      widget.onChange?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bonJour, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.name,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (_) => widget.onChange?.call(),
                ),
              ),
              if (widget.canDelete) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.alizarinCrimson,
                  ),
                  onPressed: widget.onDelete,
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _selectDate,
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _dobController,
                      decoration: InputDecoration(
                        labelText: l10n.birthdate,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedGender,
                  decoration: InputDecoration(
                    labelText: l10n.gender,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'male',
                      child: Text(l10n.gender_male),
                    ),
                    DropdownMenuItem(
                      value: 'female',
                      child: Text(l10n.gender_female),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedGender = value);
                    widget.onChange?.call();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
