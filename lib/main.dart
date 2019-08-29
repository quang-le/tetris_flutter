import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tetris/app.dart';
import 'package:tetris/board/grid.dart';
import 'package:tetris/game_bloc.dart';
import 'package:tetris/provider.dart';

void main() async {
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  Grid grid = Grid();
  GameBloc gameBloc = GameBloc();
  runApp(Provider(grid: grid, gameBloc: gameBloc, child: App()));
}
