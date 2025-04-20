class Cell {
  final int x;
  final int y;
  bool isMine;
  bool isRevealed;
  bool isFlagged; 
  int adjacentMines;
  
  Cell(this.x, this.y, this.isMine)
      : isRevealed = false,
        isFlagged = false,
        adjacentMines = 0;
}