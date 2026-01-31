import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

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
      linearDamping: 1.0, // Increased for more natural pitch friction (was 0.5)
    );

    final body = world.createBody(bodyDef);

    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(
      shape,
      restitution: 0.7, // Good bounce
      friction: 0.0, // Zero friction to prevent sticking
      density: 2.0,
    )..userData = this;

    body.createFixture(fixtureDef);
    return body;
  }

  double _stuckTimer = 0;
  static const double _stuckThreshold = 0.05; // Velocity threshold to consider "stuck"
  static const double _liberationTime = 3.0; // Seconds before nudging

  @override
  void update(double dt) {
    super.update(dt);
    
    // Check if the ball is moving slowly
    if (body.linearVelocity.length < _stuckThreshold) {
      _stuckTimer += dt;
      if (_stuckTimer >= _liberationTime) {
        _nudge();
        _stuckTimer = 0;
      }
    } else {
      _stuckTimer = 0;
    }
  }

  void _nudge() {
    print("Ball stuck! Nudging...");
    // Apply a random impulse in a random direction
    final random = DateTime.now().millisecond / 1000.0;
    final angle = random * 2 * 3.14159;
    final impulse = Vector2(0.005 * math.cos(angle), 0.005 * math.sin(angle));
    body.applyLinearImpulse(impulse);
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
