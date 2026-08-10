import 'package:flutter/material.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class CollectedPoints extends StatelessWidget {
  final PixelAdventure game;

  const CollectedPoints({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.fruitsCollected,
      builder: (context, fruitCount, child) {
        return Text('Points: $fruitCount');
      },
    );
  }
}
