import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/Components/collision_block.dart';
import 'package:pixel_adventure/Components/custom_hitbox.dart';
import 'package:pixel_adventure/Components/fruit.dart';
import 'package:pixel_adventure/Components/saw.dart';
import 'package:pixel_adventure/Components/utils.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum PlayerState { idle, running, jumping, falling, hit, appearing }

class Player extends SpriteAnimationGroupComponent
    with HasGameReference<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  Player({super.position, this.character = "Ninja Frog"});

  String character;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;

  bool keyboardActive = false;

  final double stepTime = 0.08;

  final double _gravity = 1200;
  final double _jumpForce = 350;
  final double _terminalVelocity = 700;

  double horizontalMovement = 0;
  double moveSpeed = 100;
  Vector2 startingPosition = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool hasJumped = false;
  bool gotHit = false;

  List<CollisionBlock> collisionBlocks = [];
  bool hitCeilingThisFrame = false;

  // Unique for each character
  CustomHitbox hitbox = CustomHitbox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28,
  );

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();

    // get spawn coordinates and save for deaths
    startingPosition = Vector2(position.x, position.y);

    // debugMode = true; // show player hitboxes
    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
      ),
    );
    return super.onLoad();
  }

  // Every Frame
  @override
  void update(double dt) {
    if (!gotHit) {
      _updatePlayerState(dt);
      _updatePlayerMoment(dt);
      _checkHorizontalCollisions();
      _applyGravity(dt);
      _checkVerticalCollisions();
      hitCeilingThisFrame = false;
    }

    super.update(dt);

    // Check AFTER Flame has updated the animation ticker
    if (gotHit &&
        current == PlayerState.appearing &&
        animationTicker?.done() == true) {
      velocity = Vector2.zero();
      position = startingPosition;

      gotHit = false;

      _updatePlayerState(0);
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    hasJumped =
        keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.space) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp);

    keyboardActive = horizontalMovement != 0;

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Fruit) {
      other.collidedWithPlayer();
    }
    if (other is Saw) {
      _respawn();
    }
    super.onCollision(intersectionPoints, other);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation("Idle", 11);
    runningAnimation = _spriteAnimation("Run", 12);
    jumpingAnimation = _spriteAnimation("Jump", 1);
    fallingAnimation = _spriteAnimation("Fall", 1);
    hitAnimation = _spriteAnimation("Hit", 7);

    appearingAnimation = _specialSpriteAnimation("Appearing", 7);

    // List of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
    };

    // Set current animation
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Main Characters/$character/$state (32x32).png"),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2(32, 32),
      ),
    );
  }

  SpriteAnimation _specialSpriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Main Characters/$state (96x96).png"),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2(96, 96),
        loop: false,
      ),
    );
  }

  void _updatePlayerState(double dt) {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    // Check if moving, set running animation
    if (velocity.x != 0) {
      playerState = PlayerState.running;
    }

    // Check if falling, set to falling
    if (velocity.y > _gravity) {
      playerState = PlayerState.falling;
    }

    // Check if jumping, set to jumping
    if (velocity.y < 0) {
      playerState = PlayerState.jumping;
    }

    current = playerState;
  }

  void _updatePlayerMoment(double dt) {
    if (hasJumped && isOnGround) {
      _playerJump(dt);
    }
    if (velocity.y > _gravity) {
      isOnGround = false;
    }

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _playerJump(double dt) {
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void _checkHorizontalCollisions() {
    if (hitCeilingThisFrame) return;
    // print('(${position.x},${position.y})');
    for (final block in collisionBlocks) {
      // Handle Collisions
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            print('right collision');
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            print('left collision');
            print('${position.x}');
            velocity.x = 0;
            //position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            position.x = scale.x < 0
                ? block.x + block.width + hitbox.width + hitbox.offsetX
                : block.x + block.width - hitbox.offsetX;
            print('${position.x}');
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity * dt;
    //Clamp upper and lower directions of velocity.y
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        //Handle platforms differently
        if (checkCollision(this, block)) {
          // falling
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            print('bottom collision');
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          } else if (velocity.y < 0) {
            print('top collision');
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
            hitCeilingThisFrame = true;

            break;
          }
        }
      }
    }
  }

  void _respawn() {
    const hitDuration = Duration(milliseconds: 500);

    gotHit = true;

    // Play hit animation
    current = PlayerState.hit;

    Future.delayed(hitDuration, () {
      scale.x = 1;
      position = startingPosition - Vector2.all(96 - 64);

      // Start appearing animation
      current = PlayerState.appearing;
    });
  }
}
