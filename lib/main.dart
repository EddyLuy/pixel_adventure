import 'dart:io';

import 'package:flame/flame.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:pixel_adventure/Components/fps_display.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Only apply fullscreen/orientation on mobile
  if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
    await Flame.device.fullScreen();
    await Flame.device.setLandscape();
  }

  PixelAdventure game = PixelAdventure();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [FpsDisplay(game: game)],
            ),
            Expanded(child: GameWidget(game: game)),
          ],
        ),
      ),
    ),
  );

  // runApp(GameWidget(game: kDebugMode ? PixelAdventure() : game));
}
