import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class FoosballSlider extends PositionComponent with DragCallbacks {
  final void Function(double) onValueChanged;
  final Color color;
  
  double _scrollValue = 0.5; // 0.0 to 1.0

  FoosballSlider({
    required Vector2 position,
    required Vector2 size,
    required this.onValueChanged,
    required this.color,
  }) : super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    // Track
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(size.toRect(), const Radius.circular(20)), trackPaint);

    // Thumb
    final thumbHeight = size.y * 0.3;
    final thumbY = (1.0 - _scrollValue) * (size.y - thumbHeight);
    final thumbRect = Rect.fromLTWH(0, thumbY, size.x, thumbHeight);
    
    final thumbPaint = Paint()..color = color;
    canvas.drawRRect(RRect.fromRectAndRadius(thumbRect, const Radius.circular(15)), thumbPaint);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    // Vertical drag affects the value
    // Note: event.localDelta.y is in local coordinates.
    // Thumb moves opposite to drag? Standard slider: drag up = value increases?
    // Let's say drag up = value 1.0, drag down = 0.0.
    _scrollValue -= event.localDelta.y / size.y;
    _scrollValue = _scrollValue.clamp(0.0, 1.0);
    onValueChanged(_scrollValue);
  }
}
