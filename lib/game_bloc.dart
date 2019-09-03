import 'dart:async';

import 'package:collection/collection.dart';
import 'package:frideos_core/frideos_core.dart';
import 'package:tetris/randomizer.dart';
import 'package:tetris/tetriminos/tetriminos.dart';

class GameBloc {
  GameBloc() {
    // TODO stop locking and send next block
    _isLocking.stream.listen((locking) {
      if (locking) {
        stopwatchLock.start();
      } else if (!locking) {
        stopwatchLock.stop();
        stopwatchLock.reset();
      }
    });
    gameStart = _gameStart.stream.listen((start) {
      gameLoop();
    });
  }

  var stopwatchLock = Stopwatch();
  var stopwatchFall = Stopwatch();
  var randomizer = Randomizer();
  var compareList = IterableEquality();
  var mapCompare = MapEquality();
  StreamSubscription gameStart;

  var _grid = StreamedValue<Map<List<int>, BlockType>>();
  var _landed = StreamedValue<bool>()..inStream(false);
  var _isLocking = StreamedValue<bool>()..inStream(false);
  var _tetrimino = StreamedList<List<int>>()..inStream(<List<int>>[]);
  var _goLeft = StreamedValue<bool>()..inStream(false);
  var _goRight = StreamedValue<bool>()..inStream(false);
  var _isRotating = StreamedValue<bool>()..inStream(false);
  var _gameOver = StreamedValue<bool>()..inStream(false);
  var _gameStart = StreamedValue<bool>()..inStream(true);
  var _blockType = StreamedValue<BlockType>();
  var _center = StreamedList<int>()
    ..value = ([
      5,
      21
    ]); // arbitrary value to avoid null error. correct value set by add()

  Stream<Map<List<int>, BlockType>> get grid => _grid.outStream;
  Stream<List<List<int>>> get tetrimino => _tetrimino.outStream;

  Stream<bool> get gameOver => _gameOver.outStream;

