import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state_manager.dart';

class PitchDisplay extends StatefulWidget {
  const PitchDisplay({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _PitchDisplayState();
}

class _PitchDisplayState extends State<PitchDisplay> {
  @override
  Widget build(BuildContext context) {
    return Consumer<StateManager>(builder: (context, stateManager, child) {
      return Text('${stateManager.pitch}%',
          style: Theme.of(context).textTheme.headlineSmall
      );
    });
  }
}
