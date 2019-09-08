import 'package:flutter/material.dart';
import 'package:tetris/game_bloc.dart';
import 'package:tetris/movement/detect.dart';

class Move {
  static List<int> updateCenter(
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

  static List<int> determineMovementValues(
      Direction direction, List<int> cell) {
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

  static List<List<int>> pushFromLeft(
      List<List<int>> coordinates, int pushValue) {
    coordinates.forEach((cell) {
      cell[0] -= pushValue;
    });
    return coordinates;
  }

  static List<List<int>> pushFromRight(
      List<List<int>> coordinates, int pushValue) {
    coordinates.forEach((cell) {
      cell[0] -= pushValue;
    });
    return coordinates;
  }

  static List<List<int>> pushFromBottom(
      List<List<int>> coordinates, int pushValue) {
    coordinates.forEach((cell) {
      cell[1] -= pushValue;
    });
    return coordinates;
  }

  static List<List<int>> pushFromTop(
      List<List<int>> coordinates, int pushValue) {
    coordinates.forEach((cell) {
      cell[1] -= pushValue;
    });
    return coordinates;
  }

  static int determineHorizontalPushValue(List<List<int>> overlappingCells,
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

  static int determineVerticalPushValue(List<List<int>> overlappingCells,
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
}
