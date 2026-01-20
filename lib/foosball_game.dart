import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'components/ball.dart';
import 'components/rod.dart';
import 'components/player_figure.dart';
import 'components/slider.dart';
import 'pitch.dart';

class FoosballGame extends Forge2DGame implements ContactListener {
  FoosballGame() : super(gravity: Vector2.zero());

  @override
  bool get debugMode => true;

  late List<FoosballRod> greenRods;
  late List<FoosballRod> redRods;
  
  int greenScore = 0;
  int redScore = 0;

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
    
    // Sliders stay on the GAME (HUD/Screen space)
    add(FoosballSlider(
      position: Vector2(-0.15, 0.1),
      size: Vector2(0.08, 0.6),
      color: Colors.green,
      onValueChanged: (val) {
        for (var rod in greenRods) {
          rod.updateY(val);
        }
      },
    ));
    
    add(FoosballSlider(
      position: Vector2(pitchSize.x + 0.07, 0.1),
      size: Vector2(0.08, 0.6),
      color: Colors.red,
      onValueChanged: (val) {
        for (var rod in redRods) {
          rod.updateY(val);
        }
      },
    ));

    // Initialize Rods
    greenRods = [
        FoosballRod(x: 0.15, team: Team.green, playerOffsets: [-0.15, 0.15], pitchHeight: pitchSize.y),
        FoosballRod(x: 0.75, team: Team.green, playerOffsets: [-0.25, 0, 0.25], pitchHeight: pitchSize.y),
    ];
    
    redRods = [
        FoosballRod(x: 0.45, team: Team.red, playerOffsets: [-0.25, 0, 0.25], pitchHeight: pitchSize.y),
        FoosballRod(x: 1.05, team: Team.red, playerOffsets: [-0.15, 0.15], pitchHeight: pitchSize.y),
    ];

    world.addAll(greenRods);
    world.addAll(redRods);
    
    _resetBall();
  }

  void _resetBall() {
    world.add(FoosballBall(initialPosition: Vector2(0.6, 0.4)));
  }

  void _handleGoal(Team team) {
    if (team == Team.green) {
      greenScore++;
    } else {
      redScore++;
    }
    print("Score: Green $greenScore - Red $redScore");
    
    // Reset ball after short delay
    Future.delayed(const Duration(seconds: 1), () {
        _resetBall();
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
