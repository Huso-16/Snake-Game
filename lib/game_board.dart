import 'package:flutter/material.dart';

import 'piece.dart';
import 'snake_game.dart';
import 'snake_head.dart';

class GameBoard extends StatelessWidget {
  final SnakeGameState state;
  final int cellSize;

  const GameBoard({
    Key? key,
    required this.state,
    required this.cellSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = state.cols * cellSize.toDouble();
    final height = state.rows * cellSize.toDouble();

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF050816),
            const Color(0xFF0B1025),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          _buildGrid(),
          ..._buildSnake(),
          _buildFood(),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return CustomPaint(
      size: Size(
        state.cols * cellSize.toDouble(),
        state.rows * cellSize.toDouble(),
      ),
      painter: _GridPainter(
        rows: state.rows,
        cols: state.cols,
        cellSize: cellSize.toDouble(),
      ),
    );
  }

  List<Widget> _buildSnake() {
    final widgets = <Widget>[];
    
    for (int i = 0; i < state.snake.length; i++) {
      final pos = state.snake[i];
      final isHead = i == 0;
      
      if (isHead) {
        widgets.add(
          SnakeHead(
            posX: (pos.dx.toInt() * cellSize),
            posY: (pos.dy.toInt() * cellSize),
            size: cellSize,
            direction: state.direction,
          ),
        );
      } else {
        // Body segments with green color and yellow belly
        final bodyColor = i % 2 == 0 
            ? const Color(0xFF4CAF50) // Green
            : const Color(0xFF66BB6A); // Lighter green
        widgets.add(
          _SnakeBodySegment(
            posX: (pos.dx.toInt() * cellSize),
            posY: (pos.dy.toInt() * cellSize),
            size: cellSize,
            color: bodyColor,
          ),
        );
      }
    }
    
    return widgets;
  }

  Widget _buildFood() {
    final pos = state.food;
    return Piece(
      posX: (pos.dx.toInt() * cellSize),
      posY: (pos.dy.toInt() * cellSize),
      size: cellSize,
      color: const Color(0xFFFF2E93),
      isAnimated: true,
    );
  }
}

class _GridPainter extends CustomPainter {
  final int rows;
  final int cols;
  final double cellSize;

  _GridPainter({
    required this.rows,
    required this.cols,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x33FFFFFF)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= rows; i++) {
      final dy = i * cellSize;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
    }

    for (int j = 0; j <= cols; j++) {
      final dx = j * cellSize;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SnakeBodySegment extends StatelessWidget {
  final int posX;
  final int posY;
  final int size;
  final Color color;

  const _SnakeBodySegment({
    Key? key,
    required this.posX,
    required this.posY,
    required this.size,
    required this.color,
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
          borderRadius: BorderRadius.circular(size.toDouble() * 0.2),
          gradient: LinearGradient(
            colors: [
              color,
              const Color(0xFFFFB74D).withOpacity(0.3), // Yellow belly hint
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 0.5,
            ),
          ],
        ),
        // Add subtle spots pattern
        child: CustomPaint(
          painter: _SpotPainter(),
        ),
      ),
    );
  }
}

class _SpotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF81C784).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Draw a few small spots
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.3), size.width * 0.15, paint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.7), size.width * 0.12, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


