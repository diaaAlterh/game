import 'dart:developer';
import 'package:collection/collection.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';
import 'const.dart';
import 'game_state.dart';

class LogicSteps {
  final List<GameState> gameStates = [];
  late int rowLength;
  late int columnLength;
  GameState currentGameState;

  LogicSteps({
    required this.currentGameState,
  }) {
    _gameBlocFetcher.sink.add(currentGameState);
    rowLength = currentGameState.game.length;
    columnLength = currentGameState.game.first.length;
    gameStates.add(currentGameState);
    getLeastCostSquare();
    uniformCostSearch(
      currentGameState.squarePosition[currentGameState.squareIndex],
      const SquarePosition(rowNumber: 3, columnNumber: 7),
    );
    // dfs();
    // moveRandomly();
  }

  getLeastCostSquare() {
    final hello = currentGameState.squarePosition.firstWhereOrNull((element) =>
        element.cost <
        currentGameState.squarePosition[currentGameState.squareIndex].cost);
    if (hello != null) {
      currentGameState.squareIndex =
          currentGameState.squarePosition.indexOf(hello);
    }
  }

  moveForward(Move move) {
    SquarePosition oldPosition =
        currentGameState.squarePosition[currentGameState.squareIndex];
    SquarePosition newPosition;
    switch (move) {
      case Move.left:
        newPosition =
            oldPosition.copyWith(columnNumber: oldPosition.columnNumber - 1);
      case Move.right:
        newPosition =
            oldPosition.copyWith(columnNumber: oldPosition.columnNumber + 1);
      case Move.up:
        newPosition =
            oldPosition.copyWith(rowNumber: oldPosition.rowNumber - 1);
      case Move.down:
        newPosition =
            oldPosition.copyWith(rowNumber: oldPosition.rowNumber + 1);
    }
    List<SquarePosition> availableMoves = _getAvailableMoves(oldPosition);
    if (availableMoves.contains(newPosition)) {
      _move(newPosition, decreaseNumber: false);
    } else {
      availableMoves = _getAvailableMoves(
          currentGameState.squarePosition[currentGameState.squareIndex]);
      if (availableMoves.contains(newPosition)) {
        changeSquareIndex(1);
      } else {
        _checkIfWinner(availableMoves);
      }
    }
  }

  _move(SquarePosition newPosition, {bool decreaseNumber = true}) {
    List<List<String>> newGame = [];
    for (var element in currentGameState.game) {
      List<String> row = [];
      for (var element in element) {
        row.add(element);
      }
      newGame.add(row);
    }

    log('You have made ${gameStates.length} Moves');
    if (decreaseNumber) {
      String level =
          newGame[newPosition.rowNumber - 1][newPosition.columnNumber - 1];

      switch (level) {
        case 'level2':
          newGame[newPosition.rowNumber - 1][newPosition.columnNumber - 1] =
              'level1';
        case 'level3':
          newGame[newPosition.rowNumber - 1][newPosition.columnNumber - 1] =
              'level2';
        case 'level4':
          newGame[newPosition.rowNumber - 1][newPosition.columnNumber - 1] =
              'level3';
        default:
          newGame[newPosition.rowNumber - 1][newPosition.columnNumber - 1] =
              'done';
      }
    }

    List<SquarePosition> newPositions = [];
    newPositions.addAll(currentGameState.squarePosition);
    newPositions[currentGameState.squareIndex] = newPosition;
    currentGameState = currentGameState.copyWith(
      squarePosition: newPositions,
      game: newGame,
    );
    gameStates.add(currentGameState);

    _gameBlocFetcher.sink.add(currentGameState);
  }

  bool _checkIfWinner(List<SquarePosition> availableMoves) {
    bool isWinner = true;
    if (availableMoves.isEmpty) {
      for (var row in currentGameState.game) {
        for (var element in row) {
          if (element != 'done' && element != 'empty') {
            isWinner = false;
          }
        }
        if (!isWinner) {
          break;
        }
      }
      _gameBlocFetcher.sink.add(currentGameState.copyWith(isWinner: isWinner));
    }
    return isWinner;
  }

  moveBack() {
    if (gameStates.length > 1) {
      List states = [];
      states.addAll(gameStates.toList());
      gameStates.clear();
      currentGameState = states[states.length - 2];
      print(currentGameState.squarePosition);
      _gameBlocFetcher.sink.add(currentGameState);
      states.removeAt(states.length - 1);
      for (var element in states) {
        gameStates.add(element);
      }
      log('You Still Have ${gameStates.length} States');
    } else {
      log('You Don\'t Have Anymore States');
    }
  }

