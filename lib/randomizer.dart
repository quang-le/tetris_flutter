import 'dart:math';

import 'package:tetris/game_bloc.dart';

class Randomizer {
  int _counter = 0;
  BlockType choosePiece() {
    BlockType nextPiece;
    Random random = Random();
    int bag = random.nextInt(7 - _counter);
    print('bag: $bag');

    if (_counter <= 6) {
      _counter++;
    } else {
      _counter = 0;
    }

    switch (bag) {
      case 1:
        nextPiece = BlockType.I;
        break;
      case 2:
        nextPiece = BlockType.J;
        break;
      case 3:
        nextPiece = BlockType.L;
        break;
      case 4:
        nextPiece = BlockType.S;
        break;
      case 5:
        nextPiece = BlockType.Z;
        break;
      case 6:
        nextPiece = BlockType.O;
        break;
      case 7:
        nextPiece = BlockType.T;
        break;
    }
    return nextPiece;
  }
}
