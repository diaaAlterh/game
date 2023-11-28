import 'dart:collection';
import 'dart:developer';
import 'package:collection/collection.dart';
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
    final path = dfs(currentGameState, goalGameState);
    _moveInPath(path);

    log('retries: $retries');
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
      List<GameState> path = queue.removeFirst();
      GameState currentState = path.last;

      if (!visited.contains(currentState)) {
        visited.add(currentState);

        if (currentState == goalState) {
          return path; // Return the path if the goal state is reached
        }

        List<GameState> successors = getAvailableGameStates(currentState);

        for (GameState successor in successors) {
          retries++;
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
      if (!visited.contains(currentState)) {
        visited.add(currentState);
        path.add(currentState);

        if (currentState == goalState) {
          return true; // Return true if the goal state is reached
        }

        List<GameState> successors = getAvailableGameStates(currentState);

        for (GameState successor in successors) {
          retries++;
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

  List<GameState> hillClimbing(GameState startState, GameState goalState) {
    retries = 0;
    List<GameState> path = [startState]; // Store the current path
    GameState currentState = startState;

    while (currentState != goalState) {
      List<GameState> neighbors = getAvailableGameStates(currentState);
      GameState bestNeighbor = findBestNeighbor(neighbors, goalState);

      path.add(bestNeighbor);
      currentState = bestNeighbor;
    }

    return path;
  }

  List<GameState> aStar(GameState startState, GameState goalState) {
    retries = 0;
    PriorityQueue<AStarNode> openSet =
        PriorityQueue((a, b) => (a.totalCost - b.totalCost).toInt());
    Set<GameState> closedSet = {};

    openSet.add(AStarNode(
        startState, null, 0.0, calculateHeuristic(startState, goalState)));

    while (openSet.isNotEmpty) {
      AStarNode currentNode = openSet.removeFirst();

      if (currentNode.state == goalState) {
        return reconstructPath(currentNode);
      }

      closedSet.add(currentNode.state);

      List<GameState> successors = getAvailableGameStates(currentNode.state);

      for (GameState successor in successors) {
        if (closedSet.contains(successor)) {
          continue;
        }
        int cost = calculateCost(successor);
        double successorCost = currentNode.cost + 1;
        double successorHeuristic = calculateHeuristic(successor, goalState);

        AStarNode successorNode = AStarNode(
            successor, currentNode, successorCost, successorHeuristic);

        if (!openSet.contains(successorNode)) {
          openSet.add(successorNode);
        }
      }
    }

    return [];
  }

  List<GameState> uniformCostSearch(GameState startState, GameState goalState) {
    PriorityQueue<UCSNode> openSet =
        PriorityQueue((a, b) => (a.cost - b.cost).toInt());
    Set<GameState> closedSet = {};

    openSet.add(UCSNode(startState, null, 0.0));

    while (openSet.isNotEmpty) {
      UCSNode currentNode = openSet.removeFirst();

      if (currentNode.state == goalState) {
        // Reconstruct and return the path if the goal state is reached
        return reconstructPath(currentNode);
      }

      closedSet.add(currentNode.state);

      List<GameState> successors = getAvailableGameStates(currentNode.state);

      for (GameState successor in successors) {
        retries++;
        if (closedSet.contains(successor)) {
          continue; // Skip already evaluated nodes
        }
        int cost = calculateCost(successor);
        double successorCost = currentNode.cost + cost;

        UCSNode successorNode = UCSNode(successor, currentNode, successorCost);

        if (!openSet.contains(successorNode)) {
          openSet.add(successorNode);
        }
      }
    }

    return []; // Return an empty list if no path is found
  }

  List<GameState> reconstructPath(dynamic node) {
    List<GameState> path = [];
    while (node != null) {
      path.insert(0, node.state);
      node = node.parent;
    }
    return path;
  }

  GameState findBestNeighbor(List<GameState> neighbors, GameState goalState) {
    double bestDistance = double.infinity;
    late GameState bestNeighbor;

    for (GameState neighbor in neighbors) {
      double distance = calculateHeuristic(neighbor, goalState);
      if (distance <= bestDistance) {
        bestDistance = distance;
        bestNeighbor = neighbor;
      }
    }
    log('bestNeighbor: $bestNeighbor distance to Goal:$bestDistance');
    return bestNeighbor;
  }

  double calculateHeuristic(GameState state, GameState goalState) {
    retries++;
    final manhattanDistance =
        ((state.squarePosition.rowNumber - goalState.squarePosition.rowNumber)
                    .abs() +
                (state.squarePosition.columnNumber -
                        goalState.squarePosition.columnNumber)
                    .abs())
            .toDouble();
    log('state $state is far $manhattanDistance from Goal $goalState');
    return manhattanDistance;
  }

  int calculateCost(GameState state) {
    String cellLevel = currentGameState.game[state.squarePosition.rowNumber - 1]
        [state.squarePosition.columnNumber - 1];
    String? stringLevel = map[cellLevel];
    int? level = int.tryParse(stringLevel ?? '');
    log('state $state cost $level');

    return level ?? 1;
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
    currentGameState = currentGameState.copyWith(
      squarePosition: newPosition,
    );
    gameStates.add(currentGameState);

    _gameBlocFetcher.sink.add(currentGameState);
  }

  _moveInPath(List<GameState> path) async {
    log('path: ${path.length} $path');
    if (path.isNotEmpty) {
      for (var element in path) {
        await Future.delayed(const Duration(milliseconds: 500));
        _move(element.squarePosition);
      }
    } else {
      log("No path found");
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
