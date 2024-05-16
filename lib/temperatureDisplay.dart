import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state_manager.dart';
import 'main.dart';
import 'dart:async';

// Ein StatefulWidget, das die Temperaturanzeige darstellt
class TemperatureDisplay extends StatefulWidget {
  const TemperatureDisplay({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TemperatureDisplayState();
}

// Der Zustand des TemperatureDisplay-Widgets
class _TemperatureDisplayState extends State<TemperatureDisplay> {
  @override
  Widget build(BuildContext context) {
    // Ermittelt, ob der Dark Mode aktiviert ist
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
    
    return Consumer<StateManager>(builder: (context, stateManager, child) {
      return Text(
        '${stateManager.temperature}°C', // Zeigt die aktuelle Temperatur in Celsius an
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          // Setzt die Textfarbe basierend auf dem aktuellen Modus (hell oder dunkel)
          color: currentBrightness == Brightness.dark 
              ? stateManager.darkTextColor 
              : stateManager.textColor,
        ),
      );
    });
  }
}
