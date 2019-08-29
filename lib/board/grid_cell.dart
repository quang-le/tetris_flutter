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
        noDataChild: Container(color: Colors.pink),
        stream: widget.bloc.tetrimino,
        builder: (context, tetriminoSnapshot) {
          return StreamedWidget(
              stream: widget.bloc.grid,
              builder: (context, gridSnapshot) {
                var grid = gridSnapshot.data;
                var coordinates = widget.coordinates;
                var onGrid = widget.bloc.findCell(coordinates, grid);
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 0.25),
                    color:
                        onGrid == BlockType.locked ? Colors.green : Colors.red,
                    //color: _determineCellColor(
                    //    type, tetriminoPosition, grid, coordinates),
                  ),
                  height: widget.size,
                  width: widget.size,
                  child: Text(widget.coordinates.toString()),
                );
              });
        });
  }

  // TODO uncomment when bloc is fixed
  /*Color _determineCellColor(BlockType type, List<List<int>> tetriminoPosition,
      Map<int, Cell> grid, List<int> coordinates) {
    const _comparePosition = IterableEquality();
    bool _isTetrimino = false;
    Cell onGrid = widget.bloc.findCell(coordinates, grid);
    tetriminoPosition.forEach((tetriminoCell) {
      if (_comparePosition.equals(coordinates, tetriminoCell)) {
        _isTetrimino = true;
      }
    });
    if (_isTetrimino) {
      switch (type) {
        case BlockType.O:
          return Colors.yellow;
          break;
        case BlockType.I:
          return Colors.lightBlueAccent;
          break;
        case BlockType.J:
          return Colors.blue;
          break;
        case BlockType.L:
          return Colors.orangeAccent;
          break;
        case BlockType.S:
          return Colors.green;
          break;
        case BlockType.Z:
          return Colors.redAccent;
          break;
        case BlockType.T:
          return Colors.deepPurpleAccent;
          break;
      }
    } else if (!_isTetrimino && onGrid.status) {
      return Colors.brown;
    }
    return Colors.white;
  }*/
}
