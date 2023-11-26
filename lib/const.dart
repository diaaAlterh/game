import 'game_state.dart';

/////////////////////////////////////////////////////////////////////////////
List<List<String>> game1 = [
  ['level2', 'level3', 'level1', 'level1', 'level2'],
  ['level2', 'level2', 'level2', 'level2', 'level2'],
];
SquarePosition squarePosition1 = const SquarePosition(
  rowNumber: 1,
  columnNumber: 3,
  cost: 2
);

/////////////////////////////////////////////////////////////////////////////
List<List<String>> game2 = [
  ['empty', 'level1', 'level2', 'empty', 'level1', 'level1', 'empty'],
  ['level2', 'level2', 'level2', 'level1', 'level2', 'level2', 'level1'],
  ['level1', 'level2', 'level2', 'empty', 'level2', 'level2', 'level1'],
  ['empty', 'empty', 'level2', 'level3', 'level2', 'empty', 'empty'],
];
SquarePosition squarePosition2 = const SquarePosition(
  rowNumber: 2,
  columnNumber: 4,
  cost: 3
);

//////////////////////////////////////////////////////////////////////////////