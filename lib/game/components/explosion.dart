import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame/flame.dart';
import 'package:flame/geometry.dart';

class Explosion extends SpriteAnimationComponent with HasGameRef {
  Explosion({required Vector2 position, required Vector2 size})
      : super(position: position, size: size);
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    final spriteSheet = SpriteSheet(
      image: await Flame.images.load('explosion.png'),
      srcSize: Vector2(64, 64),
    );
    
    animation = spriteSheet.createAnimation(
      row: 0,
      stepTime: 0.1,
      to: 8,
    );
  }
}