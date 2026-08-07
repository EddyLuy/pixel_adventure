import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/Components/background_tile.dart';
import 'package:pixel_adventure/Components/collision_block.dart';
import 'package:pixel_adventure/Components/player.dart';
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
    _spawningOjects();
    _addCollisions();

    // Collisions

    return super.onLoad();
  }

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer("Background");

    // repeat tile across whole game
    const tileSize = 64;

    final int numTilesY = (game.size.y / tileSize).floor();
    final int numTilesX = (game.size.x / tileSize).floor();

    if (backgroundLayer != null) {
      final backgroundColor = backgroundLayer.properties.getValue(
        'BackgroundColor',
      );

      // Generate background tiling
      for (double y = 0; y < numTilesY; y++) {
        for (double x = 0; x < numTilesX; x++) {
          // repeat across y
          final backgroundTile = BackgroundTile(
            color: backgroundColor ?? 'Gray',
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
  }

  void _spawningOjects() {
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
