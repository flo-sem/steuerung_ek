import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state_manager.dart';
import 'main.dart';
import 'dart:async';

class SpeedDisplay extends StatefulWidget {
  const SpeedDisplay({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SpeedDisplayState();
}

class _SpeedDisplayState extends State<SpeedDisplay> {
  Timer? updateTimer;
  @override
  void initState() {
    super.initState();
    var stateManager = Provider.of<StateManager>(context, listen: false);
    updateTimer =
        Timer.periodic(Duration(milliseconds: stateManager.receiveIntervalFast),
            (updateTimer) {
      var stateManager = Provider.of<StateManager>(context, listen: false);
      stateManager.setSpeed(MyAppState().getSpeed());
    });
  }

  @override
  void dispose() {
    super.dispose();
    updateTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
    var stateWatch = Provider.of<MyAppState>(context);
    return Consumer<StateManager>(builder: (context, stateManager, child) {
      return Text(
        '${stateManager.speed} km/h',
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: currentBrightness == Brightness.dark
                  ? stateManager.darkTextColor
                  : stateManager.textColor,
            ),
      );
    });
  }
}
