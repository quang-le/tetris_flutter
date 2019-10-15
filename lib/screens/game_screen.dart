import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tetris/board/board.dart';
import 'package:tetris/game_bloc.dart';
import 'package:tetris/provider.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameBloc bloc;
  StreamSubscription gameOverListen;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bloc = Provider.of(context).gameBloc;
    bloc.startGame();
    gameOverListen = bloc.gameOver.listen((isGameOver) {
      if (isGameOver) {
        // TODO toggle game over screen
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    gameOverListen.cancel();
  }

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
