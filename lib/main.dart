import 'package:flame/flame.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:pixel_adventure/Components/collected_fruit_display.dart';
import 'package:pixel_adventure/Components/current_level_display.dart';
import 'package:pixel_adventure/Components/fps_display.dart';
import 'package:pixel_adventure/Components/menu_button.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

//TODO: Controller stops working after level 1.

bool get isMobile =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Only apply fullscreen/orientation on mobile
  if (isMobile) {
    await Flame.device.fullScreen();
    await Flame.device.setLandscape();
  }

  PixelAdventure game = PixelAdventure();
  final double currentVersion = 1.01;
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CurrentLevelDisplay(game: game),
                      SizedBox(width: 12),
                      CollectedPoints(game: game),
                      SizedBox(width: 12),
                      MenuButton(game: game),
                    ],
                  ),
                  FpsDisplay(game: game),
                  Text('Version $currentVersion'),
                ],
              ),
            ),
            Expanded(child: GameWidget(game: game)),
          ],
        ),
      ),
    ),
  );

  // runApp(GameWidget(game: kDebugMode ? PixelAdventure() : game));
}
