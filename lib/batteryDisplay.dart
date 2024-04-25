import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state_manager.dart';
import 'main.dart';
import 'dart:async';

class BatteryDisplay extends StatefulWidget {
  const BatteryDisplay({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _BatteryDisplayState();
}

class _BatteryDisplayState extends State<BatteryDisplay> {
  Timer? updateTimer;
  @override
  void initState() {
    super.initState();
    var stateManager = Provider.of<StateManager>(context, listen: false);
    updateTimer =
        Timer.periodic(Duration(milliseconds: stateManager.receiveIntervalSlow),
            (updateTimer) {
      var stateManager = Provider.of<StateManager>(context, listen: false);
      stateManager.setBatteryChargingState(MyAppState().getBatteryState());
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
    return Consumer<StateManager>(builder: (context, stateManager, child) {
      return Icon(stateManager.batteryIcon,
          size: 30,
          color: currentBrightness == Brightness.dark
              ? stateManager.darkIconColor
              : stateManager.iconColor);
    });
  }
}
