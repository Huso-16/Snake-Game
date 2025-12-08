import 'dart:async';

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
  final SnakeGameEngine _engine = SnakeGameEngine();
  SnakeGameState? _state;
  ControlMode _controlMode = ControlMode.buttons;

  Direction? _queuedDirection;
  int _rows = 20;
  int _cols = 20;
  int _cellSize = 20;
  BoxConstraints? _lastConstraints;
  bool _lastHasButtons = true;
  
  Timer? _gameTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initGame();
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void _initGame() {
    setState(() {
      _state = _engine.createInitial(
        rows: _rows,
        cols: _cols,
        cellSize: _cellSize,
      );
    });
    _startTicker();
  }

  (int cols, int rows, int cellSize) _calculateGridSize(BoxConstraints constraints, bool hasButtons) {
    // Calculate available space
    final padding = 24.0;
    final topSpace = 140.0; // App bar + score + mode selector
    final bottomSpace = hasButtons ? 140.0 : 40.0;
    
    final availableWidth = constraints.maxWidth - (padding * 2);
    final availableHeight = constraints.maxHeight - topSpace - bottomSpace;
    
    // Target: 20-25 cells for good gameplay
    final targetCells = 22.0;
    
    // Calculate cell size from both dimensions, use smaller to fit
    final cellSizeFromWidth = availableWidth / targetCells;
    final cellSizeFromHeight = availableHeight / targetCells;
    
    final optimalCellSize = (cellSizeFromWidth < cellSizeFromHeight 
        ? cellSizeFromWidth 
        : cellSizeFromHeight).floor();
    
    // Clamp to reasonable bounds
    final effectiveCellSize = optimalCellSize.clamp(15, 35);
    
    // Calculate grid dimensions
    final cols = (availableWidth ~/ effectiveCellSize);
    final rows = (availableHeight ~/ effectiveCellSize);
    
    // Ensure minimum playable size
    if (cols >= 15 && rows >= 15) {
      return (cols, rows, effectiveCellSize);
    }
    
    // Fallback to defaults
    return (_cols, _rows, _cellSize);
  }

  void _startTicker() {
    _gameTimer?.cancel();
    
    void tick() {
      if (!mounted || _state == null || _state!.isGameOver) {
        _gameTimer?.cancel();
        return;
      }
      
      setState(() {
        _state = _engine.step(_state!, _queuedDirection);
        _queuedDirection = null;
      });
      
      if (mounted && _state != null && !_state!.isGameOver) {
        _gameTimer = Timer(
          Duration(milliseconds: (250 ~/ _state!.speed).clamp(50, 500)),
          tick,
        );
      }
    }
    
    _gameTimer = Timer(
      Duration(milliseconds: (250 ~/ (_state?.speed ?? 1.0)).clamp(50, 500)),
      tick,
    );
  }

  void _onDirectionChanged(Direction direction) {
    setState(() {
      _queuedDirection = direction;
    });
  }

  void _onSwipe(DragEndDetails details) {
    const minVelocity = 100.0;
    
    final dx = details.velocity.pixelsPerSecond.dx;
    final dy = details.velocity.pixelsPerSecond.dy;
    final absDx = dx.abs();
    final absDy = dy.abs();
    
    if (absDx > absDy && absDx > minVelocity) {
      if (dx > 0) {
        _onDirectionChanged(Direction.right);
      } else {
        _onDirectionChanged(Direction.left);
      }
    } else if (absDy > absDx && absDy > minVelocity) {
      if (dy > 0) {
        _onDirectionChanged(Direction.down);
      } else {
        _onDirectionChanged(Direction.up);
      }
    }
  }

  Widget _buildScore() {
    final score = _state?.score ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF00F5FF),
            Color(0xFF00FFA3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00F5FF).withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: Colors.white,
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(
            '$score',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
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
    _gameTimer?.cancel();
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
        backgroundColor: Color(0xFF020412),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF00F5FF),
          ),
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
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF00F5FF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF00F5FF)),
              onPressed: _restart,
              tooltip: 'Restart',
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final hasButtons = _controlMode == ControlMode.buttons;
          
          // Only recalculate if constraints or control mode changed significantly
          final shouldRecalculate = _lastConstraints == null ||
              (_lastConstraints!.maxWidth - constraints.maxWidth).abs() > 10 ||
              (_lastConstraints!.maxHeight - constraints.maxHeight).abs() > 10 ||
              _lastHasButtons != hasButtons;
          
          if (shouldRecalculate) {
            final (cols, rows, cellSize) = _calculateGridSize(constraints, hasButtons);
            
            if (cols != _cols || rows != _rows || cellSize != _cellSize) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _cols = cols;
                    _rows = rows;
                    _cellSize = cellSize;
                    _lastConstraints = constraints;
                    _lastHasButtons = hasButtons;
                    
                    // Reinitialize game
                    _state = _engine.createInitial(
                      rows: _rows,
                      cols: _cols,
                      cellSize: _cellSize,
                    );
                  });
                  _startTicker();
                }
              });
            } else {
              _lastConstraints = constraints;
              _lastHasButtons = hasButtons;
            }
          }
          
          return Column(
          children: [
              // Control mode selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildModeChip(
                      label: 'Buttons',
                      isSelected: _controlMode == ControlMode.buttons,
                      onTap: () {
                        setState(() {
                          _controlMode = ControlMode.buttons;
                        });
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildModeChip(
                      label: 'Swipe',
                      isSelected: _controlMode == ControlMode.swipe,
                      onTap: () {
                        setState(() {
                          _controlMode = ControlMode.swipe;
                        });
                      },
                    ),
                  ],
                ),
              ),
              
              // Game board - takes remaining space
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: GestureDetector(
                      onPanEnd: _controlMode == ControlMode.swipe ? _onSwipe : null,
                      child: GameBoard(
                        state: _state!,
                        cellSize: _cellSize,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Control panel (only for buttons mode)
              if (_controlMode == ControlMode.buttons)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: ControlPanel(
                    onTapped: _onDirectionChanged,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildModeChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00F5FF).withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00F5FF)
                : Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF00F5FF),
                size: 18,
              )
            else
              const SizedBox(width: 18),
            if (isSelected) const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF00F5FF) : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
