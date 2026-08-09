import 'package:flutter/material.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class CurrentLevelDisplay extends StatelessWidget {
  final PixelAdventure game;

  const CurrentLevelDisplay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.currentLevelIndex,
      builder: (context, levelIndex, child) {
        return Text('Level ${levelIndex + 1}');
      },
    );
  }
}
