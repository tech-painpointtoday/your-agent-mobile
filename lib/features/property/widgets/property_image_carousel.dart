import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:youragent/core/theme/app_colors.dart';

/// Property image carousel widget with image counter
class PropertyImageCarousel extends StatefulWidget {
  final bool isFullScreen;
  final List<String>? imageUrls;
  final List<XFile>? imageFiles;
  final double height;

  const PropertyImageCarousel({
    super.key,
    this.isFullScreen = true,
    this.imageUrls,
    this.imageFiles,
    this.height = 280,
  });

  @override
  State<PropertyImageCarousel> createState() => _PropertyImageCarouselState();
}

class _PropertyImageCarouselState extends State<PropertyImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  int _totalImages = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _updateTotalImages();
  }

  @override
  void didUpdateWidget(PropertyImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageUrls != oldWidget.imageUrls ||
        widget.imageFiles != oldWidget.imageFiles) {
      _updateTotalImages();
    }
  }

  void _updateTotalImages() {
    setState(() {
      if (widget.imageUrls?.isNotEmpty ?? false) {
        _totalImages = widget.imageUrls!.length;
      } else if (widget.imageFiles?.isNotEmpty ?? false) {
        _totalImages = widget.imageFiles!.length;
      } else {
        _totalImages = 0;
      }

      // Reset current page if it's out of bounds
      if (_currentPage >= _totalImages && _totalImages > 0) {
        _currentPage = 0;
        _pageController.jumpToPage(0);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if ((widget.imageUrls?.isEmpty ?? true) &&
        (widget.imageFiles?.isEmpty ?? true)) {
      return Container(
        width: double.infinity,
        height: widget.height,
        color: AppColors.basePaleGrey,
        child: const Icon(
          Icons.image_outlined,
          size: 80,
          color: AppColors.baseGrey,
        ),
      );
    }

    return Stack(
      children: [
        // Image PageView
        SizedBox(
          width: double.infinity,
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _totalImages,
            itemBuilder: (context, index) {
              if ((widget.imageUrls?.length ?? 0) > 0) {
                return CachedNetworkImage(
                  imageUrl: widget.imageUrls![index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.basePaleGrey,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.basePaleGrey,
                    child: const Icon(
                      Icons.broken_image_outlined,
                      size: 80,
                      color: AppColors.baseGrey,
                    ),
                  ),
                );
              } else if ((widget.imageFiles?.length ?? 0) > 0) {
                return Image.file(
                  File(widget.imageFiles![index].path),
                  height: widget.height,
                  width: double.infinity,
                  fit: BoxFit.cover,
                );
              }

              return Container(
                color: AppColors.basePaleGrey,
                child: const Icon(
                  Icons.broken_image_outlined,
                  size: 80,
                  color: AppColors.baseGrey,
                ),
              );
            },
          ),
        ),

        // Image counter badge
        if ((widget.imageUrls?.length ?? 0) > 1 ||
            (widget.imageFiles?.length ?? 0) > 1)
          Positioned(
            top: widget.isFullScreen ? 12 + kToolbarHeight : 12,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
              child: Text(
                '${_currentPage + 1}/$_totalImages',
                style: GoogleFonts.anuphan(
                  color: const Color(0xFFE9EAEB),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

        // Page indicators (dots) at bottom
        if ((widget.imageUrls?.length ?? 0) > 1 ||
            (widget.imageFiles?.length ?? 0) > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _totalImages,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
