import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PitchForeground extends PositionComponent {
  final Vector2 pitchSize;

  PitchForeground({required this.pitchSize}) : super(priority: 5);

  @override
  void render(Canvas canvas) {
    final linePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.005;

    // 1. Outer Boundary
    canvas.drawRect(Rect.fromLTWH(0, 0, pitchSize.x, pitchSize.y), linePaint);
    
    // 2. Center Line
    canvas.drawLine(Offset(pitchSize.x / 2, 0), Offset(pitchSize.x / 2, pitchSize.y), linePaint);
    
    // 3. Center Circle
    canvas.drawCircle(Offset(pitchSize.x / 2, pitchSize.y / 2), 0.1, linePaint);
    // Center Spot
    canvas.drawCircle(Offset(pitchSize.x / 2, pitchSize.y / 2), 0.01, Paint()..color = Colors.yellow);

    // 4. Penalty Boxes
    // Assuming standard proportions relative to pitch size
    final boxWidth = 0.2; // extending into pitch
    final boxHeight = 0.4; // along the goal line
    final goalY = pitchSize.y / 2;
    
    // Left Penalty Box
    canvas.drawRect(Rect.fromLTWH(0, goalY - boxHeight / 2, boxWidth, boxHeight), linePaint);
    
    // Right Penalty Box
    canvas.drawRect(Rect.fromLTWH(pitchSize.x - boxWidth, goalY - boxHeight / 2, boxWidth, boxHeight), linePaint);
  }
}
