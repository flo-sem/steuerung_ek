import 'package:flutter/material.dart';
import 'package:steuerung_ek/state_manager.dart';
import 'package:provider/provider.dart';
import 'package:steuerung_ek/ek_icons.dart';

// Ein StatefulWidget, das die Hupe darstellt
class Horn extends StatefulWidget {
  const Horn({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HornState();
}

// Der Zustand des Horn-Widgets
class _HornState extends State<Horn> {
  @override
  Widget build(BuildContext context) {
    // Ermittelt, ob der Dark Mode aktiviert ist
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
    
    return Consumer<StateManager>(
        builder: (context, stateManager, child) {
          return GestureDetector(
              // Gestenerkennung für das Drücken und Loslassen der Hupe
              onTapDown: (_) => stateManager.setHornState(1), // Hupe gedrückt
              onTapUp: (_) => stateManager.setHornState(0), // Hupe losgelassen
              child: Transform.scale(
                // Verändert die Skalierung des Icons basierend auf dem Zustand der Hupe
                scale: 1 - (0.2 * stateManager.hornState),
                child: Icon(EK_Icons.horn,
                    size: 60,
                    color: currentBrightness == Brightness.dark 
                      ? stateManager.darkIconColor // Farbe im Dunkelmodus
                      : stateManager.iconColor // Farbe im Hellmodus
                )
              )
          );
        }
    );
  }
}
