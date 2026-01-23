import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';

class LabeledPasswordField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final TextEditingController? compareController;
  final String? Function(String?)? validator;

  const LabeledPasswordField({
    super.key,
    required this.label,
    required this.controller,
    this.compareController,
    this.validator,
  });

  @override
  State<LabeledPasswordField> createState() => _LabeledPasswordFieldState();
}

class _LabeledPasswordFieldState extends State<LabeledPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscure,
          decoration: InputDecoration(
            hintText: widget.label,
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: SvgPicture.asset(
                'assets/icons/key.svg',
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  AppColors.shadyLady,
                  BlendMode.srcIn,
                ),
              ),
            ),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: SvgPicture.asset(
                _obscure ? 'assets/icons/form/eye-off.svg' : 'assets/icons/form/eye.svg',
                width: 22,
                height: 22,
                colorFilter: const ColorFilter.mode(
                  AppColors.shadyLady,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          validator: widget.validator,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

