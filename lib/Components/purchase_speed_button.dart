import 'package:flutter/material.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class PurchaseSpeedButton extends StatelessWidget {
  const PurchaseSpeedButton({super.key, required this.game});

  final PixelAdventure game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.fruitsCollected,
      builder: (context, fruitCount, child) {
        return ValueListenableBuilder<int>(
          valueListenable: game.speedUpgradeCost,
          builder: (context, currentCost, child) {
            return OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
              ),
              onPressed: fruitCount >= currentCost
                  ? () {
                      game.fruitsCollected.value -= currentCost;
                      game.speedUpgradeCost.value = (currentCost * 1.3).floor();
                    }
                  : null,
              child: Text(
                '$currentCost Points',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: fruitCount >= currentCost ? Colors.green : Colors.red,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
