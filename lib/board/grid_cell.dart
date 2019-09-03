import 'package:flutter/material.dart';
import 'package:tetris/game_bloc.dart';
import 'package:frideos/frideos.dart';

class GridCell extends StatefulWidget {
  final double size;
  final GameBloc bloc;
  final List<int> coordinates;

  const GridCell(
      {Key key, @required this.size, @required this.bloc, this.coordinates})
      : assert(bloc != null),
        assert(size != null),
        assert(coordinates != null),
        super(key: key);
  @override
  _GridCellState createState() => _GridCellState();
}

class _GridCellState extends State<GridCell> {
  @override
  Widget build(BuildContext context) {
    return StreamedWidget(
        stream: widget.bloc.grid,
        builder: (context, gridSnapshot) {
          var grid = gridSnapshot.data;
          var coordinates = widget.coordinates;
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 0.25),
              //color:
              //    onGrid == BlockType.locked ? Colors.green : Colors.red,
              color: _determineCellColor(grid, coordinates),
            ),
            height: widget.size,
            width: widget.size,
          );
        });
  }

  Color _determineCellColor(
      Map<List<int>, BlockType> grid, List<int> coordinates) {
    Color color;
    BlockType cell = widget.bloc.findCell(coordinates, grid);
    switch (cell) {
      case BlockType.O:
        color = Colors.yellow;
        break;
      case BlockType.I:
        color = Colors.lightBlueAccent;
        break;
      case BlockType.J:
        color = Colors.blue;
        break;
      case BlockType.L:
        color = Colors.orangeAccent;
        break;
      case BlockType.S:
        color = Colors.green;
        break;
      case BlockType.Z:
        color = Colors.redAccent;
        break;
      case BlockType.T:
        color = Colors.deepPurpleAccent;
        break;
      case BlockType.empty:
        color = Colors.black54;
        break;
      case BlockType.locked:
        color = Colors.grey;
        break;
    }
    return color;
  }
}
