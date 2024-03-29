import 'package:flutter/material.dart';
import 'package:tetris/game_bloc.dart';

class Provider extends InheritedWidget {
  final GameBloc gameBloc;

  Provider({Key key, @required this.gameBloc, @required Widget child})
      : assert(gameBloc != null),
        assert(child != null),
        super(key: key, child: child);

  static Provider of(BuildContext context) {
    return context
        .ancestorInheritedElementForWidgetOfExactType(Provider)
        .widget;
  }

  @override
  bool updateShouldNotify(Provider old) {
    return true;
  }
}
