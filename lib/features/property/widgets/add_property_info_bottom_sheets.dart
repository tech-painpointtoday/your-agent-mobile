import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/widgets/inputs/app_text_field.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/core/extensions/l10n_extensions.dart';

/// Entry point for adding a developer
class AddDeveloperBottomSheet {
  static Future<Map<String, dynamic>?> show(BuildContext context) {
    return PropertyInfoBottomSheet.show(
      context: context,
      title: context.l10n.addDeveloperTitle,
      description: context.l10n.addDeveloperDescription,
      labelBase: context.l10n.developerNameHint,
      hintText: context.l10n.developerNameHint,
    );
  }
}

/// Entry point for adding a project (condo or house)
class AddProjectBottomSheet {
  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required int developerId,
    required String developerName,
    required bool isCondoOrApt,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddProjectBottomSheetContent(
        developerId: developerId,
        developerName: developerName,
        isCondoOrApt: isCondoOrApt,
      ),
    );
  }
}

/// Bottom sheet for adding project with juristic fields
class _AddProjectBottomSheetContent extends StatefulWidget {
  final int developerId;
  final String developerName;
  final bool isCondoOrApt;

  const _AddProjectBottomSheetContent({
    required this.developerId,
    required this.developerName,
    required this.isCondoOrApt,
  });

  @override
  State<_AddProjectBottomSheetContent> createState() =>
      _AddProjectBottomSheetContentState();
}

