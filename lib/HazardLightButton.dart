import 'package:flutter/material.dart';
import 'package:steuerung_ek/ek_icons.dart';
import 'package:steuerung_ek/state_manager.dart';
import 'package:provider/provider.dart';
import 'dart:async';

// Ein StatefulWidget, das den Warnblinklicht-Knopf darstellt
class HazardLightButton extends StatefulWidget {
  const HazardLightButton({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HazardLightButtonState();
}

// Der Zustand des HazardLightButton-Widgets
class _HazardLightButtonState extends State<HazardLightButton> {
  int blink_tact = 0;
  Timer? timer2;

  @override
  void initState() {
    super.initState();
    // Timer, der alle 500 Millisekunden den Blink-Takt umschaltet
    timer2 = Timer.periodic(
      Duration(milliseconds: 500), (timer2) {
        var stateManager = Provider.of<StateManager>(context, listen: false);
        stateManager.toggleBlinkTact();
      }
    );
  }

  @override
  void dispose() {
    timer2?.cancel(); // Beendet den Timer, wenn das Widget entfernt wird
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StateManager>(
      builder: (context, stateManager, child) {
        // Ermittelt, ob der Dark Mode aktiviert ist
        Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
        return GestureDetector(
          // Gestenerkennung für das Drücken und Loslassen des Warnblinklicht-Knopfs
          onTapDown: (_) => stateManager.toggleBothBlinkerState(), // Schaltet beide Blinker ein
          onTapUp: (_) => stateManager.resetHazardLightButton(), // Setzt den Zustand des Warnblinklicht-Knopfs zurück
          child: Transform.scale(
            // Verändert die Skalierung des Icons basierend auf dem Zustand des Knopfs
            scale: 1 - (0.2 * stateManager.hazardLightButton),
            child: Icon(EK_Icons.hazardsign,
              size: 60,
              color: currentBrightness == Brightness.dark
                  ? stateManager.darkAppbarColor // Farbe im Dunkelmodus
                  : stateManager.appbarColor // Farbe im Hellmodus
            )
          )
        );
      }
    );
  }
}
