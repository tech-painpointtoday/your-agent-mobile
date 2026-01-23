import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';

/// Full-screen image modal for viewing property images
class ImageModal extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const ImageModal({super.key, required this.images, this.initialIndex = 0});

  @override
  State<ImageModal> createState() => _ImageModalState();
}

class _ImageModalState extends State<ImageModal> {
  late PageController _pageController;
  late int _currentIndex;
  static const int _initialPage = 5000; // Start in the middle for looping

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    // Calculate initial page position
    final initialPage = _initialPage + widget.initialIndex;
    _pageController = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int pageIndex) {
    final actualIndex = pageIndex % widget.images.length;
    setState(() {
      _currentIndex = actualIndex;
    });
    // Jump back to middle if we're getting too far from center
    if (pageIndex < _initialPage - 1000 || pageIndex > _initialPage + 1000) {
      _pageController.jumpToPage(_initialPage + actualIndex);
    }
  }

  void _previousImage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextImage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black87,
        child: Stack(
          children: [
            // Main content: Image and thumbnails in column
            Column(
              children: [
                // Top bar with counter and close button
                SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_currentIndex + 1}/${widget.images.length}',
                          style: GoogleFonts.anuphan(
                            fontSize: 16,
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.white,
                            size: 28,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Main image viewer - takes remaining space with fixed aspect ratio
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Center(
                        child: AspectRatio(
                          aspectRatio: 4 / 3,
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: _onPageChanged,
                            itemCount: null, // infinite loop via page index
                            itemBuilder: (context, pageIndex) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: InteractiveViewer(
                                  minScale: 0.5,
                                  maxScale: 3.0,
                                  child: CachedNetworkImage(
                                    imageUrl: widget.images[_currentIndex],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: const Color(0xFFF5F5F5),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                              ),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                          color: const Color(0xFFF5F5F5),
                                          child: const Icon(
                                            Icons.image_not_supported,
                                          ),
                                        ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom thumbnails - fixed height, no overlap
                if (widget.images.length > 1)
                  SafeArea(
                    child: Container(
                      height: 120,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Left arrow - icon only
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: IconButton(
                              onPressed: _previousImage,
                              icon: const Icon(
                                Icons.chevron_left,
                                color: AppColors.white,
                                size: 48,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                              splashRadius: 20,
                            ),
                          ),
                          // Thumbnails - centered
                          Center(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(widget.images.length, (
                                  index,
                                ) {
                                  final isSelected = index == _currentIndex;
                                  return GestureDetector(
                                    onTap: () {
                                      final currentPage =
                                          _pageController.page?.round() ??
                                          (_initialPage + widget.initialIndex);
                                      final currentImageIndex =
                                          currentPage % widget.images.length;
                                      final targetPage =
                                          currentPage -
                                          currentImageIndex +
                                          index;
                                      _pageController.animateToPage(
                                        targetPage,
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      margin: EdgeInsets.only(
                                        right: index < widget.images.length - 1
                                            ? 16
                                            : 0,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.jungleGreen
                                              : Colors.transparent,
                                          width: 3,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: CachedNetworkImage(
                                          imageUrl: widget.images[index],
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(
                                            color: const Color(0xFFF5F5F5),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(
                                                      Theme.of(
                                                        context,
                                                      ).colorScheme.primary,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                                color: const Color(0xFFF5F5F5),
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                ),
                                              ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),

                          // Right arrow - icon only
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: IconButton(
                              onPressed: _nextImage,
                              icon: const Icon(
                                Icons.chevron_right,
                                color: AppColors.white,
                                size: 48,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                              splashRadius: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
