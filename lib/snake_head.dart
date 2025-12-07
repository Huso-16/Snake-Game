import 'package:flutter/material.dart';
import 'direction.dart';

class SnakeHead extends StatelessWidget {
  final int posX;
  final int posY;
  final int size;
  final Direction direction;

  const SnakeHead({
    Key? key,
    required this.posX,
    required this.posY,
    required this.size,
    required this.direction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: posX.toDouble(),
      top: posY.toDouble(),
      child: Container(
        width: size.toDouble(),
        height: size.toDouble(),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(size.toDouble() * 0.3),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF4CAF50), // Green body
              const Color(0xFF66BB6A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withOpacity(0.6),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Yellow/orange belly
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: size.toDouble() * 0.4,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB74D), // Yellow-orange belly
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(size.toDouble() * 0.3),
                    bottomRight: Radius.circular(size.toDouble() * 0.3),
                  ),
                ),
              ),
            ),
            // Eyes
            ..._buildEyes(),
            // Tongue (if moving horizontally)
            if (direction == Direction.left || direction == Direction.right)
              _buildTongue(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEyes() {
    final eyeSize = size * 0.25;
    final eyeOffsetX = size * 0.2;
    final eyeOffsetY = size * 0.25;

    return [
      // Left eye
      Positioned(
        left: eyeOffsetX,
        top: eyeOffsetY,
        child: Container(
          width: eyeSize.toDouble(),
          height: eyeSize.toDouble(),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: Center(
            child: Container(
              width: (eyeSize * 0.5).toDouble(),
              height: (eyeSize * 0.5).toDouble(),
              decoration: const BoxDecoration(
                color: Color(0xFF2196F3), // Blue eyes
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: (eyeSize * 0.2).toDouble(),
                  height: (eyeSize * 0.2).toDouble(),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      // Right eye
      Positioned(
        right: eyeOffsetX,
        top: eyeOffsetY,
        child: Container(
          width: eyeSize.toDouble(),
          height: eyeSize.toDouble(),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: Center(
            child: Container(
              width: (eyeSize * 0.5).toDouble(),
              height: (eyeSize * 0.5).toDouble(),
              decoration: const BoxDecoration(
                color: Color(0xFF2196F3), // Blue eyes
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: (eyeSize * 0.2).toDouble(),
                  height: (eyeSize * 0.2).toDouble(),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildTongue() {
    final tongueLength = size * 0.3;
    final tongueWidth = size * 0.15;
    final isLeft = direction == Direction.left;

    return Positioned(
      top: size * 0.5,
      left: isLeft ? -tongueLength : null,
      right: isLeft ? null : -tongueLength,
      child: Container(
        width: tongueLength.toDouble(),
        height: tongueWidth.toDouble(),
        decoration: BoxDecoration(
          color: const Color(0xFFFF69B4), // Pink tongue
          borderRadius: BorderRadius.circular(tongueWidth.toDouble() * 0.5),
        ),
        child: Stack(
          children: [
            // Forked tongue
            Positioned(
              left: tongueLength * 0.6,
              top: 0,
              child: Container(
                width: (tongueLength * 0.4).toDouble(),
                height: (tongueWidth * 0.5).toDouble(),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF1493),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(tongueWidth.toDouble() * 0.5),
                    bottomRight: Radius.circular(tongueWidth.toDouble() * 0.5),
                  ),
                ),
              ),
            ),
            Positioned(
              left: tongueLength * 0.6,
              bottom: 0,
              child: Container(
                width: (tongueLength * 0.4).toDouble(),
                height: (tongueWidth * 0.5).toDouble(),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF1493),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(tongueWidth.toDouble() * 0.5),
                    bottomRight: Radius.circular(tongueWidth.toDouble() * 0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

