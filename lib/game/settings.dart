class GameSettings {
  final int width;
  final int height;
  final int minesCount;
  
  const GameSettings(this.width, this.height, this.minesCount);
  
  static const GameSettings easy = GameSettings(9, 9, 10);
  static const GameSettings medium = GameSettings(16, 16, 40);
  static const GameSettings hard = GameSettings(30, 16, 99);
}