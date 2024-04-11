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
    updateTimer = Timer.periodic(Duration(seconds: 1), (updateTimer) {
      var stateManager = Provider.of<StateManager>(context, listen: false);
      stateManager.setBatteryChargingState(MyAppState().getBatteryState());
    });
  }

  @override
  void dispose()
  {
    super.dispose();
    updateTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StateManager>(
        builder: (context, stateManager, child) {
          return Image.asset(stateManager.batteryImage, width: 70);
        });
  }
}