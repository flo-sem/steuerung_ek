import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state_manager.dart';
import 'main.dart';
import 'dart:async';

// Ein StatefulWidget, das die Geschwindigkeitsanzeige darstellt
class SpeedDisplay extends StatefulWidget {
  const SpeedDisplay({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SpeedDisplayState();
}

// Der Zustand des SpeedDisplay-Widgets
class _SpeedDisplayState extends State<SpeedDisplay> {
  @override
  Widget build(BuildContext context) {
    // Ermittelt, ob der Dark Mode aktiviert ist
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
    var stateWatch = Provider.of<MyAppState>(context); // Beobachtet den Zustand der App
    
    return Consumer<StateManager>(builder: (context, stateManager, child) {
      return Text(
        '${stateManager.speed} km/h', // Zeigt die aktuelle Geschwindigkeit in km/h an
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
          // Setzt die Textfarbe basierend auf dem aktuellen Modus (hell oder dunkel)
          color: currentBrightness == Brightness.dark 
              ? stateManager.darkTextColor 
              : stateManager.textColor,
        ),
      );
    });
  }
}
