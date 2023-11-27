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
