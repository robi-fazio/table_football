import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import '../foosball_game.dart';

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
    
    // 1. Head Fixture
    final headShape = CircleShape()..radius = 0.025;
    body.createFixture(FixtureDef(headShape, density: 1.0));

    // 2. Foot Fixture (Attached rigidly to the same body)
    // A small rectangle extending from center
    // We want the foot to be below the head? Or offset?
    // In original code: footBody was at same position as body initially?
    // "position: rodPosition + Vector2(0, rodY)" for both.
    // But they were joined by a joint at "body.position".
    // So they were overlapping?
    // And renderFoot drew it "relativePos".
    // If they are concentric, the foot is just a rectangle at the same center.
    final footShape = PolygonShape();
    footShape.setAsBox(0.015, 0.045, Vector2(0, 0), 0);
    body.createFixture(FixtureDef(footShape, density: 5.0, friction: 0.5, restitution: 0.2));

    return body;
  }

  void updatePosition(double newY) {
    if (isLoaded) {
      body.setTransform(Vector2(rodPosition.x, newY), body.angle);
    }
  }

  void kick(bool directionRight) {
    // Kick logic disabled as requested (no joint)
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
              canvas.rotate(3.14159); // Rotate 180 degrees
            }
            
            spriteRender.render(
              canvas,
              position: Vector2(-targetWidth / 2, -targetHeight / 2),
              size: Vector2(targetWidth, targetHeight),
            );
            
            canvas.restore();
        }
      }
    } else {
      final paint = Paint()..color = team == Team.red ? Colors.red : Colors.green;
      canvas.drawCircle(Offset.zero, 0.025, paint);
      
      // Head detail
      canvas.drawCircle(Offset.zero, 0.01, Paint()..color = Colors.black45);

      // Render the foot (now strictly attached)
      final footPaint = Paint()..color = team == Team.red ? Colors.redAccent : Colors.greenAccent;
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: 0.03, height: 0.09), footPaint);
    }
  }
}
