import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../backgrounds/blue_wave_background.dart';

/// A reusable silver app bar widget that can be used in CustomScrollView
/// Returns the SliverAppBar and provides scroll controller management
class SilverAppBarWidget extends StatefulWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget? actionWidget;
  final Widget? searchBar;
  final double fadeThreshold;
  final double preferredHeight;

  const SilverAppBarWidget({
    super.key,
    this.title,
    this.titleWidget,
    this.actionWidget,
    this.searchBar,
    this.fadeThreshold = 100.0,
    this.preferredHeight = 132.0,
  });

  @override
  State<SilverAppBarWidget> createState() => _SilverAppBarWidgetState();
}

class _SilverAppBarWidgetState extends State<SilverAppBarWidget> {
  double _appBarOpacity = 0.0;

  void updateOpacity(double opacity) {
    if ((opacity - _appBarOpacity).abs() > 0.01) {
      setState(() {
        _appBarOpacity = opacity;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      expandedHeight: 0,
      toolbarHeight: 0, // Set to 0 since we're using bottom property
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: Stack(
        children: [
          // Fading blue curtain
          Positioned.fill(
            child: Opacity(
              opacity: _appBarOpacity,
              child: const BlueWaveBackground(
                firstColor: Color(0xFF1743C7),
                secondColor: Color(0xFF1743C7),
              ),
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(widget.preferredHeight),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: widget.preferredHeight),
          child: Stack(
            children: [
              // Use the actual BlueWaveBackground widget with opacity
              Positioned.fill(
                child: Opacity(
                  opacity: _appBarOpacity,
                  child: const BlueWaveBackground(),
                ),
              ),
              // Content on top
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header above search
                  _buildHeader(),
                  if (widget.searchBar != null) ...[
                    const SizedBox(height: 8),
                    // Search bar below header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: widget.searchBar!,
                    ),
                  ] else
                    const SizedBox(height: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    // If titleWidget is provided, use it directly (it handles its own layout)
    if (widget.titleWidget != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        width: double.infinity,
        child: widget.titleWidget!,
      );
    }

    // Otherwise, use the standard layout with title and action
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Spacer(),
          Expanded(
            flex: 3,
            child: widget.title != null
                ? Text(
                    widget.title!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.anuphan(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: widget.actionWidget ?? const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper widget that wraps a screen with silver app bar functionality
class SilverAppBarScreen extends StatefulWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget? actionWidget;
  final Widget? searchBar;
  final Widget child;
  final double fadeThreshold;
  final double backgroundHeight;

  const SilverAppBarScreen({
    super.key,
    this.title,
    this.titleWidget,
    this.actionWidget,
    this.searchBar,
    required this.child,
    this.fadeThreshold = 100.0,
    this.backgroundHeight = 280.0,
    this.preferredHeight = 160.0,
  });

  final double preferredHeight;

  @override
  State<SilverAppBarScreen> createState() => _SilverAppBarScreenState();
}

class _SilverAppBarScreenState extends State<SilverAppBarScreen> {
  late ScrollController _scrollController;
  double _appBarOpacity = 0.0;
  final GlobalKey<_SilverAppBarWidgetState> _appBarKey =
      GlobalKey<_SilverAppBarWidgetState>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final double newOpacity = (_scrollController.offset / widget.fadeThreshold)
        .clamp(0.0, 1.0);
    _appBarKey.currentState?.updateOpacity(newOpacity);

    if ((newOpacity - _appBarOpacity).abs() > 0.01) {
      setState(() {
        _appBarOpacity = newOpacity;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Layer 1 (Bottom): Fixed BlueWaveBackground with inverse opacity
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: widget.backgroundHeight,
            child: Opacity(
              opacity: 1.0 - _appBarOpacity, // Fade out as app bar fades in
              child: const BlueWaveBackground(),
            ),
          ),

          // Layer 2 (Top): Scrollable Content
          Positioned.fill(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Sticky App Bar with fade effect
                SilverAppBarWidget(
                  key: _appBarKey,
                  title: widget.title,
                  titleWidget: widget.titleWidget,
                  actionWidget: widget.actionWidget,
                  searchBar: widget.searchBar,
                  preferredHeight: widget.preferredHeight,
                ),

                // Content
                SliverToBoxAdapter(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
