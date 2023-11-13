import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state_manager.dart';

class Display_battery extends StatefulWidget {
  const Display_battery({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _DisplayState();
}

class _DisplayState extends State<Display_battery> {

  @override
  Widget build(BuildContext context) {
    return Consumer<StateManager>(
        builder: (context, stateManager, child) {
          return Align(
            child:   Image.asset(stateManager.batteryImage, width: 80)
          ,
          );
          /*
          return Stack(
            children: [
              Image.asset(stateManager.batteryImage, width: 80),
            ],
          );

           */
        });
  }
}