import 'package:flutter/material.dart';
import 'package:steuerung_ek/state_manager.dart';
import 'package:provider/provider.dart';
import 'package:steuerung_ek/ek_icons.dart';

// Ein StatefulWidget, das den linken Blinker darstellt
class BlinkerLeft extends StatefulWidget {
  const BlinkerLeft({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BlinkerLeftState();
}

// Der Zustand des BlinkerLeft-Widgets
class _BlinkerLeftState extends State<BlinkerLeft> {
  @override
  Widget build(BuildContext context) {
    // Ermittelt die aktuelle Bildschirmhelligkeit (hell oder dunkel)
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;

    return Consumer<StateManager>(
        builder: (context, stateManager, child) {
          // Erzeugt einen berührungsempfindlichen Bereich (für den Blinker)
          return GestureDetector(
            onTapDown: (_) => stateManager.toggleBlinkerLeftState(), // Wechselt den Zustand des linken Blinkers
            child: Transform.scale(
              // Verändert die Skalierung des Icons basierend auf dem Blink-Takt und Zustand
              scale: 1 - (0.2 * stateManager.blinkTact * stateManager.blinkerLeftState),
              child: Icon(EK_Icons.arrowshape_left_fill,
                  size: 50,
                  color: currentBrightness == Brightness.dark 
                    ? stateManager.darkIconColor 
                    : stateManager.iconColor
              ),
            ),
          );
        }
    );
  }
}
