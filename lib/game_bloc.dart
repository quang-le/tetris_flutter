import 'dart:async';
import 'package:collection/collection.dart';
import 'package:frideos_core/frideos_core.dart';
import 'package:tetris/board/grid.dart';
import 'package:tetris/helpers/compare.dart';
import 'package:tetris/movement/move.dart';
import 'package:tetris/randomizer.dart';
import 'package:tetris/tetriminos/tetriminos.dart';

class GameBloc with Tetriminos, Move {
  GameBloc() {
    _isLocking.stream.listen((locking) {
      if (locking) {
        stopwatchLock.start();
      } else if (!locking) {
        stopwatchLock.stop();
        stopwatchLock.reset();
      }
    });
    gameStart = _gameStart.stream.listen((start) {
      int gameSpeed = 1000;
      gameLoop(gameSpeed);
    });

    ghostPieceUpdate = _ghostPieceShouldUpdate.outStream.listen((update) {
      if (update) {
        _updateGhostPiece();
      }
    });

    hardDropListener = _hardDrop.outStream.listen((hardDrop) {
      if (hardDrop) {
        List<List<int>> oldCells = List.from(_tetrimino.value);
        _tetrimino.value = List.from(_ghostPiece.value);
        _tetrimino.value.forEach((cell) {
          _updateCell(cell, _blockType.value, _grid.value);
        });
        _clearOldCells(oldCells, _tetrimino.value);
        _isLocking.value = true;
        print('HARD DROP DONE');
      }
    });

    isGamePaused = _pauseGame.outStream.listen((isPaused) {
      if (isPaused) {
        stopwatchLock.stop();
        stopwatchFall.stop();
      } else if (!isPaused) {
        if (!stopwatchFall.isRunning) {
          stopwatchFall.start();
        }
        if (!stopwatchLock.isRunning) {
          stopwatchLock.start();
        }
      }
    });
  }

  var stopwatchLock = Stopwatch();
  var stopwatchFall = Stopwatch();
  var randomizer = Randomizer();
  var compareList = IterableEquality();
  var mapCompare = MapEquality();
  StreamSubscription gameStart;
  StreamSubscription isGamePaused;
  StreamSubscription ghostPieceUpdate;
  StreamSubscription hardDropListener;

  var _grid = StreamedValue<Map<List<int>, BlockType>>();
  var _landed = StreamedValue<bool>()..inStream(false);
  var _isLocking = StreamedValue<bool>()..inStream(false);
  var _tetrimino = StreamedList<List<int>>()..inStream(<List<int>>[]);
  var _ghostPiece = StreamedList<List<int>>()..inStream(<List<int>>[]);
  var _ghostPieceDisplay = StreamedList<List<int>>()..inStream(<List<int>>[]);
  var _goLeft = StreamedValue<bool>()..inStream(false);
  var _goRight = StreamedValue<bool>()..inStream(false);
  var _fastDrop = StreamedValue<bool>()..value = false;
  var _hardDrop = StreamedValue<bool>()..value = false;
  var _isRotating = StreamedValue<bool>()..inStream(false);
  var _ghostPieceShouldUpdate = StreamedValue<bool>()..inStream(false);
  var _gameOver = StreamedValue<bool>()..value = true;
  var _gameStart = StreamedValue<bool>()..value = false;
  var _pauseGame = StreamedValue<bool>()..value = false;
  var _blockType = StreamedValue<BlockType>();
  var _center = StreamedList<int>()
    ..value = ([
      5,
      21
    ]); // arbitrary value to avoid null error. correct value set by add()

  Stream<Map<List<int>, BlockType>> get grid => _grid.outStream;
  Stream<List<List<int>>> get tetrimino => _tetrimino.outStream;
  Stream<List<List<int>>> get ghostPiece => _ghostPieceDisplay.outStream;
  Stream<BlockType> get blockType => _blockType.outStream;

  Stream<bool> get gameOver => _gameOver.outStream;

  void startGame() {
    _gameOver.value = false;
    _gameStart.value = true;
    return;
  }

  void pauseGame() {
    _pauseGame.value = !_pauseGame.value;
  }

  void initializeGrid(int horizontal, int vertical) {
    List<int> gridX = List<int>.generate(horizontal, (i) => i, growable: false);
    List<int> gridY = List<int>.generate(vertical, (i) => i, growable: false);
    List<List<int>> gridCoordinates =
        Grid.generateGridCoordinates(gridX, gridY);
    Map<List<int>, BlockType> grid = Grid.generateGrid(gridCoordinates);
    _grid.value = grid;
    return;
  }

