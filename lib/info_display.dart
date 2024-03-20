import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state_manager.dart';
import 'main.dart';

class Display extends StatefulWidget {
  const Display({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _DisplayState();
}

class _DisplayState extends State<Display> {
  @override
  Widget build(BuildContext context) {
    var stateWatch = Provider.of<MyAppState>(context);
    return Consumer<StateManager>(builder: (context, stateManager, child) {
      return Column(
        children: [
          Text('${stateWatch.SpeedBuffer.toString()} km/h',
              style: Theme.of(context).textTheme.headlineSmall),
          Text('${stateWatch.Test1Buffer.toString()} t1',
              style: Theme.of(context).textTheme.headlineSmall),
          Text('${stateWatch.Test2Buffer.toString()} t2',
              style: Theme.of(context).textTheme.headlineSmall),
        ],
      );
    });
  }
}
