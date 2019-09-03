import 'package:flutter/material.dart';
import 'package:tetris/game_bloc.dart';

class Tetriminos extends StatefulWidget {
  final BlockType blockType;

  const Tetriminos({Key key, this.blockType}) : super(key: key);
  @override
  _TetriminosState createState() => _TetriminosState();
}

class _TetriminosState extends State<Tetriminos> {
  List<List<int>> gridCoordinates;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    switch (widget.blockType) {
      case BlockType.I:
        gridCoordinates = [
          [24, 3],
          [24, 4],
          [24, 5],
          [24, 6],
        ];
        break;
      case BlockType.J:
        gridCoordinates = [
          [24, 3],
          [24, 4],
          [24, 5],
          [25, 5],
        ];
        break;
      case BlockType.L:
        gridCoordinates = [
          [24, 3],
          [24, 4],
          [24, 5],
          [25, 3],
        ];
        break;
      case BlockType.S:
        gridCoordinates = [
          [24, 3],
          [24, 4],
          [25, 5],
          [25, 6],
        ];
        break;
      case BlockType.Z:
        gridCoordinates = [
          [25, 3],
          [25, 4],
          [24, 5],
          [24, 6],
        ];
        break;
      case BlockType.O:
        gridCoordinates = [
          [25, 5],
          [25, 6],
          [24, 5],
          [24, 6],
        ];
        break;
      case BlockType.T:
        gridCoordinates = [
          [24, 3],
          [24, 4],
          [24, 5],
          [25, 4],
        ];
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
