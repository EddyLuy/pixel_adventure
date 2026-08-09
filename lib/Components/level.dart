import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/Components/background_tile.dart';
import 'package:pixel_adventure/Components/checkpoint.dart';
import 'package:pixel_adventure/Components/collision_block.dart';
import 'package:pixel_adventure/Components/fruit.dart';
import 'package:pixel_adventure/Components/player.dart';
import 'package:pixel_adventure/Components/saw.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

//with HasGameReference gets info about the game

class Level extends World with HasGameReference<PixelAdventure> {
  Level({required this.levelName, required this.player});

  final String levelName;
  final Player player;
  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));

    add(level);

    _scrollingBackground();
    _spawningObjects();
    _addCollisions();

    // Collisions

    return super.onLoad();
  }

  void _scrollingBackground() {
    String backgroundColor = 'Gray';

    // Try to get the Background layer from Tiled.
    // If it doesn't exist, keep the default Gray background.

    try {
      final backgroundLayer = level.tileMap.getLayer("Background");
      backgroundColor =
          backgroundLayer?.properties.getValue('Background Color') ?? 'Gray';
    } on ArgumentError {
      // No Background layer found, so use Gray.
      backgroundColor = 'Gray';
    }

    // repeat tile across whole game
    const tileSize = 64;

    final int numTilesY = (game.size.y / tileSize).floor();
    final int numTilesX = (game.size.x / tileSize).floor();

    // Generate background tiling
    for (double y = 0; y < game.size.y / numTilesY; y++) {
      for (double x = 0; x < numTilesX; x++) {
        // repeat across y
        final backgroundTile = BackgroundTile(
          color: backgroundColor,
          position: Vector2(
            x * tileSize,
            y * tileSize - tileSize,
          ), // start above
        );

        add(backgroundTile);
      }
    }
    ;
  }

  void _spawningObjects() {
    // Spawn in player at spawn point
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>("Spawnpoints");
    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          // Spawn Player
          case 'Player':
            print("Spawn Point at ${spawnPoint.x}, ${spawnPoint.y}");
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
            break;
          case 'Fruit':
            print("Fruit Spawn Point at ${spawnPoint.x}, ${spawnPoint.y}");
            final fruit = Fruit(
              fruit: spawnPoint.name,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(fruit);
            break;
          case 'Saw':
            final isVertical = spawnPoint.properties.getValue('isVertical');
            final offNeg = spawnPoint.properties.getValue('offNeg');
            final offPos = spawnPoint.properties.getValue('offPos');
            final saw = Saw(
              isVertical: isVertical,
              offNeg: offNeg,
              offPos: offPos,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(saw);
            break;
          case "Checkpoint":
            final checkpoint = Checkpoint(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(checkpoint);
            break;
          default:
        }
      }
    }
  }

  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true,
            );
            collisionBlocks.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionBlocks.add(block);
            add(block);
            break;
        }
      }
    }

    player.collisionBlocks = collisionBlocks;
  }
}