  // TODO refactor out of BloC (-> Tetrimino)
  void addPiece() {
    _tetrimino.value = coordinates(_blockType.value);
    //TODO: check if lines 19 and 20 are empty, if so: spawn from line 20, if not spawn from further up
    _tetrimino.value
        .forEach((cell) => _updateCell(cell, _blockType.value, _grid.value));
    _center.value = setCenter(_blockType.value);
    return;
  }

  void move(Direction direction) {
    // keep copy of old coordinates for clearing display
    var cellsToRemove = List<List<int>>.from(_tetrimino.value);

    // update tetrimino position in stream
    List<List<int>> updatedPosition =
        _updatePositionInStream(direction, _tetrimino);
    updatedPosition.forEach((newCell) {
      _updateCell(newCell, _blockType.value, _grid.value);
    });
    // Identify cells to keep (new cell position overlaps old cell position)
    List<List<int>> cellsToKeep =
        Compare.createListOfMatchingLists(cellsToRemove, _tetrimino.value);

    //if no cells of the new position overlap with previous position, clear old cells
    _clearOldCells(cellsToRemove, cellsToKeep);
    return;
  }

  void fall() {
    move(Direction.down);
    if (_center.value.isNotEmpty) {
      if (_center.value[1] > 0) {
        _center.value[1]--;
        _center.refresh();
      }
    }
    return;
  }

  void moveLeft() {
    move(Direction.left);
    if (_center.value.isNotEmpty) {
      if (_center.value[0] > 0) {
        _center.value[0]--;
        _center.refresh();
      }
    }
    return;
  }

  void moveRight() {
    move(Direction.right);
    if (_center.value.isNotEmpty) {
      if (_center.value[0] < 10) {
        _center.value[0]++;
        _center.refresh();
      }
    }
    return;
  }

  void userInputLeft() {
    _goRight.value = false;
    _goLeft.value = true;
    return;
  }

  void userInputRight() {
    _goLeft.value = false;
    _goRight.value = true;
    return;
  }

  void cancelHorizontalUserInput() {
    _goLeft.value = false;
    _goRight.value = false;
    return;
  }

  void cancelVerticalUserInput() {
    _hardDrop.value = false;
    _fastDrop.value = false;
    return;
  }

  void fastFall() {
    cancelHorizontalUserInput();
    _fastDrop.value = true;
    return;
  }

  void hardDrop() {
    cancelHorizontalUserInput();
    _hardDrop.value = true;
  }

  void userInputRotate() {
    _isRotating.value = true;
    return;
  }

  void rotate(Direction direction) {
    if (_center.value.isNotEmpty) {
      List<List<int>> updatedCoordinatesOnGrid = [];
      if (direction == Direction.left) {
        updatedCoordinatesOnGrid = obtainRotatedCoordinates(
            _center.value, leftMatrix, _tetrimino.value);
      } else {
        updatedCoordinatesOnGrid = obtainRotatedCoordinates(
            _center.value, rightMatrix, _tetrimino.value);
      }
      // keep copy of old coordinates for clearing display
      var cellsToRemove = List<List<int>>.from(_tetrimino.value);

      // Wall detection
      updatedCoordinatesOnGrid = detectCollisionAndUpdateCoordinates(
          updatedCoordinatesOnGrid,
          _tetrimino.value,
          _grid.value,
          _center.value);

      //update tetrimino stream
      _tetrimino.value = updatedCoordinatesOnGrid;
      // update grid with correct block value
      _tetrimino.value.forEach((cell) {
        _updateCell(cell, _blockType.value, _grid.value);
      });

      // Identify cells to keep (new cell position overlaps old cell position)
      List<List<int>> cellsToKeep =
          Compare.createListOfMatchingLists(cellsToRemove, _tetrimino.value);

      //if no cells of the new position overlap with previous position, clear old cells
      _clearOldCells(cellsToRemove, cellsToKeep);
    }
    return;
  }

  void _clearOldCells(
      List<List<int>> cellsToRemove, List<List<int>> cellsToKeep) {
    //if no cells of the new position overlap with previous position, clear old cells
    if (cellsToKeep.isEmpty) {
      cellsToRemove.forEach((cellToClear) {
        _updateCell(cellToClear, BlockType.empty, _grid.value);
      });
      //otherwise remove matching cells from clearing
    } else {
      // TODO encapsulate in _createListOfNonMatchingLists
      List<List<int>> cellsToRemoveUpdated = [];
      cellsToRemove.forEach((cellToClear) {
        var removeFromRemoveList = Compare.matchLists(cellToClear, cellsToKeep);
        if (removeFromRemoveList.isEmpty) {
          cellsToRemoveUpdated.add(cellToClear);
        }
      });
      cellsToRemove = cellsToRemoveUpdated;
      cellsToRemove.forEach((cellToClear) {
        _updateCell(cellToClear, BlockType.empty, _grid.value);
      });
    }
  }

