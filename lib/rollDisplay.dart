import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state_manager.dart';
import 'main.dart';
import 'dart:async';

// Ein StatefulWidget, das die Roll-Anzeige darstellt
class RollDisplay extends StatefulWidget {
  const RollDisplay({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RollDisplayState();
}

// Der Zustand des RollDisplay-Widgets
class _RollDisplayState extends State<RollDisplay> {
  @override
  Widget build(BuildContext context) {
    // Ermittelt, ob der Dark Mode aktiviert ist
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
    
    return Consumer<StateManager>(builder: (context, stateManager, child) {
      return Text(
        'r - ${stateManager.roll}%', // Zeigt die aktuelle Roll-Lage in Prozent an
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
