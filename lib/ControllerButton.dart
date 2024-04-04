import 'package:flutter/material.dart';
import 'package:steuerung_ek/state_manager.dart';
import 'package:provider/provider.dart';
import 'package:steuerung_ek/ControllerDisplay.dart';

class ControllerButton extends StatefulWidget {
  const ControllerButton({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _ControllerButtonState();
}

class _ControllerButtonState extends State<ControllerButton> {
  @override
  Widget build(BuildContext context) {
    return Consumer<StateManager>(
        builder: (context, stateManager, child) {
          return GestureDetector(
              onTapDown: (_) => onPressed(),
              onTapUp: (_) => stateManager.resetControllerButtonState(),
              child: Transform.scale(
                  scale: 1 - (0.2 * stateManager.controllerButtonState),
                  child: Image.asset(
                      'assets/images/controllerButton.png', width: 70)
              )
          );
        }
    );
  }

  void onPressed() {
    var stateManager = Provider.of<StateManager>(context, listen: false);
    stateManager.toggleControllerConnectionState();
    if(stateManager.controllerConnectionState == 1) {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ControllerDisplay()));
    }
    else {
      Navigator.of(context).pop();
    }
  }
}