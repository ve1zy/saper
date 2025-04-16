import 'package:flutter/material.dart';
import 'game/minesweeper_game.dart';
import 'package:flame/game.dart';
// Главное меню
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Сапер', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => GameWrapper(
                    game: MinesweeperGame(), // Создаем новую игру
                  ),
                ),
              ),
              child: const Text('Начать игру', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
  onPressed: () => Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => GameWrapper(
        game: MinesweeperGame(), // Создаем новую игру
      ),
    ),
  ),
  child: const Text('Начать игру', style: TextStyle(fontSize: 24)),
),
          ],
        ),
      ),
    );
  }
}

// Экран авторов
class AuthorsScreen extends StatelessWidget {
  const AuthorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('О команде')),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Разработчики:', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('• Иван Иванов - главный разработчик'),
            Text('   Email: ivan@example.com'),
            SizedBox(height: 15),
            Text('• Петр Петров - дизайнер'),
            Text('   Телефон: +7 (123) 456-78-90'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}

// Экран завершения игры
class GameOverScreen extends StatelessWidget {
  final bool isWin;
  final VoidCallback onRestart;
  final VoidCallback onMenu;  

   const GameOverScreen({
    super.key,
    required this.isWin,
    required this.onRestart,
    required this.onMenu,
  });

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isWin ? 'ПОБЕДА!' : 'ПОРАЖЕНИЕ',
              style: const TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: onRestart,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              child: const Text('Новая игра', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onMenu,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              child: const Text('В главное меню', style: TextStyle(fontSize: 24)),
            ),
          ],
        ),
      ),
    );
  } 
}

// Обертка для игры
class GameWrapper extends StatelessWidget {
  final FlameGame game;
  const GameWrapper({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: game),
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.pause, color: Colors.white),
              onPressed: () => _showPauseMenu(context, game),
            ),
          ),
        ],
      ),
    );
  }

  void _showPauseMenu(BuildContext context, FlameGame game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Пауза'),
        content: const Text('Игра приостановлена'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Продолжить'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainMenuScreen()),
              );
            },
            child: const Text('В меню'),
          ),
        ],
      ),
    );
  }
}