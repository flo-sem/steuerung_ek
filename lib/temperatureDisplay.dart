import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state_manager.dart';
import 'main.dart';
import 'dart:async';

class TemperatureDisplay extends StatefulWidget {
  const TemperatureDisplay({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _TemperatureDisplayState();
}

class _TemperatureDisplayState extends State<TemperatureDisplay> {
  Timer? updateTimer;
  @override
  void initState()
  {
    super.initState();
    updateTimer = Timer.periodic(Duration(seconds: 1), (updateTimer) {
      var stateManager = Provider.of<StateManager>(context, listen:false);
      stateManager.setTemperature(MyAppState().getTemperature());
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
    return Consumer<StateManager>(builder: (context, stateManager, child) {
      return Text('${stateManager.temperature}°C',
          style: Theme.of(context).textTheme.headlineSmall
      );
    });
  }
}
