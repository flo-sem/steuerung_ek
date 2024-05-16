import 'package:flutter/material.dart';
import 'package:steuerung_ek/state_manager.dart';
import 'package:provider/provider.dart';
import 'package:steuerung_ek/ek_icons.dart';

// Ein StatefulWidget, das den rechten Blinker darstellt
class BlinkerRight extends StatefulWidget {
  const BlinkerRight({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BlinkerRightState();
}

// Der Zustand des BlinkerRight-Widgets
class _BlinkerRightState extends State<BlinkerRight> {
  @override
  Widget build(BuildContext context) {
    // Ermittelt die aktuelle Bildschirmhelligkeit (hell oder dunkel)
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;

    return Consumer<StateManager>(
        builder: (context, stateManager, child) {
          // Erzeugt einen berührungsempfindlichen Bereich (für den Blinker)
          return GestureDetector(
            onTapDown: (_) => stateManager.toggleBlinkerRightState(), // Wechselt den Zustand des rechten Blinkers
            child: Transform.scale(
                // Verändert die Skalierung des Icons basierend auf dem Blink-Takt und Zustand
                scale: 1 - (0.2 * stateManager.blinkTact * stateManager.blinkerRightState),
                child: Icon(EK_Icons.arrowshape_right_fill,
                    size: 50,
                    color: currentBrightness == Brightness.dark 
                      ? stateManager.darkIconColor 
                      : stateManager.iconColor
                ),
            )
          );
        }
    );
  }
}
