import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/minesweeper_game.dart';
import 'screens.dart';
import 'game/settings.dart';
class GameWrapper extends StatefulWidget {
  final GameSettings settings;

  const GameWrapper({super.key, this.settings = GameSettings.easy});

  @override
  State<GameWrapper> createState() => _GameWrapperState();
}

class _GameWrapperState extends State<GameWrapper> {
  late MinesweeperGame game;
  bool _isPaused = false;
  final _lifecycleObserver = _AppLifecycleObserver();
  OverlayEntry? _pauseOverlay;

 @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    game = MinesweeperGame(settings: widget.settings)
      ..onGameEnd = _handleGameEnd
      ..onPause = (isPaused) {
        if (mounted) setState(() => _isPaused = isPaused);
      };
  }

  void _showPauseDialog() {
    if (_pauseOverlay != null) return;
    
    _pauseOverlay = OverlayEntry(
      builder: (context) => _buildPauseDialog(),
    );
    Overlay.of(context).insert(_pauseOverlay!);
    setState(() {
      _isPaused = true;
      game.pauseGame();
    });
  }

  void _hidePauseDialog() {
    _pauseOverlay?.remove();
    _pauseOverlay = null;
    setState(() {
      _isPaused = false;
      game.resumeGame();
    });
  }

  void _handleGameEnd(bool isWin) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildGameOverDialog(isWin),
    );
  }

  Widget _buildPauseDialog() {
    return Material(
      color: Colors.black.withOpacity(0.5),
      child: Center(
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
              const Text('Игра на паузе', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _hidePauseDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: gradientDialogButton(
  text: 'Продолжить',
  onPressed: _hidePauseDialog,
  startColor: Colors.green,
  endColor: Colors.lightGreen,
),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainMenuScreen()),
                    (route) => false,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: gradientDialogButton(
  text: 'В меню',
  onPressed: () => Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const MainMenuScreen()),
    (route) => false,
  ),
  startColor: Colors.blue,
  endColor: Colors.lightBlue,
),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverDialog(bool isWin) {
  final time = game.currentTimeInSeconds;
  String levelKey;
  if (game.settings == GameSettings.easy) {
    levelKey = 'easy';
  } else if (game.settings == GameSettings.medium) {
    levelKey = 'medium';
  } else {
    levelKey = 'hard';
  }

  return FutureBuilder<int?>(
    future: GameStats.getRecord(levelKey),
    builder: (context, snapshot) {
      final record = snapshot.data;
      return AlertDialog(
        backgroundColor: Colors.grey[800]!,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isWin ? 'Победа!' : 'Поражение',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 10),
            Text(
              'Время: $time секунд',
              style: const TextStyle(fontSize: 18),
            ),
            if (isWin && (record == null || time < record))
              const Text(
                'Новый рекорд!',
                style: TextStyle(fontSize: 18, color: Colors.green),
              ),
            if (record != null)
              Text(
                'Рекорд: $record секунд',
                style: const TextStyle(fontSize: 18),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _initGame());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: gradientDialogButton1(
  text: 'Новая игра',
  startColor: Colors.green,
  endColor: Colors.lightGreen,
),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainMenuScreen()),
                  (route) => false,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: gradientDialogButton(
  text: 'В меню',
  onPressed: () => Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const MainMenuScreen()),
    (route) => false,
  ),
  startColor: Colors.blue,
  endColor: Colors.lightBlue,
),
              ),
            ),
          ],
        ),
      );
    },
  );
}

  @override
  void dispose() {
    _pauseOverlay?.remove();
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: game),
          Positioned(
            top: 10,
            right: 10,
            child: Positioned(
  top: 10,
  right: 10,
  child: pauseButton(onPressed: _showPauseDialog),
),
          ),
        ],
      ),
    );
  }
}

class _AppLifecycleObserver with WidgetsBindingObserver {
  void Function(AppLifecycleState)? onStateChanged;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    onStateChanged?.call(state);
  }
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
}Widget gradientDialogButton({
  required String text,
  required VoidCallback onPressed,
  Color startColor = Colors.green,
  Color endColor = Colors.lightGreen,
}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15),
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
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ),
  );
}
Widget gradientDialogButton1({
  required String text,
  Color startColor = Colors.green,
  Color endColor = Colors.lightGreen,
}) {
  return GestureDetector(
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15),
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
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ),
  );
}