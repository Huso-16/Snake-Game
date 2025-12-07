import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

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
  
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  DateTime? _lastGyroUpdate;
  static const _gyroUpdateInterval = Duration(milliseconds: 200); // Debounce interval
  static const _tiltThreshold = 2.0; // Minimum tilt to trigger direction change

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initGame();
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
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
    _setupGyroControls();
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

  void _setupGyroControls() {
    _accelerometerSubscription?.cancel();
    
    if (_controlMode == ControlMode.gyro) {
      _accelerometerSubscription = accelerometerEventStream().listen(
        (AccelerometerEvent event) {
          final now = DateTime.now();
          if (_lastGyroUpdate != null &&
              now.difference(_lastGyroUpdate!) < _gyroUpdateInterval) {
            return; // Debounce
          }
          
          final x = event.x;
          final y = event.y;
          final absX = x.abs();
          final absY = y.abs();
          
          // Determine dominant axis
          if (absX > absY && absX > _tiltThreshold) {
            // Horizontal tilt
            _lastGyroUpdate = now;
            if (x > 0) {
              _onDirectionChanged(Direction.right);
            } else {
              _onDirectionChanged(Direction.left);
            }
          } else if (absY > absX && absY > _tiltThreshold) {
            // Vertical tilt
            _lastGyroUpdate = now;
            if (y > 0) {
              _onDirectionChanged(Direction.down);
            } else {
              _onDirectionChanged(Direction.up);
            }
          }
        },
        onError: (error) {
          // Handle sensor errors gracefully
          print('Gyro sensor error: $error');
        },
      );
    }
  }

  void _onSwipe(DragEndDetails details) {
    const minVelocity = 100.0; // Minimum velocity threshold
    
    final dx = details.velocity.pixelsPerSecond.dx;
    final dy = details.velocity.pixelsPerSecond.dy;
    final absDx = dx.abs();
    final absDy = dy.abs();
    
    // Determine dominant axis with minimum threshold
    if (absDx > absDy && absDx > minVelocity) {
      // Horizontal swipe
      if (dx > 0) {
        _onDirectionChanged(Direction.right);
      } else {
        _onDirectionChanged(Direction.left);
      }
    } else if (absDy > absDx && absDy > minVelocity) {
      // Vertical swipe
      if (dy > 0) {
        _onDirectionChanged(Direction.down);
      } else {
        _onDirectionChanged(Direction.up);
      }
    }
    // If neither axis meets threshold, ignore the swipe
  }

  Widget _buildScore() {
    final score = _state?.score ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00F5FF).withOpacity(0.9),
            const Color(0xFF00FFA3).withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00F5FF).withOpacity(0.6),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '$score',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _buildScore(),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF00F5FF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF00F5FF)),
              onPressed: _restart,
            ),
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
                      _setupGyroControls();
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
                      _setupGyroControls();
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
                      _setupGyroControls();
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onPanEnd:
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
