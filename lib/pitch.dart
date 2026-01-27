import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'components/player_figure.dart';
import 'foosball_game.dart';

class Pitch extends BodyComponent<FoosballGame> {
  final Vector2 size;
  final void Function(Team) onGoal;
  Sprite? _backgroundSprite;

  Pitch({required this.size, required this.onGoal}) : super(priority: -1);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _backgroundSprite = await game.loadSprite('greenPitch2.jpg');
  }

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
    // 1. Frame Colors (3D Effect)
    final baseColor = const Color(0xFF8D6E63);
    final hsl = HSLColor.fromColor(baseColor);
    
    final topColor = hsl.withLightness((hsl.lightness * 0.6).clamp(0.0, 1.0)).toColor();    // 40% darker
    final leftColor = hsl.withLightness((hsl.lightness * 0.7).clamp(0.0, 1.0)).toColor();   // 30% darker
    final rightColor = hsl.withLightness((hsl.lightness * 0.8).clamp(0.0, 1.0)).toColor();  // 20% darker
    final bottomColor = hsl.withLightness((hsl.lightness * 0.9).clamp(0.0, 1.0)).toColor(); // 10% darker
    
    final frameThickness = 0.05;
    final goalHalfWidth = 0.12;
    
    // 2. Draw Top Frame (Trapezoid)
    final topFramePath = Path()
      ..moveTo(-frameThickness, -frameThickness)
      ..lineTo(size.x + frameThickness, -frameThickness)
      ..lineTo(size.x, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(topFramePath, Paint()..color = topColor);

    // 3. Draw Bottom Frame (Trapezoid)
    final bottomFramePath = Path()
      ..moveTo(0, size.y)
      ..lineTo(size.x, size.y)
      ..lineTo(size.x + frameThickness, size.y + frameThickness)
      ..lineTo(-frameThickness, size.y + frameThickness)
      ..close();
    canvas.drawPath(bottomFramePath, Paint()..color = bottomColor);

    // 4. Draw Left Frame (Split by goal)
    // Top-Left Segment
    final topLeftPath = Path()
      ..moveTo(-frameThickness, -frameThickness) // Top-Outer
      ..lineTo(0, 0)                           // Inner Corner
      ..lineTo(0, size.y / 2 - goalHalfWidth)  // Inner Goal Start
      ..lineTo(-frameThickness, size.y / 2 - goalHalfWidth) // Outer Goal Start
      ..close();
    canvas.drawPath(topLeftPath, Paint()..color = leftColor);
    
    // Bottom-Left Segment
    final bottomLeftPath = Path()
      ..moveTo(0, size.y / 2 + goalHalfWidth)  // Inner Goal End
      ..lineTo(0, size.y)                      // Inner Corner
      ..lineTo(-frameThickness, size.y + frameThickness) // Bottom-Outer
      ..lineTo(-frameThickness, size.y / 2 + goalHalfWidth) // Outer Goal End
      ..close();
    canvas.drawPath(bottomLeftPath, Paint()..color = leftColor);

    // 5. Draw Right Frame (Split by goal)
    // Top-Right Segment
    final topRightPath = Path()
      ..moveTo(size.x + frameThickness, -frameThickness) // Top-Outer
      ..lineTo(size.x, 0)                              // Inner Corner
      ..lineTo(size.x, size.y / 2 - goalHalfWidth)     // Inner Goal Start
      ..lineTo(size.x + frameThickness, size.y / 2 - goalHalfWidth) // Outer Goal Start
      ..close();
    canvas.drawPath(topRightPath, Paint()..color = rightColor);

    // Bottom-Right Segment
    final bottomRightPath = Path()
      ..moveTo(size.x, size.y / 2 + goalHalfWidth)     // Inner Goal End
      ..lineTo(size.x, size.y)                         // Inner Corner
      ..lineTo(size.x + frameThickness, size.y + frameThickness) // Bottom-Outer
      ..lineTo(size.x + frameThickness, size.y / 2 + goalHalfWidth) // Outer Goal End
      ..close();
    canvas.drawPath(bottomRightPath, Paint()..color = rightColor);

    // 6. Draw Goal Backgrounds (Black, extending outwards)
    final goalDepth = 0.05;
    final goalPaint = Paint()..color = Colors.black;
    
    // Left Goal
    canvas.drawRect(Rect.fromLTWH(-goalDepth, size.y / 2 - goalHalfWidth, goalDepth, goalHalfWidth * 2), goalPaint);
    
    // Right Goal
    canvas.drawRect(Rect.fromLTWH(size.x, size.y / 2 - goalHalfWidth, goalDepth, goalHalfWidth * 2), goalPaint);

    // 3. Draw Pitch Background inside
    if (_backgroundSprite != null) {
      _backgroundSprite!.render(
        canvas,
        position: Vector2.zero(),
        size: size,
      );
    } else {
      final paint = Paint()
        ..color = Colors.green.withOpacity(0.5)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
    }
  }
}
