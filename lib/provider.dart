import 'package:flutter/material.dart';
import 'package:tetris/board/grid.dart';

class Provider extends InheritedWidget {
  final Grid grid;

  Provider({Key key, @required this.grid, @required Widget child})
      : assert(grid != null),
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
