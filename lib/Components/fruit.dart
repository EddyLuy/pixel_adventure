import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/Components/custom_hitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Fruit extends SpriteAnimationComponent
    with HasGameReference<PixelAdventure> {
  Fruit({this.fruit = 'Apple', super.position, super.size});

  final String fruit;

  //animation time
  final double stepTime = 0.05;

  // final hitbox = CustomHitbox(offsetX: offsetX, offsetY: offsetY, width: width, height: height)

  @override
  FutureOr<void> onLoad() {
    debugMode = true;
    //  priority = -1; // can layer fruit behind player
    //From frame data is a horizontal strip of images
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Fruits/$fruit.png'),
      SpriteAnimationData.sequenced(
        amount: 17,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
    return super.onLoad();
  }
}
