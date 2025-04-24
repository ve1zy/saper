import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame/flame.dart';
class Explosion extends SpriteAnimationComponent {
  Explosion({required Vector2 position, required Vector2 size})
      : super(position: position, size: size);
  
  @override
Future<void> onLoad() async {
  super.onLoad();
  try {
    final spriteSheet = SpriteSheet(
      image: await Flame.images.load('explosion.png'),
      srcSize: Vector2(220, 212), // Размер одного кадра
    );
    animation = spriteSheet.createAnimation(
      row: 0,
      stepTime: 0.1,
      to: 9,
    );
  } catch (e) {
    print('Ошибка загрузки анимации: $e');
  }
}
}