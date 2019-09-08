import 'package:collection/collection.dart';
import 'package:tetris/game_bloc.dart';
import 'package:tetris/movement/move.dart';

class Detect {
  static List<List<int>> findOverlappingCells(
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

  static BlockType findCell(
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

  static List<int> reachBottom(List<List<int>> tetrimino) {
    return tetrimino.firstWhere((cell) => cell[1] == 0, orElse: () => []);
  }

  static List<int> reachTop(
      List<List<int>> tetrimino, Map<List<int>, BlockType> grid) {
    return tetrimino.firstWhere((cell) {
      List<int> nextBlock = [cell[0], cell[1] - 1];
      BlockType nextBlockType = findCell(nextBlock, grid);
      return (nextBlock[1] == 20 &&
          nextBlockType == BlockType.locked &&
          tetrimino.contains(nextBlock) == false);
    }, orElse: () => []);
  }

  static List<int> reachOtherBlock(
      List<List<int>> tetrimino, Map<List<int>, BlockType> grid) {
    return tetrimino.firstWhere((cell) {
      List<int> nextBlock = [cell[0], cell[1] - 1];
      BlockType nextBlockType = findCell(nextBlock, grid);
      return (nextBlockType == BlockType.locked &&
          tetrimino.contains(nextBlock) == false);
    }, orElse: () => []);
  }

  static List<int> reachLeftLimit(List<List<int>> tetrimino) {
    return tetrimino.firstWhere((cell) => cell[0] == 0, orElse: () => []);
  }

  static List<int> reachRightLimit(List<List<int>> tetrimino) {
    return tetrimino.firstWhere((cell) => cell[0] == 9, orElse: () => []);
  }

  static List<int> reachBlockOnLeft(
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

  static List<int> reachBlockOnRight(
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

  // TODO change name to account for return type
  // TODO use map to refactor
  static List<List<int>> rotateContactDetection(
      List<List<int>> tetrimino,
      List<List<int>> initialTetriminoPosition,
      Map<List<int>, BlockType> grid,
      List<int> center) {
    List<List<int>> overlappingCells = [];
    List<List<int>> leftOverlap = [];
    List<List<int>> rightOverlap = [];
    List<List<int>> topOverlap = [];
    List<List<int>> bottomOverlap = [];
    int pushValue = 0;
    bool isPushHorizontal = true;

    // check if new coordinates are out of bounds or overlap with a block
    overlappingCells = findOverlappingCells(tetrimino, grid);
    if (overlappingCells.isEmpty) {
      return tetrimino;
    }

    // TODO put in separate func
    //sort overlapping bocks by overlap type (up,down,left,right)
    overlappingCells.forEach((cell) {
      List<int> centeredCell = [cell[0] - center[0], cell[1] - center[1]];
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

    //if 2 overlaps on same axis: no rotation
    if ((topOverlap.isNotEmpty && bottomOverlap.isNotEmpty) ||
        (leftOverlap.isNotEmpty && rightOverlap.isNotEmpty)) {
      return initialTetriminoPosition;
    }

    /// Push from the left, no y axis ambiguity
    if (leftOverlap.isNotEmpty &&
        rightOverlap.isEmpty &&
        topOverlap.isEmpty &&
        bottomOverlap.isEmpty) {
      pushValue = _determineHorizontalPushValue(leftOverlap, isLeftSide: true);
      tetrimino = _pushFromLeft(tetrimino, pushValue);
      isPushHorizontal = true;
    }

    /// Push from the right, no y axis ambiguity
    else if (rightOverlap.isNotEmpty &&
        leftOverlap.isEmpty &&
        topOverlap.isEmpty &&
        bottomOverlap.isEmpty) {
      pushValue =
          _determineHorizontalPushValue(rightOverlap, isLeftSide: false);
      tetrimino = _pushFromRight(tetrimino, pushValue);
      isPushHorizontal = true;
    }

    /// Push from the bottom, no x axis ambiguity
    else if (bottomOverlap.isNotEmpty &&
        topOverlap.isEmpty &&
        leftOverlap.isEmpty &&
        rightOverlap.isEmpty) {
      pushValue = _determineVerticalPushValue(bottomOverlap, isBottom: true);
      tetrimino = _pushFromBottom(tetrimino, pushValue);
      isPushHorizontal = false;
    }

    /// Push from the top, no x axis ambiguity
    else if (topOverlap.isNotEmpty &&
        bottomOverlap.isEmpty &&
        leftOverlap.isEmpty &&
        rightOverlap.isEmpty) {
      pushValue = _determineVerticalPushValue(topOverlap, isBottom: false);
      tetrimino = _pushFromTop(tetrimino, pushValue);
      isPushHorizontal = false;
    }

    /// Push with top_left ambiguity
    else if (topOverlap.isNotEmpty &&
        leftOverlap.isNotEmpty &&
        bottomOverlap.isEmpty &&
        rightOverlap.isEmpty) {
      if (leftOverlap.length > 1) {
        pushValue =
            _determineHorizontalPushValue(leftOverlap, isLeftSide: true);
        tetrimino = _pushFromLeft(tetrimino, pushValue);
        isPushHorizontal = true;
      } else if (topOverlap.length > 1) {
        pushValue = _determineVerticalPushValue(topOverlap, isBottom: false);
        tetrimino = _pushFromTop(tetrimino, pushValue);
        isPushHorizontal = false;
      } else if (leftOverlap.length == 1 && topOverlap.length == 1) {
        pushValue =
            _determineHorizontalPushValue(leftOverlap, isLeftSide: true);
        tetrimino = _pushFromLeft(tetrimino, pushValue);
        var overlappingAfterPush =
            _findOverlappingCells(tetrimino, _grid.value);

        // if overlap after pushing on the side, do vertical push
        if (overlappingAfterPush.isEmpty) {
          isPushHorizontal = true;
          // overlap after this push will be done before return
        } else {
          pushValue = _determineVerticalPushValue(topOverlap, isBottom: false);
          tetrimino = _pushFromTop(tetrimino, pushValue);
          isPushHorizontal = false;
        }
      }
    }

    /// Push with bottom left ambiguity
    else if (bottomOverlap.isNotEmpty &&
        leftOverlap.isNotEmpty &&
        topOverlap.isEmpty &&
        rightOverlap.isEmpty) {
      if (leftOverlap.length > 1) {
        pushValue =
            _determineHorizontalPushValue(leftOverlap, isLeftSide: true);
        tetrimino = _pushFromLeft(tetrimino, pushValue);
        isPushHorizontal = true;
      } else if (bottomOverlap.length > 1) {
        pushValue = _determineVerticalPushValue(topOverlap, isBottom: true);
        tetrimino = _pushFromBottom(tetrimino, pushValue);
        isPushHorizontal = false;
      } else if (leftOverlap.length == 1 && bottomOverlap.length == 1) {
        pushValue =
            _determineHorizontalPushValue(leftOverlap, isLeftSide: true);
        tetrimino = _pushFromLeft(tetrimino, pushValue);
        var overlappingAfterPush =
            _findOverlappingCells(tetrimino, _grid.value);
        if (overlappingAfterPush.isEmpty) {
          isPushHorizontal = true;
        } else {
          pushValue = _determineVerticalPushValue(topOverlap, isBottom: true);
          tetrimino = _pushFromBottom(tetrimino, pushValue);
          isPushHorizontal = false;
        }
      }
    }

    /// Push with top right ambiguity
    else if (topOverlap.isNotEmpty &&
        rightOverlap.isNotEmpty &&
        bottomOverlap.isEmpty &&
        leftOverlap.isEmpty) {
      if (rightOverlap.length > 1) {
        pushValue =
            _determineHorizontalPushValue(rightOverlap, isLeftSide: false);
        tetrimino = _pushFromRight(tetrimino, pushValue);
      } else if (topOverlap.length > 1) {
        pushValue = _determineVerticalPushValue(topOverlap, isBottom: false);
        tetrimino = _pushFromTop(tetrimino, pushValue);
      } else if (rightOverlap.length == 1 && topOverlap.length == 1) {
        pushValue =
            _determineHorizontalPushValue(rightOverlap, isLeftSide: false);
        tetrimino = _pushFromRight(tetrimino, pushValue);
        var overlappingAfterPush =
            _findOverlappingCells(tetrimino, _grid.value);
        if (overlappingAfterPush.isEmpty) {
          isPushHorizontal = true;
        } else {
          pushValue = _determineVerticalPushValue(topOverlap, isBottom: false);
          tetrimino = _pushFromTop(tetrimino, pushValue);
          isPushHorizontal = false;
        }
      }
    }

    ///Push with bottom right ambiguity
    else if (bottomOverlap.isNotEmpty &&
        rightOverlap.isNotEmpty &&
        topOverlap.isEmpty &&
        leftOverlap.isEmpty) {
      if (rightOverlap.length > 1) {
        pushValue =
            _determineHorizontalPushValue(rightOverlap, isLeftSide: false);
        tetrimino = _pushFromRight(tetrimino, pushValue);
      } else if (bottomOverlap.length > 1) {
        pushValue = _determineVerticalPushValue(bottomOverlap, isBottom: true);
        tetrimino = _pushFromBottom(tetrimino, pushValue);
      } else if (rightOverlap.length == 1 && bottomOverlap.length == 1) {
        pushValue =
            _determineHorizontalPushValue(rightOverlap, isLeftSide: false);
        tetrimino = _pushFromRight(tetrimino, pushValue);
        var overlappingAfterPush =
            _findOverlappingCells(tetrimino, _grid.value);
        if (overlappingAfterPush.isEmpty) {
          isPushHorizontal = true;
        } else {
          pushValue =
              _determineVerticalPushValue(bottomOverlap, isBottom: true);
          tetrimino = _pushFromBottom(tetrimino, pushValue);
          isPushHorizontal = false;
        }
      }
    }
    // testing coordinates after push, if still overlap, don't rotate
    var controlCellsAfterPush = findOverlappingCells(tetrimino, grid);
    if (controlCellsAfterPush.isNotEmpty) {
      tetrimino = initialTetriminoPosition;
    } else {
      Move.updateCenter(center, pushValue, isPushHorizontal);
    }
    return tetrimino;
  }
}
