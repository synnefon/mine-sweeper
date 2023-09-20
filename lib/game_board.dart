import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mine_sweeper/cell.dart';
import 'package:mine_sweeper/game_over_controller.dart';
import 'package:mine_sweeper/location.dart';
import 'package:mine_sweeper/main.dart';
import 'package:mine_sweeper/two_dimensional_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameBoard extends StatefulWidget {
  final int height;
  final int width;
  final int numMines;
  final StreamController<int> numRemainingStreamController;

  GameBoard({
    required this.height,
    required this.width,
    required this.numMines,
    required this.numRemainingStreamController,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardController extends ChangeNotifier {
  int numCellsOpened = 0;
  int xIndex = 0;
  int yIndex = 0;

  void updateNumCellsOpened(int delta) {
    numCellsOpened += delta;
    notifyListeners();
  }
}

class _GameBoardState extends State<GameBoard> {
  late final List<Location> mineLocations;

  late final StreamController<Location> initGameController;
  late final StreamSubscription initGameSubscription;
  late final StreamController<Location> gameStateController;
  late final StreamSubscription gameStateSubscription;

  late final _GameBoardController _gameBoardController = _GameBoardController();
  // late final GameOverController _gameOverController = GameOverController();

  late final SharedPreferences db;

  GlobalKey menuKey = GlobalKey();

  late List<List<Cell>> board;

  @override
  Widget build(BuildContext context) {
    gameStateSubscription = gameStateController.stream.listen((location) => _handleOpenCell(context, location));

    return Container(
      margin: EdgeInsets.only(bottom: 35.0),
      child: TwoDimensionalGridView(
        delegate: TwoDimensionalChildBuilderDelegate(
          maxXIndex: widget.width - 1,
          maxYIndex: widget.height - 1,
          builder: (BuildContext context, ChildVicinity vicinity) {
            return board[vicinity.yIndex][vicinity.xIndex];
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    // _loadPersistentState();

    gameStateController = StreamController<Location>.broadcast();

    initGameController = StreamController<Location>.broadcast();
    initGameSubscription = initGameController.stream.listen((location) => _initBoard(initialLocation: location));

    board = List.generate(widget.height, (h) {
      return List.generate(widget.width, (w) {
        return Cell(
          key: UniqueKey(),
          isMined: false,
          numMinedNeighbors: 0,
          gameStateController: initGameController,
          numRemainingStreamController: StreamController<int>(),
          neighborLocations: [],
          cellLocation: Location(x: w, y: h),
        );
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    gameStateSubscription.cancel();
    initGameSubscription.cancel();
    super.dispose();
  }

  // void _loadPersistentState() async {
  //   db = await SharedPreferences.getInstance();
  //   db.setInt('counter', 10);
  // }

  void _initBoard({required Location initialLocation}) {
    final List<Location> initialLocations = _findNeighbors(initialLocation.x, initialLocation.y) + [initialLocation];

    final List<Location> randomizedLocations = List.generate(widget.height, (h) {
      return List.generate(widget.width, (w) => Location(x: w, y: h));
    }).expand((e) {
      return e;
    }).where((location) {
      return !initialLocations.any((il) => il == location);
    }).toList()
      ..shuffle();

    mineLocations = List.generate(widget.numMines, (idx) => randomizedLocations[idx]);

    setState(() {
      board = List.generate(widget.height, (h) {
        return List.generate(widget.width, (w) {
          List<Location> neighborLocations = _findNeighbors(w, h);
          Location cellLocation = Location(x: w, y: h);
          return Cell(
            key: UniqueKey(),
            isMined: locationIsMined(cellLocation),
            numMinedNeighbors: neighborLocations.where((location) => locationIsMined(location)).length,
            gameStateController: gameStateController,
            numRemainingStreamController: widget.numRemainingStreamController,
            neighborLocations: neighborLocations,
            cellLocation: cellLocation,
          );
        });
      });
    });

    _clearAdjoiningEmpties(initialLocation);
  }

  // Widget _displayGameOverPopup() {
  //   PopupMenu menu = PopupMenu(
  //     context: context,
  //     items: [
  //       MenuItem(title: 'Mail', image: Icon(Icons.mail, color: Colors.white)),
  //       MenuItem(title: 'Power', image: Icon(Icons.power, color: Colors.white)),
  //       MenuItem(title: 'Setting', image: Icon(Icons.settings, color: Colors.white)),
  //       MenuItem(title: 'PopupMenu', image: Icon(Icons.menu, color: Colors.white))
  //     ],
  //     onClickMenu: (menuProvider) => {},
  //     onDismiss: () => {},
  //   );
  //   menu.show(widgetKey: menuKey);
  //   return menu;
  // }

  void _explodeMine(BuildContext context) {
    print("here");
    // _gameOverController.showOverlay(context);
  }

  void _checkGameWon() {
    if (_gameBoardController.numCellsOpened >= (widget.height * widget.width) - numMines) print("game won!");
  }

  void _handleOpenCell(BuildContext context, Location location) {
    Cell cell = board[location.y][location.x];

    _gameBoardController.updateNumCellsOpened(1);

    if (cell.isMined) return _explodeMine(context);
    if (cell.numMinedNeighbors == 0) _clearAdjoiningEmpties(location);

    return _checkGameWon();
  }

  void _clearAdjoiningEmpties(Location location) async {
    final int x = location.x;
    final int y = location.y;

    board[y][x].open();
    if (!(board[y][x].numMinedNeighbors == 0)) return;

    var openedLocations = {};
    openedLocations[y] = {x: true};

    List<Location> connectingCells = [Location(x: x, y: y)];

    while (connectingCells.isNotEmpty) {
      var l = connectingCells.removeAt(0);

      Cell cell = board[l.y][l.x];
      cell.open();
      cell.open(); // do this twice in case the cell is flagged

      var connected = cell.neighborLocations
          .where((l) => locationIsEmpty(l))
          .where((l) => locationIsUnopened(l))
          .where((l) => openedLocations[l.y]?[l.x] == null);

      connectingCells.addAll(connected);

      for (Location c in connected) {
        openedLocations[c.y] = openedLocations[c.y] ?? {};
        openedLocations[c.y][c.x] = true;
      }

      var connectedNonEmpties = cell.neighborLocations
          .where((l) => locationIsConnectedEmpty(l))
          .where((l) => openedLocations[l.y]?[l.x] == null);

      for (Location c in connectedNonEmpties) {
        openedLocations[c.y] = openedLocations[c.y] ?? {};
        openedLocations[c.y][c.x] = true;
        board[c.y][c.x].open();
        board[c.y][c.x].open();
      }
    }
  }

  dynamic locationIsMined(Location location) => mineLocations.any((l) => l == location);
  dynamic locationIsEmpty(Location location) => board[location.y][location.x].numMinedNeighbors == 0;
  dynamic locationIsUnopened(Location location) => !(board[location.y][location.x].isOpen());
  dynamic locationIsConnectedEmpty(Location location) {
    Cell cell = board[location.y][location.x];
    return cell.neighborLocations.any((nl) => locationIsEmpty(nl));
  }

  List<Location> _findNeighbors(int x, int y) {
    var maxPossibleX = widget.width - 1;
    var maxPossibleY = widget.height - 1;

    var xPlus1 = min(x + 1, maxPossibleX);
    var xMinus1 = max(x - 1, 0);
    var yPlus1 = min(y + 1, maxPossibleY);
    var yMinus1 = max(y - 1, 0);

    var allNeighbors = _combinations([
      {x, xPlus1, xMinus1}.toList(),
      {y, yPlus1, yMinus1}.toList(),
    ]);

    return allNeighbors
        .where((neighbor) => neighbor[0] != x || neighbor[1] != y)
        .map((e) => Location(x: e[0], y: e[1]))
        .toList();
  }

  Iterable<List<T>> _combinations<T>(List<List<T>> lists, [int index = 0, List<T>? prefix]) sync* {
    prefix ??= <T>[];

    if (lists.length == index) {
      yield prefix.toList();
    } else {
      for (final value in lists[index]) {
        yield* _combinations(lists, index + 1, prefix..add(value));
        prefix.removeLast();
      }
    }
  }
}
