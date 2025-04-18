import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'cell.dart';
import 'settings.dart';
import 'package:flame/events.dart';
import 'package:flutter/gestures.dart';
import '../screens.dart';
import '../game_wrapper.dart';
class MinesweeperGame extends FlameGame with TapDetector, LongPressDetector {
  late GameSettings settings;
  late List<List<Cell>> grid;
  late int flagsPlaced;
  late int cellsRevealed;
  late bool gameOver;
  late bool gameWon;
  late DateTime startTime;
  DateTime? _endTime;
  final Random _random = Random();
  BuildContext? _gameContext;
  BuildContext? gameWrapperContext;
  late void Function(bool isPaused) onPause;
  bool _isPaused = false;
  DateTime? _pauseStartTime;
  Duration _pausedDuration = Duration.zero;
  late void Function(bool isWin) onGameEnd; 
  MinesweeperGame({GameSettings? settings}) {
    this.settings = settings ?? GameSettings.easy;
  }
int get currentTimeInSeconds {
    if (_endTime != null) {
      return _endTime!.difference(startTime).inSeconds;
    }
    if (_isPaused && _pauseStartTime != null) {
      return _pauseStartTime!.difference(startTime).inSeconds - _pausedDuration.inSeconds;
    }
    return DateTime.now().difference(startTime).inSeconds - _pausedDuration.inSeconds;
  }
  void pauseGame() {
    if (_isPaused) return;
    _isPaused = true;
    _pauseStartTime = DateTime.now();
    if (onPause != null) {
      onPause(true);
    }
  }

  void resumeGame() {
    if (!_isPaused) return;
    _isPaused = false;
    if (_pauseStartTime != null) {
      _pausedDuration += DateTime.now().difference(_pauseStartTime!);
    }
    if (onPause != null) {
      onPause(false);
    }
  }
  @override
  Future<void> onLoad() async {
    super.onLoad();
    resetGame();
  }
  void initContext(BuildContext context) {
  _gameContext = context;
}


void _endGame(bool isWin) {
  _endTime = DateTime.now();
  gameOver = !isWin;
  gameWon = isWin;

  if (!isWin) {
    for (final row in grid) {
      for (final cell in row) {
        if (cell.isMine) cell.isRevealed = true;
      }
    }
  }

  if (onGameEnd != null) {
    onGameEnd(isWin);
  }
}
  void resetGame({GameSettings? newSettings}) {
    if (newSettings != null) {
      settings = newSettings;
    }
_endTime = null;
    grid = List.generate(
      settings.height,
      (y) => List.generate(
        settings.width,
        (x) => Cell(x, y, false),
      ),
    );

    var minesPlaced = 0;
    while (minesPlaced < settings.minesCount) {
      final x = _random.nextInt(settings.width);
      final y = _random.nextInt(settings.height);
      
      if (!grid[y][x].isMine) {
        grid[y][x].isMine = true;
        minesPlaced++;
      }
    }

    for (int y = 0; y < settings.height; y++) {
      for (int x = 0; x < settings.width; x++) {
        if (!grid[y][x].isMine) {
          grid[y][x].adjacentMines = countAdjacentMines(x, y);
        }
      }
    }

    flagsPlaced = 0;
    cellsRevealed = 0;
    gameOver = false;
    gameWon = false;
    _endTime = null;
    startTime = DateTime.now();
  }

  int countAdjacentMines(int x, int y) {
    int count = 0;
    
    for (int dy = -1; dy <= 1; dy++) {
      for (int dx = -1; dx <= 1; dx++) {
        if (dx == 0 && dy == 0) continue;
        
        final nx = x + dx;
        final ny = y + dy;
        
        if (nx >= 0 && nx < settings.width && 
            ny >= 0 && ny < settings.height && 
            grid[ny][nx].isMine) {
          count++;
        }
      }
    }
    return count;
  }

