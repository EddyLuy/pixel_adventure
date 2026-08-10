import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pixel_adventure/Components/collected_fruit_display.dart';
import 'package:pixel_adventure/Components/purchase_speed_button.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class MenuButton extends StatelessWidget {
  MenuButton({super.key, required this.game});

  final PixelAdventure game;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.pause),
      onPressed: () {
        game.pauseEngine();

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Menu'),
            content: menuContents(),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  game.resumeEngine();
                },
                child: const Text('Resume'),
              ),
            ],
          ),
        );
      },
    );
  }

  Column menuContents() {
    return Column(
      children: [
        Text('Game is paused.'),
        SizedBox(height: 12),
        CollectedPoints(game: game),
        SizedBox(height: 12),
        Row(
          children: [
            Text('Purchase Speed'),
            SizedBox(width: 12),
            PurchaseSpeedButton(game: game),
          ],
        ),
      ],
    );
  }
}
