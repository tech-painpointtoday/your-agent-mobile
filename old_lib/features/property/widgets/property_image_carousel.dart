import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:youragent/widgets/shared_carousel_controller.dart';

class PropertyImageCarousel extends StatefulWidget {
  final String primaryImageUrl;
  final List<String>? allImageUrls;
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const PropertyImageCarousel({
    super.key,
    required this.primaryImageUrl,
    this.allImageUrls,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<PropertyImageCarousel> createState() => _PropertyImageCarouselState();
}

class _PropertyImageCarouselState extends State<PropertyImageCarousel> {
  late PageController _pageController;
  late List<String> _images;
  int _currentPage = 0;
  bool _isHovered = false;
  late SharedCarouselController _sharedController;
  int _lastSharedTick = 0;
  int _pausedAtTick = 0;

  @override
  void initState() {
    super.initState();
    // Combine primary image with all images, removing duplicates
    final normalizedPrimary = _normalizedImageUrl(widget.primaryImageUrl);
    _images = [normalizedPrimary];
    if (widget.allImageUrls != null && widget.allImageUrls!.isNotEmpty) {
      for (final url in widget.allImageUrls!) {
        final normalizedUrl = _normalizedImageUrl(url);
        if (!_images.contains(normalizedUrl)) {
          _images.add(normalizedUrl);
        }
      }
    }

    _pageController = PageController(initialPage: 0);
    _sharedController = SharedCarouselController();
    _lastSharedTick = _sharedController.currentTick;
    _pausedAtTick = _lastSharedTick;

    // Listen to shared controller for synchronized auto-play
    if (_images.length > 1) {
      _sharedController.addListener(_onSharedTick);
    }
  }

  @override
  void dispose() {
    _sharedController.removeListener(_onSharedTick);
    _pageController.dispose();
    super.dispose();
  }

  void _onSharedTick() {
    if (!mounted || _images.length <= 1) return;

    final currentTick = _sharedController.currentTick;

    if (_isHovered) {
      // When hovered, just track the tick but don't animate
      _pausedAtTick = currentTick;
      return;
    }

    // When not hovered, advance on each tick
    if (currentTick > _lastSharedTick) {
      _lastSharedTick = currentTick;
      if (_pageController.hasClients) {
        if (_currentPage < _images.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _goToPrevious() {
    if (_pageController.hasClients) {
      final newPage = _currentPage > 0 ? _currentPage - 1 : _images.length - 1;
      setState(() {
        _currentPage = newPage;
      });
      _pageController.animateToPage(
        newPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNext() {
    if (_pageController.hasClients) {
      final newPage = _currentPage < _images.length - 1 ? _currentPage + 1 : 0;
      setState(() {
        _currentPage = newPage;
      });
      _pageController.animateToPage(
        newPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String _normalizedImageUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    if (url.startsWith('/')) {
      return 'https://dev.yourhome.co.th$url';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    if (_images.length == 1) {
      // Single image - no carousel needed
      return ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: _normalizedImageUrl(_images[0]),
          fit: BoxFit.cover,
          width: widget.width,
          height: widget.height,
          placeholder: (context, url) => Container(
            color: const Color(0xFFF5F5F5),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: const Color(0xFFF5F5F5),
            child: const Icon(Icons.image_not_supported),
          ),
        ),
      );
    }

    // Multiple images - show carousel with hover controls
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
          _pausedAtTick = _sharedController.currentTick;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
        // Sync to current shared position when unhovered
        final currentTick = _sharedController.currentTick;
        final ticksPassed = currentTick - _pausedAtTick;
        if (ticksPassed > 0 && _images.length > 1) {
          final targetPage = (_currentPage + ticksPassed) % _images.length;
          _currentPage = targetPage;
          _lastSharedTick = currentTick;
          if (_pageController.hasClients) {
            _pageController.animateToPage(
              _currentPage,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        }
      },
      child: Stack(
        children: [
          // Image Carousel
          ClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: _normalizedImageUrl(_images[index]),
                  fit: BoxFit.cover,
                  width: widget.width,
                  height: widget.height,
                  placeholder: (context, url) => Container(
                    color: const Color(0xFFF5F5F5),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: const Color(0xFFF5F5F5),
                    child: const Icon(Icons.image_not_supported),
                  ),
                );
              },
            ),
          ),
          // Navigation Buttons and Indicators (shown on hover)
          if (_isHovered) ...[
            // Previous Button
            Positioned(
              top: 137,
              left: 8,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _goToPrevious,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      size: 18,
                      color: Color(0xFF181D27),
                    ),
                  ),
                ),
              ),
            ),
            // Next Button
            Positioned(
              top: 137,
              right: 8,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _goToNext,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Color(0xFF181D27),
                    ),
                  ),
                ),
              ),
            ),
            // Indicator Dots
            Positioned(
              bottom: 44,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      _images.length,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: index == _currentPage
                                ? Colors.white
                                : const Color(0xFFA4A7AE),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
