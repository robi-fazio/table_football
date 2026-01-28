import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class VerticalScroll extends PositionComponent with DragCallbacks {
  final ValueChanged<double> onScroll;
  final Color color;
  double _progress = 0.5; // Start in the middle

  VerticalScroll({
    required Vector2 initialPosition,
    required double width,
    required double height,
    required this.onScroll,
    this.color = Colors.green,
  }) : super(
          position: initialPosition,
          size: Vector2(width, height),
          anchor: Anchor.center,
        );

  @override
  void onDragUpdate(DragUpdateEvent event) {
    // Current local Y in track coordinates (from top of track)
    final localY = event.localStartPosition.y + event.localDelta.y;
    
    // Normalize to 0..1
    _progress = (localY / size.y).clamp(0.0, 1.0);
    
    onScroll(_progress);
  }

  @override
  void render(Canvas canvas) {
    // 1. Draw Track (White Bar)
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    final trackRect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRRect(RRect.fromRectAndRadius(trackRect, Radius.circular(size.x / 2)), trackPaint);

    // 2. Draw Handle (Circle)
    final handlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // Radius: make it larger than the track width.
    final handleRadius = size.x * 0.8; 
    
    // Y position based on progress
    final handleY = _progress * size.y;
    
    canvas.drawCircle(Offset(size.x / 2, handleY), handleRadius, handlePaint);
  }
}
