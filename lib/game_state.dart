import 'package:equatable/equatable.dart';

class GameState extends Equatable {
  final List<SquarePosition> squarePosition;
  final List<List<String>> game;
  final bool? isWinner;
  int squareIndex;

   GameState({
    required this.squarePosition,
    this.isWinner,
    required this.game,
    this.squareIndex = 0,
  });

  GameState copyWith({
    List<SquarePosition>? squarePosition,
    List<List<String>>? game,
    bool? isWinner,
    int? squareIndex,
  }) =>
      GameState(
        squarePosition: squarePosition ?? this.squarePosition,
        isWinner: isWinner ?? this.isWinner,
        game: game ?? this.game,
        squareIndex: squareIndex ?? this.squareIndex,
      );

  @override
  List<Object?> get props => ['game'];
}

class SquarePosition extends Equatable {
  final int rowNumber;
  final int columnNumber;
  final int cost;

  const SquarePosition({
    required this.rowNumber,
    required this.columnNumber,
    this.cost=1,
  });

  SquarePosition copyWith({
    int? rowNumber,
    int? columnNumber,
    int? cost,
  }) =>
      SquarePosition(
        rowNumber: rowNumber ?? this.rowNumber,
        columnNumber: columnNumber ?? this.columnNumber,
        cost: cost ?? this.cost,
      );

  @override
  List<Object?> get props => [
        rowNumber,
        columnNumber,
      ];
}
