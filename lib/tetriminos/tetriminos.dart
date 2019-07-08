import 'package:flutter/material.dart';
import 'package:tetris/board/grid.dart';

class Tetriminos extends StatefulWidget {
  final BlockType blockType;

  const Tetriminos({Key key, this.blockType}) : super(key: key);
  @override
  _TetriminosState createState() => _TetriminosState();
}

class _TetriminosState extends State<Tetriminos> {
  List<GridCoordinate> gridCoordinates;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    switch (widget.blockType) {
      case BlockType.I:
        gridCoordinates = [
          GridCoordinate(y: 24, x: 3),
          GridCoordinate(y: 24, x: 4),
          GridCoordinate(y: 24, x: 5),
          GridCoordinate(y: 24, x: 6),
        ];
        break;
      case BlockType.J:
        gridCoordinates = [
          GridCoordinate(y: 24, x: 3),
          GridCoordinate(y: 24, x: 4),
          GridCoordinate(y: 24, x: 5),
          GridCoordinate(y: 25, x: 5),
        ];
        break;
      case BlockType.L:
        gridCoordinates = [
          GridCoordinate(y: 24, x: 3),
          GridCoordinate(y: 24, x: 4),
          GridCoordinate(y: 24, x: 5),
          GridCoordinate(y: 25, x: 3),
        ];
        break;
      case BlockType.S:
        gridCoordinates = [
          GridCoordinate(y: 24, x: 3),
          GridCoordinate(y: 24, x: 4),
          GridCoordinate(y: 25, x: 5),
          GridCoordinate(y: 25, x: 6),
        ];
        break;
      case BlockType.Z:
        gridCoordinates = [
          GridCoordinate(y: 25, x: 3),
          GridCoordinate(y: 25, x: 4),
          GridCoordinate(y: 24, x: 5),
          GridCoordinate(y: 24, x: 6),
        ];
        break;
      case BlockType.O:
        gridCoordinates = [
          GridCoordinate(y: 25, x: 5),
          GridCoordinate(y: 25, x: 6),
          GridCoordinate(y: 24, x: 5),
          GridCoordinate(y: 24, x: 6),
        ];
        break;
      case BlockType.T:
        gridCoordinates = [
          GridCoordinate(y: 24, x: 3),
          GridCoordinate(y: 24, x: 4),
          GridCoordinate(y: 24, x: 5),
          GridCoordinate(y: 25, x: 4),
        ];
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

enum BlockType { I, J, L, T, S, Z, O }
