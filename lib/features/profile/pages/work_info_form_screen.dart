import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

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

  final List<ProficiencyLevel> _proficiencyLevels = ProficiencyLevel.values;

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
        // Try to map existing value to enum label if it's the English value
        final level = ProficiencyLevel.fromValue(value.toString());
        _languages.add(
          LanguagePair(
            id: UniqueKey().toString(),
            keyController: TextEditingController(text: key),
            valueController: TextEditingController(
              text: level?.label ?? value.toString(),
            ),
          ),
        );
      });
    } else {
      // Pre-fill default languages
      _languages.add(
        LanguagePair(
          id: UniqueKey().toString(),
          keyController: TextEditingController(text: 'ไทย'),
          valueController: TextEditingController(
            text: ProficiencyLevel.fluent.label,
          ),
        ),
      );
      _languages.add(
        LanguagePair(
          id: UniqueKey().toString(),
          keyController: TextEditingController(text: 'อังกฤษ'),
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
      // Optional: initialize empty or default socials if needed
      // Pre-fill default social links
      _socialLinks.add(
        SocialLinkPair(
          id: UniqueKey().toString(),
          keyController: TextEditingController(text: 'Facebook'),
          valueController: TextEditingController(),
        ),
      );
      _socialLinks.add(
        SocialLinkPair(
          id: UniqueKey().toString(),
          keyController: TextEditingController(text: 'Instagram'),
          valueController: TextEditingController(),
        ),
      );
      _socialLinks.add(
        SocialLinkPair(
          id: UniqueKey().toString(),
          keyController: TextEditingController(text: 'Line'),
          valueController: TextEditingController(),
        ),
      );
      _socialLinks.add(
        SocialLinkPair(
          id: UniqueKey().toString(),
          keyController: TextEditingController(text: 'LinkedIn'),
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

  Future<void> _onSave() async {
    final Map<String, String> languagesMap = {};
    for (var p in _languages) {
      final key = p.keyController.text.trim();
      final label = p.valueController.text.trim();
      if (key.isNotEmpty && label.isNotEmpty) {
        // Convert Thai label back to English value for API
        final level = ProficiencyLevel.fromValue(label);
        languagesMap[key] = level?.value ?? label;
      }
    }

    final Map<String, String> socialLinksMap = {};
    for (var p in _socialLinks) {
      final key = p.keyController.text.trim();
      var value = p.valueController.text.trim();
      if (key.isNotEmpty && value.isNotEmpty) {
        // Fix prefix for website input
        if (!value.startsWith('http://') && !value.startsWith('https://')) {
          if (!value.startsWith('www.')) {
            value = 'www.$value';
          }
          value = 'https://$value';
        } else if (value.startsWith('https://') &&
            !value.startsWith('https://www.')) {
          value = value.replaceFirst('https://', 'https://www.');
        } else if (value.startsWith('http://') &&
            !value.startsWith('http://www.')) {
          value = value.replaceFirst('http://', 'http://www.');
        }

        // Validate URL
        final uri = Uri.tryParse(value);
        final canLaunch = await canLaunchUrl(Uri.parse(value));
        if (!canLaunch ||
            uri == null ||
            !uri.hasAbsolutePath ||
            !value.contains('.')) {
          StatusDialog.showError(
            context: context,
            title: 'URL ไม่ถูกต้อง',
            message:
                'กรุณาตรวจสอบลิงก์ของ $key (เช่น https://www.$key.com/username)',
          );
          return;
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
                        SizedBox(height: 24),
                        _buildLanguageSection(),
                        SizedBox(height: 24),
                        _buildSocialSection(),
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
        icon: SvgPicture.asset(
          'assets/icons/chevron-left.svg',
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        onPressed: () => Navigator.of(context).pop(),
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

  Widget _buildLanguageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).languageProficiencyLabel,
          style: GoogleFonts.anuphan(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.baseBlack,
          ),
        ),
        SizedBox(height: 12),
        ..._languages.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            key: ValueKey(item.id),
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildInputContainer(
                    child: TextField(
                      controller: item.keyController,
                      style: GoogleFonts.anuphan(
                        fontSize: 14,
                        color: AppColors.baseBlack,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'ภาษา',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child: _buildInputContainer(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value:
                            _proficiencyLevels.any(
                              (l) => l.label == item.valueController.text,
                            )
                            ? item.valueController.text
                            : null,
                        hint: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'ระดับความถนัด',
                            style: GoogleFonts.anuphan(
                              fontSize: 14,
                              color: AppColors.baseGrey,
                            ),
                          ),
                        ),
                        isExpanded: true,
                        icon: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: SvgPicture.asset(
                            'assets/icons/chevron-down.svg',
                            width: 16,
                            height: 16,
                            fit: BoxFit.scaleDown,
                            colorFilter: const ColorFilter.mode(
                              AppColors.baseGrey,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        items: _proficiencyLevels.map((ProficiencyLevel level) {
                          return DropdownMenuItem<String>(
                            value: level.label,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                level.label,
                                style: GoogleFonts.anuphan(
                                  fontSize: 14,
                                  color: AppColors.baseBlack,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            item.valueController.text = newValue ?? '';
                          });
                        },
                      ),
                    ),
                  ),
                ),
                if (_languages.length > 1) ...[
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _languages[index].keyController.dispose();
                        _languages[index].valueController.dispose();
                        _languages.removeAt(index);
                      });
                    },
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
        _buildAddButton(
          label: AppLocalizations.of(context).addLabel,
          onTap: () {
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
        ),
      ],
    );
  }

  Widget _buildSocialSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).socialLinks,
          style: GoogleFonts.anuphan(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.baseBlack,
          ),
        ),
        SizedBox(height: 12),
        ..._socialLinks.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            key: ValueKey(item.id),
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildInputContainer(
                    child: TextField(
                      controller: item.keyController,
                      style: GoogleFonts.anuphan(
                        fontSize: 14,
                        color: AppColors.baseBlack,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'แพลตฟอร์ม',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: _buildInputContainer(
                    child: TextField(
                      controller: item.valueController,
                      style: GoogleFonts.anuphan(
                        fontSize: 14,
                        color: AppColors.baseBlack,
                      ),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).linkOrIdHint,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 12, right: 8),
                          child: Icon(
                            Icons.link,
                            size: 18,
                            color: AppColors.baseGrey,
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_socialLinks.length > 1) ...[
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _socialLinks[index].keyController.dispose();
                        _socialLinks[index].valueController.dispose();
                        _socialLinks.removeAt(index);
                      });
                    },
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
        _buildAddButton(
          label: AppLocalizations.of(context).addLabel,
          onTap: () {
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
        ),
      ],
    );
  }

  Widget _buildInputContainer({required Widget child}) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9EAEB)),
      ),
      child: child,
    );
  }

  Widget _buildAddButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE9EAEB),
            style: BorderStyle.none,
          ),
        ),
        child: CustomPaint(
          painter: DashRectPainter(color: const Color(0xFFE9EAEB)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, size: 18, color: Color(0xFF717680)),
              const SizedBox(width: 8),
              Text(
                'เพิ่มรายการ',
                style: GoogleFonts.anuphan(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF717680),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashRectPainter({required this.color, this.strokeWidth = 1, this.gap = 5});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    Path path = Path();
    double radius = 12;

    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ),
    );

    canvas.drawPath(_dashPath(path, dashGap: gap), paint);
  }

  Path _dashPath(Path source, {double dashGap = 5}) {
    final Path dest = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double len = dashGap;
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, distance + len),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
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

enum ProficiencyLevel {
  beginner('พอใช้', 'Beginner'),
  intermediate('ปานกลาง', 'Intermediate'),
  advanced('ดี', 'Advanced'),
  fluent('คล่องแคล่ว', 'Fluent');

  final String label;
  final String value;
  const ProficiencyLevel(this.label, this.value);

  static ProficiencyLevel? fromValue(String? val) {
    if (val == null) return null;
    return ProficiencyLevel.values.firstWhere(
      (l) => l.value.toLowerCase() == val.toLowerCase() || l.label == val,
      orElse: () => ProficiencyLevel.beginner,
    );
  }
}
