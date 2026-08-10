import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/Components/background_tile.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class ScrollingBackground extends PositionComponent
    with HasGameReference<PixelAdventure> {
  final String color;

  ScrollingBackground({this.color = 'Gray'});

  static const double tileSize = 64;
  static const double scrollSpeed = 0.5;

  @override
  FutureOr<void> onLoad() {
    priority = -1;

    final int numTilesX = (game.size.x / tileSize).ceil();
    final int numTilesY = (game.size.y / tileSize).ceil();

    // Extra row above and below prevents gaps while scrolling.
    for (int y = -1; y <= numTilesY; y++) {
      for (int x = 0; x <= numTilesX; x++) {
        add(
          BackgroundTile(
            color: color,
            position: Vector2(x * tileSize, y * tileSize),
          ),
        );
      }
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    position.y += scrollSpeed;

    if (position.y >= tileSize) {
      position.y -= tileSize;
    }

    super.update(dt);
  }
}
