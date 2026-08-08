import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Saw extends SpriteAnimationComponent
    with HasGameReference<PixelAdventure> {
  Saw({
    super.position,
    super.size,
    this.isVertical = false,
    this.offNeg = 0,
    this.offPos = 0,
  });

  final bool isVertical;
  final double offNeg;
  final double offPos;

  //animation time
  final double sawAnimationSpeed = 0.03;
  final int moveSpeed = 50;
  final int tileSize = 16;
  double moveDirection = 1;
  double rangeNeg = 0;
  double rangePos = 0;

  @override
  FutureOr<void> onLoad() {
    priority = -1;

    add(CircleHitbox());
    // debugMode = true;

    //get range saws can move from Tiled
    if (isVertical) {
      rangeNeg = position.y - offNeg * tileSize;
      rangePos = position.y + offPos * tileSize;
    } else {
      // horizontal
      rangeNeg = position.x - offNeg * tileSize;
      rangePos = position.x + offPos * tileSize;
    }

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Saw/On (38x38).png'),
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: sawAnimationSpeed,
        textureSize: Vector2.all(38),
      ),
    );

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isVertical) {
      _moveVertically(dt);
    } else {
      moveHorizontally(dt);
    }
    super.update(dt);
  }

  void _moveVertically(double dt) {
    if (position.y >= rangePos) {
      // flip move direction at bounds
      moveDirection = -1;
    } else if (position.y < rangeNeg) {
      // flip move direction at bounds
      moveDirection = 1;
    }
    position.y += moveDirection * moveSpeed * dt;
  }

  void moveHorizontally(double dt) {
    if (position.x >= rangePos) {
      // flip move direction at bounds
      moveDirection = -1;
    } else if (position.x < rangeNeg) {
      // flip move direction at bounds
      moveDirection = 1;
    }
    position.x += moveDirection * moveSpeed * dt;
  }
}
