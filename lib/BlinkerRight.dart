import 'package:flutter/material.dart';
import 'package:steuerung_ek/state_manager.dart';
import 'package:provider/provider.dart';
import 'package:steuerung_ek/ek_icons.dart';

class BlinkerRight extends StatefulWidget {
  const BlinkerRight({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _BlinkerRightState();
}

class _BlinkerRightState extends State<BlinkerRight> {
  @override
  Widget build(BuildContext context) {
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
    return Consumer<StateManager>(
        builder: (context, stateManager, child) {
          return GestureDetector(
            onTapDown: (_) => stateManager.toggleBlinkerRightState(),
            child: Transform.scale(
                scale: 1 - (0.2*stateManager.blinkTact*stateManager.blinkerRightState),
                //child: Image.asset('assets/images/blinkerRight.png', width:50)
              child: Icon(EK_Icons.arrowshape_right_fill,
                  size: 50,
                  color: currentBrightness == Brightness.dark ? stateManager.darkIconColor : stateManager.iconColor
              ),
            )
          );
        }
    );
  }
}