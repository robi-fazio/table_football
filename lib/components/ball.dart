import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class FoosballBall extends BodyComponent {
  final Vector2 initialPosition;
  final double radius = 0.03; // Increased to 3cm for better visibility

  FoosballBall({required this.initialPosition}) : super(priority: 10);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    print("Ball loaded at $initialPosition");
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: initialPosition,
      type: BodyType.dynamic,
      bullet: true,
      fixedRotation: false,
    );

    final body = world.createBody(bodyDef);

    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(
      shape,
      restitution: 0.8,
      friction: 0.1,
      density: 1.0,
    )..userData = this;

    body.createFixture(fixtureDef);
    return body;
  }

  @override
  void render(Canvas canvas) {
    // Brighter color: Yellow
    final paint = Paint()..color = Colors.yellowAccent;
    canvas.drawCircle(Offset.zero, radius, paint);
    
    // Add an outline
    final strokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.005;
    canvas.drawCircle(Offset.zero, radius, strokePaint);
  }
}
