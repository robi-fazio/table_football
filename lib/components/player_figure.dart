import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

enum Team { red, green }

class PlayerFigure extends BodyComponent {
  final Vector2 rodPosition;
  final Team team;
  final double rodY;

  late Body footBody;
  late RevoluteJoint joint;

  PlayerFigure({
    required this.rodPosition,
    required this.team,
    required this.rodY,
  });

  @override
  Body createBody() {
    // The "Body" (Rod attachment) - a small circle
    final bodyDef = BodyDef(
      position: rodPosition + Vector2(0, rodY),
      type: BodyType.kinematic,
    );
    final body = world.createBody(bodyDef);
    final bodyShape = CircleShape()..radius = 0.025;
    body.createFixture(FixtureDef(bodyShape, density: 1.0));

    // The "Foot" - a dynamic body attached to the main body
    final footDef = BodyDef(
      position: rodPosition + Vector2(0, rodY),
      type: BodyType.dynamic,
      bullet: true,
    );
    footBody = world.createBody(footDef);
    
    // Foot fixture (a protrusion)
    final footShape = PolygonShape();
    // A small rectangle extending from center
    footShape.setAsBox(0.015, 0.045, Vector2(0, 0), 0);
    footBody.createFixture(FixtureDef(footShape, density: 5.0, friction: 0.5, restitution: 0.2));

    // RevoltJoint to connect them
    final jointDef = RevoluteJointDef()
      ..initialize(body, footBody, body.position)
      ..enableLimit = true
      ..lowerAngle = -0.1
      ..upperAngle = 0.1
      ..enableMotor = true
      ..maxMotorTorque = 100.0
      ..motorSpeed = 0.0;
    
    joint = world.createJoint(jointDef) as RevoluteJoint;

    return body;
  }

  void updatePosition(double newY) {
    if (isLoaded) {
      body.setTransform(Vector2(rodPosition.x, newY), body.angle);
      // Foot follows body (joint handles this, but we need to keep foot "synced" if kinematic body teleports)
      // Actually with a joint, the foot will follow.
    }
  }

  void kick(bool directionRight) {
    // Set motor speed for a quick snap
    final speed = directionRight ? 50.0 : -50.0;
    joint.setLimits(directionRight ? 0.0 : -1.5, directionRight ? 1.5 : 0.0);
    joint.setMotorSpeed(speed);
    
    // Reset after a short delay
    Future.delayed(const Duration(milliseconds: 150), () {
      if (isLoaded) {
          joint.setLimits(-0.1, 0.1);
          joint.setMotorSpeed(-speed);
      }
    });
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = team == Team.red ? Colors.red : Colors.green;
    canvas.drawCircle(Offset.zero, 0.025, paint);
    
    // Head detail
    canvas.drawCircle(Offset.zero, 0.01, Paint()..color = Colors.black45);

    // Render the foot (since it's a separate body, we usually let it render itself, 
    // but for simplicity we'll render it here or make it a separate BodyComponent)
    _renderFoot(canvas);
  }

  void _renderFoot(Canvas canvas) {
    // Calculate foot relative position and angle
    final relativePos = footBody.position - body.position;
    final angle = footBody.angle - body.angle;
    
    canvas.save();
    canvas.translate(relativePos.x, relativePos.y);
    canvas.rotate(angle);
    
    final footPaint = Paint()..color = team == Team.red ? Colors.redAccent : Colors.greenAccent;
    canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: 0.03, height: 0.09), footPaint);
    
    canvas.restore();
  }
}
