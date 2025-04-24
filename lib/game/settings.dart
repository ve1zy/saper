import 'package:shared_preferences/shared_preferences.dart';
class GameSettings {
  final int width;
  final int height;
  final int minesCount;

  const GameSettings(this.width, this.height, this.minesCount);

  static const GameSettings easy = GameSettings(9, 9, 10);
  static const GameSettings medium = GameSettings(16, 16, 40);
  static const GameSettings hard = GameSettings(20, 25, 99);
}
class GameStats {

  static Future<void> updateRecord(String level, int time) async {
    final prefs = await SharedPreferences.getInstance();
    final currentRecord = prefs.getInt(level);
    if (currentRecord == null || time < currentRecord) {
      await prefs.setInt(level, time);
    }
  }

  static Future<int?> getRecord(String level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(level);
  }
}