class _AddProjectBottomSheetContentState
    extends State<_AddProjectBottomSheetContent> {
  final _nameThController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _juristicPhoneController = TextEditingController();
  final _juristicEmailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isButtonEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameThController.addListener(_updateButtonState);
    _nameEnController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    final isValid =
        _nameThController.text.isNotEmpty && _nameEnController.text.isNotEmpty;
    if (isValid != _isButtonEnabled) {
      setState(() {
        _isButtonEnabled = isValid;
      });
    }
  }

  @override
  void dispose() {
    _nameThController.removeListener(_updateButtonState);
    _nameEnController.removeListener(_updateButtonState);
    _nameThController.dispose();
    _nameEnController.dispose();
    _juristicPhoneController.dispose();
    _juristicEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: 32 + bottomPadding + bottomInset,
      ),
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 24,
            children: [
              // Drag Handle
              Container(
                width: 48,
                height: 6,
                decoration: ShapeDecoration(
                  color: AppColors.baseLightGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // Header
              SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          l10n.addProjectNameTitle,
                          style: GoogleFonts.anuphan(
                            color: AppColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '(${widget.developerName} #${widget.developerId})',
                            style: GoogleFonts.anuphan(
                              color: AppColors.baseGrey,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      l10n.addProjectNameDescription,
                      style: GoogleFonts.anuphan(
                        color: AppColors.baseGrey,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              // ...

              // Project Name
              AppTextField(
                label: '${l10n.projectNameHint} (ภาษาไทย)',
                controller: _nameThController,
                hintText: l10n.projectNameHint,
                isRequired: true,
              ),

              // Project Name (English)
              AppTextField(
                label: '${l10n.projectNameHint} (ภาษาอังกฤษ)',
                controller: _nameEnController,
                hintText: l10n.projectNameHint,
                isRequired: true,
              ),

              // Juristic Contact Phone (Optional)
              AppTextField(
                label: l10n.juristicContactPhoneLabel,
                controller: _juristicPhoneController,
                hintText: '02-1234567',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final phoneRegex = RegExp(r'^[0-9\-]{9,13}$');
                  if (!phoneRegex.hasMatch(value)) {
                    return l10n.please_enter_valid_number;
                  }
                  return null;
                },
              ),

              // Juristic Contact Email (Optional)
              AppTextField(
                label: l10n.juristicContactEmailLabel,
                controller: _juristicEmailController,
                hintText: l10n.emailHintJuristic,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
                  if (!emailRegex.hasMatch(value)) {
                    return l10n.enter_valid_email;
                  }
                  return null;
                },
              ),

              // Action Buttons
              Row(
                spacing: 16,
                children: [
                  Expanded(
                    child: AppButton(
                      text: l10n.statusCancelled,
                      style: AppButtonStyle.outline,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded(
                    child: AppButton(
                      text: l10n.addNowButton,
                      style: AppButtonStyle.primary,
                      enabled: _isButtonEnabled && !_isLoading,
                      isLoading: _isLoading,
                      onPressed: (_isButtonEnabled && !_isLoading)
                          ? () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _isLoading = true);
                                try {
                                  final apiService =
                                      DependencyInjection.propertyApiService;
                                  final response = widget.isCondoOrApt
                                      ? await apiService.createCondoProject(
                                          developerId: widget.developerId,
                                          nameEn: _nameEnController.text.trim(),
                                          nameTh: _nameThController.text.trim(),
                                          juristicContactPhone:
                                              _juristicPhoneController
                                                  .text
                                                  .isNotEmpty
                                              ? _juristicPhoneController.text
                                                    .trim()
                                              : null,
                                          juristicContactEmail:
                                              _juristicEmailController
                                                  .text
                                                  .isNotEmpty
                                              ? _juristicEmailController.text
                                                    .trim()
                                              : null,
                                        )
                                      : await apiService.createHouseProject(
                                          developerId: widget.developerId,
                                          nameEn: _nameEnController.text.trim(),
                                          nameTh: _nameThController.text.trim(),
                                          juristicContactPhone:
                                              _juristicPhoneController
                                                  .text
                                                  .isNotEmpty
                                              ? _juristicPhoneController.text
                                                    .trim()
                                              : null,
                                          juristicContactEmail:
                                              _juristicEmailController
                                                  .text
                                                  .isNotEmpty
                                              ? _juristicEmailController.text
                                                    .trim()
                                              : null,
                                        );
                                  if (context.mounted) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (context.mounted) {
                                            context.pop(response);
                                          }
                                        });
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    setState(() => _isLoading = false);
                                    StatusDialog.showError(
                                      context: context,
                                      title: context.l10n.error,
                                      message: e.toString().replaceFirst(
                                        'Exception: ',
                                        '',
                                      ),
                                    );
                                  }
                                }
                              }
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Generic bottom sheet component for adding property-related master data
class PropertyInfoBottomSheet extends StatefulWidget {
  final String title;
  final String description;
  final String labelBase;
  final String hintText;

  const PropertyInfoBottomSheet({
    super.key,
    required this.title,
    required this.description,
    required this.labelBase,
    required this.hintText,
  });

  static Future<Map<String, dynamic>?> show({
    required BuildContext context,
    required String title,
    required String description,
    required String labelBase,
    required String hintText,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PropertyInfoBottomSheet(
        title: title,
        description: description,
        labelBase: labelBase,
        hintText: hintText,
      ),
    );
  }

  @override
  State<PropertyInfoBottomSheet> createState() =>
      _PropertyInfoBottomSheetState();
}

class _PropertyInfoBottomSheetState extends State<PropertyInfoBottomSheet> {
  final _nameThController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isButtonEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameThController.addListener(_updateButtonState);
    _nameEnController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    final isValid =
        _nameThController.text.isNotEmpty && _nameEnController.text.isNotEmpty;
    if (isValid != _isButtonEnabled) {
      setState(() {
        _isButtonEnabled = isValid;
      });
    }
  }

  @override
  void dispose() {
    _nameThController.removeListener(_updateButtonState);
    _nameEnController.removeListener(_updateButtonState);
    _nameThController.dispose();
    _nameEnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: 32 + bottomPadding + bottomInset,
      ),
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 24,
            children: [
              // Drag Handle
              Container(
                width: 48,
                height: 6,
                decoration: ShapeDecoration(
                  color: AppColors.baseLightGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // Header Section (Title & Description)
              SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.anuphan(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      widget.description,
                      style: GoogleFonts.anuphan(
                        color: AppColors.baseGrey,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Thai name field
              _buildInputField(
                label: widget.labelBase,
                suffix: '(ภาษาไทย)',
                controller: _nameThController,
                hintText: widget.hintText,
                isRequired: true,
              ),

              // English name field
              _buildInputField(
                label: widget.labelBase,
                suffix: '(ภาษาอังกฤษ)',
                controller: _nameEnController,
                hintText: widget.hintText,
                isRequired: true,
              ),

              // Action Buttons
              Row(
                spacing: 16,
                children: [
                  Expanded(
                    child: AppButton(
                      text: context.l10n.statusCancelled,
                      style: AppButtonStyle.outline,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded(
                    child: AppButton(
                      text: context.l10n.addNowButton,
                      style: AppButtonStyle.primary,
                      enabled: _isButtonEnabled && !_isLoading,
                      isLoading: _isLoading,
                      onPressed: (_isButtonEnabled && !_isLoading)
                          ? () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _isLoading = true);
                                try {
                                  final response = await DependencyInjection
                                      .propertyApiService
                                      .createDeveloper(
                                        nameEn: _nameEnController.text.trim(),
                                        nameTh: _nameThController.text.trim(),
                                      );
                                  if (mounted) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (mounted) {
                                            Navigator.pop(context, response);
                                          }
                                        });
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    setState(() => _isLoading = false);
                                    StatusDialog.showError(
                                      context: context,
                                      title: context.l10n.error,
                                      message: e.toString().replaceFirst(
                                        'Exception: ',
                                        '',
                                      ),
                                    );
                                  }
                                }
                              }
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String suffix,
    required TextEditingController controller,
    required String hintText,
    required bool isRequired,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Text(
                label,
                style: GoogleFonts.anuphan(
                  color: AppColors.baseBlack,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                suffix,
                style: GoogleFonts.anuphan(
                  color: AppColors.baseGrey,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              if (isRequired)
                Text(
                  '*',
                  style: GoogleFonts.anuphan(
                    color: AppColors.error,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
          AppTextField(
            label: '', // Empty because we built the label row above
            controller: controller,
            hintText: hintText,
            isRequired: isRequired,
          ),
        ],
      ),
    );
  }
}
