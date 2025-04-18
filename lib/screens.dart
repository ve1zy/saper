import 'package:flutter/material.dart';
import 'game/minesweeper_game.dart';
import 'game_wrapper.dart';

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
                  builder: (context) => const GameWrapper(),
                ),
              ),
              child: const Text('Начать игру', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthorsScreen()),
                );
              },
              child: const Text('Об авторах', style: TextStyle(fontSize: 24)),
            ),
          ],
        ),
      ),
    );
  }
}
class AuthorsScreen extends StatelessWidget {
  const AuthorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Об авторах'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
            SizedBox(height: 15),
            Text('• Алексей Алексеев - тестировщик'),
            Text('   GitHub: github.com/alexeydev'),
          ],
        ),
      ),
    );
  }
}
class GameOverDialog extends StatelessWidget {
  final bool isWin;
  final VoidCallback onRestart;
  final VoidCallback onMenu;

  const GameOverDialog({
    super.key,
    required this.isWin,
    required this.onRestart,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[800]!.withOpacity(0.9),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isWin ? 'ПОБЕДА!' : 'ПОРАЖЕНИЕ',
            style: const TextStyle(
              fontSize: 32,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRestart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('Новая игра'),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onMenu,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('В главное меню'),
            ),
          ),
        ],
      ),
    );
  }
}