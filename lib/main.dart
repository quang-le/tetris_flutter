import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tetris/app.dart';
import 'package:tetris/board/grid.dart';
import 'package:tetris/provider.dart';

void main() async {
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  Grid grid = Grid();
  runApp(Provider(grid: grid, child: App()));
}