  void checkContactOnSide() {
    var hasReachedLeftLimit = reachLeftLimit(_tetrimino.value);
    var hasReachedRightLimit = reachRightLimit(_tetrimino.value);
    var hasReachedBlockOnLeft = reachBlockOnLeft(_tetrimino.value, _grid.value);
    var hasReachedBlockOnRight =
        reachBlockOnRight(_tetrimino.value, _grid.value);

    if (hasReachedLeftLimit.isNotEmpty || hasReachedBlockOnLeft.isNotEmpty) {
      _goLeft.value = false;
    }

    if (hasReachedRightLimit.isNotEmpty || hasReachedBlockOnRight.isNotEmpty) {
      _goRight.value = false;
    }
  }

  void checkContactBelow() {
    var hasReachedBottom = reachBottom(_tetrimino.value);
    var hasReachedTop = reachTop(_tetrimino.value, _grid.value);
    var hasReachedOtherBlock = reachOtherBlock(_tetrimino.value, _grid.value);

    if (hasReachedTop.isNotEmpty) {
      _gameOver.value = true;
      print('++++++++++++++++++++GAME OVER+++++++++++++++++++++');
      return;
    }

    if (hasReachedBottom.isNotEmpty || hasReachedOtherBlock.isNotEmpty) {
      if (!_isLocking.value) {
        _isLocking.value = true;
        return;
      }
      return;
    }
    _isLocking.value = false;
    return;
  }

  void _checkGhostPieceContact() {
    print('checking contact');
    var hasReachedBottom = reachBottom(_ghostPiece.value);
    var hasReachedOtherBlock = reachOtherBlock(_ghostPiece.value, _grid.value);

    if (hasReachedBottom.isEmpty && hasReachedOtherBlock.isEmpty) {
      _updatePositionInStream(Direction.down, _ghostPiece);
      _checkGhostPieceContact();
    } else {
      _ghostPieceDisplay.value = _ghostPiece.value;
      return;
    }
  }

  void _updateGhostPiece() {
    _ghostPiece.value = List<List<int>>.from(_tetrimino.value);
    _checkGhostPieceContact();
  }

  List<List<int>> _updatePositionInStream(
      Direction direction, StreamedList<List<int>> stream) {
    stream.value.forEach((cell) {
      List<int> newCell = determineMovementValues(direction, cell);
      stream.replace(cell, newCell);
      stream.refresh();
    });
    return stream.value;
  }

  void _updateCell(
    List<int> coordinates,
    BlockType type,
    Map<List<int>, BlockType> grid,
  ) {
    Map<List<int>, BlockType> clonedGrid = Map<List<int>, BlockType>.from(grid);
    clonedGrid.forEach((index, blockType) {
      if (compareList.equals(index, coordinates)) {
        clonedGrid[index] = type;
      }
    });
    _grid.value = clonedGrid;
    return;
  }

// TODO get width and height from widget i.o. hard coded in function
  // TODO REFACTOR: pass line length to check against controlLine and save the creation of Line
  List<Map<List<int>, BlockType>> checkFullLines(
      Map<List<int>, BlockType> grid) {
    Map<List<int>, BlockType> clonedGrid = Map<List<int>, BlockType>.from(grid);
    List<Map<List<int>, BlockType>> fullLines = [];
    // Create subMaps by line/ y coordinate
    // use decremental loop to allow grid update from top to bottom
    for (var i = 19; i >= 0; i--) {
      Map<List<int>, BlockType> line = {};
      Map<List<int>, BlockType> controlLine = {};
      clonedGrid.forEach((coordinates, type) {
        if (coordinates[1] == i) {
          controlLine.putIfAbsent(coordinates, () => type);
        }
      });
      // create a line with all locked blocks and a control line with all blocks
      controlLine.forEach((coordinates, type) {
        if (type == BlockType.locked) {
          line.putIfAbsent(coordinates, () => type);
        }
      });
      // check if line is full then add to fullLines
      if (mapCompare.equals(line, controlLine)) {
        fullLines.add(line);
      }
    }

    return fullLines;
  }

