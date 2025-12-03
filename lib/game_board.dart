import 'package:flutter/material.dart';

import 'piece.dart';
import 'snake_game.dart';

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
    return state.snake.asMap().entries.map((entry) {
      final index = entry.key;
      final pos = entry.value;
      final isHead = index == 0;

      return Piece(
        posX: (pos.dx.toInt() * cellSize),
        posY: (pos.dy.toInt() * cellSize),
        size: cellSize,
        color: isHead ? const Color(0xFF00F5FF) : const Color(0xFF00FFA3),
        isAnimated: false,
      );
    }).toList();
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


