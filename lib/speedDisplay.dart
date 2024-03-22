import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state_manager.dart';

class SpeedDisplay extends StatefulWidget {
  const SpeedDisplay({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SpeedDisplayState();
}

class _SpeedDisplayState extends State<SpeedDisplay> {
  @override
  Widget build(BuildContext context) {
    //var bluetoothValues = Provider.of<MyAppState>(context); noch benötigt??
    return Consumer<StateManager>(builder: (context, stateManager, child) {
      return Text('${stateManager.speed} km/h',
                  style: Theme.of(context).textTheme.headlineSmall
      );
    });
  }
}
