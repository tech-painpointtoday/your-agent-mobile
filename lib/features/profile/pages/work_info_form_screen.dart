import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../widgets/badges/app_badge.dart';
import '../../../widgets/buttons/app_button.dart';
import '../../../widgets/inputs/app_text_field.dart';
import '../../../widgets/dialogs/status_dialog.dart';
import '../../../widgets/modals/app_confirmation_bottom_sheet.dart';
import '../bloc/profile_bloc.dart';
import '../models/agent_profile.dart';
import 'profile_screen.dart';
import 'package:youragent/l10n/app_localizations.dart';

class WorkInfoFormScreen extends StatefulWidget {
  final AgentDetails? agent;

  const WorkInfoFormScreen({super.key, this.agent});

  @override
  State<WorkInfoFormScreen> createState() => _WorkInfoFormScreenState();
}

class _WorkInfoFormScreenState extends State<WorkInfoFormScreen> {
  late final TextEditingController _companyController;
  late final TextEditingController _licenseController;
  late final TextEditingController _experienceController;
  final List<LanguagePair> _languages = [];
  final List<SocialLinkPair> _socialLinks = [];

  @override
  void initState() {
    super.initState();
    _companyController = TextEditingController(text: widget.agent?.companyName);
    _licenseController = TextEditingController(
      text: widget.agent?.licenseNumber,
    );
    _experienceController = TextEditingController(
      text: widget.agent?.yearsOfExperience?.toString() ?? '0',
    );

    // Initialize languages
    if (widget.agent?.languages != null &&
        widget.agent!.languages!.isNotEmpty) {
      widget.agent!.languages!.forEach((key, value) {
        _languages.add(
          LanguagePair(
            id: UniqueKey().toString(),
            keyController: TextEditingController(text: key),
            valueController: TextEditingController(text: value.toString()),
          ),
        );
      });
    } else {
      _languages.add(
        LanguagePair(
          id: UniqueKey().toString(),
          keyController: TextEditingController(),
          valueController: TextEditingController(),
        ),
      );
    }

    // Initialize social links
    if (widget.agent?.socialLinks != null &&
        widget.agent!.socialLinks!.isNotEmpty) {
      widget.agent!.socialLinks!.forEach((key, value) {
        _socialLinks.add(
          SocialLinkPair(
            id: UniqueKey().toString(),
            keyController: TextEditingController(text: key),
            valueController: TextEditingController(text: value.toString()),
          ),
        );
      });
    } else {
      _socialLinks.add(
        SocialLinkPair(
          id: UniqueKey().toString(),
          keyController: TextEditingController(),
          valueController: TextEditingController(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _licenseController.dispose();
    _experienceController.dispose();
    for (var p in _languages) {
      p.keyController.dispose();
      p.valueController.dispose();
    }
    for (var p in _socialLinks) {
      p.keyController.dispose();
      p.valueController.dispose();
    }
    super.dispose();
  }

  void _onSave() {
    final Map<String, String> languagesMap = {};
    for (var p in _languages) {
      final key = p.keyController.text.trim();
      final value = p.valueController.text.trim();
      if (key.isNotEmpty && value.isNotEmpty) {
        languagesMap[key] = value;
      }
    }

    final Map<String, String> socialLinksMap = {};
    for (var p in _socialLinks) {
      final key = p.keyController.text.trim();
      var value = p.valueController.text.trim();
      if (key.isNotEmpty && value.isNotEmpty) {
        // Fix prefix for website input
        if (!value.startsWith('http://') && !value.startsWith('https://')) {
          value = 'https://$value';
        }
        socialLinksMap[key] = value;
      }
    }

    final data = {
      'company_name': _companyController.text.trim(),
      'license_number': _licenseController.text.trim(),
      'years_of_experience':
          int.tryParse(_experienceController.text.trim()) ?? 0,
      'languages': languagesMap,
      'social_links': socialLinksMap,
    };

    AppConfirmationBottomSheet.show(
      context: context,
      title: AppLocalizations.of(context).saveWorkInfoTitle,
      description: AppLocalizations.of(context).saveWorkInfoMessage,
      confirmLabel: AppLocalizations.of(context).confirmSaveLabel,
      onConfirm: () {
        context.read<ProfileBloc>().add(UpdateWorkInfo(data));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<ProfileBloc>(),
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            ProfileScreen.needsRefresh = true;
            context.pop();
          } else if (state is ProfileError) {
            StatusDialog.showError(
              context: context,
              title: AppLocalizations.of(context).errorOccurredTitle,
              message: state.message,
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.primary,
          appBar: _buildAppBar(context),
          body: Container(
            margin: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppBadge(
                          label: AppLocalizations.of(context).workInfoLabel,
                          color: BadgeColor.blue,
                          style: BadgeStyle.plain,
                        ),
                        SizedBox(height: 24),
                        AppTextField(
                          label: AppLocalizations.of(context).companyNameHint,
                          hintText: AppLocalizations.of(
                            context,
                          ).companyNameHint,
                          controller: _companyController,
                        ),
                        SizedBox(height: 16),
                        AppTextField(
                          label: AppLocalizations.of(context).licenseNumberHint,
                          hintText: AppLocalizations.of(
                            context,
                          ).licenseNumberHint,
                          controller: _licenseController,
                        ),
                        SizedBox(height: 16),
                        AppTextField(
                          label: 'ประสบการณ์ทำงาน (ปี)',
                          hintText: '0',
                          controller: _experienceController,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 24),
                        _buildDynamicSection(
                          title: AppLocalizations.of(
                            context,
                          ).languageProficiencyLabel,
                          items: _languages,
                          keyHint: 'ภาษา (เช่น ไทย)',
                          valueHint: 'ระดับ (เช่น Beginner)',
                          onAdd: () {
                            setState(() {
                              _languages.add(
                                LanguagePair(
                                  id: UniqueKey().toString(),
                                  keyController: TextEditingController(),
                                  valueController: TextEditingController(),
                                ),
                              );
                            });
                          },
                          onRemove: (index) {
                            setState(() {
                              _languages[index].keyController.dispose();
                              _languages[index].valueController.dispose();
                              _languages.removeAt(index);
                            });
                          },
                        ),
                        SizedBox(height: 24),
                        _buildDynamicSection(
                          title: AppLocalizations.of(context).socialLinks,
                          items: _socialLinks,
                          keyHint: 'แพลตฟอร์ม (เช่น Facebook)',
                          valueHint: AppLocalizations.of(context).linkOrIdHint,
                          onAdd: () {
                            setState(() {
                              _socialLinks.add(
                                SocialLinkPair(
                                  id: UniqueKey().toString(),
                                  keyController: TextEditingController(),
                                  valueController: TextEditingController(),
                                ),
                              );
                            });
                          },
                          onRemove: (index) {
                            setState(() {
                              _socialLinks[index].keyController.dispose();
                              _socialLinks[index].valueController.dispose();
                              _socialLinks.removeAt(index);
                            });
                          },
                        ),
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                _buildBottomButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        AppLocalizations.of(context).addWorkInfoTitle,
        style: GoogleFonts.anuphan(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              text: AppLocalizations.of(context).statusCancelled,
              style: AppButtonStyle.outline,
              onPressed: () => context.pop(),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                return AppButton(
                  text: AppLocalizations.of(context).confirmSaveLabel,
                  style: AppButtonStyle.primary,
                  isLoading: state is ProfileUpdateLoading,
                  onPressed: _onSave,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicSection({
    required String title,
    required List<dynamic> items,
    required String keyHint,
    required String valueHint,
    required VoidCallback onAdd,
    required Function(int) onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.anuphan(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.baseBlack,
              ),
            ),
            GestureDetector(
              onTap: onAdd,
              child: Row(
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context).addLabel,
                    style: GoogleFonts.anuphan(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            key: ValueKey(item.id),
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: AppTextField(
                    label: '',
                    hintText: keyHint,
                    controller: item.keyController,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: AppTextField(
                    label: '',
                    hintText: valueHint,
                    controller: item.valueController,
                  ),
                ),
                if (items.length > 1) ...[
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => onRemove(index),
                    child: const Icon(
                      Icons.remove_circle_outline,
                      color: AppColors.supportRedDeep,
                      size: 20,
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}

class LanguagePair {
  final String id;
  final TextEditingController keyController;
  final TextEditingController valueController;
  LanguagePair({
    required this.id,
    required this.keyController,
    required this.valueController,
  });
}

class SocialLinkPair {
  final String id;
  final TextEditingController keyController;
  final TextEditingController valueController;
  SocialLinkPair({
    required this.id,
    required this.keyController,
    required this.valueController,
  });
}
