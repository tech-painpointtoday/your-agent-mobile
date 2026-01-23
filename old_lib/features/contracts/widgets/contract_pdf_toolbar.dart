import 'package:flutter/material.dart';

/// Toolbar widget for PDF viewer controls
/// Matches the reference image layout exactly
class ContractPdfToolbar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final double zoom;
  final bool fitToWidth;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback onZoomOut;
  final VoidCallback onZoomIn;
  final VoidCallback onToggleFit;
  final VoidCallback onPrint;
  final VoidCallback onDownload;
  final VoidCallback onFullScreen;
  final VoidCallback onRotate;
  final VoidCallback onMenu;
  final String fileName;
  final List<PopupMenuEntry> Function(BuildContext)? menuItemsBuilder;
  final List<PopupMenuEntry> Function(BuildContext)? fullScreenMenuItemsBuilder;

  const ContractPdfToolbar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.zoom,
    required this.fitToWidth,
    required this.onPrev,
    required this.onNext,
    required this.onZoomOut,
    required this.onZoomIn,
    required this.onToggleFit,
    required this.onPrint,
    required this.onDownload,
    required this.onFullScreen,
    required this.onRotate,
    required this.onMenu,
    required this.fileName,
    this.menuItemsBuilder,
    this.fullScreenMenuItemsBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Vertical divider widget
    Widget buildDivider() {
      return Container(
        width: 1,
        height: 20,
        color: const Color(0xFF5A5A5A),
        margin: const EdgeInsets.symmetric(horizontal: 8),
      );
    }

    // Left section: Hamburger menu + File name
    final leftSection = <Widget>[
      _ToolbarIcon(
        icon: Icons.menu,
        onTap: onMenu,
        menuItemsBuilder: menuItemsBuilder,
      ),
      const SizedBox(width: 12),
      Flexible(
        child: Text(
          fileName,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            overflow: TextOverflow.ellipsis,
          ),
          maxLines: 1,
        ),
      ),
    ];

    // Center section: Page indicator, zoom controls, fit width, rotate
    final centerSection = <Widget>[
      // Page indicator with highlighted current page
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '$currentPage',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      Text(
        ' / $totalPages',
        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
      buildDivider(),
      // Zoom controls
      _ToolbarIcon(icon: Icons.remove, onTap: onZoomOut),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '${zoom.round()}%',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      const SizedBox(width: 8),
      _ToolbarIcon(icon: Icons.add, onTap: onZoomIn),
      buildDivider(),
    ];

    // Right section: Download, Print, More options
    final rightSection = <Widget>[
      // Fit width icon
      Flexible(
        child: _ToolbarIcon(icon: Icons.fit_screen, onTap: onToggleFit),
      ),
      // Rotate icon
      Flexible(
        child: _ToolbarIcon(icon: Icons.rotate_right, onTap: onRotate),
      ),
      Flexible(
        child: _ToolbarIcon(icon: Icons.download, onTap: onDownload),
      ),
      Flexible(
        child: _ToolbarIcon(icon: Icons.print, onTap: onPrint),
      ),
      Flexible(
        child: _ToolbarIcon(
          icon: Icons.more_vert,
          onTap: onFullScreen,
          menuItemsBuilder: fullScreenMenuItemsBuilder,
        ),
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(color: Color(0xFF323639)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 420;
          if (isNarrow) {
            // For narrow screens, allow horizontal scrolling
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...leftSection,
                  const SizedBox(width: 16),
                  ...centerSection,
                  const SizedBox(width: 16),
                  ...rightSection,
                ],
              ),
            );
          }

          // For wide screens, use Spacer to push sections apart
          return Row(
            children: [
              ...leftSection,
              const Spacer(),
              ...centerSection,
              const Spacer(),
              ...rightSection,
            ],
          );
        },
      ),
    );
  }
}

/// Individual icon button for the toolbar
class _ToolbarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final List<PopupMenuEntry> Function(BuildContext)? menuItemsBuilder;

  const _ToolbarIcon({
    required this.icon,
    required this.onTap,
    this.menuItemsBuilder,
  });

  @override
  Widget build(BuildContext context) {
    // If menu items builder is provided, check if it returns items
    if (menuItemsBuilder != null) {
      // Check if menu should be shown (has items)
      final hasMenuItems = menuItemsBuilder!(context).isNotEmpty;

      // If menu items are empty, fall back to InkWell with callback
      if (!hasMenuItems) {
        return Center(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
          ),
        );
      }

      // Use PopupMenuButton for proper positioning when items exist
      return PopupMenuButton(
        icon: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        offset: const Offset(0, 40), // Position menu below the button
        itemBuilder: (menuContext) => menuItemsBuilder!(menuContext),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        color: Theme.of(context).colorScheme.surface,
      );
    }

    // Otherwise, use InkWell for simple tap actions
    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
