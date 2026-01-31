import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'components/ball.dart';
import 'components/rod.dart';
import 'components/player_figure.dart';
import 'components/vertical_scroll.dart';
import 'components/round_arrow_button.dart';
import 'components/pitch_foreground.dart';
import 'pitch.dart';

class FoosballGame extends Forge2DGame implements ContactListener {
  FoosballGame() : super(gravity: Vector2.zero());

  @override
  bool get debugMode => false;

  late List<FoosballRod> greenRods;
  late List<FoosballRod> redRods;
  
  late RoundArrowButton leftButton;
  late RoundArrowButton rightButton;
  
  late RoundArrowButton redLeftButton;
  late RoundArrowButton redRightButton;

  late VerticalScroll greenSlider;
  late VerticalScroll redSlider;
  
  // No score text
  
  final double pitchRightX = 1.2;
  // Symmetrical margin for left side?
  // Pitch is centered at 0? No, walls are (0,0) to (size.x, size.y).
  // Green pitch image covers 0 to size.x.
  // Pitch width is size.x (approx 1.2?). 
  // Let's assume left margin is negative? Or pitch is shifted?
  // User said "center them between the right screen border and the right border of the pitch".
  // For Red, it's "top left".
  // Left border of pitch is x=0. 
  // Left screen border is camera.visibleWorldRect.left.
  
  int greenScore = 0;
  int redScore = 0;

  // ...

  void _updateButtonPositions() {
    if (!leftButton.isLoaded || !rightButton.isLoaded || !redLeftButton.isLoaded || !redRightButton.isLoaded || !greenSlider.isLoaded || !redSlider.isLoaded) return;
    
    // Get the actual visible area of the world
    final visibleRect = camera.visibleWorldRect;
    final screenRightX = visibleRect.right;
    final screenLeftX = visibleRect.left;
    
    // Green Buttons (Bottom Right)
    final rightMarginCenterX = (pitchRightX + screenRightX) / 2;
    const buttonY = 0.8;
    final horizontalSpacing = leftButton.size.x * 2.0; // 1 button width gap (center-center = 2*width)
    
    leftButton.position.setValues(rightMarginCenterX - (horizontalSpacing / 2), buttonY);
    rightButton.position.setValues(rightMarginCenterX + (horizontalSpacing / 2), buttonY);
    
    // Red Buttons (Top Left)
    // Left margin center: between screenLeftX and Pitch Left (0.0)
    final leftMarginCenterX = (screenLeftX + 0.0) / 2;
    
    // "Top is where you have arrows on the red poles." -> Pitch top is 0.0?
    // Wait, rows Y positions: 0.45, 1.05... pitchHeight was passed to rods.
    // Pitch.createBody: walls (0,0) to (size.x, size.y).
    // So top is Y=0? Or Y=size.y?
    // Usually Y goes down in Flutter/Flame.
    // User said "Bottom is where you have arrows on the green poles" and I put them at Y=0.8.
    // Pitch height is likely around 0.8-0.9?
    // Let's check pitchSize.
    // In main/foosball_game: pitchSize = Vector2(1.2, 0.8)?
    // Let's assume Top is Y=0. 
    // Let's put red buttons at Y=0.0 (or aligned with top border).
    const topButtonY = 0.0;
    
    redLeftButton.position.setValues(leftMarginCenterX - (horizontalSpacing / 2), topButtonY);
    redRightButton.position.setValues(leftMarginCenterX + (horizontalSpacing / 2), topButtonY);

    // Sliders positioning
    // Vertically centered in the viewport
    final viewportCenterY = visibleRect.center.dy;
    
    greenSlider.position.setValues(leftMarginCenterX, viewportCenterY);
    redSlider.position.setValues(rightMarginCenterX, viewportCenterY);
  }

  @override
  Color backgroundColor() => const Color(0xFF1A1A1A);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Register for contact callbacks
    world.physicsWorld.setContactListener(this);
    
    // Modern Flame camera: Center on the pitch
    camera.viewfinder.visibleGameSize = Vector2(1.5, 1.0); 
    camera.viewfinder.position = Vector2(0.6, 0.4);
    camera.viewfinder.anchor = Anchor.center;

    final pitchSize = Vector2(1.2, 0.8);
    // Add game objects to the WORLD so the camera can see them
    world.add(Pitch(size: pitchSize, onGoal: _handleGoal));
    world.add(PitchForeground(pitchSize: pitchSize));
    
    // Sliders stay on the GAME (HUD/Screen space)
    greenSlider = VerticalScroll(
      initialPosition: Vector2.zero(), 
      width: 0.045,
      height: 0.4,
      onScroll: (progress) {
         final newY = 0.247 + (progress * 0.306);
         for (var rod in greenRods) {
           rod.rodY = newY;
         }
      },
    );
    world.add(greenSlider);
    
    redSlider = VerticalScroll(
      initialPosition: Vector2.zero(),
      width: 0.045,
      height: 0.4,
      color: Colors.red,
      onScroll: (progress) {
         final newY = 0.247 + (progress * 0.306);
         for (var rod in redRods) {
           rod.rodY = newY;
         }
      },
    );
    world.add(redSlider);

