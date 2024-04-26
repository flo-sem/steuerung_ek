import 'package:flutter/material.dart';
import 'package:steuerung_ek/state_manager.dart';
import 'package:provider/provider.dart';
import 'package:steuerung_ek/ek_icons.dart';

class BlinkerLeft extends StatefulWidget {
  const BlinkerLeft({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _BlinkerLeftState();
}

class _BlinkerLeftState extends State<BlinkerLeft> {
  @override
  Widget build(BuildContext context) {
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
    return Consumer<StateManager>(
        builder: (context, stateManager, child) {
          return GestureDetector(
            onTapDown: (_) => stateManager.toggleBlinkerLeftState(),
            child: Transform.scale(
              scale: 1 - (0.2*stateManager.blinkTact*stateManager.blinkerLeftState),
              //child: Image.asset('assets/images/blinkerLeft.png', width: 50)
              child: Icon(EK_Icons.arrowshape_left_fill,
                  size: 50,
                  color: currentBrightness == Brightness.dark ? stateManager.darkIconColor : stateManager.iconColor
              ),
            )
          );
        }
    );
  }
}