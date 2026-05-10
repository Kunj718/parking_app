import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ScannerOverlayPainter extends CustomPainter {
  final double animValue; // 0.0 → 1.0 scan line animation
  final bool isScanned;

  const ScannerOverlayPainter({
    required this.animValue,
    required this.isScanned,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final dimPaint = Paint()..color = Colors.black.withOpacity(0.72);
    final frameColor = isScanned ? AppColors.emerald : AppColors.electricBlue;

    // Frame dimensions
    const frameSize = 260.0;
    final cx = size.width / 2;
    final cy = size.height / 2 - 40;
    final frameRect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: frameSize,
      height: frameSize,
    );

    // Dim overlay with hole
    final outerPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final innerPath = Path()
      ..addRRect(RRect.fromRectAndRadius(frameRect, const Radius.circular(20)));
    final dimPath = Path.combine(PathOperation.difference, outerPath, innerPath);
    canvas.drawPath(dimPath, dimPaint);

    // Corner brackets
    const cornerLen = 32.0;
    const cornerRadius = 6.0;
    final cornerPaint = Paint()
      ..color = frameColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    _drawCorners(canvas, frameRect, cornerLen, cornerRadius, cornerPaint);

    // Scan line
    if (!isScanned) {
      final scanY = frameRect.top + frameRect.height * animValue;
      final scanPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            AppColors.electricBlue.withOpacity(0),
            AppColors.electricBlue.withOpacity(0.85),
            AppColors.electricBlue.withOpacity(0),
          ],
        ).createShader(Rect.fromLTWH(frameRect.left, scanY - 1, frameRect.width, 2));
      canvas.drawRect(
        Rect.fromLTWH(frameRect.left, scanY - 1, frameRect.width, 2),
        scanPaint,
      );
      // Glow below line
      final glowPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.electricBlue.withOpacity(0.15),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(frameRect.left, scanY, frameRect.width, 24));
      canvas.drawRect(
        Rect.fromLTWH(frameRect.left, scanY, frameRect.width, 24),
        glowPaint,
      );
    } else {
      // Success fill
      final successPaint = Paint()
        ..color = AppColors.emerald.withOpacity(0.12)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(frameRect, const Radius.circular(20)),
        successPaint,
      );
    }
  }

  void _drawCorners(
    Canvas canvas,
    Rect rect,
    double len,
    double r,
    Paint paint,
  ) {
    final tl = rect.topLeft;
    final tr = rect.topRight;
    final bl = rect.bottomLeft;
    final br = rect.bottomRight;

    // Top-left
    canvas.drawPath(
        Path()
          ..moveTo(tl.dx, tl.dy + len)
          ..lineTo(tl.dx, tl.dy + r)
          ..arcToPoint(Offset(tl.dx + r, tl.dy), radius: Radius.circular(r))
          ..lineTo(tl.dx + len, tl.dy),
        paint);
    // Top-right
    canvas.drawPath(
        Path()
          ..moveTo(tr.dx - len, tr.dy)
          ..lineTo(tr.dx - r, tr.dy)
          ..arcToPoint(Offset(tr.dx, tr.dy + r), radius: Radius.circular(r), clockwise: false)
          ..lineTo(tr.dx, tr.dy + len),
        paint);
    // Bottom-left
    canvas.drawPath(
        Path()
          ..moveTo(bl.dx, bl.dy - len)
          ..lineTo(bl.dx, bl.dy - r)
          ..arcToPoint(Offset(bl.dx + r, bl.dy), radius: Radius.circular(r), clockwise: false)
          ..lineTo(bl.dx + len, bl.dy),
        paint);
    // Bottom-right
    canvas.drawPath(
        Path()
          ..moveTo(br.dx - len, br.dy)
          ..lineTo(br.dx - r, br.dy)
          ..arcToPoint(Offset(br.dx, br.dy - r), radius: Radius.circular(r))
          ..lineTo(br.dx, br.dy - len),
        paint);
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter old) =>
      old.animValue != animValue || old.isScanned != isScanned;
}
