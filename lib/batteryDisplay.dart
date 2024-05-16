import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state_manager.dart';
import 'main.dart';
import 'dart:async';

// Ein StatefulWidget, das die Batterieanzeige darstellt
class BatteryDisplay extends StatefulWidget {
  const BatteryDisplay({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BatteryDisplayState();
}

// Der Zustand des BatteryDisplay-Widgets
class _BatteryDisplayState extends State<BatteryDisplay> {
  @override
  Widget build(BuildContext context) {
    // Ermittelt die aktuelle Bildschirmhelligkeit (hell oder dunkel)
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;

    return Consumer<StateManager>(builder: (context, stateManager, child) {
      // Zeigt ein Batterie-Icon an, dessen Farbe je nach Bildschirmhelligkeit variiert
      return Icon(stateManager.batteryIcon,
          size: 30,
          color: currentBrightness == Brightness.dark
              ? stateManager.darkIconColor
              : stateManager.iconColor);
    });
  }
}
