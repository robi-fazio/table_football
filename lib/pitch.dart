import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class Pitch extends BodyComponent {
  final Vector2 size;
  final void Function(Team) onGoal;

  Pitch({required this.size, required this.onGoal});

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: Vector2.zero(),
      type: BodyType.static,
    );

    final body = world.createBody(bodyDef);

    // Wall shapes
    _createWall(body, Vector2(0, 0), Vector2(size.x, 0));
    _createWall(body, Vector2(0, size.y), Vector2(size.x, size.y));
    
    final goalHalfWidth = 0.12; 
    
    // Left Goal area
    _createWall(body, Vector2(0, 0), Vector2(0, size.y / 2 - goalHalfWidth));
    _createWall(body, Vector2(0, size.y / 2 + goalHalfWidth), Vector2(0, size.y));
    
    // Right Goal area
    _createWall(body, Vector2(size.x, 0), Vector2(size.x, size.y / 2 - goalHalfWidth));
    _createWall(body, Vector2(size.x, size.y / 2 + goalHalfWidth), Vector2(size.x, size.y));

    // Goal Sensors
    _createGoalSensor(body, Vector2(-0.02, size.y / 2), goalHalfWidth, Team.red); // If ball hits left, Red (P2) scores? No, P1 usually shoots left.
    // Let's say: Left Goal -> Red scores, Right Goal -> Green scores.
    _createGoalSensor(body, Vector2(size.x + 0.02, size.y / 2), goalHalfWidth, Team.green);

    return body;
  }

  void _createGoalSensor(Body body, Vector2 pos, double halfWidth, Team scoringTeam) {
    final shape = PolygonShape()..setAsBox(0.01, halfWidth, pos, 0);
    final fixtureDef = FixtureDef(shape, isSensor: true)..userData = scoringTeam;
    body.createFixture(fixtureDef);
  }

  void _createWall(Body body, Vector2 start, Vector2 end) {
    final shape = EdgeShape()..set(start, end);
    final fixtureDef = FixtureDef(shape, friction: 0.3, restitution: 0.4);
    body.createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    // Draw the pitch surface
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
    
    // Draw lines
    final linePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.005;
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), linePaint);
    canvas.drawLine(Offset(size.x / 2, 0), Offset(size.x / 2, size.y), linePaint);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 0.1, linePaint);
  }
}
