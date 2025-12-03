import 'package:flutter/material.dart';

class Piece extends StatefulWidget {
  final int posX, posY;
  final int size;
  final Color color;
  final bool isAnimated;

  const Piece({
    Key? key,
    required this.posX,
    required this.posY,
    required this.size,
    this.color = const Color(0XFFBF3100),
    this.isAnimated = false,
  }) : super(key: key);

  @override
  _PieceState createState() => _PieceState();
}

class _PieceState extends State<Piece> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      lowerBound: 0.25,
      upperBound: 1.0,
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController?.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController?.reset();
      } else if (status == AnimationStatus.dismissed) {
        _animationController?.forward();
      }
    });

    _animationController?.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.posX.toDouble(),
      top: widget.posY.toDouble(),
      child: AnimatedBuilder(
        animation: _animationController!,
        builder: (context, child) {
          final scale =
              widget.isAnimated ? (_animationController?.value ?? 1.0) : 1.0;
          return Opacity(
            opacity: widget.isAnimated ? 0.7 + 0.3 * scale : 1.0,
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: widget.size.toDouble(),
                height: widget.size.toDouble(),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(widget.size.toDouble()),
                  gradient: LinearGradient(
                    colors: [
                      widget.color.withOpacity(0.9),
                      Colors.white.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.7),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
