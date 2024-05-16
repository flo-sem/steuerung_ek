import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state_manager.dart';
import 'main.dart';
import 'dart:async';

// Ein StatefulWidget, das die Neigungsanzeige darstellt
class PitchDisplay extends StatefulWidget {
  const PitchDisplay({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PitchDisplayState();
}

// Der Zustand des PitchDisplay-Widgets
class _PitchDisplayState extends State<PitchDisplay> {
  @override
  Widget build(BuildContext context) {
    // Ermittelt, ob der Dark Mode aktiviert ist
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
    
    return Consumer<StateManager>(builder: (context, stateManager, child) {
      return Text(
        'p - ${stateManager.pitch}%', // Zeigt die aktuelle Neigung in Prozent an
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
