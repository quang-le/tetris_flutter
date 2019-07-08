class Grid {
  static List<int> gridX = List<int>.generate(20, (i) => i, growable: false);

  static List<int> gridY = List<int>.generate(40, (i) => i, growable: false);

  /*static List<GridCoordinate> _generateGrid(List<int> xAxis, List<int> yAxis) {
    xAxis.forEach((x) => yAxis.forEach((y) => GridCoordinate(x: x, y: y)));
  }*/

  static List<GridCoordinate> _generateGrid() {
    List<GridCoordinate> list = [];
    for (var i = 0; i < gridX.length; i++) {
      for (var j = 0; j < gridY.length; j++) {
        list.add(GridCoordinate(x: gridX[i], y: gridY[j]));
      }
    }
    return list;
  }

  List<GridCoordinate> grid = _generateGrid();
}

class GridCoordinate {
  int x;
  int y;

  GridCoordinate({this.x, this.y});

  GridCoordinate.fromJson(Map<String, dynamic> json) {
    x = json['x'];
    y = json['y'];
  }
  @override
  String toString() {
    return '(x:$x,y:$y)';
  }
}
