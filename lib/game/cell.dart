class Cell {
  final int x;
  final int y;
  bool isMine;
  bool isRevealed;
  bool isFlagged; // Флаг, что клетка помечена флажком
  int adjacentMines;
  
  Cell(this.x, this.y, this.isMine)
      : isRevealed = false,
        isFlagged = false,
        adjacentMines = 0;
}