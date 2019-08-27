import 'package:flutter/material.dart';
import 'package:tetris/board/board.dart';
import 'package:tetris/board/grid.dart';
import 'package:tetris/home_page.dart';

class App extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tetris',
      theme: ThemeData.dark(),
      //home: HomePage(),
      home: Builder(builder: (builderContext) {
        var width = MediaQuery.of(builderContext).size.width;
        var height = MediaQuery.of(builderContext).size.height;
        return Board(width: width, height: height);
      }),
    );
  }
}
