import 'package:tetris/game_bloc.dart';
import 'package:vector_math/vector_math.dart';

class Tetriminos {
  static List<List<int>> coordinates(BlockType type) {
    List<List<int>> coordinates;

    switch (type) {
      case BlockType.I:
        coordinates = [
          [3, 24],
          [4, 24],
          [5, 24],
          [6, 24],
        ];
        break;
      case BlockType.J:
        coordinates = [
          [3, 24],
          [4, 24],
          [5, 24],
          [5, 25],
        ];
        break;
      case BlockType.L:
        coordinates = [
          [3, 24],
          [4, 24],
          [5, 24],
          [3, 25],
        ];
        break;
      case BlockType.S:
        coordinates = [
          [3, 24],
          [4, 24],
          [4, 25],
          [5, 25],
        ];
        break;
      case BlockType.Z:
        coordinates = [
          [3, 25],
          [4, 25],
          [4, 24],
          [5, 24],
        ];
        break;
      case BlockType.O:
        coordinates = [
          [4, 25],
          [5, 25],
          [4, 24],
          [5, 24],
        ];
        break;
      case BlockType.T:
        coordinates = [
          [3, 24],
          [4, 24],
          [5, 24],
          [4, 25],
        ];
        break;
      default:
        coordinates = [];
        break;
    }
    return coordinates;
  }

  static setCenter(BlockType type) {
    List<int> center;
    switch (type) {
      case BlockType.I:
        center = [4, 24];
        break;
      case BlockType.J:
        center = [4, 24];
        break;
      case BlockType.L:
        center = [4, 24];
        break;
      case BlockType.S:
        center = [4, 24];
        break;
      case BlockType.Z:
        center = [4, 24];
        break;
      case BlockType.O:
        center = [];
        break;
      case BlockType.T:
        center = [4, 24];
        break;
      default:
        center = [];
        break;
    }
    return center;
  }

  static Matrix2 leftMatrix = Matrix2.fromList([0, -1, 1, 0]);
  static Matrix2 rightMatrix = Matrix2.fromList([0, 1, -1, 0]);

  static List<List<int>> centerCoordinatesOnCell(
      List<int> center, List<List<int>> tetrimino) {
    List<List<int>> centeredCoordinates = [];
    tetrimino.forEach((cell) {
      List<int> offSetCoordinates = [
        (cell[0] - center[0]),
        (cell[1] - center[1])
      ];
      centeredCoordinates.add(offSetCoordinates);
    });
    return centeredCoordinates;
  }

  static List<List<int>> convertCoordinatesToGrid(
      List<int> center, List<List<int>> rotatedTetrimino) {
    List<List<int>> tetriminoOnGrid = [];
    rotatedTetrimino.forEach((cell) {
      List<int> gridCell = [];
      int gridCellX = cell[0] + center[0];
      gridCell.add(gridCellX);
      int gridCellY = cell[1] + center[1];
      gridCell.add(gridCellY);
      tetriminoOnGrid.add(gridCell);
    });
    return tetriminoOnGrid;
  }

  static List<Vector2> convertListToVector(List<List<int>> tetrimino) {
    List<Vector2> vectorCoordinates = [];
    tetrimino.forEach((cell) {
      List<double> toDouble = [cell[0].toDouble(), cell[1].toDouble()];
      Vector2 vector = Vector2.array(toDouble);
      vectorCoordinates.add(vector);
    });
    return vectorCoordinates;
  }

  static List<List<int>> convertVectorToList(List<Vector2> vectors) {
    List<List<int>> list = [];
    vectors.forEach((vector) {
      List<double> vectorToArray = [0, 0];
      vector.copyIntoArray(vectorToArray);
      List<int> doubleToInt = [
        vectorToArray[0].toInt(),
        vectorToArray[1].toInt()
      ];
      list.add(doubleToInt);
    });
    return list;
  }
}

//enum Spin  {up,down,left,right}
