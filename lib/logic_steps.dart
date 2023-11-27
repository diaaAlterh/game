import 'dart:collection';
import 'dart:developer';
import 'package:rxdart/rxdart.dart';
import 'const.dart';
import 'game_state.dart';

class LogicSteps {
  final List<GameState> gameStates = [];
  GameState currentGameState;

  LogicSteps({
    required this.currentGameState,
  }) {
    _gameBlocFetcher.sink.add(currentGameState);
    gameStates.add(currentGameState);
    GameState goalGameState = currentGameState.copyWith(
        squarePosition: const SquarePosition(
            rowNumber: 3, columnNumber: 7)); // Set your goal state
    final path = bfs(currentGameState, goalGameState);
    _moveInPath(path);

    print(retries);
  }

  List<GameState> getAvailableGameStates(GameState currentGameState) {
    int rowLength = currentGameState.game.length;
    int columnLength = currentGameState.game.first.length;
    SquarePosition squarePosition = currentGameState.squarePosition;
    List<GameState> availableStates = [];

    // Check and add move up if possible
    if (squarePosition.rowNumber > 1) {
      availableStates.add(
        currentGameState.copyWith(
          squarePosition: SquarePosition(
            rowNumber: squarePosition.rowNumber - 1,
            columnNumber: squarePosition.columnNumber,
          ),
        ),
      );
    }

    // Check and add move down if possible
    if (squarePosition.rowNumber < rowLength) {
      availableStates.add(
        currentGameState.copyWith(
          squarePosition: SquarePosition(
            rowNumber: squarePosition.rowNumber + 1,
            columnNumber: squarePosition.columnNumber,
          ),
        ),
      );
    }

    // Check and add move left if possible
    if (squarePosition.columnNumber > 1) {
      availableStates.add(currentGameState.copyWith(
          squarePosition: SquarePosition(
        rowNumber: squarePosition.rowNumber,
        columnNumber: squarePosition.columnNumber - 1,
      )));
    }

    // Check and add move right if possible
    if (squarePosition.columnNumber < columnLength) {
      availableStates.add(
        currentGameState.copyWith(
          squarePosition: SquarePosition(
            rowNumber: squarePosition.rowNumber,
            columnNumber: squarePosition.columnNumber + 1,
          ),
        ),
      );
    }

    availableStates.removeWhere((element) {
      String cellLevel =
          currentGameState.game[element.squarePosition.rowNumber - 1]
              [element.squarePosition.columnNumber - 1];
      if (cellLevel == 'empty' || cellLevel == 'done') {
        return true;
      }
      if (squarePosition == element) {
        return true;
      }
      return false;
    });
    // log('availableMoves: $availableMoves');
    return availableStates;
  }

  int retries = 0;

  List<GameState> bfs(GameState startState, GameState goalState) {
    retries = 0;
    Queue<List<GameState>> queue = Queue(); // Queue to store paths
    Set<GameState> visited = {}; // Set to store visited states

    queue.add([startState]);
    while (queue.isNotEmpty) {
      retries++;
      List<GameState> path = queue.removeFirst();
      GameState currentState = path.last;

      if (!visited.contains(currentState)) {
        visited.add(currentState);

        if (currentState == goalState) {
          return path; // Return the path if the goal state is reached
        }

        List<GameState> successors = getAvailableGameStates(currentState);

        for (GameState successor in successors) {
          if (!visited.contains(successor)) {
            List<GameState> newPath = List.from(path);
            newPath.add(successor);
            queue.add(newPath);
          }
        }
      }
    }

    return []; // Return an empty list if no path is found
  }

  List<GameState> dfs(GameState startState, GameState goalState) {
    retries = 0;
    Set<GameState> visited = {}; // Set to store visited states
    List<GameState> path = [];

    bool dfsRecursive(GameState currentState) {
      retries++;
      if (!visited.contains(currentState)) {
        visited.add(currentState);
        path.add(currentState);

        if (currentState == goalState) {
          return true; // Return true if the goal state is reached
        }

        List<GameState> successors = getAvailableGameStates(currentState);

        for (GameState successor in successors) {
          if (!visited.contains(successor)) {
            if (dfsRecursive(successor)) {
              return true; // Return true if goal found in the recursive call
            }
          }
        }

        path.removeLast(); // Backtrack if no goal found in the current path
      }

      return false; // Return false if the goal is not found in this path
    }

    dfsRecursive(startState);

    return path; // Return the path
  }

  moveForward(Move move) {
    SquarePosition oldPosition = currentGameState.squarePosition;
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
    List<GameState> availableMoves = getAvailableGameStates(currentGameState);
    if (availableMoves.map((e) => e.squarePosition).contains(newPosition)) {
      _move(newPosition);
    }
  }

  _move(SquarePosition newPosition) {
    log('You have made ${gameStates.length} Moves');

    currentGameState = currentGameState.copyWith(
      squarePosition: newPosition,
    );
    gameStates.add(currentGameState);

    _gameBlocFetcher.sink.add(currentGameState);
  }

  _moveInPath(List<GameState> path) async {
    print('path: ${path.length} $path');
    if (path.isNotEmpty) {
      for (var element in path) {
        await Future.delayed(const Duration(milliseconds: 500));
        _move(element.squarePosition);
      }
    } else {
      print("No path found");
    }
  }

  moveBack() {
    if (gameStates.length > 1) {
      List states = [];
      states.addAll(gameStates.toList());
      gameStates.clear();
      currentGameState = states[states.length - 2];
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

  final _gameBlocFetcher = BehaviorSubject<GameState>();

  Stream<GameState> get gameStream => _gameBlocFetcher.stream;
}

LogicSteps logicSteps = LogicSteps(
  currentGameState: GameState(
    squarePosition: squarePosition,
    game: game,
  ),
);

enum Move { left, right, up, down }
