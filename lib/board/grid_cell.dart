import 'package:flutter/material.dart';
import 'package:tetris/board/grid.dart';
import 'package:tetris/game_bloc.dart';
import 'package:frideos/frideos.dart';

class GridCell extends StatefulWidget {
  final double size;
  final GameBloc bloc;
  final GridCoordinate coordinates;

  const GridCell(
      {Key key, @required this.size, @required this.bloc, this.coordinates})
      : assert(bloc != null),
        assert(size != null),
        assert(coordinates != null),
        super(key: key);
  @override
  _GridCellState createState() => _GridCellState();
}

//TO DO : add coordinate
class _GridCellState extends State<GridCell> {
  @override
  Widget build(BuildContext context) {
    return StreamedWidget(
        stream: widget.bloc.gridState,
        builder: (context, snapshot) {
          return Container(
            height: widget.size,
            width: widget.size,
            // color:
            //   snapshot.data[widget.coordinates] ? Colors.green : Colors.red,
            child: Text('Bite'),
          );
        });
  }
}
