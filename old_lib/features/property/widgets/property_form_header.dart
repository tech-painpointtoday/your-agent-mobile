import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/domain/entities/user.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Enum to define the mode of the property form
enum PropertyFormMode { view, create, edit }

/// A sticky header bar for property forms with different states based on mode
class PropertyFormHeader extends StatelessWidget {
  final PropertyFormMode mode;
  final VoidCallback? onBack;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onSecondaryAction;
  final bool isLoading;

  const PropertyFormHeader({
    super.key,
    required this.mode,
    this.onBack,
    this.onPrimaryAction,
    this.onSecondaryAction,
    this.isLoading = false,
  });

  String get _title {
    switch (mode) {
      case PropertyFormMode.view:
        return 'ข้อมูลอสังหาริมทรัพย์';
      case PropertyFormMode.create:
        return 'สร้างอสังหาริมทรัพย์';
      case PropertyFormMode.edit:
        return 'แก้ไขข้อมูลอสังหาริมทรัพย์';
    }
  }

  String get _primaryButtonLabel {
    switch (mode) {
      case PropertyFormMode.view:
        return 'แก้ไข';
      case PropertyFormMode.create:
        return 'สร้าง';
      case PropertyFormMode.edit:
        return 'บันทึก';
    }
  }

  String get _secondaryButtonLabel {
    switch (mode) {
      case PropertyFormMode.view:
        return 'ลบ';
      case PropertyFormMode.create:
      case PropertyFormMode.edit:
        return 'ยกเลิก';
    }
  }

  /// Safely navigate back - check if we can pop, otherwise go to properties list
  void _navigateBack(BuildContext context) {
    final role = DependencyInjection.authRepository.currentRole ?? UserRole.agent;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/${role.name}/properties');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Button typography: Body md / SemiBold (Anuphan, 16pt, 24pt line height)
    final primaryButtonTextStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      height: 24 / 16,
      letterSpacing: 0,
      color: Colors.white,
    );
    final secondaryButtonTextStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      height: 24 / 16,
      letterSpacing: 0,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      child: Row(
        children: [
          // Back button
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              icon: SvgPicture.asset('assets/icons/form/chevron-left.svg', width: 20, height: 20),
              onPressed: onBack ?? () => _navigateBack(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ),
          const SizedBox(width: 16),
          // Title
          Text(_title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const Spacer(),
          // Primary button
          if (mode == PropertyFormMode.create || mode == PropertyFormMode.edit)
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: isLoading
                    ? null
                    : () {
                        debugPrint('PropertyFormHeader: Primary button pressed (${mode.name})');
                        debugPrint(
                          'PropertyFormHeader: onPrimaryAction is ${onPrimaryAction != null ? "set" : "null"}',
                        );
                        debugPrint('PropertyFormHeader: isLoading = $isLoading');
                        onPrimaryAction?.call();
                      },
                icon: SvgPicture.asset(
                  mode == PropertyFormMode.create ? 'assets/icons/form/plus-2.svg' : 'assets/icons/form/save.svg',
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
                label: Text(_primaryButtonLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  minimumSize: const Size(0, 48),
                  textStyle: primaryButtonTextStyle,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            )
          else if (mode == PropertyFormMode.view)
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: isLoading
                    ? null
                    : () {
                        debugPrint('PropertyFormHeader: Primary button pressed (view mode)');
                        debugPrint(
                          'PropertyFormHeader: onPrimaryAction is ${onPrimaryAction != null ? "set" : "null"}',
                        );
                        debugPrint('PropertyFormHeader: isLoading = $isLoading');
                        onPrimaryAction?.call();
                      },
                icon: SvgPicture.asset(
                  'assets/icons/form/edit-2.svg',
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
                label: Text(_primaryButtonLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  minimumSize: const Size(0, 48),
                  textStyle: primaryButtonTextStyle,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          const SizedBox(width: 12),
          // Secondary button
          if (mode == PropertyFormMode.view)
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: null,
                //[TODO] tmp
                //onPressed: isLoading ? null : onSecondaryAction,
                icon: SvgPicture.asset(
                  'assets/icons/form/trash-2.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
                label: Text(_secondaryButtonLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.ruby500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  minimumSize: const Size(0, 48),
                  textStyle: primaryButtonTextStyle,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            )
          else
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: isLoading ? null : onSecondaryAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.gray400,
                  side: const BorderSide(color: AppColors.gray200),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  minimumSize: const Size(0, 48),
                  textStyle: secondaryButtonTextStyle,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_secondaryButtonLabel),
              ),
            ),
        ],
      ),
    );
  }
}
