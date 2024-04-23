import 'package:flutter/material.dart';
import 'package:steuerung_ek/state_manager.dart';
import 'package:provider/provider.dart';
import 'package:steuerung_ek/ek_icons.dart';
import 'package:steuerung_ek/ControllerDisplay.dart';

class ControllerButton extends StatefulWidget {
  const ControllerButton({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _ControllerButtonState();
}

class _ControllerButtonState extends State<ControllerButton> {
  @override
  Widget build(BuildContext context) {
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
    return Consumer<StateManager>(builder: (context, stateManager, child) {
      return GestureDetector(
          onTapDown: (_) => onPressed(),
          onTapUp: (_) => stateManager.resetControllerButtonState(),
          child: Transform.scale(
            scale: 1 - (0.2 * stateManager.controllerButtonState),
            // child: Image.asset('assets/images/controllerButton.png', width: 70)
            child: Icon(EK_Icons.gamecontroller,
                size: 70,
                color: currentBrightness == Brightness.dark
                    ? stateManager.darkIconColor
                    : stateManager.iconColor),
          ));
    });
  }

  void onPressed() {
    var stateManager = Provider.of<StateManager>(context, listen: false);
    stateManager.toggleControllerConnectionState();
    if (stateManager.controllerConnectionState == 1) {
      stateManager.usingController = 1;
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => ControllerDisplay()));
    } else {
      stateManager.usingController = 0;
      Navigator.of(context).pop();
    }
  }
}
