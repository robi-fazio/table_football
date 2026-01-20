import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class KickButton extends PositionComponent with TapCallbacks {
  final bool isRight;
  final VoidCallback onTap;
  final Color color;

  KickButton({
    required Vector2 position,
    required Vector2 size,
    required this.isRight,
    required this.onTap,
    required this.color,
  }) : super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    final rect = size.toRect();
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(5)), paint);

    final arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.005;

    final path = Path();
    if (isRight) {
      path.moveTo(size.x * 0.3, size.y * 0.2);
      path.lineTo(size.x * 0.7, size.y * 0.5);
      path.lineTo(size.x * 0.3, size.y * 0.8);
    } else {
      path.moveTo(size.x * 0.7, size.y * 0.2);
      path.lineTo(size.x * 0.3, size.y * 0.5);
      path.lineTo(size.x * 0.7, size.y * 0.8);
    }
    canvas.drawPath(path, arrowPaint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap();
  }
}
