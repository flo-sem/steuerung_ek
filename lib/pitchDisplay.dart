import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state_manager.dart';
import 'main.dart';
import 'dart:async';

class PitchDisplay extends StatefulWidget {
  const PitchDisplay({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _PitchDisplayState();
}

class _PitchDisplayState extends State<PitchDisplay> {
  Timer? updateTimer;
  @override
  void initState()
  {
    super.initState();
    var stateManager = Provider.of<StateManager>(context, listen:false);
    updateTimer = Timer.periodic(Duration(milliseconds: stateManager.receiveIntervalSlow), (updateTimer) {
      var stateManager = Provider.of<StateManager>(context, listen:false);
      stateManager.setPitch(MyAppState().getPitch());
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
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
    return Consumer<StateManager>(builder: (context, stateManager, child) {
      return Text(
        'p - ${stateManager.pitch}%',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: currentBrightness == Brightness.dark ? stateManager.darkTextColor : stateManager.textColor,
        ),
      );
    });
  }
}
