import 'dart:async';

import 'package:collection/collection.dart';
import 'package:frideos_core/frideos_core.dart';
import 'package:tetris/randomizer.dart';

class GameBloc {
  GameBloc() {
    // TODO stop locking and send next block
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
      gameLoop();
    });
  }

  var stopwatch = Stopwatch();
  var randomizer = Randomizer();
  StreamSubscription gameStart;

  var _grid = StreamedValue<Map<List<int>, BlockType>>();
  var _landed = StreamedValue<bool>()..inStream(false);
  var _isLocking = StreamedValue<bool>()..inStream(false);
  var _tetrimino = StreamedList<List<int>>()..inStream(<List<int>>[]);
  var _goLeft = StreamedValue<bool>()..inStream(false);
  var _goRight = StreamedValue<bool>()..inStream(false);
  var _gameOver = StreamedValue<bool>()..inStream(false);
  var _gameStart = StreamedValue<bool>()..inStream(true);
  var _blockType = StreamedValue<BlockType>();

  Stream<Map<List<int>, BlockType>> get grid => _grid.outStream;
  Stream<List<List<int>>> get tetrimino => _tetrimino.outStream;
  Stream<BlockType> get tetriminoType => _blockType.outStream;

  Stream<bool> get gameOver => _gameOver.outStream;

  void startGame() {
    _gameStart.inStream(true);
    return;
  }

  void initializeGrid(int horizontal, int vertical) {
    List<int> gridX = List<int>.generate(horizontal, (i) => i, growable: false);
    List<int> gridY = List<int>.generate(vertical, (i) => i, growable: false);
    List<List<int>> gridCoordinates = _generateGridCoordinates(gridX, gridY);
    Map<List<int>, BlockType> grid = _generateGrid(gridCoordinates);
    _grid.value = grid;
    return;
  }

  List<List<int>> _generateGridCoordinates(List<int> gridX, List<int> gridY) {
    List<List<int>> coordinates = [];
    for (var j = 0; j < gridY.length; j++) {
      for (var i = 0; i < gridX.length; i++) {
        coordinates.add([gridX[i], gridY[j]]);
      }
    }
    return coordinates;
  }

  Map<List<int>, BlockType> _generateGrid(List<List<int>> gridCoordinates) {
    Map<List<int>, BlockType> grid = {};
    for (var i = 0; i < gridCoordinates.length; i++) {
      List<int> coordinates = gridCoordinates[i];
      grid.putIfAbsent(coordinates, () => BlockType.empty);
      print('grid[$coordinates]: ${grid[coordinates]}');
    }
    return grid;
  }

  // TODO fix falling function
  //make the tetrimino fall
  void fall() {
    var gridClone = Map<List<int>, BlockType>.from(_grid.value);
    print('falling');
    _tetrimino.value.forEach((cell) {
      print('cell: $cell');
      List<int> newCell = [cell[0], cell[1] - 1];
      _updateCell(cell, BlockType.empty, gridClone);
      _updateCell(newCell, _blockType.value, gridClone);
      _tetrimino.replace(cell, newCell);
      print('cell updated: $cell');
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

  // TODO Fix contact detection
  void checkContactBelow() {
    print('checking for contact');
    _tetrimino.value.forEach((cell) {
      List<int> nextBlock = [cell[0], cell[1] - 1];
      BlockType nextBlockType = findCell(nextBlock, _grid.value);
      if (cell[1] == 0) {
        print('reached bottom');
        // TO DO: test without ternary
        !_isLocking.value ? _isLocking.value = true : null;
        return;
      } else if (nextBlock[1] == 21 && nextBlockType == BlockType.locked) {
        _gameOver.value = true;
        return;
      } else if (nextBlockType == BlockType.locked &&
          _tetrimino.value.contains(nextBlock) == false) {
        // TO DO: test without ternary
        !_isLocking.value ? _isLocking.value = true : null;
        print('found block underneath');
        return;
      }
      _isLocking.value = false;
    });
    return;
  }

  // TODO : make this function work
  void addPiece() {
    switch (_blockType.value) {
      case BlockType.I:
        _tetrimino.value = [
          [3, 24],
          [4, 24],
          [5, 24],
          [6, 24],
        ];
        break;
      case BlockType.J:
        _tetrimino.value = [
          [3, 24],
          [4, 24],
          [5, 24],
          [5, 25],
        ];
        break;
      case BlockType.L:
        _tetrimino.value = [
          [3, 24],
          [4, 24],
          [5, 24],
          [3, 25],
        ];
        break;
      case BlockType.S:
        _tetrimino.value = [
          [3, 24],
          [4, 24],
          [5, 25],
          [6, 25],
        ];
        break;
      case BlockType.Z:
        _tetrimino.value = [
          [3, 25],
          [4, 25],
          [5, 24],
          [6, 24],
        ];
        break;
      case BlockType.O:
        _tetrimino.value = [
          [5, 25],
          [6, 25],
          [5, 24],
          [6, 24],
        ];
        break;
      case BlockType.T:
        _tetrimino.value = [
          [3, 24],
          [4, 24],
          [5, 24],
          [4, 25],
        ];
        break;
      default:
        break;
    }

    _tetrimino.value
        .forEach((cell) => _updateCell(cell, _blockType.value, _grid.value));
    print('added new piece');
    return;
  }

  void _updateCell(
    List<int> coordinates,
    BlockType type,
    Map<List<int>, BlockType> grid,
  ) {
    Map<List<int>, BlockType> clonedGrid = Map<List<int>, BlockType>.from(grid);
    clonedGrid.forEach((index, blockType) {
      const compareCoordinates = IterableEquality();
      if (compareCoordinates.equals(index, coordinates)) {
        blockType = type;
      }
    });
    _grid.inStream(clonedGrid);
    return;
  }

  BlockType findCell(
    List<int> coordinates,
    Map<List<int>, BlockType> grid,
  ) {
    const compareLists = IterableEquality();
    BlockType target;
    grid.forEach((index, type) {
      if (compareLists.equals(index, coordinates)) {
        target = type;
      }
    });
    return target;
  }

  void hasLanded() {
    //dispose listeners for left and right
    //re-initiaize all movement tracking streams
    _isLocking.value = false;
    _landed.value = false;
    print('piece landed');
    return;
  }

  // TODO double check randomizer
  void gameLoop() {
    while (_gameOver.value == false) {
      var newBlock = randomizer.choosePiece();
      _blockType.value = newBlock;
      print('block added: ${_blockType.value}');
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
    _grid.dispose();
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

enum BlockType { I, J, L, T, S, Z, O, empty, locked }
