import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frideos_core/frideos_core.dart';
import 'package:tetris/board/grid.dart';
import 'package:frideos/frideos.dart';
import 'package:tetris/randomizer.dart';
import 'package:tetris/tetriminos/tetriminos.dart';

class GameBloc {
  final Grid grid;

  GameBloc({@required this.grid}) : assert(grid != null) {
    _makeGridState(_gridState);
    _isLocking.stream.listen((locking) {
      if (locking) {
        stopwatch.start();
      } else if (!locking) {
        stopwatch.stop();
        stopwatch.reset();
      }
    });
    gameStart = _gameStart.stream.listen((start) {
      print('game starting');
    });
  }

  var stopwatch = Stopwatch();
  var randomizer = Randomizer();
  StreamSubscription gameStart;
  var _gridStream = StreamedValue<Map<GridCoordinate, bool>>();
  var _landed = StreamedValue<bool>()..inStream(false);
  var _isLocking = StreamedValue<bool>()..inStream(false);
  var _tetrimino = StreamedValue<List<GridCoordinate>>()..inStream([]);
  var _goLeft = StreamedValue<bool>()..inStream(false);
  var _goRight = StreamedValue<bool>()..inStream(false);
  var _gameOver = StreamedValue<bool>()..inStream(false);
  var _gameStart = StreamedValue<bool>()..inStream(false);
  var _blockType = StreamedValue<BlockType>();

  Stream<Map<GridCoordinate, bool>> get gridState => _gridStream.outStream;

  Stream<bool> get gameOver => _gameOver.outStream;

  void startGame() {
    _gameStart.inStream(true);
  }

  void updateGridState(GridCoordinate cell) {
    print('_gridState[cell]: ${_gridState[cell]}');
    _gridState[cell] = !_gridState[cell];
    print('_gridState[cell]: ${_gridState[cell]}');
    _gridStream.inStream(_gridState);
  }

  //assign status false to each cell of the grid and sink it into the stream
  Map<GridCoordinate, bool> _gridState = {};

  Map<GridCoordinate, bool> _makeGridState(
      Map<GridCoordinate, bool> gridState) {
    grid.grid.forEach((cell) => gridState[cell] = false);
    _gridStream.inStream(gridState);
    return gridState;
  }

  //make the tetrimino fall
  void fall() {
    print('falling');
    _tetrimino.value.forEach((square) {
      _gridStream.value[square] = false;
      square.y += 1;
      _gridStream.value[square] = true;
    });
    print('falling done');
  }

  void goLeft() {
    _goLeft.inStream(true);
    _goLeft.inStream(false);
    checkContactBelow();
  }

  void goRight() {
    _goRight.inStream(true);
    _goRight.inStream(false);
    checkContactBelow();
  }

  //check if the piece is in contact with the bottom, or the puzzle
  void checkContactBelow() {
    print('checking for contact');
    _tetrimino.value.forEach((block) {
      GridCoordinate nextBlock = GridCoordinate(x: block.x, y: block.y - 1);
      if (block.y == 0) {
        print('reached bottom');
        !_isLocking.value ? _isLocking.inStream(true) : null;
        return;
      } else if (nextBlock.y == 21 && _gridStream.value[nextBlock] == true) {
        _gameOver.inStream(true);
        return;
      } else if (_gridStream.value[nextBlock] == true &&
          _tetrimino.value.contains(nextBlock) == false) {
        !_isLocking.value ? _isLocking.inStream(true) : null;
        print('found block underneath');
        return;
      }
      _isLocking.inStream(false);
    });
  }

  void addPiece() {
    switch (_blockType.value) {
      case BlockType.I:
        _tetrimino.inStream([
          GridCoordinate(y: 24, x: 3),
          GridCoordinate(y: 24, x: 4),
          GridCoordinate(y: 24, x: 5),
          GridCoordinate(y: 24, x: 6),
        ]);
        break;
      case BlockType.J:
        _tetrimino.inStream([
          GridCoordinate(y: 24, x: 3),
          GridCoordinate(y: 24, x: 4),
          GridCoordinate(y: 24, x: 5),
          GridCoordinate(y: 25, x: 5),
        ]);
        break;
      case BlockType.L:
        _tetrimino.inStream([
          GridCoordinate(y: 24, x: 3),
          GridCoordinate(y: 24, x: 4),
          GridCoordinate(y: 24, x: 5),
          GridCoordinate(y: 25, x: 3),
        ]);
        break;
      case BlockType.S:
        _tetrimino.inStream([
          GridCoordinate(y: 24, x: 3),
          GridCoordinate(y: 24, x: 4),
          GridCoordinate(y: 25, x: 5),
          GridCoordinate(y: 25, x: 6),
        ]);
        break;
      case BlockType.Z:
        _tetrimino.inStream([
          GridCoordinate(y: 25, x: 3),
          GridCoordinate(y: 25, x: 4),
          GridCoordinate(y: 24, x: 5),
          GridCoordinate(y: 24, x: 6),
        ]);
        break;
      case BlockType.O:
        _tetrimino.inStream([
          GridCoordinate(y: 25, x: 5),
          GridCoordinate(y: 25, x: 6),
          GridCoordinate(y: 24, x: 5),
          GridCoordinate(y: 24, x: 6),
        ]);
        break;
      case BlockType.T:
        _tetrimino.inStream([
          GridCoordinate(y: 24, x: 3),
          GridCoordinate(y: 24, x: 4),
          GridCoordinate(y: 24, x: 5),
          GridCoordinate(y: 25, x: 4),
        ]);
        break;
    }

    _tetrimino.value.forEach((block) => _gridState[block] = true);
    print('added new piece');
  }

  void hasLanded() {
    //dispose listeners for left and right
    //re-initiaize all movement tracking streams
    _isLocking.inStream(false);
    _landed.inStream(false);
    print('piece landed');
  }

  void gameLoop() {
    while (_gameOver.value == false) {
      _blockType.inStream(randomizer.choosePiece());
      addPiece();
      while (_landed.value == false) {
        checkContactBelow();
        if (_isLocking.value == false) {
          Future.delayed(Duration(milliseconds: 600));
          fall();
        }
      }
    }
  }
}
