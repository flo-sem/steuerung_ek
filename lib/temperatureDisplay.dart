import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state_manager.dart';

class TemperatureDisplay extends StatefulWidget {
  const TemperatureDisplay({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _TemperatureDisplayState();
}

class _TemperatureDisplayState extends State<TemperatureDisplay> {
  @override
  Widget build(BuildContext context) {
    return Consumer<StateManager>(builder: (context, stateManager, child) {
      return Text('${stateManager.temperature}°C',
          style: Theme.of(context).textTheme.headlineSmall
      );
    });
  }
}
