import 'package:tetris/game_bloc.dart';
import 'package:vector_math/vector_math.dart';

class Tetriminos {
  List<List<int>> coordinates(BlockType type) {
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

  setCenter(BlockType type) {
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

  Matrix2 leftMatrix = Matrix2.fromList([0, -1, 1, 0]);
  Matrix2 rightMatrix = Matrix2.fromList([0, 1, -1, 0]);
}

//enum Spin  {up,down,left,right}
