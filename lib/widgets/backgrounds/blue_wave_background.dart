import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ColorsWaveBackground extends StatelessWidget {
  final Widget? child;
  final Color firstColor;
  final Color secondColor;
  final bool hasFilter;

  const ColorsWaveBackground({
    super.key,
    this.child,
    this.firstColor = const Color(0xFF1743C7),
    this.secondColor = const Color(0xFF64D6FF),
    this.hasFilter = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double parentWidth = constraints.maxWidth;
        final double parentHeight = constraints.maxHeight.isInfinite
            ? MediaQuery.of(context).size.height
            : constraints.maxHeight;

        final double glowWidth = parentWidth * 1.5;
        final double glowHeight = parentWidth * 1.2;

        final double positionRight = -glowWidth * 0.4;
        final double positionBottom = -glowHeight * 0.65;

        return Stack(
          children: [
            if (!hasFilter)
              CustomPaint(
                painter: _BlueWavePainter(
                  firstColor: firstColor,
                  secondColor: secondColor,
                ),
                size: Size(parentWidth, parentHeight),
                child: SizedBox.expand(child: child),
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [firstColor, secondColor],
                  ),
                ),
                child: SizedBox.expand(child: child),
              ),

            if (hasFilter)
              Positioned(
                right: positionRight,
                bottom: positionBottom,
                width: glowWidth,
                height: glowHeight,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.elliptical(glowWidth, glowHeight),
                    ),
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.64,
                      colors: [
                        Color(0xFF7EFF81).withOpacity(0.8),
                        Color(0xFF7EFF81).withOpacity(0.0),
                      ],
                      stops: const [0.4, 0.8],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _BlueWavePainter extends CustomPainter {
  final Color firstColor;
  final Color secondColor;

  const _BlueWavePainter({required this.firstColor, required this.secondColor});

  @override
  void paint(Canvas canvas, Size size) {
    // 1) Base vertical gradient – deep blue to light blue
    final Paint backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          firstColor, // deep blue (top)
          secondColor, // light cyan (bottom)
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // 2) Single smooth wave band (lighter overlay)
    final Paint wavePaint = Paint()
      ..color = AppColors.white.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    // Start the wave a bit above the vertical center and create
    // a gentle S-curve towards the right.
    final Path wavePath = Path()..moveTo(0, size.height * 0.55);
    wavePath.cubicTo(
      size.width * 0.25,
      size.height * 0.48,
      size.width * 0.60,
      size.height * 0.65,
      size.width,
      size.height * 0.58,
    );
    // Close the shape downwards so it blends into the light bottom.
    wavePath
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Backwards-compatible alias used by some screens.
///
/// `test_youragent` used `BlueWaveBackground`, while the current implementation
/// is `ColorsWaveBackground`. Keeping this wrapper avoids having to update all
/// call sites.
class BlueWaveBackground extends ColorsWaveBackground {
  const BlueWaveBackground({
    super.key,
    super.child,
    super.firstColor,
    super.secondColor,
    super.hasFilter,
  });
}
