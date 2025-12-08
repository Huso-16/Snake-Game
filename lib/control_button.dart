import 'package:flutter/material.dart';

class ControlButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Icon icon;

  const ControlButton({
    Key? key,
    required this.onPressed,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70.0,
      height: 70.0,
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
            color: const Color(0xFF00F5FF).withOpacity(0.6),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          borderRadius: BorderRadius.circular(35),
          child: Center(
            child: Icon(
              icon.icon,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}
