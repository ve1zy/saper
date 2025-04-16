import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/minesweeper_game.dart';
import 'screens.dart';

class GameWrapper extends StatefulWidget {
  const GameWrapper({super.key});

  @override
  State<GameWrapper> createState() => _GameWrapperState();
}

class _GameWrapperState extends State<GameWrapper> {
  late final MinesweeperGame game;

  @override
  void initState() {
    super.initState();
    game = MinesweeperGame()
      ..onGameEnd = _handleGameEnd; // Подписываемся на событие окончания игры
  }

  void _handleGameEnd(bool isWin) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => GameOverScreen(
          isWin: isWin,
          onRestart: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const GameWrapper()),
          ),
          onMenu: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainMenuScreen()),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: game);
  }
}