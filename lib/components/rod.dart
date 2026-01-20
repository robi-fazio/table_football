import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'player_figure.dart';
import 'kick_button.dart';

class FoosballRod extends Component {
  final double x;
  final Team team;
  final List<double> playerOffsets;
  final double pitchHeight;
  
  late final List<PlayerFigure> players;
  late final PositionComponent topHandle;
  late final PositionComponent bottomHandle;
  
  double _currentY = 0.4;

  FoosballRod({
    required this.x,
    required this.team,
    required this.playerOffsets,
    required this.pitchHeight,
  });

  @override
  Future<void> onLoad() async {
    players = playerOffsets.map((offset) {
      return PlayerFigure(
        rodPosition: Vector2(x, 0),
        team: team,
        rodY: _currentY + offset,
      );
    }).toList();
    
    addAll(players);

    // Add handles with buttons
    topHandle = PositionComponent(
      position: Vector2(x - 0.04, -0.08),
      size: Vector2(0.08, 0.06),
    );
    bottomHandle = PositionComponent(
      position: Vector2(x - 0.04, pitchHeight + 0.02),
      size: Vector2(0.08, 0.06),
    );

    final btnSize = Vector2(0.03, 0.04);
    
    topHandle.add(KickButton(
      position: Vector2(0.005, 0.01),
      size: btnSize,
      isRight: false,
      color: Colors.white,
      onTap: () => kick(false),
    ));
    topHandle.add(KickButton(
      position: Vector2(0.045, 0.01),
      size: btnSize,
      isRight: true,
      color: Colors.white,
      onTap: () => kick(true),
    ));

    bottomHandle.add(KickButton(
      position: Vector2(0.005, 0.01),
      size: btnSize,
      isRight: false,
      color: Colors.white,
      onTap: () => kick(false),
    ));
    bottomHandle.add(KickButton(
      position: Vector2(0.045, 0.01),
      size: btnSize,
      isRight: true,
      color: Colors.white,
      onTap: () => kick(true),
    ));

    addAll([topHandle, bottomHandle]);
  }

  void updateY(double yPercent) {
    const margin = 0.15;
    _currentY = margin + (yPercent * (pitchHeight - 2 * margin));
    
    for (int i = 0; i < players.length; i++) {
        players[i].updatePosition(_currentY + playerOffsets[i]);
    }

    // Handles stay at the top/bottom edges of the screen, 
    // but the rod line itself "slides" through them? 
    // In the sketch the handles seem to be fixed or move?
    // "the left and right movements of the player bars is done with the arrows on each bar."
    // Let's keep handles fixed at top/bottom for now as UI anchors.
  }

  void kick(bool directionRight) {
    for (var player in players) {
      player.kick(directionRight);
    }
  }
}
