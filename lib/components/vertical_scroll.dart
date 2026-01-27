import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class VerticalScroll extends PositionComponent with DragCallbacks {
  final double minTopY;
  final double maxTopY;
  final ValueChanged<double> onScroll;
  final Color color;

  VerticalScroll({
    required Vector2 initialPosition,
    required double width,
    required double height,
    required this.minTopY,
    required this.maxTopY,
    required this.onScroll,
    this.color = Colors.green,
  }) : super(
          position: initialPosition,
          size: Vector2(width, height),
          anchor: Anchor.center,
        );

  @override
  void onDragUpdate(DragUpdateEvent event) {
    // Current top Y
    double currentTop = position.y - size.y / 2;
    
    // Desired new top Y
    double newTop = currentTop + event.localDelta.y;
    
    // Clamp to constraints
    newTop = min(max(newTop, minTopY), maxTopY);
    
    // Update center position
    position.y = newTop + size.y / 2;
    
    // Calculate progress (0.0 at top limit, 1.0 at bottom limit)
    // Actually, let's pass the raw top position or normalized?
    // User wants movement sync. Let's pass normalized 0..1
    double range = maxTopY - minTopY;
    double progress = (newTop - minTopY) / range;
    
    onScroll(progress);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    final rect = size.toRect();
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(0.02)), paint);
  }
}
