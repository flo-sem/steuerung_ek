import 'package:flutter/material.dart';
import 'package:steuerung_ek/state_manager.dart';
import 'package:provider/provider.dart';
import 'package:steuerung_ek/ek_icons.dart';

// Ein StatefulWidget, das das Gaspedal darstellt
class GasPedal extends StatefulWidget {
  const GasPedal({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GasPedalState();
}

// Der Zustand des GasPedal-Widgets
class _GasPedalState extends State<GasPedal> {
  @override
  Widget build(BuildContext context) {
    //ermittelt den darkmode
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;

    return Consumer<StateManager>(
      builder: (context, stateManager, child) {
        // Stack-Widget, um mehrere Kinder übereinander zu legen
        return Stack(
          children: <Widget> [
            Align(
              // Align-Widget, um das Gaspedal innerhalb des Containers zu zentrieren
              child: SizedBox(
                height: 240,
                width: 130,
                child: Center(
                  child: GestureDetector(
                    // Gestenerkennung für das Drücken und Loslassen des Gaspedals
                    onTapDown: (_) => stateManager.setPedalState(100), // Gaspedal gedrückt
                    onTapUp: (_) => stateManager.setPedalState(0), // Gaspedal losgelassen
                    child: Transform(
                      // Transform-Widget zur Rotation des Icons basierend auf dem Pedalzustand
                      transform: Matrix4.rotationX(0.003 * stateManager.pedalState),
                      child: Icon(EK_Icons.pedal_accelerator,
                          size: 150,
                          color: currentBrightness == Brightness.dark
                              ? stateManager.darkIconColor // Farbe im Dunkelmodus
                              : stateManager.iconColor // Farbe im Hellmodus
                      )
                    )
                  )
                )
              )
            )
          ],
        );
      }
    );
  }
}