  void startGame() {
    _gameStart.value = true;
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
    }
    return grid;
  }

  void addPiece() {
    _tetrimino.value = Tetriminos.coordinates(_blockType.value);

    _tetrimino.value
        .forEach((cell) => _updateCell(cell, _blockType.value, _grid.value));
    _center.value = Tetriminos.setCenter(_blockType.value);
    return;
  }

  void move(Direction direction) {
    // keep copy of old coordinates for clearing display
    var cellsToRemove = List<List<int>>.from(_tetrimino.value);

    // update tetrimino position in stream
    _updateTetriminoPositionInStream(direction);

    // Identify cells to keep (new cell position overlaps old cell position)
    List<List<int>> cellsToKeep =
        _createListOfMatchingLists(cellsToRemove, _tetrimino.value);

    //if no cells of the new position overlap with previous position, clear old cells
    _clearOldCells(cellsToRemove, cellsToKeep);

    return;
  }

  void fall() {
    move(Direction.down);
    if (_center.value.isNotEmpty) {
      if (_center.value[1] > 0) {
        _center.value[1]--;
        _center.refresh();
      }
    }

    return;
  }

  void moveLeft() {
    move(Direction.left);
    if (_center.value.isNotEmpty) {
      if (_center.value[0] > 0) {
        _center.value[0]--;
        _center.refresh();
      }
    }
    return;
  }

  void moveRight() {
    move(Direction.right);
    if (_center.value.isNotEmpty) {
      if (_center.value[0] < 10) {
        _center.value[0]++;
        _center.refresh();
      }
    }
    return;
  }

  void userInputLeft() {
    _goRight.value = false;
    _goLeft.value = true;
    return;
  }

  void userInputRight() {
    _goLeft.value = false;
    _goRight.value = true;
    return;
  }

  void userInputEnd() {
    _goLeft.value = false;
    _goRight.value = false;
    return;
  }

  void userInputRotate() {
    _isRotating.value = true;
    return;
  }

  // TODO add left or right param
  List<List<int>> _obtainRotatedCoordinates() {
    var center = _center.value;
    var matrix = Tetriminos.leftMatrix;
    var tetrimino = _tetrimino.value;
    if (center.isNotEmpty) {
      var offSetBlocks = Tetriminos.centerCoordinatesOnCell(center, tetrimino);
      var vectorTetrimino = Tetriminos.convertListToVector(offSetBlocks);
      vectorTetrimino.forEach((cell) {
        cell.postmultiply(matrix);
        print("rotated cell: $cell");
      });
      var updatedCoordinates = Tetriminos.convertVectorToList(vectorTetrimino);
      var updatedCoordinatesOnGrid =
          Tetriminos.convertCoordinatesToGrid(center, updatedCoordinates);
      return updatedCoordinatesOnGrid;
    }
    return tetrimino;
  }

  // TODO add left or right param
  void rotate() {
    if (_center.value.isNotEmpty) {
      var updatedCoordinatesOnGrid = _obtainRotatedCoordinates();

      // keep copy of old coordinates for clearing display
      var cellsToRemove = List<List<int>>.from(_tetrimino.value);

      // TODO add wall detection here

      //update tetrimino stream
      _tetrimino.value = updatedCoordinatesOnGrid;
      // update grid with correct block value
      _tetrimino.value.forEach((cell) {
        _updateCell(cell, _blockType.value, _grid.value);
      });

      // Identify cells to keep (new cell position overlaps old cell position)
      List<List<int>> cellsToKeep =
          _createListOfMatchingLists(cellsToRemove, _tetrimino.value);

      //if no cells of the new position overlap with previous position, clear old cells
      _clearOldCells(cellsToRemove, cellsToKeep);
    }

    return;
  }

  void _clearOldCells(
      List<List<int>> cellsToRemove, List<List<int>> cellsToKeep) {
    //if no cells of the new position overlap with previous position, clear old cells
    if (cellsToKeep.isEmpty) {
      cellsToRemove.forEach((cellToClear) {
        _updateCell(cellToClear, BlockType.empty, _grid.value);
      });
      //otherwise remove matching cells from clearing
    } else {
      // TODO encapsulate in _createListOfNonMatchingLists
      List<List<int>> cellsToRemoveUpdated = [];
      cellsToRemove.forEach((cellToClear) {
        var removeFromRemoveList = _matchLists(cellToClear, cellsToKeep);
        if (removeFromRemoveList.isEmpty) {
          cellsToRemoveUpdated.add(cellToClear);
        }
      });
      cellsToRemove = cellsToRemoveUpdated;
      cellsToRemove.forEach((cellToClear) {
        _updateCell(cellToClear, BlockType.empty, _grid.value);
      });
    }
  }

  // TODO refactor all reachBlock functions for clarity
  void checkContactOnSide() {
    var reachLeftLimit =
        _tetrimino.value.firstWhere((cell) => cell[0] == 0, orElse: () => []);
    var reachRightLimit =
        _tetrimino.value.firstWhere((cell) => cell[0] == 9, orElse: () => []);
    var reachBlockOnLeft = _tetrimino.value.firstWhere((cell) {
      if (cell[0] != 0) {
        List<int> nextBlock = [cell[0] - 1, cell[1]];
        BlockType nextBlockType = findCell(nextBlock, _grid.value);
        return ((nextBlockType == BlockType.locked &&
            _tetrimino.value.contains(nextBlock) == false));
      }
      return false;
    }, orElse: () => []);

    var reachBlockOnRight = _tetrimino.value.firstWhere((cell) {
      if (cell[0] != 9) {
        List<int> nextBlock = [cell[0] + 1, cell[1]];
        BlockType nextBlockType = findCell(nextBlock, _grid.value);
        return ((nextBlockType == BlockType.locked &&
            _tetrimino.value.contains(nextBlock) == false));
      }
      return false;
    }, orElse: () => []);

    if (reachLeftLimit.isNotEmpty || reachBlockOnLeft.isNotEmpty) {
      _goLeft.value = false;
    }

    if (reachRightLimit.isNotEmpty || reachBlockOnRight.isNotEmpty) {
      _goRight.value = false;
    }
  }

  void checkContactBelow() {
    var reachBottom =
        _tetrimino.value.firstWhere((cell) => cell[1] == 0, orElse: () => []);
    var reachTop = _tetrimino.value.firstWhere((cell) {
      List<int> nextBlock = [cell[0], cell[1] - 1];
      BlockType nextBlockType = findCell(nextBlock, _grid.value);
      return (nextBlock[1] == 20 &&
          nextBlockType == BlockType.locked &&
          _tetrimino.value.contains(nextBlock) == false);
    }, orElse: () => []);

    var reachOtherBlock = _tetrimino.value.firstWhere((cell) {
      List<int> nextBlock = [cell[0], cell[1] - 1];
      BlockType nextBlockType = findCell(nextBlock, _grid.value);
      return (nextBlockType == BlockType.locked &&
          _tetrimino.value.contains(nextBlock) == false);
    }, orElse: () => []);

    if (reachTop.isNotEmpty) {
      _gameOver.value = true;
      print('++++++++++++++++++++GAME OVER+++++++++++++++++++++');
      return;
    }

    if (reachBottom.isNotEmpty || reachOtherBlock.isNotEmpty) {
      if (!_isLocking.value) {
        _isLocking.value = true;
        return;
      }
      return;
    }
    _isLocking.value = false;
    return;
  }

  List<int> _determineMovementValues(Direction direction, List<int> cell) {
    List<int> movementValues = [];
    switch (direction) {
      case Direction.down:
        movementValues = [cell[0], cell[1] - 1];
        break;
      case Direction.left:
        if (cell[0] > 0) {
          movementValues = [cell[0] - 1, cell[1]];
        } else {
          movementValues = [cell[0], cell[1]];
        }
        break;
      case Direction.right:
        if (cell[0] < 10) {
          movementValues = [cell[0] + 1, cell[1]];
        } else {
          movementValues = [cell[0], cell[1]];
        }
    }
    return movementValues;
  }

  void _updateTetriminoPositionInStream(Direction direction) {
    _tetrimino.value.forEach((cell) {
      List<int> newCell = _determineMovementValues(direction, cell);
      _updateCell(newCell, _blockType.value, _grid.value);
      _tetrimino.replace(cell, newCell);
      _tetrimino.refresh();
    });
  }

  List<List<int>> _createListOfMatchingLists(
      List<List<int>> list1, List<List<int>> list2) {
    List<List<int>> cellsToKeep = [];
    list1.forEach((oldCell) {
      var matchingCell = _matchLists(oldCell, list2);
      if (matchingCell.isNotEmpty) {
        cellsToKeep.add(matchingCell);
      }
    });
    return cellsToKeep;
  }

