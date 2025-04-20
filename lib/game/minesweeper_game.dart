import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'cell.dart';
import 'settings.dart';
import 'package:flame/events.dart';
import 'package:flutter/gestures.dart';
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
  int? _flagX;
  int? _flagY;
  bool _isLongPressing = false;
  BuildContext? gameWrapperContext;
  late void Function(bool isPaused) onPause;
  bool _isPaused = false;
  DateTime? _pauseStartTime;
  Duration _pausedDuration = Duration.zero;
  late void Function(bool isWin) onGameEnd; 
  late double _offsetX;
late double _offsetY;
late double _cellSize;
Vector2? _pendingFlagPosition;
bool _isFlagging = false;
final double _flagPressDuration = 0.5;
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
  _calculateSizes();

  canvas.drawRect(
    Rect.fromLTWH(0, 0, size.x, size.y),
    Paint()..color = const Color(0xFF222222),
  );

  for (int y = 0; y < settings.height; y++) {
    for (int x = 0; x < settings.width; x++) {
      final cell = grid[y][x];
      final rect = Rect.fromLTWH(
        _offsetX + x * _cellSize,
        _offsetY + y * _cellSize,
        _cellSize,
        _cellSize,
      );
      if (cell.isFlagged) {
    _drawFlag(canvas, rect);
  }

      canvas.drawRect(
        rect,
        Paint()..color = cell.isRevealed ? Colors.grey[300]! : Colors.grey[500]!,
      );
      
      canvas.drawRect(
        rect,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

if (_pendingFlagPosition != null && 
    x == _pendingFlagPosition!.x.toInt() && 
    y == _pendingFlagPosition!.y.toInt()) {
  canvas.drawRect(
    rect,
    Paint()..color = _isFlagging ? Colors.red.withOpacity(0.3) : Colors.white.withOpacity(0.1),
  );
}

      if (cell.isRevealed) {
        _drawRevealedCell(canvas, cell, rect);
      } else if (cell.isFlagged) {
        _drawFlag(canvas, rect);
      }
    }
  }


  _drawHud(canvas);
}

void _calculateSizes() {
  _cellSize = min(
    size.x / settings.width,
    size.y / settings.height,
  ) * 0.9;
  
  final fieldWidth = _cellSize * settings.width;
  final fieldHeight = _cellSize * settings.height;
  _offsetX = (size.x - fieldWidth) / 2;
  _offsetY = (size.y - fieldHeight) / 2;
}

void _drawRevealedCell(Canvas canvas, Cell cell, Rect rect) {
  if (cell.isMine) {
    canvas.drawCircle(
      Offset(rect.left + _cellSize / 2, rect.top + _cellSize / 2),
      _cellSize / 3,
      Paint()..color = Colors.black,
    );
  } else if (cell.adjacentMines > 0) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: cell.adjacentMines.toString(),
        style: TextStyle(
          color: getNumberColor(cell.adjacentMines),
          fontSize: _cellSize * 0.6,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        rect.left + (_cellSize - textPainter.width) / 2,
        rect.top + (_cellSize - textPainter.height) / 2,
      ),
    );
  }
}

void _drawFlag(Canvas canvas, Rect rect) {
  final flagPaint = Paint()..color = Colors.red;
  
  canvas.drawRect(
    Rect.fromLTWH(
      rect.left + _cellSize * 0.3,
      rect.top + _cellSize * 0.2,
      _cellSize * 0.1,
      _cellSize * 0.6,
    ),
    flagPaint,
  );
  
  final path = Path()
    ..moveTo(rect.left + _cellSize * 0.4, rect.top + _cellSize * 0.2)
    ..lineTo(rect.left + _cellSize * 0.7, rect.top + _cellSize * 0.35)
    ..lineTo(rect.left + _cellSize * 0.4, rect.top + _cellSize * 0.5);
  canvas.drawPath(path, flagPaint..style = PaintingStyle.fill);
}

void _drawHud(Canvas canvas) {
  final flagsText = TextPainter(
    text: TextSpan(
      text: 'Флаги: ${settings.minesCount - flagsPlaced}',
      style: const TextStyle(color: Colors.white, fontSize: 24),
    ),
    textDirection: TextDirection.ltr,
  );
  flagsText.layout();
  flagsText.paint(canvas, Offset(_offsetX, _offsetY - 30));

  final timeText = TextPainter(
    text: TextSpan(
      text: 'Время: ${currentTimeInSeconds}',
      style: const TextStyle(color: Colors.white, fontSize: 24),
    ),
    textDirection: TextDirection.ltr,
  );
  timeText.layout();
  timeText.paint(
    canvas,
    Offset(_offsetX + _cellSize * settings.width - timeText.width, _offsetY - 30),
  );
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
  _calculateSizes();
  final position = info.eventPosition.widget;
  final x = ((position.x - _offsetX) / _cellSize).floor();
  final y = ((position.y - _offsetY) / _cellSize).floor();

  if (x >= 0 && x < settings.width && y >= 0 && y < settings.height) {
    _pendingFlagPosition = Vector2(x.toDouble(), y.toDouble());
    _isFlagging = false;
    
    Future.delayed(Duration(milliseconds: (_flagPressDuration * 1000).toInt()), () {
      if (_pendingFlagPosition != null && !_isFlagging) {
        _isFlagging = true;
        _placeOrRemoveFlag(_pendingFlagPosition!);
      }
    });
  }
}

@override
void onTapUp(TapUpInfo info) {
  if (_pendingFlagPosition != null && !_isFlagging) {
    final cell = grid[_pendingFlagPosition!.y.toInt()][_pendingFlagPosition!.x.toInt()];
    if (!cell.isRevealed && !cell.isFlagged) {
      revealCell(_pendingFlagPosition!.x.toInt(), _pendingFlagPosition!.y.toInt());
    }
  }
  _pendingFlagPosition = null;
  _isFlagging = false;
}

@override
void onTapCancel() {
  _pendingFlagPosition = null;
  _isFlagging = false;
}
void _placeOrRemoveFlag(Vector2 position) {
  if (gameOver || gameWon) return;
  
  final x = position.x.toInt();
  final y = position.y.toInt();
  final cell = grid[y][x];
  
  if (!cell.isRevealed) {
    cell.isFlagged = !cell.isFlagged;
    flagsPlaced += cell.isFlagged ? 1 : -1;
    
    if (checkWinCondition()) {
      gameWon = true;
      _endGame(true);
    }
  }
}
@override
void onLongPressStart(LongPressStartInfo info) {
  _calculateSizes();
  final position = info.eventPosition.widget;
  _flagX = ((position.x - _offsetX) / _cellSize).floor();
  _flagY = ((position.y - _offsetY) / _cellSize).floor();
  _isLongPressing = true;
}

@override
void onLongPressEnd(LongPressEndInfo info) {
  if (_flagX != null && _flagY != null && _isLongPressing) {
    _toggleFlag(_flagX!, _flagY!);
  }
  _isLongPressing = false;
}
void _toggleFlag(int x, int y) {
  if (x < 0 || x >= settings.width || y < 0 || y >= settings.height) return;
  
  final cell = grid[y][x];
  
  if (!cell.isRevealed) {
    cell.isFlagged = !cell.isFlagged;
    flagsPlaced += cell.isFlagged ? 1 : -1;
    
    if (checkWinCondition()) {
      gameWon = true;
      _endGame(true);
    }
  }
}
  bool checkWinCondition() {
  for (final row in grid) {
    for (final cell in row) {
      if (!cell.isMine && !cell.isRevealed) {
        return false;
      }
    }
  }
  return true;
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
