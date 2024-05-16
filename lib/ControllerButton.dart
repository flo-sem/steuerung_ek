import 'package:flutter/material.dart';
import 'package:steuerung_ek/state_manager.dart';
import 'package:provider/provider.dart';
import 'package:steuerung_ek/ek_icons.dart';
import 'package:steuerung_ek/ControllerDisplay.dart';

// Ein StatefulWidget, das den Controller-Button darstellt
class ControllerButton extends StatefulWidget {
  const ControllerButton({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ControllerButtonState();
}

// Der Zustand des ControllerButton-Widgets
class _ControllerButtonState extends State<ControllerButton> {
  @override
  Widget build(BuildContext context) {
    // Ermittelt die aktuelle Bildschirmhelligkeit (hell oder dunkel)
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;

    return Consumer<StateManager>(builder: (context, stateManager, child) {
      // Erzeugt einen berührungsempfindlichen Bereich (für den Controller-Button)
      return GestureDetector(
          onTapDown: (_) => onPressed(), // Reaktion auf Druck
          onTapUp: (_) => stateManager.resetControllerButtonState(), // Reaktion auf Loslassen
          child: Transform.scale(
            // Verändert die Skalierung des Icons basierend auf dem Zustand
            scale: 1 - (0.2 * stateManager.controllerButtonState),
            child: Icon(EK_Icons.gamecontroller,
                size: 70,
                color: currentBrightness == Brightness.dark
                    ? stateManager.darkIconColor
                    : stateManager.iconColor),
          ));
    });
  }

  // Methode, die beim Drücken des Buttons ausgeführt wird
  void onPressed() {
    var stateManager = Provider.of<StateManager>(context, listen: false);
    stateManager.toggleControllerConnectionState();
    if (stateManager.controllerConnectionState == 1) {
      stateManager.usingController = 1;
      print('[CONTROLLER] Controller Enabled');
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => ControllerDisplay()));
    } else {
      stateManager.usingController = 0;
      print('[CONTROLLER] Controller Disabled');
      Navigator.of(context).pop();
    }
  }
}
