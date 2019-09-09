import 'package:tetris/game_bloc.dart';

class Grid {
  static List<List<int>> generateGridCoordinates(
      List<int> gridX, List<int> gridY) {
    List<List<int>> coordinates = [];
    for (var j = 0; j < gridY.length; j++) {
      for (var i = 0; i < gridX.length; i++) {
        coordinates.add([gridX[i], gridY[j]]);
      }
    }
    return coordinates;
  }

  static Map<List<int>, BlockType> generateGrid(
      List<List<int>> gridCoordinates) {
    Map<List<int>, BlockType> grid = {};
    for (var i = 0; i < gridCoordinates.length; i++) {
      List<int> coordinates = gridCoordinates[i];
      grid.putIfAbsent(coordinates, () => BlockType.empty);
    }
    return grid;
  }
}
