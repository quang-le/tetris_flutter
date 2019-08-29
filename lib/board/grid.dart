// TO DO : refactor. class may not be necessary
import 'package:flutter/material.dart';

class Grid {
  static List<int> gridX = List<int>.generate(20, (i) => i, growable: false);

  static List<int> gridY = List<int>.generate(40, (i) => i, growable: false);

  /*static List<GridCoordinate> _generateGrid(List<int> xAxis, List<int> yAxis) {
    xAxis.forEach((x) => yAxis.forEach((y) => GridCoordinate(x: x, y: y)));
  }*/

  static List<List<int>> _generateGrid() {
    List<List<int>> list = [];
    for (var j = 0; j < gridY.length; j++) {
      for (var i = 0; i < gridX.length; i++) {
        list.add([gridX[i], gridY[j]]);
      }
    }
    return list;
  }

  // TO DO: refactor to return Map<int,Cell>
  List<List<int>> grid = _generateGrid();
}

// TO DO : create Cell class

class Cell {
  final int index;
  final List<int> coordinates;
  bool status = false;

  Cell({@required this.index, @required this.coordinates, this.status})
      : assert(index != null),
        assert(coordinates != null);
}
