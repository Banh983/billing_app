import 'package:flutter/material.dart';

class DashedBorderBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const DashedBorderBox({
    super.key,
    required this.child,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: Container(width: double.infinity, padding: padding, child: child),
    );
  }
}

class DashedLine extends StatelessWidget {
  const DashedLine({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashLinePainter(),
      child: const SizedBox(width: double.infinity, height: 1.4),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const dashWidth = 2.8;
    const dashSpace = 4.0;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    _drawDashedLine(
      canvas,
      Offset(rect.left, rect.top),
      Offset(rect.right, rect.top),
      paint,
      dashWidth,
      dashSpace,
    );
    _drawDashedLine(
      canvas,
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.bottom),
      paint,
      dashWidth,
      dashSpace,
    );
    _drawDashedLine(
      canvas,
      Offset(rect.right, rect.bottom),
      Offset(rect.left, rect.bottom),
      paint,
      dashWidth,
      dashSpace,
    );
    _drawDashedLine(
      canvas,
      Offset(rect.left, rect.bottom),
      Offset(rect.left, rect.top),
      paint,
      dashWidth,
      dashSpace,
    );
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
    final totalDistance = (end - start).distance;
    if (totalDistance == 0) return;

    final direction = (end - start) / totalDistance;
    double distance = 0;

    while (distance < totalDistance) {
      final currentStart = start + direction * distance;
      final currentEnd =
          start + direction * (distance + dashWidth).clamp(0, totalDistance);

      canvas.drawLine(currentStart, currentEnd, paint);
      distance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.2;

    const dashWidth = 6.0;
    const dashSpace = 4.0;

    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset((startX + dashWidth).clamp(0, size.width), 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
