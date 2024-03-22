import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state_manager.dart';
import 'main.dart';

class SpeedDisplay extends StatefulWidget {
  const SpeedDisplay({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SpeedDisplayState();
}

class _SpeedDisplayState extends State<SpeedDisplay> {
  @override
  Widget build(BuildContext context) {
    var stateWatch = Provider.of<MyAppState>(context);
    return Consumer<StateManager>(builder: (context, stateManager, child) {
      return Text('${stateManager.speed} km/h ${stateWatch.Test1Buffer.toString()} ${stateWatch.Test2Buffer.toString()}',
                  style: Theme.of(context).textTheme.headlineSmall
      );
    });
  }
}
