import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:youragent/utils/image_url_helper.dart';

class ProfileAvatar extends StatelessWidget {
  final String name;
  final VoidCallback onEditPressed;
  final XFile? selectedImage;
  final String? profilePhoto;

  const ProfileAvatar({
    super.key,
    required this.name,
    required this.onEditPressed,
    this.selectedImage,
    this.profilePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = name.trim().isNotEmpty ? name.trim().characters.first : '?';
    // Blue gradient colors for avatar
    const blueTop = Color(0xFF3B82F6);
    const blueBottom = Color(0xFF1E40AF);

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        children: [
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onEditPressed,
                child: ClipOval(
                  child: selectedImage != null
                      ? Image.file(
                          File(selectedImage!.path),
                          fit: BoxFit.cover,
                        )
                      : _buildAvatarContent(theme, initial),
                ),
              ),
            ),
          ),
          Positioned(
            right: 18,
            bottom: 18,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onEditPressed,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SvgPicture.asset(
                    'assets/icons/form/edit-2.svg',
                    width: 18,
                    height: 18,
                    colorFilter: ColorFilter.mode(
                      theme.colorScheme.onSurface.withValues(alpha: 0.75),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarContent(ThemeData theme, String initial) {
    final profilePhotoUrl = ImageUrlHelper.getProfilePhotoUrl(profilePhoto);
    
    if (profilePhotoUrl != null) {
      return CachedNetworkImage(
        imageUrl: profilePhotoUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildGradientAvatar(theme, initial),
        errorWidget: (context, url, error) => _buildGradientAvatar(theme, initial),
      );
    }
    
    return _buildGradientAvatar(theme, initial);
  }

  Widget _buildGradientAvatar(ThemeData theme, String initial) {
    const blueTop = Color(0xFF3B82F6);
    const blueBottom = Color(0xFF1E40AF);
    
    return DecoratedBox(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [blueTop, blueBottom],
        ),
      ),
      child: Center(
        child: Text(
          initial.toUpperCase(),
          style: theme.textTheme.displayLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
