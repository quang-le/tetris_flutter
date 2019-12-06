import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tetris/game_bloc.dart';
import 'package:tetris/tetriminos/tetriminos.dart';
import 'package:vector_math/vector_math.dart';

class Move {
  // Find the status of a cell on the grid
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

  List<int> determineMovementValues(Direction direction, List<int> cell) {
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

  /// Determine in tetrimino is in contact with other blocks
  List<int> reachBottom(List<List<int>> tetrimino) {
    return tetrimino.firstWhere((cell) => cell[1] == 0, orElse: () => []);
  }

  List<int> reachTop(
      List<List<int>> tetrimino, Map<List<int>, BlockType> grid) {
    return tetrimino.firstWhere((cell) {
      List<int> nextBlock = [cell[0], cell[1] - 1];
      BlockType nextBlockType = findCell(nextBlock, grid);
      return (nextBlock[1] == 20 &&
          nextBlockType == BlockType.locked &&
          tetrimino.contains(nextBlock) == false);
    }, orElse: () => []);
  }

  List<int> reachOtherBlock(
      List<List<int>> tetrimino, Map<List<int>, BlockType> grid) {
    return tetrimino.firstWhere((cell) {
      List<int> nextBlock = [cell[0], cell[1] - 1];
      BlockType nextBlockType = findCell(nextBlock, grid);
      return (nextBlockType == BlockType.locked &&
          tetrimino.contains(nextBlock) == false);
    }, orElse: () => []);
  }

  List<int> reachLeftLimit(List<List<int>> tetrimino) {
    return tetrimino.firstWhere((cell) => cell[0] == 0, orElse: () => []);
  }

  List<int> reachRightLimit(List<List<int>> tetrimino) {
    return tetrimino.firstWhere((cell) => cell[0] == 9, orElse: () => []);
  }

  List<int> reachBlockOnLeft(
      List<List<int>> tetrimino, Map<List<int>, BlockType> grid) {
    return tetrimino.firstWhere((cell) {
      if (cell[0] != 0) {
        List<int> nextBlock = [cell[0] - 1, cell[1]];
        BlockType nextBlockType = findCell(nextBlock, grid);
        return ((nextBlockType == BlockType.locked &&
            tetrimino.contains(nextBlock) == false));
      }
      return false;
    }, orElse: () => []);
  }

  List<int> reachBlockOnRight(
      List<List<int>> tetrimino, Map<List<int>, BlockType> grid) {
    return tetrimino.firstWhere((cell) {
      if (cell[0] != 9) {
        List<int> nextBlock = [cell[0] + 1, cell[1]];
        BlockType nextBlockType = findCell(nextBlock, grid);
        return ((nextBlockType == BlockType.locked &&
            tetrimino.contains(nextBlock) == false));
      }
      return false;
    }, orElse: () => []);
  }

  ///END

  // TODO change name to account for return type
  // TODO REFACTOR to avoid changing tetrimino directly
  List<List<int>> detectCollisionAndUpdateCoordinates(
      List<List<int>> tetrimino,
      List<List<int>> initialTetriminoPosition,
      Map<List<int>, BlockType> grid,
      List<int> center) {
    int pushValue = 0;
    bool isPushHorizontal = true;
    Map<String, dynamic> push = {};

    // check if new coordinates are out of bounds or overlap with a block
    // I check it here to avoid unnecessary operations below
    List<List<int>> overlappingCells = _findOverlappingCells(tetrimino, grid);
    if (overlappingCells.isEmpty) {
      return tetrimino;
    }

    Map<String, List<List<int>>> overlappingByPosition =
        _overlappingCellsByPosition(overlappingCells, center);
    // TODO see if these declaration can be eliminated while keeping code legible
    List<List<int>> leftOverlap = overlappingByPosition['leftOverlap'];
    List<List<int>> rightOverlap = overlappingByPosition['rightOverlap'];
    List<List<int>> topOverlap = overlappingByPosition['topOverlap'];
    List<List<int>> bottomOverlap = overlappingByPosition['bottomOverlap'];
    bool left = (leftOverlap.isNotEmpty &&
        rightOverlap.isEmpty &&
        topOverlap.isEmpty &&
        bottomOverlap.isEmpty);
    bool right = (rightOverlap.isNotEmpty &&
        leftOverlap.isEmpty &&
        topOverlap.isEmpty &&
        bottomOverlap.isEmpty);
    bool bottom = (bottomOverlap.isNotEmpty &&
        topOverlap.isEmpty &&
        leftOverlap.isEmpty &&
        rightOverlap.isEmpty);
    bool top = (topOverlap.isNotEmpty &&
        bottomOverlap.isEmpty &&
        leftOverlap.isEmpty &&
        rightOverlap.isEmpty);
    bool topLeft = (topOverlap.isNotEmpty &&
        leftOverlap.isNotEmpty &&
        bottomOverlap.isEmpty &&
        rightOverlap.isEmpty);
    bool bottomLeft = (bottomOverlap.isNotEmpty &&
        leftOverlap.isNotEmpty &&
        topOverlap.isEmpty &&
        rightOverlap.isEmpty);
    bool topRight = (topOverlap.isNotEmpty &&
        rightOverlap.isNotEmpty &&
        bottomOverlap.isEmpty &&
        leftOverlap.isEmpty);
    bool bottomRight = (bottomOverlap.isNotEmpty &&
        rightOverlap.isNotEmpty &&
        topOverlap.isEmpty &&
        leftOverlap.isEmpty);
    bool noSpace = ((topOverlap.isNotEmpty && bottomOverlap.isNotEmpty) ||
        (leftOverlap.isNotEmpty && rightOverlap.isNotEmpty));

    //if 2 overlaps on same axis: no rotation
    if (noSpace) {
      return initialTetriminoPosition;
    }

    /// Push from the left, no y axis ambiguity
    if (left) {
      push = _pushFromLeft(leftOverlap, tetrimino);
    }

    /// Push from the right, no y axis ambiguity
    else if (right) {
      push = _pushFromRight(rightOverlap, tetrimino);
    }

    /// Push from the bottom, no x axis ambiguity
    else if (bottom) {
      push = _pushFromBottom(bottomOverlap, tetrimino);
    }

    /// Push from the top, no x axis ambiguity
    else if (top) {
      push = _pushFromTop(topOverlap, tetrimino);
    }

    /// Push with top_left ambiguity
    else if (topLeft) {
      push = _pushFromTopLeft(leftOverlap, topOverlap, tetrimino, grid);
    }

    /// Push with bottom left ambiguity
    else if (bottomLeft) {
      push = _pushFromBottomLeft(leftOverlap, bottomOverlap, tetrimino, grid);
    }

    /// Push with top right ambiguity
    else if (topRight) {
      push = _pushFromTopRight(rightOverlap, topOverlap, tetrimino, grid);
    }

    ///Push with bottom right ambiguity
    else if (bottomRight) {
      push = _pushFromBottomRight(rightOverlap, bottomOverlap, tetrimino, grid);
    }
    pushValue = push['pushValue'] as int;
    tetrimino = push['coordinates'] as List<List<int>>;
    isPushHorizontal = push['isPushHorizontal'] as bool;
    // testing coordinates after push, if still overlap, don't rotate
    var controlCellsAfterPush = _findOverlappingCells(tetrimino, grid);
    if (controlCellsAfterPush.isNotEmpty) {
      tetrimino = initialTetriminoPosition;
    } else {
      center = _updateCenter(center, pushValue, isPushHorizontal);
    }
    return tetrimino;
  }

  /// Position correction when rotating a tetrimino

  // TODO add left or right param
  List<List<int>> obtainRotatedCoordinates(
      List<int> center, Matrix2 matrix, List<List<int>> tetrimino) {
    //var center = _center.value;
    //var matrix = Tetriminos.leftMatrix;
    //var tetrimino = _tetrimino.value;
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

  List<int> _updateCenter(
      List<int> center, int pushValue, bool isPushHorizontal) {
    print('center old value : ${center.toString()}');
    if (isPushHorizontal) {
      center[0] -= pushValue;
    } else {
      center[1] -= pushValue;
    }
    print('center new value : ${center.toString()}');
    return center;
  }

  List<List<int>> _findOverlappingCells(
      List<List<int>> tetrimino, Map<List<int>, BlockType> grid) {
    List<List<int>> overlappingCells = [];
    tetrimino.forEach((cell) {
      BlockType cellType = findCell(cell, grid);
      if (cellType == BlockType.locked) {
        overlappingCells.add(cell);
      } else if ((cell[0] < 0) || (cell[0] > 9) || cell[1] < 0) {
        overlappingCells.add(cell);
      }
    });
    return overlappingCells;
  }

  Map<String, List<List<int>>> _overlappingCellsByPosition(
      List<List<int>> overlappingCells, List<int> center) {
    Map<String, List<List<int>>> _overlappingCellsByPosition = {
      'leftOverlap': [],
      'rightOverlap': [],
      'topOverlap': [],
      'bottomOverlap': []
    };
    overlappingCells.forEach((cell) {
      List<int> centeredCell = [cell[0] - center[0], cell[1] - center[1]];
      if (centeredCell[0] < 0) {
        _overlappingCellsByPosition['leftOverlap'].add(centeredCell);
      }
      if (centeredCell[0] > 0) {
        _overlappingCellsByPosition['rightOverlap'].add(centeredCell);
      }
      if (centeredCell[1] < 0) {
        _overlappingCellsByPosition['bottomOverlap'].add(centeredCell);
      }
      if (centeredCell[1] > 0) {
        _overlappingCellsByPosition['topOverlap'].add(centeredCell);
      }
    });
    return _overlappingCellsByPosition;
  }

  Map<String, dynamic> _horizontalPush(
      List<List<int>> overlap, List<List<int>> tetrimino, bool isLeftSide) {
    Map<String, dynamic> result = {
      'pushValue': null,
      'isPushHorizontal': null,
      'coordinates': null,
    };
    result['pushValue'] =
        _determineHorizontalPushValue(overlap, isLeftSide: isLeftSide);
    result['coordinates'] = isLeftSide
        ? _pushCoordinatesFromLeft(tetrimino, result['pushValue'])
        : _pushCoordinatesFromRight(tetrimino, result['pushValue']);
    result['isPushHorizontal'] = true;
    return result;
  }

  Map<String, dynamic> _verticalPush(
      List<List<int>> overlap, List<List<int>> tetrimino, bool isBottom) {
    Map<String, dynamic> result = {
      'pushValue': null,
      'isPushHorizontal': null,
      'coordinates': null,
    };
    result['pushValue'] =
        _determineVerticalPushValue(overlap, isBottom: isBottom);
    result['coordinates'] = isBottom
        ? _pushCoordinatesFromBottom(tetrimino, result['pushValue'])
        : _pushCoordinatesFromTop(tetrimino, result['pushValue']);
    result['isPushHorizontal'] = false;
    return result;
  }

  Map<String, dynamic> _pushFromLeft(
      List<List<int>> leftOverlap, List<List<int>> tetrimino) {
    return _horizontalPush(leftOverlap, tetrimino, true);
  }

  Map<String, dynamic> _pushFromRight(
      List<List<int>> rightOverlap, List<List<int>> tetrimino) {
    return _horizontalPush(rightOverlap, tetrimino, false);
  }

  Map<String, dynamic> _pushFromTop(
      List<List<int>> topOverlap, List<List<int>> tetrimino) {
    return _verticalPush(topOverlap, tetrimino, false);
  }

  Map<String, dynamic> _pushFromBottom(
      List<List<int>> bottomOverlap, List<List<int>> tetrimino) {
    return _verticalPush(bottomOverlap, tetrimino, true);
  }

  Map<String, dynamic> _biDirectionalPush(
      List<List<int>> horizontalOverlap,
      List<List<int>> verticalOverlap,
      List<List<int>> tetrimino,
      Map<List<int>, BlockType> grid,
      {@required bool isLeft,
      @required bool isBottom}) {
    Map<String, dynamic> push = {};
    if (horizontalOverlap.length > 1) {
      if (isLeft) {
        push = _pushFromLeft(horizontalOverlap, tetrimino);
      } else {
        push = _pushFromRight(horizontalOverlap, tetrimino);
      }
    } else if (verticalOverlap.length > 1) {
      if (isBottom) {
        _pushFromBottom(verticalOverlap, tetrimino);
      } else {
        push = _pushFromTop(verticalOverlap, tetrimino);
      }
    } else if (horizontalOverlap.length == 1 && verticalOverlap.length == 1) {
      if (isLeft) {
        push = _pushFromLeft(horizontalOverlap, tetrimino);
      } else {
        push = _pushFromRight(horizontalOverlap, tetrimino);
      }
      var overlappingAfterPush =
          _findOverlappingCells(push['coordinates'], grid);

      // if overlap after pushing on the side, do vertical push
      if (overlappingAfterPush.isNotEmpty) {
        if (isBottom) {
          push = _pushFromBottom(verticalOverlap, tetrimino);
        } else {
          push = _pushFromTop(verticalOverlap, tetrimino);
        }
      }
    }
    return push;
  }

  Map<String, dynamic> _pushFromTopLeft(
      List<List<int>> leftOverlap,
      List<List<int>> topOverlap,
      List<List<int>> tetrimino,
      Map<List<int>, BlockType> grid) {
    return _biDirectionalPush(leftOverlap, topOverlap, tetrimino, grid,
        isLeft: true, isBottom: false);
  }

  Map<String, dynamic> _pushFromBottomLeft(
      List<List<int>> leftOverlap,
      List<List<int>> bottomOverlap,
      List<List<int>> tetrimino,
      Map<List<int>, BlockType> grid) {
    return _biDirectionalPush(leftOverlap, bottomOverlap, tetrimino, grid,
        isLeft: true, isBottom: true);
  }

  Map<String, dynamic> _pushFromTopRight(
      List<List<int>> rightOverlap,
      List<List<int>> topOverlap,
      List<List<int>> tetrimino,
      Map<List<int>, BlockType> grid) {
    return _biDirectionalPush(rightOverlap, topOverlap, tetrimino, grid,
        isLeft: false, isBottom: false);
  }

  Map<String, dynamic> _pushFromBottomRight(
      List<List<int>> rightOverlap,
      List<List<int>> bottomOverlap,
      List<List<int>> tetrimino,
      Map<List<int>, BlockType> grid) {
    return _biDirectionalPush(rightOverlap, bottomOverlap, tetrimino, grid,
        isLeft: false, isBottom: true);
  }

  List<List<int>> _pushCoordinatesFromLeft(
      List<List<int>> coordinates, int pushValue) {
    coordinates.forEach((cell) {
      cell[0] -= pushValue;
    });
    return coordinates;
  }

  List<List<int>> _pushCoordinatesFromRight(
      List<List<int>> coordinates, int pushValue) {
    coordinates.forEach((cell) {
      cell[0] -= pushValue;
    });
    return coordinates;
  }

  List<List<int>> _pushCoordinatesFromBottom(
      List<List<int>> coordinates, int pushValue) {
    coordinates.forEach((cell) {
      cell[1] -= pushValue;
    });
    return coordinates;
  }

  List<List<int>> _pushCoordinatesFromTop(
      List<List<int>> coordinates, int pushValue) {
    coordinates.forEach((cell) {
      cell[1] -= pushValue;
    });
    return coordinates;
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

  /// END
}
