import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mine_sweeper/location.dart';

const Image hidden = Image(fit: BoxFit.fill, image: AssetImage('assets/hidden.png'), filterQuality: FilterQuality.none);
const Image mined = Image(fit: BoxFit.fill, image: AssetImage('assets/mine.png'), filterQuality: FilterQuality.none);
const Image flagged = Image(fit: BoxFit.fill, image: AssetImage('assets/flag.png'), filterQuality: FilterQuality.none);
const List<Image> clearedCells = [
  Image(fit: BoxFit.fill, image: AssetImage("assets/0.png"), filterQuality: FilterQuality.none),
  Image(fit: BoxFit.fill, image: AssetImage("assets/1.png"), filterQuality: FilterQuality.none),
  Image(fit: BoxFit.fill, image: AssetImage("assets/2.png"), filterQuality: FilterQuality.none),
  Image(fit: BoxFit.fill, image: AssetImage("assets/3.png"), filterQuality: FilterQuality.none),
  Image(fit: BoxFit.fill, image: AssetImage("assets/4.png"), filterQuality: FilterQuality.none),
  Image(fit: BoxFit.fill, image: AssetImage("assets/5.png"), filterQuality: FilterQuality.none),
  Image(fit: BoxFit.fill, image: AssetImage("assets/6.png"), filterQuality: FilterQuality.none),
  Image(fit: BoxFit.fill, image: AssetImage("assets/7.png"), filterQuality: FilterQuality.none),
  Image(fit: BoxFit.fill, image: AssetImage("assets/8.png"), filterQuality: FilterQuality.none),
];

class Cell extends StatefulWidget {
  final bool isMined;
  final int numMinedNeighbors;
  final StreamController<Location> gameStateController;
  final StreamController<int> numRemainingStreamController;
  late final _CellController _controller;
  final List<Location> neighborLocations;
  final Location cellLocation;

  void open() => _controller.open();
  void flag() => _controller.flag();
  bool isOpen() => _controller.isOpen;

  Cell({
    Key? key,
    required this.isMined,
    required this.numMinedNeighbors,
    required this.gameStateController,
    required this.numRemainingStreamController,
    required this.neighborLocations,
    required this.cellLocation,
  }) : super(key: key) {
    _controller = _CellController(
      isMined: isMined,
      numMinedNeighbors: numMinedNeighbors,
      gameStateController: gameStateController,
      numRemainingStreamController: numRemainingStreamController,
      cellLocation: cellLocation,
    );
  }

  void dispose() {
    numRemainingStreamController.close();
  }

  @override
  State<Cell> createState() => _CellState();
}

class _CellState extends State<Cell> {
  @override
  void initState() {
    if (!mounted) return;
    widget._controller.addListener(() => {if (mounted) setState(() {})});

    if (!mounted) return;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => {widget._controller.open()},
      onLongPress: () => {if (!widget.isOpen()) widget.flag()},
      onDoubleTap: () => {},
      child: Container(
        color: Colors.grey,
        child: widget._controller.image,
      ),
    );
  }
}

class _CellController extends ChangeNotifier {
  final bool isMined;
  final int numMinedNeighbors;
  final StreamController<Location> gameStateController;
  final StreamController<int> numRemainingStreamController;
  final Location cellLocation;

  bool isOpen = false;
  Image image = hidden;
  int lastClicked = 0;

  _CellController({
    required this.isMined,
    required this.numMinedNeighbors,
    required this.gameStateController,
    required this.numRemainingStreamController,
    required this.cellLocation,
  });

  void open() {
    if (image == flagged) return unFlagCell();
    if (image != hidden) return;

    isOpen = true;
    image = isMined ? mined : clearedCells[numMinedNeighbors];

    gameStateController.add(cellLocation);

    notifyListeners();
  }

  void flag() {
    if (image == hidden) {
      flagCell();
    } else if (image == flagged) {
      unFlagCell();
    }
  }

  void unFlagCell() {
    image = hidden;
    numRemainingStreamController.add(1);

    notifyListeners();
  }

  void flagCell() {
    image = flagged;
    numRemainingStreamController.add(-1);

    notifyListeners();
  }
}
