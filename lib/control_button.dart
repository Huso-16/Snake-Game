import 'package:flutter/material.dart';

class ControlButton extends StatelessWidget {
  final Function onPressed;
  final Icon icon;

  const ControlButton({Key? key, required this.onPressed, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64.0,
      height: 64.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color(0xFF00FFA3),
            Color(0xFF00F5FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.6),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => onPressed(),
          child: Center(
            child: Icon(
              icon.icon,
              color: Colors.black,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
