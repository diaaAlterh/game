import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game/game_state.dart';
import 'package:game/logic_steps.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
            logicSteps.moveForward(Move.up),
        const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
            logicSteps.moveForward(Move.down),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            logicSteps.moveForward(Move.left),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            logicSteps.moveForward(Move.right),
        const SingleActivator(LogicalKeyboardKey.delete): () =>
            logicSteps.moveBack(),
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF915EB8),
        body: Focus(
          autofocus: true,
          child: StreamBuilder<GameState>(
              stream: logicSteps.gameStream,
              builder: (context, snapshot) {
                final gameState = snapshot.data;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(
                    gameState?.game.length ?? 0,
                    (rowIndex) => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        gameState?.game[rowIndex].length ?? 0,
                        (columnIndex) {
                          final isSelected = gameState?.squarePosition ==
                              SquarePosition(
                                rowNumber: rowIndex + 1,
                                columnNumber: columnIndex + 1,
                              );
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.transparent,
                                  ),
                                  borderRadius: BorderRadius.circular(4)),
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                map[gameState?.game[rowIndex][columnIndex] ??
                                        ''] ??
                                    '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 25),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}
