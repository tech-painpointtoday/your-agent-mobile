import 'dart:math' as math;
import 'package:flutter/material.dart';

class PieChartWidget extends StatelessWidget {
  final Map<String, int> data;
  final List<Color> colors;
  final double size;
  final double strokeWidth;

  const PieChartWidget({
    super.key,
    required this.data,
    required this.colors,
    this.size = 120,
    this.strokeWidth = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(width: size, height: size);
    }

    final total = data.values.fold<int>(0, (sum, value) => sum + value);
    if (total == 0) {
      return SizedBox(width: size, height: size);
    }

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PieChartPainter(
          data: data,
          colors: colors,
          strokeWidth: strokeWidth,
          total: total,
        ),
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final Map<String, int> data;
  final List<Color> colors;
  final double strokeWidth;
  final int total;

  _PieChartPainter({
    required this.data,
    required this.colors,
    required this.strokeWidth,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    double startAngle = -math.pi / 2; // Start from top

    int colorIndex = 0;
    for (final entry in data.entries) {
      final value = entry.value;
      final sweepAngle = (value / total) * 2 * math.pi;

      final paint = Paint()
        ..color = colors[colorIndex % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
      colorIndex++;
    }
  }

  @override
  bool shouldRepaint(_PieChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.colors != colors ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.total != total;
  }
}


