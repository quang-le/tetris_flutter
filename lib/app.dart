import 'package:flutter/material.dart';
import 'package:tetris/screens/game_screen.dart';
import 'package:tetris/screens/home_page.dart';

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
      home: HomePage(),
      //home: GameScreen(),
    );
  }
}
