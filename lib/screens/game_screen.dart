import 'package:flutter/material.dart';
import 'package:tetris/board/board.dart';
import 'package:tetris/provider.dart';

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var bloc = Provider.of(context).gameBloc;
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return SafeArea(
        bottom: false,
        child: Scaffold(
            body: Row(
          children: <Widget>[
            Spacer(),
            Board(width: width * 4 / 5, height: height),
            Expanded(
              child: RaisedButton(
                child: Text('Pause Game'),
                onPressed: () {
                  bloc.pauseGame();
                  print('game paused');
                },
              ),
            ),
          ],
        )));
  }
}
