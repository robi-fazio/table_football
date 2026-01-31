import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import '../foosball_game.dart';
import 'package:table_football/components/ball.dart';
import 'dart:math' as math;

enum Team { red, green }

class PlayerFigure extends BodyComponent<FoosballGame> {
  final Vector2 rodPosition;
  final Team team;
  final double rodY;

  PlayerFigure({
    required this.rodPosition,
    required this.team,
    required this.rodY,
  }) : super(priority: 10);

  @override
  Body createBody() {
    // The "Body" (Rod attachment) - a small circle
    final bodyDef = BodyDef(
      position: rodPosition + Vector2(0, rodY),
      type: BodyType.kinematic,
    );
    final body = world.createBody(bodyDef);
    
    // 1. Head Fixture (Center of Rod)
    final headShape = CircleShape()..radius = 0.025;
    body.createFixture(FixtureDef(headShape, density: 2.0, friction: 0.1, restitution: 0.5));

    // 2. Foot Fixture (Hanging DOWN from rod)
    // Offset it so it acts like a pendulum
    final footShape = PolygonShape();
    // width 0.03 (2*0.015), height 0.06 (2*0.03)
    // Center it at (0, 0.04) so it's below the head
    footShape.setAsBox(0.015, 0.03, Vector2(0, 0.04), 0); 
    
    // Increased density for a heavy, solid kick
    body.createFixture(FixtureDef(footShape, density: 20.0, friction: 0.0, restitution: 0.6));

    return body;
  }

  void updatePosition(double newY) {
    if (isLoaded) {
      body.setTransform(Vector2(rodPosition.x, newY), body.angle);
    }
  }

  double _kickTargetAngle = 0;
  static const double _kickSpeed = 15.0; // Speed of rotation
  static const double _maxKickAngle = 0.7; // ~40 degrees

  @override
  void update(double dt) {
    super.update(dt);
    
    // Smoothly rotate towards the target angle
    if (body.bodyType == BodyType.kinematic) {
        final currentAngle = body.angle;
        if ((currentAngle - _kickTargetAngle).abs() > 0.05) {
            final step = _kickSpeed * dt;
            final newAngle = (currentAngle < _kickTargetAngle) 
                ? math.min(currentAngle + step, _kickTargetAngle)
                : math.max(currentAngle - step, _kickTargetAngle);
            body.setTransform(body.position, newAngle);
        }
    }
  }

  void kick(bool directionRight) {
    // Rotate the player to "kick"
    // directionRight ends up being +angle or -angle depending on team orientation
    // Red team (right side) faces Left (pi). 
    // Green team (left side) faces Right (0).
    
    if (team == Team.green) {
        // Green kicks to the right (Counter Clockwise / +Angle swings foot forward?)
        // Wait, if foot is center, rotation doesn't "swing" it unless the pivot is offset.
        // The foot is a box at (0,0). Rotating it just spins it in place.
        // For a foosball kick, the rod is the pivot. The feet are below the rod.
        // We need to move the foot fixture DOWN relative to the body (rod).
        // Currently: footShape.setAsBox(0.015, 0.045, Vector2(0, 0), 0);
        // Change foot shape to be OFFSET.
        _kickTargetAngle = directionRight ? -_maxKickAngle : _maxKickAngle; 
        // Actually, let's just snap to "cocked" back, then swing forward?
        // Simple: Set target to swing forward.
         _kickTargetAngle = -_maxKickAngle; // Swing foot forward (up? no standard angles)
         // Let's assume -Angle is CW (kick right if foot is down)
         
         // Actually, let's just oscillate.
         // Kick = Swing to angle, then return.
         _performKickSwing(true);
    } else {
        _performKickSwing(false);
    }
  }
  