  void clearLines(List<Map<List<int>, BlockType>> fullLines) {
    if (fullLines.isNotEmpty) {
      fullLines.forEach((line) {
        line.forEach((index, cell) {
          _updateCell(index, BlockType.empty, _grid.value);
        });
      });
      // make list of y coordinate of cleared line
      List<int> yCoordinate = [];
      fullLines.forEach((line) {
        List<List<int>> lineKeys = line.keys.toList();
        int coordinateToAdd = lineKeys[0][1];
        yCoordinate.add(coordinateToAdd);
      });
      yCoordinate.sort();
      //TODO refactor to avoid nested loop
      // for each coordinate, replace the blockType by the type of the block above
      for (var i = yCoordinate.length - 1; i >= 0; i--) {
        for (var j = yCoordinate[i]; j < 21; j++) {
          _grid.value.forEach((gridCoord, type) {
            if (gridCoord[1] == j) {
              var cellToMoveDown = Compare.matchLists(
                  [gridCoord[0], gridCoord[1] + 1], _grid.value.keys.toList());
              var newType = _grid.value[cellToMoveDown];
              _updateCell(gridCoord, newType, _grid.value);
            }
          });
        }
      }
    }
    return;
  }

  void gameLoop(int fallSpeed) async {
    List<Map<List<int>, BlockType>> fullLines = [];
    while (_gameOver.value == false) {
      /// Game pause
      if (!_pauseGame.value) {
        // TODO make newBlock array so next piece can be displayed. push and pop pieces as game progresses
        // TODO put it all in a function or a stream so it can be called when swapping with stored piece
        var newBlock = randomizer.choosePiece();
        _blockType.value = newBlock;
        addPiece();
        _ghostPiece.value = List<List<int>>.from(_tetrimino.value);
        _checkGhostPieceContact();
        while (_landed.value == false) {
          /// Game pause
          /// This if statement might create bug when pausing
          if (!_pauseGame.value) {
            stopwatchFall.start();
            while (stopwatchFall.elapsedMilliseconds < fallSpeed &&
                !_hardDrop.value &&
                !_fastDrop.value) {
              // Future necessary for performance and to give time to render
              await Future.delayed(Duration(milliseconds: 100));
              checkContactOnSide();

              /// Game pause
              if (!_pauseGame.value) {
                if (_fastDrop.value) {
                  while (!_isLocking.value && _fastDrop.value) {
                    ///WARNING potential bug here if user fast drops just before contact
                    fall();
                    checkContactBelow();
                    // TODO find a ratio with fallSpeed
                    await Future.delayed(
                        Duration(milliseconds: fallSpeed ~/ 5));
                  }
                }

                /// Game pause
                if (!_pauseGame.value) {
                  if (_isRotating.value) {
                    rotate(Direction.left);
                    _isRotating.value = false;
                    _ghostPieceShouldUpdate.value = true;
                  }
                  if (_goLeft.value) {
                    moveLeft();
                    _ghostPieceShouldUpdate.value = true;
                  }
                  if (_goRight.value) {
                    moveRight();
                    _ghostPieceShouldUpdate.value = true;
                  }
                  checkContactBelow();
                }
              }
            }
            stopwatchFall.stop();
            stopwatchFall.reset();

            if ((_isLocking.value == true &&
                    stopwatchLock.elapsedMilliseconds > 1000) ||
                (_isLocking.value && _hardDrop.value) ||
                (_isLocking.value && _fastDrop.value)) {
              _landed.value = true;
              print('==============LANDED================');
            } else if (_isLocking.value == false && !_pauseGame.value) {
              fall();
            }
          }
        }
        // reinitialize control values if block landed
        if (_landed.value == true) {
          _isLocking.value = false;
          _hardDrop.value = false;
          _fastDrop.value = false;
          _tetrimino.value.forEach(
              (cell) => _updateCell(cell, BlockType.locked, _grid.value));
          _tetrimino.value = [];

          fullLines = checkFullLines(_grid.value);
          if (fullLines.isNotEmpty) {
            await Future.delayed(Duration(milliseconds: 2000));
            clearLines(fullLines);
          }
        }
        _landed.value = false;
      }
    }
  }

  void dispose() {
    gameStart.cancel();
    _center.dispose();
    _grid.dispose();
    _landed.dispose();
    _isLocking.dispose();
    _tetrimino.dispose();
    _blockType.dispose();
    _goLeft.dispose();
    _goRight.dispose();
    _gameStart.dispose();
    _gameOver.dispose();
    _isRotating.dispose();
    _fastDrop.dispose();
    _hardDrop.dispose();
    _ghostPiece.dispose();
    _pauseGame.dispose();
    _ghostPieceDisplay.dispose();
    isGamePaused.cancel();
    ghostPieceUpdate.cancel();
    hardDropListener.cancel();
  }
}

enum BlockType { I, J, L, T, S, Z, O, empty, locked }

enum Direction { left, right, down }
