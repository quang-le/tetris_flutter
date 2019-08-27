import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frideos_core/frideos_core.dart';
import 'package:tetris/board/grid.dart';
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
  var _gridStream = StreamedValue<Map<List<int>, bool>>();
  var _landed = StreamedValue<bool>()..inStream(false);
  var _isLocking = StreamedValue<bool>()..inStream(false);
  var _tetrimino = StreamedValue<List<List<int>>>()..inStream(<List<int>>[]);
  var _tetriminoType = StreamedValue<BlockType>();
  var _goLeft = StreamedValue<bool>()..inStream(false);
  var _goRight = StreamedValue<bool>()..inStream(false);
  var _gameOver = StreamedValue<bool>()..inStream(false);
  var _gameStart = StreamedValue<bool>()..inStream(false);
  var _blockType = StreamedValue<BlockType>();

  Stream<Map<List<int>, bool>> get gridState => _gridStream.outStream;
  Stream<BlockType> get tetriminoType => _tetriminoType.outStream;

  Stream<bool> get gameOver => _gameOver.outStream;

  void startGame() {
    _gameStart.inStream(true);
    return;
  }

  //assign status false to each cell of the grid and sink it into the stream
  Map<List<int>, bool> _gridState = {};

  // TO DO : refactor this func to call it with params from widget
  Map<List<int>, bool> _makeGridState(Map<List<int>, bool> gridState) {
    grid.grid.forEach((cell) {
      gridState[cell] = false;
      print(cell);
      print(gridState[[0, 0]]);
    });
    _gridStream.inStream(gridState);
    print(gridState.isEmpty);
    return gridState;
  }

  void updateGridState(List<int> cell) {
    print('_gridState[cell]: ${_gridState[cell]}');
    _gridState[cell] = !_gridState[cell];
    print('_gridState[cell]: ${_gridState[cell]}');
    _gridStream.inStream(_gridState);
    return;
  }

  //make the tetrimino fall
  void fall() {
    print('falling');
    _tetrimino.value.forEach((square) {
      _gridStream.value[square] = false;
      square[1] -= 1;
      _gridStream.value[square] = true;
    });
    print('falling done');
    return;
  }

  void goLeft() {
    _goLeft.inStream(true);
    _goLeft.inStream(false);
    checkContactBelow();
    return;
  }

  void goRight() {
    _goRight.inStream(true);
    _goRight.inStream(false);
    checkContactBelow();
    return;
  }

  //check if the piece is in contact with the bottom, or the puzzle
  void checkContactBelow() {
    print('checking for contact');
    _tetrimino.value.forEach((block) {
      List<int> nextBlock = [block[0], block[1] - 1];
      if (block[1] == 0) {
        print('reached bottom');
        // TO DO: test without ternary
        !_isLocking.value ? _isLocking.inStream(true) : null;
        return;
      } else if (nextBlock[1] == 21 && _gridStream.value[nextBlock] == true) {
        _gameOver.inStream(true);
        return;
      } else if (_gridStream.value[nextBlock] == true &&
          _tetrimino.value.contains(nextBlock) == false) {
        // TO DO: test without ternary
        !_isLocking.value ? _isLocking.inStream(true) : null;
        print('found block underneath');
        return;
      }
      _isLocking.inStream(false);
    });
    return;
  }

  void addPiece() {
    switch (_blockType.value) {
      case BlockType.I:
        _tetrimino.inStream([
          [3, 24],
          [4, 24],
          [5, 24],
          [6, 24],
        ]);
        break;
      case BlockType.J:
        _tetrimino.inStream([
          [3, 24],
          [4, 24],
          [5, 24],
          [5, 25],
        ]);
        break;
      case BlockType.L:
        _tetrimino.inStream([
          [3, 24],
          [4, 24],
          [5, 24],
          [3, 25],
        ]);
        break;
      case BlockType.S:
        _tetrimino.inStream([
          [3, 24],
          [4, 24],
          [5, 25],
          [6, 25],
        ]);
        break;
      case BlockType.Z:
        _tetrimino.inStream([
          [3, 25],
          [4, 25],
          [5, 24],
          [6, 24],
        ]);
        break;
      case BlockType.O:
        _tetrimino.inStream([
          [5, 25],
          [6, 25],
          [5, 24],
          [6, 24],
        ]);
        break;
      case BlockType.T:
        _tetrimino.inStream([
          [3, 24],
          [4, 24],
          [5, 24],
          [4, 25],
        ]);
        break;
    }

    _tetrimino.value.forEach((block) => _gridState[block] = true);
    print('added new piece');
    return;
  }

  void hasLanded() {
    //dispose listeners for left and right
    //re-initiaize all movement tracking streams
    _isLocking.inStream(false);
    _landed.inStream(false);
    print('piece landed');
    return;
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

  void dispose() {
    gameStart.cancel();
    _gridStream.dispose();
    _landed.dispose();
    _isLocking.dispose();
    _tetrimino.dispose();
    _blockType.dispose();
    _goLeft.dispose();
    _goRight.dispose();
    _gameStart.dispose();
    _gameOver.dispose();
  }
}
