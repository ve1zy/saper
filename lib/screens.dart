import 'package:flutter/material.dart';
import 'game_wrapper.dart';
import 'game/settings.dart';
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
            const Text('Рекорды', style: TextStyle(fontSize: 30)),
            const SizedBox(height: 20),
            RecordDisplay(level: 'Легкий', keyName: 'easy'),
            RecordDisplay(level: 'Средний', keyName: 'medium'),
            RecordDisplay(level: 'Тяжелый', keyName: 'hard'),
            const SizedBox(height: 20),
            
            gradientButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DifficultySelectionScreen()),
                );
              },
  text: 'Начать игру',
  startColor: Colors.blue,
  endColor: Colors.cyan,
),
            const SizedBox(height: 20),
            gradientButton(
  text: 'Об авторах',
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AuthorsScreen()),
    );
  },
  startColor: Colors.orange,
  endColor: Colors.deepOrange,
),
          ],
        ),
      ),
    );
  }
}

class RecordDisplay extends StatefulWidget {
  final String level;
  final String keyName;

  const RecordDisplay({super.key, required this.level, required this.keyName});

  @override
  State<RecordDisplay> createState() => _RecordDisplayState();
}

class _RecordDisplayState extends State<RecordDisplay> {
  String? recordText;

  @override
  void initState() {
    super.initState();
    _loadRecord();
  }

  Future<void> _loadRecord() async {
    final record = await GameStats.getRecord(widget.keyName);
    setState(() {
      recordText = record != null ? '${widget.level}: $record сек.' : '${widget.level}: Рекорд не установлен';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      recordText ?? 'Загрузка...',
      style: const TextStyle(fontSize: 18),
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
        leading: pauseButton(onPressed: () => Navigator.pop(context)),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),  
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Разработчики:', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('• Жуков Павел Алексеевич - главный разработчик'),
            Text('   Email: zhukowgg@gmail.com'),
            Text('   Телефон: +7 (913) 961-22-79'),
            Text('   Телеграм: @wtfimcryin'),
            Text('   GitHub: https://github.com/ve1zy'),
            SizedBox(height: 15),
            Text('• Асмолов Роман Андреевич - дизайнер'),
            SizedBox(height: 15),
            Text('• Боргуль Иван Сергеевич - тестировщик'),
          ],
        ),
      ),
    );
  }
}
class DifficultySelectionScreen extends StatelessWidget {
  const DifficultySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбор уровня сложности'),
        leading: pauseButton(onPressed: () => Navigator.pop(context)),
      ),
      
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameWrapper(settings: GameSettings.easy),
                  ),
                );
              },
              child: const Text('Легкий (9x9, 10 мин)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameWrapper(settings: GameSettings.medium),
                  ),
                );
              },
              child: const Text('Средний (16x16, 40 мин)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameWrapper(settings: GameSettings.hard),
                  ),
                );
              },
              child: const Text('Тяжелый (20x25, 99 мин)'),
            ),
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
Widget gradientButton({
  required String text,
  required VoidCallback onPressed,
  Color startColor = Colors.blue,
  Color endColor = Colors.cyan,
}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  );
}
Widget pauseButton({required VoidCallback onPressed}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Icon(
        Icons.pause,
        size: 30,
        color: Colors.white,
      ),
    ),
  );
}