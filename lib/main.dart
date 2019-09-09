import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tetris/app.dart';
import 'package:tetris/game_bloc.dart';
import 'package:tetris/provider.dart';

void main() async {
  debugPrintGestureArenaDiagnostics = true;
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  GameBloc gameBloc = GameBloc();
  runApp(Provider(gameBloc: gameBloc, child: App()));
}
