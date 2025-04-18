import 'package:flutter/material.dart';
import 'game/minesweeper_game.dart';
import 'game_wrapper.dart'; // Только этот импорт для GameWrapper// Должен быть только этот импорт GameWrapper
import 'package:flame/game.dart';
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
// class GameOverScreen extends StatelessWidget {
//   final bool isWin;
//   final VoidCallback onRestart;
//   final VoidCallback onMenu;

//   const GameOverScreen({
//     super.key,
//     required this.isWin,
//     required this.onRestart,
//     required this.onMenu,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black.withOpacity(0.7), // Исправлено withOpacity
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               isWin ? 'ПОБЕДА!' : 'ПОРАЖЕНИЕ',
//               style: const TextStyle(
//                 fontSize: 40,
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 40),
//             ElevatedButton(
//               onPressed: onRestart,
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
//               ),
//               child: const Text('Новая игра', style: TextStyle(fontSize: 24)),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: onMenu,
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
//               ),
//               child: const Text('В главное меню', style: TextStyle(fontSize: 24)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // 
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
      backgroundColor: Colors.transparent, // Полностью прозрачный фон
      body: Stack(
        children: [
          // Полупрозрачное затемнение
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          
          // Основное содержимое
          Center(
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[800]!.withOpacity(0.9),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
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
            ),
          ),
        ],
      ),
    );
  }
}