// TODO refactor variable names for clarity
  List<int> _matchLists(List<int> list, List<List<int>> list2D) {
    var matchingCell = list2D
        .firstWhere((cell) => compareList.equals(cell, list), orElse: () => []);

    return matchingCell;
  }

  void _updateCell(
    List<int> coordinates,
    BlockType type,
    Map<List<int>, BlockType> grid,
  ) {
    Map<List<int>, BlockType> clonedGrid = Map<List<int>, BlockType>.from(grid);
    clonedGrid.forEach((index, blockType) {
      if (compareList.equals(index, coordinates)) {
        clonedGrid[index] = type;
      }
    });
    _grid.value = clonedGrid;
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

// TODO get width and height from widget i.o. hard coded in function
  void clearLines(Map<List<int>, BlockType> grid) {
    Map<List<int>, BlockType> clonedGrid = Map<List<int>, BlockType>.from(grid);
    List<Map<List<int>, BlockType>> fullLines = [];
    // Create subMaps by line/ y coordinate
    // use decremental loop to allow grid update from top to bottom
    for (var i = 19; i >= 0; i--) {
      Map<List<int>, BlockType> line = {};
      Map<List<int>, BlockType> controlLine = {};
      clonedGrid.forEach((coordinates, type) {
        if (coordinates[1] == i) {
          controlLine.putIfAbsent(coordinates, () => type);
        }
      });
      // create a line with all locked blocks and a control line with all blocks
      controlLine.forEach((coordinates, type) {
        if (type == BlockType.locked) {
          line.putIfAbsent(coordinates, () => type);
        }
      });
      // check if line is full then add to fullLines
      if (mapCompare.equals(line, controlLine)) {
        fullLines.add(line);
      }
    }
    // clear full lines from grid
    if (fullLines.isNotEmpty) {
      fullLines.forEach((line) {
        line.forEach((index, cell) {
          _updateCell(index, BlockType.empty, _grid.value);
        });
      });
      // make list of y coordinate of cleared line
      List<int> yCoordinate = [];
      fullLines.forEach((line) {
        List<List<int>> lineKeys = line.keys.toList();
        int coordinateToAdd = lineKeys[0][1];
        yCoordinate.add(coordinateToAdd);
      });
      yCoordinate.sort();
      // for each coordinate, replace the blockType by the type of the block above
      for (var i = yCoordinate.length - 1; i >= 0; i--) {
        for (var j = yCoordinate[i]; j < 21; j++) {
          _grid.value.forEach((gridCoord, type) {
            if (gridCoord[1] == j) {
              var cellToMoveDown = _matchLists(
                  [gridCoord[0], gridCoord[1] + 1], _grid.value.keys.toList());
              var newType = _grid.value[cellToMoveDown];
              _updateCell(gridCoord, newType, _grid.value);
            }
          });
        }
      }
    }
  }

  void gameLoop() async {
    while (_gameOver.value == false) {
      var newBlock = randomizer.choosePiece();
      _blockType.value = newBlock;
      addPiece();
      while (_landed.value == false) {
        stopwatchFall.start();
        // TODO modify fall delay programmatically
        while (stopwatchFall.elapsedMilliseconds < 2000) {
          // Future necessary for performance and to give time to render
          await Future.delayed(Duration(milliseconds: 100));
          checkContactOnSide();
          if (_isRotating.value) {
            rotate();
            _isRotating.value = false;
          }

          if (_goLeft.value) {
            moveLeft();
          }
          if (_goRight.value) {
            moveRight();
          }
          checkContactBelow();
        }
        stopwatchFall.stop();
        stopwatchFall.reset();
        if (_isLocking.value == true &&
            stopwatchLock.elapsedMilliseconds > 1000) {
          _landed.value = true;
          print('==============LANDED================');
        } else if (_isLocking.value == false) {
          // TODO modify fall delay programmatically
          //await Future.delayed(Duration(milliseconds: 400));
          fall();
        }
      }
      // reinitialize control values if block landed
      if (_landed.value == true) {
        _isLocking.value = false;
        _tetrimino.value.forEach(
            (cell) => _updateCell(cell, BlockType.locked, _grid.value));
        _tetrimino.value = [];
        clearLines(_grid.value);
      }
      _landed.value = false;
    }
  }

  void dispose() {
    gameStart.cancel();
    _center.dispose();
    _grid.dispose();
    _landed.dispose();
    _isLocking.dispose();
    _tetrimino.dispose();
    _blockType.dispose();
    _goLeft.dispose();
    _goRight.dispose();
    _gameStart.dispose();
    _gameOver.dispose();
    _isRotating.dispose();
  }
}

enum BlockType { I, J, L, T, S, Z, O, empty, locked }

enum Direction { left, right, down }
