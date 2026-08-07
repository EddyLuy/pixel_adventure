import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class BackgroundTile extends SpriteComponent
    with HasGameReference<PixelAdventure> {
  final String color;
  BackgroundTile({this.color = 'Gray', super.position});

  @override
  FutureOr<void> onLoad() {
    priority = -1; //make it behind everything else
    size = Vector2.all(64.6); // size of tile image plus a bit to hide gap
    sprite = Sprite(game.images.fromCache('Background/$color.png'));
    return super.onLoad();
  }
}