  @override
  void render(Canvas canvas) {
    if (_isPaused) {
    final pauseText = TextPainter(
      text: const TextSpan(
        text: 'ПАУЗА',
        style: TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    pauseText.layout();
    pauseText.paint(
      canvas,
      Offset(
        (size.x - pauseText.width) / 2,
        (size.y - pauseText.height) / 2,
      ),
    );
  }
    super.render(canvas);
    
    final cellSize = size.x / settings.width;
    
    for (int y = 0; y < settings.height; y++) {
      for (int x = 0; x < settings.width; x++) {
        final cell = grid[y][x];
        final rect = Rect.fromLTWH(x * cellSize, y * cellSize, cellSize, cellSize);
        
        if (cell.isRevealed) {
          canvas.drawRect(rect, Paint()..color = Colors.grey[300]!);
        } else {
          canvas.drawRect(rect, Paint()..color = Colors.grey[500]!);
        }
        
        canvas.drawRect(
          rect,
          Paint()
            ..color = Colors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
        
        if (cell.isRevealed) {
          if (cell.isMine) {
            canvas.drawCircle(
              Offset(x * cellSize + cellSize / 2, y * cellSize + cellSize / 2),
              cellSize / 3,
              Paint()..color = Colors.black,
            );
          } else if (cell.adjacentMines > 0) {
            final textPainter = TextPainter(
              text: TextSpan(
                text: cell.adjacentMines.toString(),
                style: TextStyle(
                  color: getNumberColor(cell.adjacentMines),
                  fontSize: cellSize * 0.6,
                  fontWeight: FontWeight.bold,
                ),
              ),
              textDirection: TextDirection.ltr,
            );
            textPainter.layout();
            textPainter.paint(
              canvas,
              Offset(
                x * cellSize + (cellSize - textPainter.width) / 2,
                y * cellSize + (cellSize - textPainter.height) / 2,
              ),
            );
          }
        } else if (cell.isFlagged) {
          final flagPaint = Paint()..color = Colors.red;
          canvas.drawRect(
            Rect.fromLTWH(
              x * cellSize + cellSize * 0.3,
              y * cellSize + cellSize * 0.2,
              cellSize * 0.1,
              cellSize * 0.6,
            ),
            flagPaint,
          );
          final path = Path()
            ..moveTo(x * cellSize + cellSize * 0.4, y * cellSize + cellSize * 0.2)
            ..lineTo(x * cellSize + cellSize * 0.7, y * cellSize + cellSize * 0.35)
            ..lineTo(x * cellSize + cellSize * 0.4, y * cellSize + cellSize * 0.5)
            ..close();
          canvas.drawPath(path, flagPaint);
        }
      }
    }
    
     
    final flagsText = TextPainter(
      text: TextSpan(
        text: 'Flags: ${settings.minesCount - flagsPlaced}',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    flagsText.layout();
    flagsText.paint(canvas, const Offset(10, 10));
    
    final timeElapsed = DateTime.now().difference(startTime).inSeconds;
    final timeText = TextPainter(
      text: TextSpan(
        text: 'Time: ${currentTimeInSeconds}',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    timeText.layout();
    timeText.paint(canvas, Offset(size.x - timeText.width - 10, 10));
  }

  Color getNumberColor(int number) {
    switch (number) {
      case 1: return Colors.blue;
      case 2: return Colors.green;
      case 3: return Colors.red;
      case 4: return Colors.purple;
      case 5: return Colors.brown;
      case 6: return Colors.teal;
      case 7: return Colors.black;
      case 8: return Colors.grey;
      default: return Colors.black;
    }
  }

 @override
  void onTapDown(TapDownInfo info) {
    if (gameOver || gameWon) {
      resetGame();
      return;
    }
    
    final cellSize = size.x / settings.width;
    final gamePosition = info.eventPosition.widget;
    final x = (gamePosition.x / cellSize).floor();
    final y = (gamePosition.y / cellSize).floor();
    
    if (x >= 0 && x < settings.width && y >= 0 && y < settings.height) {
      final cell = grid[y][x];
      
      if (!cell.isRevealed && !cell.isFlagged) {
        revealCell(x, y);
      }
    }
  }
  bool checkWinCondition() {
  // Проверяем, все ли не-мины открыты
  for (final row in grid) {
    for (final cell in row) {
      if (!cell.isMine && !cell.isRevealed) {
        return false;
      }
    }
  }
  return true;
}
@override
void onLongPress() {
  if (gameOver || gameWon) return;
  
  final cellSize = size.x / settings.width;
  final viewportSize = camera.viewport.size;
  final centerPosition = Vector2(viewportSize.x / 2, viewportSize.y / 2);
  
  final x = (centerPosition.x / cellSize).floor();
  final y = (centerPosition.y / cellSize).floor();
  
  if (x >= 0 && x < settings.width && y >= 0 && y < settings.height) {
    final cell = grid[y][x];
    
    if (!cell.isRevealed) {
      cell.isFlagged = !cell.isFlagged;
      flagsPlaced += cell.isFlagged ? 1 : -1;
      
      if (checkWinCondition()) {
        gameWon = true;
      }
    }
  }
}
   void revealCell(int x, int y) {
  if (gameOver || gameWon) return;
  
  final cell = grid[y][x];
  if (cell.isRevealed || cell.isFlagged) return;

  cell.isRevealed = true;
  cellsRevealed++;

  if (cell.isMine) {
    _endGame(false);
    return;
  }

  if (checkWinCondition()) {
    _endGame(true);
    return;
  }

  if (cell.adjacentMines == 0) {
    for (var dy = -1; dy <= 1; dy++) {
      for (var dx = -1; dx <= 1; dx++) {
        if (dx == 0 && dy == 0) continue;
        final nx = x + dx;
        final ny = y + dy;
        if (nx >= 0 && nx < settings.width && ny >= 0 && ny < settings.height) {
          revealCell(nx, ny);
        }
      }
    }
  }
} 
@override
  void update(double dt) {
    if (!_isPaused) {
      super.update(dt);
    }
  }
}
