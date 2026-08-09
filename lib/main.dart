import 'dart:io';

import 'package:flame/flame.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:pixel_adventure/Components/current_level_display.dart';
import 'package:pixel_adventure/Components/fps_display.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

//TODO: Controller stops working after level 1.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Only apply fullscreen/orientation on mobile
  if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
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
                  CurrentLevelDisplay(game: game),
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
