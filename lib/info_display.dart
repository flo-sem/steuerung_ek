import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state_manager.dart';

class Display extends StatefulWidget {
  const Display({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _DisplayState();
}

class _DisplayState extends State<Display> {
  @override
  Widget build(BuildContext context) {
    var stateBluetooth = Provider.of<StateBluetooth>(context);
    var stateManager = Provider.of<StateManager>(context);
    return Stack(
      children: [
        Align(
            child: Text('${stateBluetooth.testBuffer.toString()} km/h',
                style: Theme.of(context).textTheme.headlineSmall)),
      ],
    );
  }
}
