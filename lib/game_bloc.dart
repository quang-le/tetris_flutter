import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
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

  List<List<int>> _findOverlappingCells(List<List<int>> tetrimino) {
    List<List<int>> overlappingCells = [];
    tetrimino.forEach((cell) {
      BlockType cellType = findCell(cell, _grid.value);
      if (cellType == BlockType.locked) {
        overlappingCells.add(cell);
      } else if ((cell[0] < 0) || (cell[0] > 9) || cell[1] < 0) {
        overlappingCells.add(cell);
      }
    });
    return overlappingCells;
  }

// TODO change name to account for return type
  List<List<int>> rotateContactDetection(List<List<int>> tetrimino) {
    List<List<int>> result = List.from(tetrimino);
    List<List<int>> overlappingCells = [];
    List<List<int>> leftOverlap = [];
    List<List<int>> rightOverlap = [];
    List<List<int>> topOverlap = [];
    List<List<int>> bottomOverlap = [];

    // check if new coordinates are out of bounds or overlap with a block
    overlappingCells = _findOverlappingCells(result);
    if (overlappingCells.isEmpty) {
      return result;
    }

    // TODO put in separate func
    //sort overlapping bocks by overlap type (up,down,left,right)
    overlappingCells.forEach((cell) {
      List<int> centeredCell = [
        cell[0] - _center.value[0],
        cell[1] - _center.value[1]
      ];
      if (centeredCell[0] < 0) {
        leftOverlap.add(centeredCell);
      }
      if (centeredCell[0] > 0) {
        rightOverlap.add(centeredCell);
      }
      if (centeredCell[1] < 0) {
        bottomOverlap.add(centeredCell);
      }
      if (centeredCell[1] > 0) {
        topOverlap.add(centeredCell);
      }
    });

    // TODO pass tetrimino.value as param
    //if 2 overlaps on same axis: no rotation
    if ((topOverlap.isNotEmpty && bottomOverlap.isNotEmpty) ||
        (leftOverlap.isNotEmpty && rightOverlap.isNotEmpty)) {
      return _tetrimino.value;
    }

    /// Push from the left, no y axis ambiguity
    if (leftOverlap.isNotEmpty &&
        rightOverlap.isEmpty &&
        topOverlap.isEmpty &&
        bottomOverlap.isEmpty) {
      var pushedTetrimino = _pushFromLeft(result, leftOverlap);
      result = pushedTetrimino;
    }

    /// Push from the right, no y axis ambiguity
    else if (rightOverlap.isNotEmpty &&
        leftOverlap.isEmpty &&
        topOverlap.isEmpty &&
        bottomOverlap.isEmpty) {
      var pushedTetrimino = _pushFromRight(result, rightOverlap);
      result = pushedTetrimino;
    }

    /// Push from the bottom, no x axis ambiguity
    else if (bottomOverlap.isNotEmpty &&
        topOverlap.isEmpty &&
        leftOverlap.isEmpty &&
        rightOverlap.isEmpty) {
      var pushedTetrimino = _pushFromBottom(result, bottomOverlap);
      result = pushedTetrimino;
    }

    /// Push from the top, no x axis ambiguity
    else if (topOverlap.isNotEmpty &&
        bottomOverlap.isEmpty &&
        leftOverlap.isEmpty &&
        rightOverlap.isEmpty) {
      var pushedTetrimino = _pushFromTop(result, topOverlap);
      result = pushedTetrimino;
    }

    /// Push with top_left ambiguity
    else if (topOverlap.isNotEmpty &&
        leftOverlap.isNotEmpty &&
        bottomOverlap.isEmpty &&
        rightOverlap.isEmpty) {
      if (leftOverlap.length > 1) {
        var pushedTetrimino = _pushFromLeft(result, leftOverlap);
        result = pushedTetrimino;
      } else if (topOverlap.length > 1) {
        var pushedTetrimino = _pushFromTop(result, topOverlap);
        result = pushedTetrimino;
      } else if (leftOverlap.length == 1 && topOverlap.length == 1) {
        var pushedTetrimino = _pushFromLeft(result, leftOverlap);
        var overlappingAfterPush = _findOverlappingCells(pushedTetrimino);

        // if overlap after pushing on the side, do vertical push
        if (overlappingAfterPush.isEmpty) {
          result = pushedTetrimino;
          // overlap after this push will be done before return
        } else {
          pushedTetrimino = _pushFromTop(result, topOverlap);
          result = pushedTetrimino;
        }
      }
    }

    /// Push with bottom left ambiguity
    else if (bottomOverlap.isNotEmpty &&
        leftOverlap.isNotEmpty &&
        topOverlap.isEmpty &&
        rightOverlap.isEmpty) {
      if (leftOverlap.length > 1) {
        var pushedTetrimino = _pushFromLeft(result, leftOverlap);
        result = pushedTetrimino;
      } else if (bottomOverlap.length > 1) {
        var pushedTetrimino = _pushFromTop(result, bottomOverlap);
        result = pushedTetrimino;
      } else if (leftOverlap.length == 1 && bottomOverlap.length == 1) {
        var pushedTetrimino = _pushFromLeft(result, leftOverlap);
        var overlappingAfterPush = _findOverlappingCells(pushedTetrimino);
        if (overlappingAfterPush.isEmpty) {
          result = pushedTetrimino;
        } else {
          pushedTetrimino = _pushFromTop(result, bottomOverlap);
          result = pushedTetrimino;
        }
      }
    }

    /// Push with top right ambiguity
    else if (topOverlap.isNotEmpty &&
        rightOverlap.isNotEmpty &&
        bottomOverlap.isEmpty &&
        leftOverlap.isEmpty) {
      if (rightOverlap.length > 1) {
        var pushedTetrimino = _pushFromLeft(result, rightOverlap);
        result = pushedTetrimino;
      } else if (topOverlap.length > 1) {
        var pushedTetrimino = _pushFromTop(result, topOverlap);
        result = pushedTetrimino;
      } else if (rightOverlap.length == 1 && topOverlap.length == 1) {
        var pushedTetrimino = _pushFromLeft(result, rightOverlap);
        var overlappingAfterPush = _findOverlappingCells(pushedTetrimino);
        if (overlappingAfterPush.isEmpty) {
          result = pushedTetrimino;
        } else {
          pushedTetrimino = _pushFromTop(result, topOverlap);
          result = pushedTetrimino;
        }
      }
    }

    ///Push with bottom right ambiguity
    else if (bottomOverlap.isNotEmpty &&
        rightOverlap.isNotEmpty &&
        topOverlap.isEmpty &&
        leftOverlap.isEmpty) {
      if (rightOverlap.length > 1) {
        var pushedTetrimino = _pushFromLeft(result, rightOverlap);
        result = pushedTetrimino;
      } else if (bottomOverlap.length > 1) {
        var pushedTetrimino = _pushFromTop(result, bottomOverlap);
        result = pushedTetrimino;
      } else if (rightOverlap.length == 1 && bottomOverlap.length == 1) {
        var pushedTetrimino = _pushFromLeft(result, rightOverlap);
        var overlappingAfterPush = _findOverlappingCells(pushedTetrimino);
        if (overlappingAfterPush.isEmpty) {
          result = pushedTetrimino;
        } else {
          pushedTetrimino = _pushFromTop(result, bottomOverlap);
          result = pushedTetrimino;
        }
      }
    }
    // TODO test for overlap with new coordinates before returning
    var controlCellsAfterPush = _findOverlappingCells(result);
    if (controlCellsAfterPush.isNotEmpty) {
      result = _tetrimino.value;
    }
    return result;
  }

  List<List<int>> _pushFromRight(
      List<List<int>> coordinates, List<List<int>> controlData) {
    var pushedTetrimino = List.from(coordinates);
    int pushValue =
        _determineHorizontalPushValue(controlData, isLeftSide: false);
    pushedTetrimino.forEach((cell) {
      cell[0] += pushValue;
    });
    return pushedTetrimino;
  }

  List<List<int>> _pushFromLeft(
      List<List<int>> coordinates, List<List<int>> controlData) {
    var pushedTetrimino = List.from(coordinates);
    int pushValue =
        _determineHorizontalPushValue(controlData, isLeftSide: true);
    pushedTetrimino.forEach((cell) {
      cell[0] += pushValue;
    });
    return pushedTetrimino;
  }

  List<List<int>> _pushFromTop(
      List<List<int>> coordinates, List<List<int>> controlData) {
    var pushedTetrimino = List.from(coordinates);
    int pushValue = _determineVerticalPushValue(controlData, isBottom: false);
    pushedTetrimino.forEach((cell) {
      cell[1] += pushValue;
    });
    return pushedTetrimino;
  }

  List<List<int>> _pushFromBottom(
      List<List<int>> coordinates, List<List<int>> controlData) {
    var pushedTetrimino = List.from(coordinates);
    int pushValue = _determineVerticalPushValue(controlData, isBottom: true);
    pushedTetrimino.forEach((cell) {
      cell[1] += pushValue;
    });
    return pushedTetrimino;
  }

  int _determineHorizontalPushValue(List<List<int>> overlappingCells,
      {@required bool isLeftSide}) {
    int pushValue = 0;
    if (overlappingCells.length > 1) {
      // TODO test value extraction
      // push only by the highest difference. values need to be compared because BlockType.I
      // potentially pushes by 2 blocks:
      if (isLeftSide) {
        overlappingCells.sort((coord1, coord2) => coord1[0] - coord2[0]);
        print(overlappingCells.toString());
      } else {
        overlappingCells.sort((coord1, coord2) => coord2[0] - coord1[0]);
        print(overlappingCells.toString());
      }
    }
    pushValue = overlappingCells[0][0];
    return pushValue;
  }

  int _determineVerticalPushValue(List<List<int>> overlappingCells,
      {@required bool isBottom}) {
    int pushValue = 0;
    if (overlappingCells.length > 1) {
      // TODO test value extraction
      // push only by the highest difference. values need to be compared because BlockType.I
      // potentially pushes by 2 blocks:
      if (isBottom) {
        overlappingCells.sort((coord1, coord2) => coord1[1] - coord2[1]);
        print(overlappingCells.toString());
      } else {
        overlappingCells.sort((coord1, coord2) => coord2[1] - coord1[1]);
        print(overlappingCells.toString());
      }
    }
    pushValue = overlappingCells[0][1];
    return pushValue;
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

  // TODO fix this code, it doesn't detect anything
  Map<String, List<int>> detectCellOverlap(List<List<int>> tetrimino) {
    Map<String, List<int>> result = {};
    List<int> leftWallOverlap =
        tetrimino.firstWhere((cell) => cell[0] < 0, orElse: () => []);
    List<int> rightWallOverlap =
        tetrimino.firstWhere((cell) => cell[0] > 9, orElse: () => []);
    List<int> bottomOverlap =
        tetrimino.firstWhere((cell) => cell[1] < 0, orElse: () => []);
    List<int> leftBlockOverlap = tetrimino.firstWhere((cell) {
      if (cell[0] != 0) {
        List<int> nextBlock = [cell[0] - 1, cell[1]];
        BlockType nextBlockType = findCell(nextBlock, _grid.value);
        return ((nextBlockType == BlockType.locked &&
            tetrimino.contains(nextBlock) == true));
      }
      return false;
    }, orElse: () => []);
    List<int> rightBlockOverlap = tetrimino.firstWhere((cell) {
      if (cell[0] != 9) {
        List<int> nextBlock = [cell[0] + 1, cell[1]];
        BlockType nextBlockType = findCell(nextBlock, _grid.value);
        return ((nextBlockType == BlockType.locked &&
            tetrimino.contains(nextBlock) == true));
      }
      return false;
    }, orElse: () => []);

    List<int> bottomBlockOverlap = tetrimino.firstWhere((cell) {
      if (cell[1] != 0) {
        List<int> nextBlock = [cell[0], cell[1] - 1];
        BlockType nextBlockType = findCell(nextBlock, _grid.value);
        return ((nextBlockType == BlockType.locked &&
            tetrimino.contains(nextBlock) == true));
      }
      return false;
    }, orElse: () => []);

    List<int> topBlockOverlap = tetrimino.firstWhere((cell) {
      if (cell[1] != 21) {
        List<int> nextBlock = [cell[0], cell[1] + 1];
        BlockType nextBlockType = findCell(nextBlock, _grid.value);
        return ((nextBlockType == BlockType.locked &&
            tetrimino.contains(nextBlock) == true));
      }
      return false;
    }, orElse: () => []);

    result.putIfAbsent("leftWall", () => leftWallOverlap);
    result.putIfAbsent("leftBlock", () => leftBlockOverlap);
    result.putIfAbsent("rightWall", () => rightWallOverlap);
    result.putIfAbsent("rightBlock", () => rightBlockOverlap);
    result.putIfAbsent("topBlock", () => topBlockOverlap);
    result.putIfAbsent("bottom", () => bottomOverlap);
    result.putIfAbsent("bottomBlock", () => bottomBlockOverlap);

    return result;
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
