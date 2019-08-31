import 'dart:math';

import 'package:tetris/game_bloc.dart';

class Randomizer {
  int _pieces = 6;
  List<int> _availablePieces = [0, 1, 2, 3, 4, 5, 6];
  BlockType choosePiece() {
    BlockType nextPiece;
    int bag;
    // If length=0 randomizer crashes
    if (_availablePieces.length > 1) {
      while (bag == null) {
        bag = _generateNumber(_pieces, _availablePieces);
      }
      _availablePieces.remove(bag);
    } else {
      bag = _availablePieces[0];
      _availablePieces = [0, 1, 2, 3, 4, 5, 6];
    }
    print('bag :$bag');

    switch (bag) {
      case 0:
        nextPiece = BlockType.I;
        break;
      case 1:
        nextPiece = BlockType.J;
        break;
      case 2:
        nextPiece = BlockType.L;
        break;
      case 3:
        nextPiece = BlockType.S;
        break;
      case 4:
        nextPiece = BlockType.Z;
        break;
      case 5:
        nextPiece = BlockType.O;
        break;
      case 6:
        nextPiece = BlockType.T;
        break;
    }
    return nextPiece;
  }

  int _generateNumber(int piecesRange, List<int> availablePieces) {
    Random random = Random();
    int bag = random.nextInt(piecesRange);
    if (availablePieces.contains(bag)) {
      return bag;
    }
    return null;
  }
}
