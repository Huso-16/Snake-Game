import 'dart:math';

import 'package:flutter/material.dart';

import 'direction.dart';

class SnakeGameState {
  final List<Offset> snake;
  final Offset food;
  final Direction direction;
  final int rows;
  final int cols;
  final int cellSize;
  final int score;
  final double speed;
  final bool isGameOver;

  const SnakeGameState({
    required this.snake,
    required this.food,
    required this.direction,
    required this.rows,
    required this.cols,
    required this.cellSize,
    required this.score,
    required this.speed,
    required this.isGameOver,
  });

  SnakeGameState copyWith({
    List<Offset>? snake,
    Offset? food,
    Direction? direction,
    int? rows,
    int? cols,
    int? cellSize,
    int? score,
    double? speed,
    bool? isGameOver,
  }) {
    return SnakeGameState(
      snake: snake ?? this.snake,
      food: food ?? this.food,
      direction: direction ?? this.direction,
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      cellSize: cellSize ?? this.cellSize,
      score: score ?? this.score,
      speed: speed ?? this.speed,
      isGameOver: isGameOver ?? this.isGameOver,
    );
  }
}

class SnakeGameEngine {
  final Random _random = Random();

  SnakeGameState createInitial({
    required int rows,
    required int cols,
    int cellSize = 20,
  }) {
    final initialDirection = Direction.right;
    final initialSnake = <Offset>[
      Offset((cols ~/ 2).toDouble(), (rows ~/ 2).toDouble()),
    ];
    final food = _generateFood(rows: rows, cols: cols, snake: initialSnake);

    return SnakeGameState(
      snake: initialSnake,
      food: food,
      direction: initialDirection,
      rows: rows,
      cols: cols,
      cellSize: cellSize,
      score: 0,
      speed: 1,
      isGameOver: false,
    );
  }

  SnakeGameState step(SnakeGameState state, Direction? nextDirection) {
    if (state.isGameOver) return state;
    
    // Safety check: ensure valid grid dimensions
    if (state.rows <= 0 || state.cols <= 0) {
      return state.copyWith(isGameOver: true);
    }

    final Direction effectiveDirection =
        _validateDirectionChange(state.direction, nextDirection);

    final List<Offset> newSnake = List<Offset>.from(state.snake);

    final Offset head = newSnake.first;
    Offset newHead = _nextHead(head, effectiveDirection, state.rows, state.cols);

    if (_hitsSelf(newHead, newSnake)) {
      return state.copyWith(isGameOver: true);
    }

    newSnake.insert(0, newHead);

    Offset newFood = state.food;
    int newScore = state.score;
    double newSpeed = state.speed;

    if (newHead == state.food) {
      newScore += 5;
      newSpeed += 0.05;
      newFood = _generateFood(
        rows: state.rows,
        cols: state.cols,
        snake: newSnake,
      );
    } else {
      newSnake.removeLast();
    }

    return state.copyWith(
      snake: newSnake,
      food: newFood,
      direction: effectiveDirection,
      score: newScore,
      speed: newSpeed,
    );
  }

  Direction _validateDirectionChange(
      Direction current, Direction? requested) {
    if (requested == null) return current;
    if ((current == Direction.left && requested == Direction.right) ||
        (current == Direction.right && requested == Direction.left) ||
        (current == Direction.up && requested == Direction.down) ||
        (current == Direction.down && requested == Direction.up)) {
      return current;
    }
    return requested;
  }

  Offset _nextHead(
      Offset head, Direction direction, int rows, int cols) {
    // Safety check: ensure valid dimensions
    if (rows <= 0 || cols <= 0) {
      return head; // Return current position if grid is invalid
    }

    int x = head.dx.toInt();
    int y = head.dy.toInt();

    if (direction == Direction.right) {
      x = (x + 1 + cols) % cols;
    } else if (direction == Direction.left) {
      x = (x - 1 + cols) % cols;
    } else if (direction == Direction.up) {
      y = (y - 1 + rows) % rows;
    } else if (direction == Direction.down) {
      y = (y + 1 + rows) % rows;
    }

    return Offset(x.toDouble(), y.toDouble());
  }

  bool _hitsSelf(Offset head, List<Offset> snake) {
    for (int i = 1; i < snake.length; i++) {
      if (snake[i] == head) return true;
    }
    return false;
  }

  Offset _generateFood({
    required int rows,
    required int cols,
    required List<Offset> snake,
  }) {
    // Safety check: ensure valid grid dimensions
    if (rows <= 0 || cols <= 0) {
      // Return a default position if grid is invalid
      return const Offset(0, 0);
    }

    // Limit iterations to prevent infinite loops
    int attempts = 0;
    const maxAttempts = 1000;
    
    while (attempts < maxAttempts) {
      final x = _random.nextInt(cols);
      final y = _random.nextInt(rows);
      final candidate = Offset(x.toDouble(), y.toDouble());
      if (!snake.contains(candidate)) {
        return candidate;
      }
      attempts++;
    }
    
    // Fallback: return first available position if random generation fails
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        final candidate = Offset(x.toDouble(), y.toDouble());
        if (!snake.contains(candidate)) {
          return candidate;
        }
      }
    }
    
    // Last resort: return a position that might overlap (shouldn't happen)
    return Offset((cols ~/ 2).toDouble(), (rows ~/ 2).toDouble());
  }
}


