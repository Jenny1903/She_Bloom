import 'package:flutter/material.dart';

class BlobPainter extends CustomPainter {
  final Color color;

  BlobPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Start left-middle
    path.moveTo(0, size.height * 0.25);

    // Top curve
    path.cubicTo(
      size.width * 0.25,
      0,
      size.width * 0.75,
      0,
      size.width,
      size.height * 0.25,
    );

    // Right side down
    path.lineTo(size.width, size.height * 0.8);

    // Bottom curve
    path.cubicTo(
      size.width * 0.75,
      size.height,
      size.width * 0.25,
      size.height,
      0,
      size.height * 0.8,
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}