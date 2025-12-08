import 'package:flutter/material.dart';

import 'control_button.dart';
import 'direction.dart';

class ControlPanel extends StatelessWidget {
  final void Function(Direction direction) onTapped;

  const ControlPanel({
    Key? key,
    required this.onTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Left button
          ControlButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => onTapped(Direction.left),
          ),
          
          const SizedBox(width: 20),
          
          // Center column (up/down)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ControlButton(
                icon: const Icon(Icons.arrow_drop_up_rounded),
                onPressed: () => onTapped(Direction.up),
              ),
              const SizedBox(height: 20.0),
              ControlButton(
                icon: const Icon(Icons.arrow_drop_down_rounded),
                onPressed: () => onTapped(Direction.down),
              ),
            ],
          ),
          
          const SizedBox(width: 20),
          
          // Right button
          ControlButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () => onTapped(Direction.right),
          ),
        ],
      ),
    );
  }
}