  void _performKickSwing(bool isGreen) {
      // Simple swing animation:
      // 1. Cock back? or Just Swing?
      // For responsiveness, Swing immediately.
      
      // Swing "Forward"
      // Green (Right): Negative angle (CW)? No, +y is down. 
      // 0 is Right. 90 (PI/2) is Down.
      // Foot is normally at 90 (hanging down). 
      // But we built it centered. 
      // FIXURE CHANGE REQUIRED: Move foot down.
      
      // Let's rely on the updated fixture in the next step.
      // Assuming foot is at (0, 0.045) (hanging down).
      // Resting angle = 0.
      
      // Kick Right (Green): Rotate to -0.5 (Swing foot Right/Up).
      // Kick Left (Red): Rotate to 0.5 (Swing foot Left/Up).
      
      final swingAngle = isGreen ? -1.2 : 1.2;
      _kickTargetAngle = swingAngle; // Fast swing
      
      // Return to rest after short delay
      Future.delayed(const Duration(milliseconds: 150), () {
          _kickTargetAngle = 0;
      });
  }

  void tiltBack() {
      // Cock back to receive/pass
      // Green: Rotate back (+Angle)
      _kickTargetAngle = team == Team.green ? 0.7 : -0.7;
  }

  void resetTilt() {
      _kickTargetAngle = 0;
  }

  Sprite? _greenSprite;
  Sprite? _backSprite;
  Sprite? _kickSprite;
  
  Sprite? _redSprite;
  Sprite? _redBackSprite;
  Sprite? _redKickSprite;
  
  bool _showBack = false;
  bool _showKick = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (team == Team.green) {
      _greenSprite = await game.loadSprite('playerGreenHead.png');
      _backSprite = await game.loadSprite('playerGreenBack.png');
      _kickSprite = await game.loadSprite('playerGreenKick.png');
    } else if (team == Team.red) {
      _redSprite = await game.loadSprite('playerRedHead.png');
      _redBackSprite = await game.loadSprite('playerRedBack.png');
      _redKickSprite = await game.loadSprite('playerRedKick.png');
    }
  }

  void swapSprite(bool showBack) {
    _showBack = showBack;
  }
  
  void swapToKick(bool showKick) {
    _showKick = showKick;
  }

  @override
  void render(Canvas canvas) {
    if ((team == Team.green && _greenSprite != null) || (team == Team.red && _redSprite != null)) {
      
      Sprite? spriteRender;
      Sprite? headSprite;
      
      if (team == Team.green) {
        headSprite = _greenSprite;
        if (_showKick && _kickSprite != null) {
          spriteRender = _kickSprite;
        } else if (_showBack && _backSprite != null) {
          spriteRender = _backSprite;
        } else {
          spriteRender = _greenSprite;
        }
      } else {
        // Red team
        headSprite = _redSprite;
        if (_showKick && _redKickSprite != null) {
          spriteRender = _redKickSprite;
        } else if (_showBack && _redBackSprite != null) {
          spriteRender = _redBackSprite;
        } else {
          spriteRender = _redSprite;
        }
      }
      
      // The head sprite determines the target height for consistency
      // Green figure width used 0.078. Let's use same base for Red.
      final double targetWidthHead = 0.078;
      
      if (headSprite != null) {
        final double headAspectRatio = headSprite.srcSize.y / headSprite.srcSize.x;
        final double targetHeight = targetWidthHead * headAspectRatio;
        
        if (spriteRender != null) {
            final double spriteAspectRatio = spriteRender.srcSize.y / spriteRender.srcSize.x;
            final double targetWidth = targetHeight / spriteAspectRatio;
            
            canvas.save();
            if (team == Team.red) {
              canvas.rotate(3.14159); // Face opposition
            }
            
            // Reverted rotation: body is no longer physically tilted
            // We just render the sprite.
            
            spriteRender.render(
              canvas,
              position: Vector2(-targetWidth / 2, -targetHeight / 2),
              size: Vector2(targetWidth, targetHeight),
            );
            
            canvas.restore();
        }
      }
    }
  }
}
