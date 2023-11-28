import 'package:equatable/equatable.dart';

class GameState extends Equatable {
  final SquarePosition squarePosition;
  final List<List<String>> game;

  const GameState({
    required this.squarePosition,
    required this.game,
  });

  GameState copyWith({
    SquarePosition? squarePosition,
  }) =>
      GameState(
        squarePosition: squarePosition ?? this.squarePosition,
        game: game,
      );

  @override
  List<Object?> get props => [squarePosition];
}

class SquarePosition extends Equatable {
  final int rowNumber;
  final int columnNumber;

  const SquarePosition({
    required this.rowNumber,
    required this.columnNumber,
  });

  SquarePosition copyWith({
    int? rowNumber,
    int? columnNumber,
    int? cost,
  }) =>
      SquarePosition(
        rowNumber: rowNumber ?? this.rowNumber,
        columnNumber: columnNumber ?? this.columnNumber,
      );

  @override
  List<Object?> get props => [
        rowNumber,
        columnNumber,
      ];
}

enum Move { left, right, up, down }

class AStarNode {
  final GameState state;
  final AStarNode? parent;
  final double cost; // g(n): Cost to reach this node
  final double heuristic; // h(n): Heuristic estimate to the goal

  AStarNode(this.state, this.parent, this.cost, this.heuristic);

  double get totalCost => cost + heuristic;
}

class UCSNode {
  final GameState state;
  final UCSNode? parent;
  final double cost; // g(n): Cost to reach this node

  UCSNode(this.state, this.parent, this.cost);
}

Map<String, String> map = {
  "empty": '',
  "done": '0',
  "level1": '1',
  "level2": '2',
  "level3": '3',
  "level4": '4',
};