    // Initialize Rods
    greenRods = [
        FoosballRod(x: 0.15, team: Team.green, playerOffsets: [0.0], pitchHeight: pitchSize.y),
        FoosballRod(x: 0.75, team: Team.green, playerOffsets: [-0.2, 0.2], pitchHeight: pitchSize.y),
    ];
    
    redRods = [
        FoosballRod(x: 0.45, team: Team.red, playerOffsets: [-0.2, 0.2], pitchHeight: pitchSize.y),
        FoosballRod(x: 1.05, team: Team.red, playerOffsets: [0.0], pitchHeight: pitchSize.y),
    ];

    // Directional buttons in bottom right
    final buttonSize = Vector2(0.112, 0.112);
    
    leftButton = RoundArrowButton(
      position: Vector2.zero(), // Will be set in _updateButtonPositions
      size: buttonSize,
      isRight: false,
      onPressed: () {
        for (var rod in greenRods) {
          rod.tiltBack();
          for (var player in rod.players) {
            player.swapSprite(true);
          }
        }
      },
      onReleased: () {
        for (var rod in greenRods) {
          rod.resetTilt();
          for (var player in rod.players) {
            player.swapSprite(false);
          }
        }
      },
    );

    rightButton = RoundArrowButton(
      position: Vector2.zero(), // Will be set in _updateButtonPositions
      size: buttonSize,
      isRight: true,
      onPressed: () {
        for (var rod in greenRods) {
          rod.kick(true);
          for (var player in rod.players) {
            player.swapToKick(true);
          }
        }
      },
      onReleased: () {
        for (var rod in greenRods) {
          rod.resetTilt();
          for (var player in rod.players) {
            player.swapToKick(false);
          }
        }
      },
    );

    world.add(leftButton);
    world.add(rightButton);
    
    // Add Red Buttons
    redLeftButton = RoundArrowButton(
      position: Vector2.zero(),
      size: buttonSize,
      isRight: false,
      color: Colors.red,
      onPressed: () {
        for (var rod in redRods) {
            rod.kick(false);
            for (var player in rod.players) {
                player.swapToKick(true); 
            }
        }
      },
      onReleased: () {
        for (var rod in redRods) {
            rod.resetTilt();
            for (var player in rod.players) {
                player.swapToKick(false);
            }
        }
      },
    );
    
    redRightButton = RoundArrowButton(
      position: Vector2.zero(),
      size: buttonSize,
      isRight: true,
      color: Colors.red,
      onPressed: () {
        for (var rod in redRods) {
            rod.tiltBack();
            for (var player in rod.players) {
                player.swapSprite(true); 
            }
        }
      },
      onReleased: () {
        for (var rod in redRods) {
            rod.resetTilt();
            for (var player in rod.players) {
                player.swapSprite(false);
            }
        }
      },
    );
    
    world.add(redLeftButton);
    world.add(redRightButton);
    
    // Scores removed (artefacts)

    _updateButtonPositions();


    for (var rod in greenRods) {
      world.add(rod);
      world.addAll(rod.players);
    }
    for (var rod in redRods) {
      world.add(rod);
      world.addAll(rod.players);
    }
    
    _resetBall();
  }

  void _resetBall() {
    // Remove existing ball if any
    final existingBalls = world.children.whereType<FoosballBall>();
    for (var ball in existingBalls) {
        ball.removeFromParent();
    }

    final ball = FoosballBall(initialPosition: Vector2(0.6, 0.4));
    world.add(ball);
    
    // Give it a tiny kick to start
    Future.delayed(const Duration(milliseconds: 100), () {
        if (ball.isLoaded) {
            final random = (DateTime.now().millisecond / 1000.0) - 0.5;
            ball.body.applyLinearImpulse(Vector2(random * 0.05, 0.02));
        }
    });
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      _updateButtonPositions();
    }
  }


  bool _isGoalResetting = false;

  void _handleGoal(Team team) {
    if (_isGoalResetting) return;
    _isGoalResetting = true;

    print("GOAL! Ball entered ${team == Team.green ? 'Green' : 'Red'} Goal");
    
    // Give time for the ball to physically enter the pocket
    Future.delayed(const Duration(milliseconds: 800), () {
        if (team == Team.green) {
          greenScore++;
        } else {
          redScore++;
        }
        print("Score updated: Green $greenScore - Red $redScore");
        
        _resetBall();
        _isGoalResetting = false;
    });
  }

  @override
  void beginContact(Contact contact) {
    Object? dataA = contact.fixtureA.userData;
    Object? dataB = contact.fixtureB.userData;

    if (dataA is Team && dataB is FoosballBall) {
        _handleGoal(dataA);
    } else if (dataB is Team && dataA is FoosballBall) {
        _handleGoal(dataB);
    }
  }

  @override
  void endContact(Contact contact) {}

  @override
  void postSolve(Contact contact, ContactImpulse impulse) {}

  @override
  void preSolve(Contact contact, Manifold oldManifold) {}
}
