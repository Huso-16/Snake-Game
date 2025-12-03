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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ControlButton(
            icon: const Icon(Icons.arrow_left),
            onPressed: () => onTapped(Direction.left),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ControlButton(
                icon: const Icon(Icons.arrow_drop_up_sharp),
                onPressed: () => onTapped(Direction.up),
              ),
              const SizedBox(height: 16.0),
              ControlButton(
                icon: const Icon(Icons.arrow_drop_down_sharp),
                onPressed: () => onTapped(Direction.down),
              ),
            ],
          ),
          ControlButton(
            icon: const Icon(Icons.arrow_right),
            onPressed: () => onTapped(Direction.right),
          ),
        ],
      ),
    );
  }
}
