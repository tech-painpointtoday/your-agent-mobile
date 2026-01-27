import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';

/// Property image carousel widget with image counter
class PropertyImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;

  const PropertyImageCarousel({
    super.key,
    required this.imageUrls,
    this.height = 280,
  });

  @override
  State<PropertyImageCarousel> createState() => _PropertyImageCarouselState();
}

class _PropertyImageCarouselState extends State<PropertyImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
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
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: widget.imageUrls[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.basePaleGrey,
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
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
            },
          ),
        ),

        // Image counter badge
        if (widget.imageUrls.length > 1)
          Positioned(
            top: 12,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                '${_currentPage + 1}/${widget.imageUrls.length}',
                style: GoogleFonts.anuphan(
                  color: const Color(0xFFE9EAEB),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

        // Page indicators (dots) at bottom
        if (widget.imageUrls.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.imageUrls.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
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
