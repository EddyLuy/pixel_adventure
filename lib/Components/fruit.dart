import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/Components/custom_hitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Fruit extends SpriteAnimationComponent
    with HasGameReference<PixelAdventure>, CollisionCallbacks {
  Fruit({this.fruit = 'Apple', super.position, super.size});

  final String fruit;

  bool _collected = false;

  //animation time
  final double stepTime = 0.08;

  final hitbox = CustomHitbox(offsetX: 10, offsetY: 10, width: 12, height: 12);

  @override
  void update(double dt) {
    super.update(dt);

    if (_collected && animationTicker?.done() == true) {
      removeFromParent();
    }
  }

  @override
  FutureOr<void> onLoad() {
    //  debugMode = true;
    //  priority = -1; // can layer fruit behind player
    //From frame data is a horizontal strip of images

    // Add hitboxes closer to the dimensions of the fruits themselves

    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
        collisionType: CollisionType
            .passive, //checks collision on with player, not with other objects
      ),
    );
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

  void collidedWithPlayer() {
    final int amount = 6;

    //Collection animation
    if (!_collected) {
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Items/Fruits/Collected.png'),
        SpriteAnimationData.sequenced(
          amount: amount,
          stepTime: stepTime,
          textureSize: Vector2.all(32),
          loop: false,
        ),
      );
      _collected = true;
    }
    ;
    // Future.delayed(
    //   const Duration(milliseconds: (6 * stepTime * 1000).round(),),
    //   () => removeFromParent(),
    // ); // remove fruit from game on collision
  }
}
