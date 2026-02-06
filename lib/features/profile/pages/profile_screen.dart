import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:youragent/widgets/map/map_view.dart';
import 'package:youragent/widgets/painters/dashed_border_painter.dart';

import '../../../app/router.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../utils/image_url_helper.dart';
import '../../../widgets/badges/app_badge.dart';
import '../../../widgets/buttons/app_button.dart';
import '../bloc/profile_bloc.dart';
import '../models/agent_profile.dart';
import '../widgets/change_password_bottom_sheet.dart';
import '../../../widgets/modals/app_image_picker_bottom_sheet.dart';
import '../../../widgets/dialogs/status_dialog.dart';
import 'package:youragent/l10n/app_localizations.dart';
import '../../../widgets/app_bars/silver_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static bool needsRefresh = false;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with RouteAware {
  late final ProfileBloc _profileBloc;
  bool _routeObserverSubscribed = false;

  @override
  void initState() {
    super.initState();
    _profileBloc = ProfileBloc(DependencyInjection.authApiService)
      ..add(FetchProfile());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is ModalRoute<dynamic> && !_routeObserverSubscribed) {
      profileRouteObserver.subscribe(this, route);
      _routeObserverSubscribed = true;
    }
  }

  @override
  void dispose() {
    if (_routeObserverSubscribed) {
      profileRouteObserver.unsubscribe(this);
    }
    _profileBloc.close();
    super.dispose();
  }

  @override
  void didPopNext() {
    if (ProfileScreen.needsRefresh) {
      _profileBloc.add(FetchProfile());
      ProfileScreen.needsRefresh = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(value: _profileBloc, child: const ProfileView());
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (state is ProfileError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.supportRedDeep,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: GoogleFonts.anuphan(
                      fontSize: 16,
                      color: AppColors.baseDarkGrey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    text: l10n.tryAgain,
                    style: AppButtonStyle.primary,
                    onPressed: () =>
                        context.read<ProfileBloc>().add(FetchProfile()),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is ProfileLoaded) {
          return BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileUpdateSuccess) {
                StatusDialog.showSuccess(
                  context: context,
                  title: l10n.successTitle,
                  message: l10n.profilePhotoUpdated,
                );
              } else if (state is ProfileError) {
                StatusDialog.showError(
                  context: context,
                  title: l10n.errorOccurredTitle,
                  message: state.message,
                );
              }
            },
            child: SilverAppBarScreen(
              title: l10n.yourProfile,
              backgroundHeight: 160,
              preferredHeight: 120,
              onRefresh: () async {
                context.read<ProfileBloc>().add(FetchProfile());
              },
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: Container(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/chevron-left.svg',
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                    fit: BoxFit.scaleDown,
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
              actionWidget: IconButton(
                onPressed: () => context.push('/profile/settings'),
                icon: Container(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/dots.svg',
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                    fit: BoxFit.scaleDown,
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
              child: _buildContent(
                context,
                state.profile,
                context.read<ProfileBloc>(),
              ),
            ),
          );
        }
        return const Scaffold(body: SizedBox.shrink());
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    AgentProfile profile,
    ProfileBloc profileBloc,
  ) {
    final agent = profile.agent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overlapping Section
        Container(
          height: 60, // Total height of the overlap area
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Profile Picture Overlap
              Positioned(
                top:
                    -40, // Half of the circle overlapping (assuming radius is ~60)
                left: 0,
                child: _buildProfileHeader(
                  context,
                  agent,
                  profile.verificationStatus,
                  profileBloc,
                ),
              ),
              // Change Password Button Overlap
              Positioned(
                top: 8, // Adjusted to match the overlap in the image
                right: 0,
                child: AppButton(
                  text: AppLocalizations.of(context).changePasswordButton,
                  style: AppButtonStyle.outline,
                  height: 36,
                  iconPath: 'assets/icons/security-shield.svg',
                  iconSize: 12,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  textStyle: GoogleFonts.anuphan(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.baseDarkGrey,
                  ),
                  textColor: AppColors.baseDarkGrey,
                  onPressed: () =>
                      ChangePasswordBottomSheet.show(context, profileBloc),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                agent.name,
                style: GoogleFonts.anuphan(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.baseBlack,
                ),
              ),
              Text(
                agent.email,
                style: GoogleFonts.anuphan(
                  fontSize: 16,
                  color: AppColors.baseGrey,
                ),
              ),
              const SizedBox(height: 12),
              if (profile.verificationStatus.emailVerified)
                AppBadge(
                  label: AppLocalizations.of(context).emailVerified,
                  color: BadgeColor.green,
                  style: BadgeStyle.done,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                )
              else
                AppBadge(
                  label: AppLocalizations.of(context).emailNotVerifiedYet,
                  color: BadgeColor.orange,
                  style: BadgeStyle.done,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
              const SizedBox(height: 24),
              _buildProfileCompletenessWidget(context, agent),
              const SizedBox(height: 24),
              _buildPersonalInfoCard(context, agent),
              const SizedBox(height: 16),
              _buildConnectionCodeCard(context, agent),
              const SizedBox(height: 16),
              _buildWorkInfoCard(context, agent),
              const SizedBox(height: 16),
              _buildServiceAreaCard(context, agent),
              const SizedBox(height: 64),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    AgentDetails agent,
    ProfileVerificationStatus status,
    ProfileBloc profileBloc,
  ) {
    final profilePhotoUrl = ImageUrlHelper.getProfilePhotoUrl(
      agent.profilePhoto,
    );
    final initial = agent.name.isNotEmpty ? agent.name[0].toUpperCase() : '?';

    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * (80 / 360),
          height: MediaQuery.of(context).size.width * (80 / 360),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: profilePhotoUrl != null
                ? CachedNetworkImage(
                    imageUrl: profilePhotoUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildDefaultAvatar(initial),
                    errorWidget: (context, url, error) =>
                        _buildDefaultAvatar(initial),
                  )
                : _buildDefaultAvatar(initial),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: InkWell(
            onTap: () {
              AppImagePickerBottomSheet.show(
                context: context,
                onImagesPicked: (paths) {
                  if (paths.isNotEmpty) {
                    profileBloc.add(UpdateProfilePhoto(paths.first));
                  }
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.basePaleGrey,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: SvgPicture.asset(
                'assets/icons/edit.svg',
                colorFilter: const ColorFilter.mode(
                  AppColors.baseGrey,
                  BlendMode.srcIn,
                ),
                width: MediaQuery.of(context).size.width * (14 / 360),
                height: MediaQuery.of(context).size.width * (14 / 360),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar(String initial) {
    return Container(
      color: AppColors.basePaleGrey,
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.anuphan(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard(BuildContext context, AgentDetails agent) {
    return _ProfileCard(
      title: AppLocalizations.of(context).personalInfoLabel,
      onEdit: () => context.push('/profile/edit', extra: agent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('assets/icons/user.svg', agent.name),
          const SizedBox(height: 8),
          _buildInfoRow('assets/icons/email.svg', agent.email),
          const SizedBox(height: 8),
          _buildInfoRow(
            'assets/icons/phone.svg',
            agent.mobileNumber ?? AppLocalizations.of(context).notSpecified,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).bioLabel,
            style: GoogleFonts.anuphan(fontSize: 14, color: AppColors.baseGrey),
          ),
          const SizedBox(height: 4),
          Text(
            agent.bio ?? AppLocalizations.of(context).notSpecified,
            style: GoogleFonts.anuphan(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.baseBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionCodeCard(BuildContext context, AgentDetails agent) {
    return _ProfileCard(
      title: AppLocalizations.of(context).profile_agent_code,
      onCopy: (BuildContext context) {
        Clipboard.setData(ClipboardData(text: agent.agentCredential));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).connectionCodeCopied,
              style: GoogleFonts.anuphan(fontSize: 14, color: AppColors.white),
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  agent.agentCredential,
                  style: GoogleFonts.anuphan(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.baseBlack,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            AppLocalizations.of(context).notConnectedAgency,
            style: GoogleFonts.anuphan(fontSize: 12, color: AppColors.baseGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkInfoCard(BuildContext context, AgentDetails agent) {
    final hasWorkInfo =
        agent.companyName != null && agent.companyName!.isNotEmpty;

    if (!hasWorkInfo) {
      return _ProfileCard(
        title: AppLocalizations.of(context).workInfoLabel,
        child: DottedAddButton(
          label: AppLocalizations.of(context).addInfo,
          onTap: () => context.push('/profile/work-info', extra: agent),
        ),
      );
    }

    return _ProfileCard(
      title: AppLocalizations.of(context).workInfoLabel,
      onEdit: () => context.push('/profile/work-info', extra: agent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWorkInfoRow('assets/icons/briefcase.svg', agent.companyName!),
          const SizedBox(height: 12),
          _buildWorkInfoRow(
            'assets/icons/file-check.svg',
            'เลขที่ใบอนุญาต ${agent.licenseNumber ?? AppLocalizations.of(context).notSpecified}',
          ),
          const SizedBox(height: 12),
          _buildWorkInfoRow(
            'assets/icons/hour-glass.svg',
            'ประสบการณ์ ${agent.yearsOfExperience ?? 0} ปี',
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).languageProficiency,
            style: GoogleFonts.anuphan(
              fontSize: 14,
              color: AppColors.baseGrey,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          if (agent.languages?.isNotEmpty == true)
            ...agent.languages!.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${e.key} : ${e.value}',
                  style: GoogleFonts.anuphan(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.baseBlack,
                  ),
                ),
              ),
            )
          else
            Text(
              AppLocalizations.of(context).notSpecified,
              style: GoogleFonts.anuphan(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.baseBlack,
              ),
            ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).socialLinks,
            style: GoogleFonts.anuphan(
              fontSize: 14,
              color: AppColors.baseGrey,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          if (agent.socialLinks?.isNotEmpty == true)
            ...agent.socialLinks!.entries.map((e) {
              String iconPath = '';
              final key = e.key.toLowerCase();
              if (key.contains('facebook')) {
                iconPath = 'assets/icons/social/facebook-square.png';
              } else if (key.contains('instagram')) {
                iconPath = 'assets/icons/social/instagram-square.png';
              } else if (key.contains('line')) {
                iconPath = 'assets/icons/social/line.png';
              } else if (key.contains('linkedin')) {
                iconPath = 'assets/icons/social/linkedin.png';
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    if (iconPath.isNotEmpty) ...[
                      Image.asset(iconPath, width: 24, height: 24),
                      const SizedBox(width: 12),
                    ] else ...[
                      const Icon(
                        Icons.link,
                        size: 24,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        e.value
                            .toString()
                            .replaceFirst(RegExp(r'^https?://'), '')
                            .replaceFirst(RegExp(r'^www\.'), '')
                            .split('/')
                            .lastWhere(
                              (part) => part.isNotEmpty,
                              orElse: () => '',
                            ),
                        style: GoogleFonts.anuphan(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.baseBlack,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            })
          else
            Text(
              AppLocalizations.of(context).notSpecified,
              style: GoogleFonts.anuphan(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.baseBlack,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWorkInfoRow(String iconPath, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: SvgPicture.asset(
            iconPath,
            width: 16,
            height: 16,
            fit: BoxFit.scaleDown,
            colorFilter: const ColorFilter.mode(
              AppColors.primary,
              BlendMode.srcIn,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.anuphan(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.baseBlack,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceAreaCard(BuildContext context, AgentDetails agent) {
    final hasServiceArea =
        agent.reachableRadius != null &&
        agent.serviceAreaCenterLat != null &&
        agent.serviceAreaCenterLng != null;

    if (!hasServiceArea) {
      return _ProfileCard(
        title: AppLocalizations.of(context).serviceAreaLabel,
        child: DottedAddButton(
          label: AppLocalizations.of(context).addInfo,
          onTap: () => context.push('/profile/service-area', extra: agent),
        ),
      );
    }

    final lat = double.tryParse(agent.serviceAreaCenterLat!);
    final lng = double.tryParse(agent.serviceAreaCenterLng!);

    return _ProfileCard(
      title: AppLocalizations.of(context).serviceAreaLabel,
      onEdit: () => context.push('/profile/service-area', extra: agent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MapView(
            properties: [],
            height: 120,
            initialLocation: LatLng(lat ?? 0, lng ?? 0),
            showCenterMarker: true,
            radius: (double.tryParse(agent.reachableRadius ?? '0') ?? 0) * 1000,
          ),
          const SizedBox(height: 16),
          _buildWorkInfoRow(
            'assets/icons/map-pin.svg',
            agent.address ?? AppLocalizations.of(context).addressNotSpecified,
          ),
          const SizedBox(height: 12),
          _buildWorkInfoRow(
            'assets/icons/chart-15.svg',
            'รัศมีการทำงาน ${double.tryParse(agent.reachableRadius ?? '')?.toStringAsFixed(2) ?? agent.reachableRadius} ก.ม.',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String icon, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: SvgPicture.asset(
            icon,
            width: 16,
            height: 16,
            fit: BoxFit.scaleDown,
            colorFilter: const ColorFilter.mode(
              AppColors.primary,
              BlendMode.srcIn,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.anuphan(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.baseBlack,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCompletenessWidget(
    BuildContext context,
    AgentDetails agent,
  ) {
    // Basic account: Lv 1
    // Work Info: Lv 2
    // Service Area: Lv 3
    final hasWorkInfo = agent.companyName?.isNotEmpty == true;
    final hasServiceArea = agent.reachableRadius?.isNotEmpty == true;

    int currentLevel = 1;
    if (hasWorkInfo) currentLevel = 2;
    if (hasWorkInfo && hasServiceArea) currentLevel = 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context).profileCompleteness,
              style: GoogleFonts.anuphan(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.baseBlack,
              ),
            ),
            AppBadge(
              label: 'Lv. $currentLevel',
              color: BadgeColor.blue,
              style: BadgeStyle.plain,
              hasBorder: true,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: List.generate(3, (index) {
            final isActive = index < currentLevel;
            return Expanded(
              child: Container(
                height: 12,
                margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: isActive
                      ? AppColors.primary
                      : AppColors.baseLightGrey.withValues(alpha: 0.5),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onEdit;
  final Function(BuildContext)? onCopy;
  const _ProfileCard({
    required this.title,
    required this.child,
    this.onEdit,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.baseLightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppBadge(
                label: title,
                color: BadgeColor.blue,
                style: BadgeStyle.plain,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              const Spacer(),
              if (onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  child: SvgPicture.asset(
                    'assets/icons/edit.svg',
                    colorFilter: const ColorFilter.mode(
                      AppColors.baseGrey,
                      BlendMode.srcIn,
                    ),
                    width: 20,
                    height: 20,
                    fit: BoxFit.scaleDown,
                  ),
                ),
              if (onCopy != null)
                GestureDetector(
                  onTap: () => onCopy?.call(context),
                  child: SvgPicture.asset(
                    'assets/icons/copy.svg',
                    colorFilter: const ColorFilter.mode(
                      AppColors.baseGrey,
                      BlendMode.srcIn,
                    ),
                    width: 20,
                    height: 20,
                    fit: BoxFit.scaleDown,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class DottedAddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const DottedAddButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: AppColors.baseLightGrey,
          strokeWidth: 1,
          dashWidth: 6,
          dashSpace: 4,
          radius: 12,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/plus.svg',
                width: 16,
                height: 16,
                fit: BoxFit.scaleDown,
                colorFilter: const ColorFilter.mode(
                  AppColors.baseGrey,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.anuphan(
                  color: AppColors.baseDarkGrey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
