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
    _lifecycleObserver.onStateChanged = _handleAppLifecycleChange;
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
    _initGame();
  }

  void _initGame() {
    game = MinesweeperGame(settings: widget.settings)
      ..onGameEnd = _handleGameEnd
      ..onPause = (isPaused) {
        if (mounted) setState(() => _isPaused = isPaused);
      };
  }

  void _handleAppLifecycleChange(AppLifecycleState state) {
    if (!mounted) return;
    
    setState(() {
      if (state == AppLifecycleState.paused) {
        _showPauseDialog();
      } else if (state == AppLifecycleState.resumed) {
        _hidePauseDialog();
      }
    });
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
                  child: const Text('Продолжить'),
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
                  child: const Text('В меню'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverDialog(bool isWin) {
    return AlertDialog(
      // backgroundColor: Colors.grey[800]!.withOpacity(0.9),
      backgroundColor: Colors.grey[800]!,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(isWin ? 'Победа!' : 'Поражение', style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 30),
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
              child: const Text('Новая игра'),
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
              child: const Text('В меню'),
            ),
          ),
        ],
      ),
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
            child: IconButton(
              icon: const Icon(Icons.pause),
              onPressed: _showPauseDialog,
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