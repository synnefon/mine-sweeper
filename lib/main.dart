import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mine_sweeper/game_board.dart';
import 'package:mine_sweeper/info_bar.dart';
// import 'package:shared_preferences/shared_preferences.dart';

enum CellState { unopened, opened, bomb }

const int height = 20;
const int width = 14;
const int numMines = (14 * 20) - 9;

void main() {
  // SharedPreferences.setMockInitialValues({});

  runApp(MinesweeperApp());
}

class MinesweeperApp extends StatefulWidget {
  const MinesweeperApp({super.key});

  @override
  State<MinesweeperApp> createState() => _MinesweeperAppState();
}

class _MinesweeperAppState extends State<MinesweeperApp> {
  late InfoBar infoBar;
  late GameBoard board;
  late StreamController<int> numRemainingStreamController;
  late Stream numRemainingStream;

  @override
  void initState() {
    numRemainingStreamController = StreamController<int>.broadcast();
    numRemainingStream = numRemainingStreamController.stream;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mine Sweeper',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade600,
      ),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: PointerDeviceKind.values.toSet(),
      ),
      home: Scaffold(
        appBar: InfoBar(numRemainingStream: numRemainingStream, numMines: numMines),
        body: GameBoard(
          height: height,
          width: width,
          numMines: numMines,
          numRemainingStreamController: numRemainingStreamController,
        ),
      ),
    );
  }
}
