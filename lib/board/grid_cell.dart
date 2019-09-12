import 'package:flutter/material.dart';
import 'package:tetris/game_bloc.dart';
import 'package:frideos/frideos.dart';
import 'package:tetris/helpers/compare.dart';

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
          return StreamedWidget(
              stream: widget.bloc.ghostPiece,
              builder: (context, ghostSnapshot) {
                return StreamedWidget(
                    stream: widget.bloc.blockType,
                    builder: (context, blockTypeSnapshot) {
                      return Container(
                        decoration: BoxDecoration(
                          border: _determineBorder(coordinates,
                              ghostSnapshot.data, blockTypeSnapshot.data),
                          color: _determineCellColor(grid, coordinates),
                        ),
                        height: widget.size,
                        width: widget.size,
                      );
                    });
              });
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

  Border _determineBorder(
      List<int> coordinates, List<List<int>> ghostPiece, BlockType type) {
    Color color = Colors.grey;
    double width = 0.25;
    List<int> isGhostPiece = Compare.matchLists(coordinates, ghostPiece);
    if (isGhostPiece.isNotEmpty) {
      switch (type) {
        case BlockType.O:
          color = Colors.yellow;
          width = 0.75;
          width = 0.75;
          break;
        case BlockType.I:
          color = Colors.lightBlueAccent;
          width = 0.75;
          break;
        case BlockType.J:
          color = Colors.blue;
          width = 0.75;
          break;
        case BlockType.L:
          color = Colors.orangeAccent;
          width = 0.75;
          break;
        case BlockType.S:
          color = Colors.green;
          width = 0.75;
          break;
        case BlockType.Z:
          color = Colors.redAccent;
          width = 0.75;
          break;
        case BlockType.T:
          color = Colors.deepPurpleAccent;
          width = 0.75;
          break;
        default:
          color = Colors.grey;
          break;
      }
    }
    return Border.all(color: color, width: width);
  }
}
