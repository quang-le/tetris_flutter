import 'package:flutter/material.dart';
import 'package:tetris/board/grid_cell.dart';
import 'package:tetris/game_bloc.dart';
import 'package:tetris/provider.dart';

class Board extends StatefulWidget {
  final double height;
  final double width;

  const Board({Key key, @required this.height, @required this.width})
      : assert(height != null),
        assert(width != null),
        super(key: key);

  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board> {
  GameBloc bloc;

  // TODO : add int rows & int columns
  @override
  void initState() {
    // TODO: use Boelens Provider or Provider library
    bloc = Provider.of(context).gameBloc;
    bloc.initializeGrid(10, 24);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      child: Column(
        children: _gameGrid(context, 10, 20),
      ),
    );
  }

  List<Widget> _gameGrid(BuildContext context, int width, int height) {
    double cellSize = widget.width / width;
    List<Widget> result = [];
    for (var i = height; i >= 0; i--) {
      var row = _gameRow(context, i, width, cellSize);
      result.add(row);
    }
    return result;
  }

  Widget _gameRow(
      BuildContext context, int yCoordinate, int length, double cellSize) {
    List<Widget> result = [];
    for (var i = 0; i < length; i++) {
      var cell = GridCell(
        coordinates: [i, yCoordinate],
        size: cellSize,
        bloc: bloc,
      );
      result.add(cell);
    }
    return Row(children: result);
  }
}

/*class Square extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double squareWidth = MediaQuery.of(context).size.width;
    return Container(
      height: squareWidth,
      width: squareWidth,
    );
  }
}*/
