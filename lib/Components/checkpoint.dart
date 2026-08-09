import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/Components/player.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Checkpoint extends SpriteAnimationComponent
    with HasGameReference<PixelAdventure>, CollisionCallbacks {
  Checkpoint({super.position, super.size});

  bool reachedCheckpoint = false;

  @override
  FutureOr<void> onLoad() {
    //  debugMode = true;

    add(
      RectangleHitbox(
        position: Vector2(18, 56),
        size: Vector2(12, 8),
        collisionType:
            CollisionType.passive, // wont interact with other passive things
      ),
    );

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(
        'Items/Checkpoints/Checkpoint/Checkpoint (No Flag).png',
      ),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 1,
        textureSize: Vector2.all(64),
      ),
    );
    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player && !reachedCheckpoint) {
      _reachedCheckpoint();
    }
    super.onCollision(intersectionPoints, other);
  }

  void _reachedCheckpoint() {
    reachedCheckpoint = true;
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(
        'Items/Checkpoints/Checkpoint/Checkpoint (Flag Out) (64x64).png',
      ),
      SpriteAnimationData.sequenced(
        loop: false,
        amount: 26,
        stepTime: 0.03,
        textureSize: Vector2.all(64),
      ),
    );

    const flagDuration = Duration(milliseconds: 50 * 26);

    Future.delayed(flagDuration, () {
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache(
          'Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle)(64x64).png',
        ),
        SpriteAnimationData.sequenced(
          amount: 10,
          stepTime: 0.03,
          textureSize: Vector2.all(64),
        ),
      );
    });
  }
}
