import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state_manager.dart';

class BatteryDisplay extends StatefulWidget {
  const BatteryDisplay({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _BatteryDisplayState();
}

class _BatteryDisplayState extends State<BatteryDisplay> {

  @override
  Widget build(BuildContext context) {
    return Consumer<StateManager>(
        builder: (context, stateManager, child) {
          return Image.asset(stateManager.batteryImage, width: 70);
        });
  }
}