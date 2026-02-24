import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final bool isRequired;
  final String? hintText;
  final int maxLines;
  final int? maxLength;
  final Widget? suffix;
  final Widget? prefix;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final bool showCursor;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final ScrollController? scrollController;
  final bool showScrollbar;

  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;

  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.isRequired = false,
    this.hintText,
    this.maxLines = 1,
    this.maxLength,
    this.suffix,
    this.prefix,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.focusNode,
    this.showCursor = true,
    this.inputFormatters,
    this.obscureText = false,
    this.scrollController,
    this.showScrollbar = false,
    this.validator,
    this.autovalidateMode,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _isObscured = widget.obscureText;
    }
  }

  void _toggleObscureText() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  Widget? _buildSuffixIcon() {
    // If obscureText is enabled, show eye toggle icon
    if (widget.obscureText) {
      return GestureDetector(
        onTap: _toggleObscureText,
        child: SvgPicture.asset(
          _isObscured ? 'assets/icons/eye-off.svg' : 'assets/icons/eye.svg',
          colorFilter: ColorFilter.mode(AppColors.baseGrey, BlendMode.srcIn),
          width: 16,
          height: 16,
        ),
      );
    }
    // Otherwise, return the custom suffix if provided
    return widget.suffix;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text.rich(
            TextSpan(
              text: widget.label,
              style: GoogleFonts.anuphan(
                color: AppColors.baseBlack,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              children: [
                if (widget.isRequired)
                  TextSpan(
                    text: ' *',
                    style: GoogleFonts.anuphan(
                      color: AppColors.supportRedDeep,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          scrollPhysics: const ClampingScrollPhysics(),
          focusNode: widget.focusNode,
          controller: widget.controller,
          obscureText: _isObscured,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          showCursor: widget.readOnly ? false : widget.showCursor,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          autovalidateMode: widget.autovalidateMode,
          scrollController: widget.scrollController,
          style: GoogleFonts.anuphan(fontSize: 14, color: AppColors.baseBlack),
          decoration: InputDecoration(
            counterText: '',
            hintText: widget.hintText ?? widget.label,
            hintStyle: GoogleFonts.anuphan(
              color: AppColors.baseGrey,
              fontSize: 14,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            suffixIcon: Padding(
              padding: widget.showScrollbar
                  ? EdgeInsets.only(right: 32)
                  : EdgeInsets.symmetric(horizontal: 16),
              child: _buildSuffixIcon(),
            ),
            prefixIcon: widget.prefix,
            suffixIconConstraints: const BoxConstraints(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.baseLightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.baseLightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.baseLightGrey),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.supportRedDeep),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.supportRedDeep,
                width: 1.5,
              ),
            ),
            errorStyle: GoogleFonts.anuphan(
              color: AppColors.supportRedDeep,
              fontSize: 12,
            ),
            filled: true,
            fillColor: widget.readOnly
                ? AppColors.baseOffWhite
                : AppColors.baseWhite,
          ),
        ).let((child) {
          if (widget.showScrollbar) {
            return RawScrollbar(
              thickness: 8,
              controller: widget.scrollController,
              thumbVisibility: true,
              thumbColor: AppColors.baseLightGrey,
              minThumbLength: 64,
              radius: Radius.circular(8),
              mainAxisMargin: 16,
              crossAxisMargin: 16,
              trackVisibility: false,
              child: child,
            );
          }
          return child;
        }),
      ],
    );
  }
}

extension LetExtension<T> on T {
  R let<R>(R Function(T) block) => block(this);
}
