import 'package:flame/components.dart';

//debugMode = true shows the collisions in debug mode

class CollisionBlock extends PositionComponent {
  bool isPlatform;
  CollisionBlock({super.position, super.size, this.isPlatform = false}) {
    // debugMode = true; // show hitboxes on blocks
  }
}
