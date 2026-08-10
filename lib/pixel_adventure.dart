import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:pixel_adventure/Components/jump_button.dart';
import 'package:pixel_adventure/Components/player.dart';
import 'package:pixel_adventure/enums/enums_characters.dart';
import 'package:pixel_adventure/Components/level.dart';

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  @override
  // Match colour of background to remove black bars
  Color backgroundColor() => const Color(0xFF211F30);
  late CameraComponent cam;

  // Levels
  List<String> levelNames = ['Level-01', 'Level-02', 'Level-03'];
  final ValueNotifier<int> currentLevelIndex = ValueNotifier<int>(
    0,
  ); // will update in real time

  final ValueNotifier<int> fruitsCollected = ValueNotifier<int>(
    0,
  ); // will update in real time

  bool get isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  double currentFps = 0;
  double _fpsTimer = 0;
  int _fpsFrames = 0;

  //Initialize player
  Player player = Player(character: EnumCharacterNames.pink.text);
  JoystickComponent? joystick;
  bool showMobileControls = true;

  // Points and Menu
  final ValueNotifier<int> speedUpgradeCost = ValueNotifier(5);

  @override
  FutureOr<void> onLoad() async {
    // load images into cache
    // load all safe if you don't have many
    await images.loadAllImages();

    print(levelNames[currentLevelIndex.value]);
    _loadLevel();

    // Show joystick only if mobile
    if (showMobileControls && isMobile) {
      addJoystick();
      add(JumpButton());
    }

    // add(FpsTextComponent(position: Vector2(10, 10)));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    _fpsTimer += dt;
    _fpsFrames++;

    if (_fpsTimer >= 0.5) {
      currentFps = _fpsFrames / _fpsTimer;

      _fpsTimer = 0;
      _fpsFrames = 0;
    }

    double remainingDt = dt.clamp(0.0, 0.05);
    const double maxSubStep = 1.0 / 120.0;
    while (remainingDt > 0) {
      final step = remainingDt < maxSubStep ? remainingDt : maxSubStep;
      if (joystick != null) {
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

    add(joystick!);
  }

  void updateJoystick() {
    if (joystick == null) return;

    // Physical controller takes priority over the on-screen joystick
    if (player.controllerConnected) {
      player.joystickMovement = 0;
      return;
    }

    // Keyboard takes priority over the on-screen joystick
    if (player.keyboardActive) {
      player.joystickMovement = 0;
      return;
    }

    // Joystick isn't being touched
    if (joystick!.intensity == 0) {
      player.joystickMovement = 0;
      return;
    }

    // Joystick is actively being moved
    switch (joystick!.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.joystickMovement = -1;
        break;

      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.joystickMovement = 1;
        break;

      default:
        player.joystickMovement = 0;
        break;
    }
  }

  void loadNextLevel() {
    if (currentLevelIndex.value < levelNames.length - 1) {
      currentLevelIndex.value++;
      removeWhere((component) => component is Level);
      _loadLevel();
    } else {
      // No more levels remaining
    }
  }

  void _loadLevel() {
    Level world = Level(
      levelName: levelNames[currentLevelIndex.value],
      player: player,
    );

    cam = CameraComponent.withFixedResolution(
      world: world,
      width: 640,
      height: 360,
    );
    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([cam, world]);
  }
}
