import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class FpsDisplay extends StatefulWidget {
  final PixelAdventure game;

  const FpsDisplay({super.key, required this.game});

  @override
  State<FpsDisplay> createState() => _FpsDisplayState();
}

class _FpsDisplayState extends State<FpsDisplay> {
  double fps = 0;

  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!mounted) return;

      setState(() {
        fps = widget.game.currentFps;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      'FPS: ${fps.toStringAsFixed(0)}',
      style: const TextStyle(color: Color.fromARGB(255, 9, 0, 33)),
    );
  }
}
