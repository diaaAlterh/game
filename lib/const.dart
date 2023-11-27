import 'game_state.dart';

List<List<String>> game = [
  ['empty', 'level1', 'level2', 'empty', 'level1', 'level1', 'empty'],
  ['level2', 'level2', 'level2', 'level1', 'level2', 'level2', 'level1'],
  ['level1', 'level2', 'level2', 'empty', 'level2', 'level2', 'level1'],
  ['empty', 'empty', 'level2', 'level3', 'level2', 'empty', 'empty'],
];

SquarePosition squarePosition = const SquarePosition(
  rowNumber: 2,
  columnNumber: 4,
);

/////////////////////////////////////////////////////////////////////////////
List<List<String>> game1 = [
  ['level2', 'level3', 'level1', 'level1', 'level2'],
  ['level2', 'level2', 'level2', 'level2', 'level2'],
];
SquarePosition squarePosition1 = const SquarePosition(
  rowNumber: 1,
  columnNumber: 3,
);

/////////////////////////////////////////////////////////////////////////////
