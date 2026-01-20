import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class FoosballBall extends BodyComponent {
  final Vector2 initialPosition;
  final double radius = 0.02; // 2cm radius in meters

  FoosballBall({required this.initialPosition});

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: initialPosition,
      type: BodyType.dynamic,
      bullet: true,
      fixedRotation: false,
      linearDamping: 0.5,
      angularDamping: 0.5,
    );

    final body = world.createBody(bodyDef);

    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(
      shape,
      restitution: 0.8, // Bouncy ball
      friction: 0.1,
      density: 1.0,
    )..userData = this;

    body.createFixture(fixtureDef);
    return body;
  }

  @override
  void render(Canvas canvas) {
    // Basic blue ball visual for now
    final paint = Paint()..color = Colors.blue;
    canvas.drawCircle(Offset.zero, radius, paint);
  }
}
