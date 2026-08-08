import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/painting.dart';
import 'package:pixel_adventure/Components/player.dart';
import 'package:pixel_adventure/enums/enums_characters.dart';
import 'package:pixel_adventure/Components/level.dart';

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks {
  @override
  // Match colour of background to remove black bars
  Color backgroundColor() => const Color(0xFF211F30);
  late final CameraComponent cam;

  //Initialize player
  Player player = Player(character: EnumCharacterNames.pink.text);
  late JoystickComponent joystick;
  bool showJoystick = true;

  @override
  FutureOr<void> onLoad() async {
    // load images into cache
    // load all safe if you don't have many
    await images.loadAllImages();

    final world = Level(levelName: 'Level-01', player: player);

    cam = CameraComponent.withFixedResolution(
      world: world,
      width: 640,
      height: 360,
    );
    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([cam, world]);

    add(FpsTextComponent(position: Vector2(10, 10)));

    if (showJoystick) {
      addJoystick();
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    double remainingDt = dt.clamp(0.0, 0.05);
    const double maxSubStep = 1.0 / 120.0;
    while (remainingDt > 0) {
      final step = remainingDt < maxSubStep ? remainingDt : maxSubStep;
      if (showJoystick) {
        updateJoystick();
      }
      super.update(step);
      remainingDt -= step;
    }
  }

  void addJoystick() {
    joystick = JoystickComponent(
      knob: SpriteComponent(sprite: Sprite(images.fromCache("HUD/Knob.png"))),
      background: SpriteComponent(
        sprite: Sprite(images.fromCache("HUD/Joystick.png")),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );

    add(joystick);
  }

  void updateJoystick() {
    // If keyboard is active, joystick must not interfere
    if (player.keyboardActive) return;

    // If joystick is not being touched, stop movement
    if (joystick.intensity == 0) {
      player.horizontalMovement = 0;
      return;
    }

    // Joystick is actively being moved
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;

      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;

      default:
        player.horizontalMovement = 0;
        break;
    }
  }
}