  List<SquarePosition> _getAvailableMoves(SquarePosition squarePosition) {
    List<SquarePosition> availableMoves = [];

    // Check and add move up if possible
    if (squarePosition.rowNumber > 1) {
      availableMoves.add(SquarePosition(
        rowNumber: squarePosition.rowNumber - 1,
        columnNumber: squarePosition.columnNumber,
      ));
    }

    // Check and add move down if possible
    if (squarePosition.rowNumber < rowLength) {
      availableMoves.add(SquarePosition(
        rowNumber: squarePosition.rowNumber + 1,
        columnNumber: squarePosition.columnNumber,
      ));
    }

    // Check and add move left if possible
    if (squarePosition.columnNumber > 1) {
      availableMoves.add(SquarePosition(
        rowNumber: squarePosition.rowNumber,
        columnNumber: squarePosition.columnNumber - 1,
      ));
    }

    // Check and add move right if possible
    if (squarePosition.columnNumber < columnLength) {
      availableMoves.add(SquarePosition(
        rowNumber: squarePosition.rowNumber,
        columnNumber: squarePosition.columnNumber + 1,
      ));
    }

    availableMoves.removeWhere((element) {
      String cellLevel = currentGameState.game[element.rowNumber - 1]
          [element.columnNumber - 1];
      if (cellLevel == 'empty' || cellLevel == 'done') {
        return true;
      }
      if (currentGameState.squarePosition.contains(element)) {
        return true;
      }
      return false;
    });
    // log('availableMoves: $availableMoves');
    return availableMoves;
  }

  int retries = 0;

  Future<List<SquarePosition>> moveRandomly() async {
    retries++;
    List<SquarePosition> result = [];

    result.add(currentGameState.squarePosition[currentGameState.squareIndex]);
    for (var element in result) {
      final moves = _getAvailableMoves(element);
      if (moves.isNotEmpty) {
        moves.shuffle();
        await Future.delayed(const Duration(microseconds: 0));
        _move(moves.first);
        result.add(moves.first);
      }
    }
    if (_checkIfWinner([])) {
      print(result);
      Fluttertoast.showToast(
          msg: 'Numbers Of Retries: $retries ', timeInSecForIosWeb: 10);
      return result;
    } else {
      _gameBlocFetcher.sink.add(gameStates.first);
      currentGameState = gameStates.first;
      moveRandomly();
    }
    return result;
  }

  Future<List<SquarePosition>> dfs() async {
    List<SquarePosition> result = [];

    result.add(currentGameState.squarePosition[currentGameState.squareIndex]);
    for (var element in result) {
      final moves = _getAvailableMoves(element);
      if (moves.isNotEmpty) {
        moves.shuffle();
        await Future.delayed(const Duration(milliseconds: 800));
        for (var element in moves) {
          _move(element);
        }
        result.addAll(moves);
      }
    }
    _checkIfWinner([]);
    print(result);
    return result;
  }

  changeSquareIndex(int newIndex) {
    if (currentGameState.squarePosition.length > newIndex) {
      print('hello');
      currentGameState = currentGameState.copyWith(
        squareIndex: newIndex,
      );
      _gameBlocFetcher.sink.add(currentGameState);
    }
  }

  final _gameBlocFetcher = BehaviorSubject<GameState>();

  Stream<GameState> get gameStream => _gameBlocFetcher.stream;

  Future<List<SquarePosition>> uniformCostSearch(
    SquarePosition start,
    SquarePosition goal,
  ) async {
    final PriorityQueue<_SearchNode> priorityQueue =
        HeapPriorityQueue<_SearchNode>();
    final Set<SquarePosition> visited = <SquarePosition>{};

    priorityQueue.add(_SearchNode(position: start, cost: 0, path: [start]));

    while (priorityQueue.isNotEmpty) {
      final current = priorityQueue.removeFirst();

      if (current.position == goal) {
        log('ucs: ${current.path}');
        for (var element in current.path) {
          await Future.delayed(const Duration(milliseconds: 800));
          _move(element, decreaseNumber: false);
        }
        return current.path;
      }

      if (!visited.contains(current.position)) {
        visited.add(current.position);

        final List<SquarePosition> moves = _getAvailableMoves(current.position);
        for (final move in moves) {
          if (!visited.contains(move)) {
            final int moveCost = getMoveCost(move);
            final int heuristicCost = getHeuristicCost(move, goal);
            print('${current.cost} ${heuristicCost} ${move}');

            final List<SquarePosition> newPath = List.from(current.path)
              ..add(move);

            priorityQueue.add(_SearchNode(
                position: move, cost: current.cost + moveCost +heuristicCost, path: newPath));
          }
        }
      }
    }

    return [];
  }
  int getHeuristicCost(SquarePosition move, SquarePosition goal) {
    return (move.rowNumber - goal.columnNumber).abs() + (move.columnNumber - goal.rowNumber).abs();
  }


  int getMoveCost(SquarePosition next) {
    String level =
        currentGameState.game[next.rowNumber - 1][next.columnNumber - 1];
    return currentGameState.squarePosition[currentGameState.squareIndex].cost *
        int.parse(level.split('level')[1]);
  }
}

LogicSteps logicSteps = LogicSteps(
  currentGameState: GameState(
    squarePosition: [squarePosition1, squarePosition2],
    squareIndex: 1,
    game: game2,
  ),
);

class _SearchNode implements Comparable<_SearchNode> {
  final SquarePosition position;
  final int cost;
  final List<SquarePosition> path;

  _SearchNode({
    required this.position,
    required this.cost,
    required this.path,
  });

  @override
  int compareTo(_SearchNode other) => cost.compareTo(other.cost);
}

enum Move { left, right, up, down }
