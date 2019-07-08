import 'package:flutter/material.dart';

class Board extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class Square extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double squareWidth = MediaQuery.of(context).size.width;
    return Container(
      height: squareWidth,
      width: squareWidth,
    );
  }
}
