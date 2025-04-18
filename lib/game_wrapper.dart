import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/minesweeper_game.dart';
import 'screens.dart';
import 'game/settings.dart'; // Добавьте эту строку в импорты
class GameWrapper extends StatefulWidget {
  final GameSettings settings;
  
  const GameWrapper({super.key, this.settings = GameSettings.easy});

  @override
  State<GameWrapper> createState() => _GameWrapperState();
}

class _GameWrapperState extends State<GameWrapper> {
  late final MinesweeperGame game;

  @override
  void initState() {
    super.initState();
    game = MinesweeperGame() // Игра создается внутри
      ..onGameEnd = _handleGameEnd;
  }

  void _handleGameEnd(bool isWin) {
    if (!mounted) return;
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => GameOverScreen(
          isWin: isWin,
          onRestart: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const GameWrapper()),
          ),
          onMenu: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainMenuScreen()),
            (route) => false,
          ),
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(game: game),
    );
  }
}