import 'package:flutter/material.dart';

import 'control_panel.dart';
import 'control_mode.dart';
import 'direction.dart';
import 'game_board.dart';
import 'snake_game.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  static const int _cellSize = 20;

  final SnakeGameEngine _engine = SnakeGameEngine();
  SnakeGameState? _state;
  ControlMode _controlMode = ControlMode.buttons;

  Direction? _queuedDirection;
  late int _rows;
  late int _cols;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initGame();
    });
  }

  void _initGame() {
    final size = MediaQuery.of(context).size;
    _cols = (size.width ~/ _cellSize);
    _rows = ((size.height * 0.5) ~/ _cellSize);

    setState(() {
      _state = _engine.createInitial(
        rows: _rows,
        cols: _cols,
        cellSize: _cellSize,
      );
    });

    _startTicker();
  }

  void _startTicker() {
    Future.doWhile(() async {
      if (!mounted || _state == null || _state!.isGameOver) {
        return false;
      }
      await Future.delayed(
        Duration(milliseconds: (250 ~/ _state!.speed)),
      );
      if (!mounted) return false;
      setState(() {
        _state = _engine.step(_state!, _queuedDirection);
        _queuedDirection = null;
      });
      return true;
    });
  }

  void _onDirectionChanged(Direction direction) {
    setState(() {
      _queuedDirection = direction;
    });
  }

  void _onSwipe(DragEndDetails details) {
    if (details.velocity.pixelsPerSecond.dx.abs() >
        details.velocity.pixelsPerSecond.dy.abs()) {
      if (details.velocity.pixelsPerSecond.dx > 0) {
        _onDirectionChanged(Direction.right);
      } else {
        _onDirectionChanged(Direction.left);
      }
    } else {
      if (details.velocity.pixelsPerSecond.dy > 0) {
        _onDirectionChanged(Direction.down);
      } else {
        _onDirectionChanged(Direction.up);
      }
    }
  }

  Widget _buildScore() {
    final score = _state?.score ?? 0;
    return Text(
      'Score: $score',
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _restart() {
    setState(() {
      _state = _engine.createInitial(
        rows: _rows,
        cols: _cols,
        cellSize: _cellSize,
      );
      _queuedDirection = null;
    });
    _startTicker();
  }

  @override
  Widget build(BuildContext context) {
    if (_state == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF020412),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: _buildScore(),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _restart,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Buttons'),
                  selected: _controlMode == ControlMode.buttons,
                  onSelected: (_) {
                    setState(() {
                      _controlMode = ControlMode.buttons;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Swipe'),
                  selected: _controlMode == ControlMode.swipe,
                  onSelected: (_) {
                    setState(() {
                      _controlMode = ControlMode.swipe;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Gyro'),
                  selected: _controlMode == ControlMode.gyro,
                  onSelected: (_) {
                    setState(() {
                      _controlMode = ControlMode.gyro;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onHorizontalDragEnd:
                  _controlMode == ControlMode.swipe ? _onSwipe : null,
              onVerticalDragEnd:
                  _controlMode == ControlMode.swipe ? _onSwipe : null,
              child: GameBoard(
                state: _state!,
                cellSize: _cellSize,
              ),
            ),
          ),
          const Spacer(),
          if (_controlMode == ControlMode.buttons)
            ControlPanel(
              onTapped: _onDirectionChanged,
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
