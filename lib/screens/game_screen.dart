import 'package:flutter/material.dart';
import 'package:tetris/board/board.dart';

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return SafeArea(
        bottom: false,
        child: Scaffold(
            body: Row(
          children: <Widget>[
            Spacer(),
            Board(width: width * 4 / 5, height: height),
            Spacer(),
          ],
        )));
  }
}
