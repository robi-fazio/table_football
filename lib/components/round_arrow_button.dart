import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class RoundArrowButton extends PositionComponent with TapCallbacks {
  final bool isRight;
  final VoidCallback? onPressed;
  final VoidCallback? onReleased;
  final Color color;

  RoundArrowButton({
    required Vector2 position,
    required Vector2 size,
    required this.isRight,
    this.onPressed,
    this.onReleased,
    this.color = Colors.green,
  }) : super(position: position, size: size, anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    // Top-left to bottom-right gradient
    // We use a slightly darker version for the bottom-right
    final hsl = HSLColor.fromColor(color);
    final darkerColor = hsl.withLightness((hsl.lightness - 0.1).clamp(0.0, 1.0)).toColor();
    
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color, darkerColor],
      ).createShader(size.toRect())
      ..style = PaintingStyle.fill;
    
    final radius = size.x / 2;
    canvas.drawCircle(Offset(radius, radius), radius, paint);

    // Border: 20% of circle width, 40% transparent (60% opacity)
    final borderPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.x * 0.2;
    canvas.drawCircle(Offset(radius, radius), radius, borderPaint);

    final arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.x * 0.05
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final padding = size.x * 0.25;
    if (isRight) {
      path.moveTo(padding, size.y * 0.5);
      path.lineTo(size.x - padding, size.y * 0.5);
      path.lineTo(size.x - padding - size.x * 0.2, size.y * 0.3);
      path.moveTo(size.x - padding, size.y * 0.5);
      path.lineTo(size.x - padding - size.x * 0.2, size.y * 0.7);
    } else {
      path.moveTo(size.x - padding, size.y * 0.5);
      path.lineTo(padding, size.y * 0.5);
      path.lineTo(padding + size.x * 0.2, size.y * 0.3);
      path.moveTo(padding, size.y * 0.5);
      path.lineTo(padding + size.x * 0.2, size.y * 0.7);
    }
    canvas.drawPath(path, arrowPaint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onPressed?.call();
  }
  
  @override
  void onTapUp(TapUpEvent event) {
    onReleased?.call();
  }
  
  @override
  void onTapCancel(TapCancelEvent event) {
    onReleased?.call();
  }
}
