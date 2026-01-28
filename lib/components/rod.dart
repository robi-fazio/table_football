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
  
  double _currentY = 0.4;

  FoosballRod({
    required this.x,
    required this.team,
    required this.playerOffsets,
    required this.pitchHeight,
  }) : super(priority: 6);

  @override
  Future<void> onLoad() async {
    players = playerOffsets.map((offset) {
      return PlayerFigure(
        rodPosition: Vector2(x, 0),
        team: team,
        rodY: _currentY + offset,
      );
    }).toList();
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

  set rodY(double y) {
    _currentY = y;
    for (int i = 0; i < players.length; i++) {
        players[i].updatePosition(_currentY + playerOffsets[i]);
    }
  }

  @override
  void render(Canvas canvas) {
    final baseColor = team == Team.red ? Colors.red : Colors.green;
    final hsl = HSLColor.fromColor(baseColor);
    final darkerColor = hsl.withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0)).toColor();

    final strokeWidth = 0.015;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [baseColor, darkerColor],
      ).createShader(Rect.fromLTWH(x - strokeWidth / 2, -0.025, strokeWidth, pitchHeight + 0.05))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw the rod shaft
    // frameThickness is 0.05, so center is at 0.025 offset from pitch edges
    canvas.drawLine(
        Offset(x, -0.025), 
        Offset(x, pitchHeight + 0.025), 
        paint
    );
  }

  void kick(bool directionRight) {
    for (var player in players) {
      player.kick(directionRight);
    }
  }
}
