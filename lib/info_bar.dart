import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class InfoBar extends StatefulWidget implements PreferredSizeWidget {
  final Stream numRemainingStream;
  final int numMines;

  InfoBar({required this.numRemainingStream, required this.numMines});

  @override
  State<InfoBar> createState() => _InfoBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _InfoBarState extends State<InfoBar> {
  late final StreamSubscription<int> numRemainingSubscription;
  late final StopWatchTimer _stopWatchTimer;

  int numMinesRemaining = 0;
  int time = 0;

  void _updateNumMinesRemaining(num delta) {
    if (-1 <= delta && delta <= 1) setState(() => numMinesRemaining += delta as int);
  }

  @override
  void initState() {
    _stopWatchTimer = StopWatchTimer();
    _stopWatchTimer.onStartTimer();
    _stopWatchTimer.secondTime.listen((value) => setState(() => time = value));

    numMinesRemaining = widget.numMines;

    numRemainingSubscription =
        widget.numRemainingStream.listen((delta) => _updateNumMinesRemaining(delta)) as StreamSubscription<int>;

    super.initState();
  }

  @override
  void dispose() async {
    numRemainingSubscription.cancel();
    super.dispose();
    await _stopWatchTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text("TIME: $time"),
          Text("MINES: $numMinesRemaining"),
        ],
      ),
      //
      backgroundColor: Colors.grey.shade600,
      foregroundColor: Colors.white,
    );
  }
}
