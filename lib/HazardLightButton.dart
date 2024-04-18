import 'package:flutter/material.dart';
import 'package:steuerung_ek/ek_icons.dart';
import 'package:steuerung_ek/state_manager.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class HazardLightButton extends StatefulWidget {
  const HazardLightButton({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _HazardLightButtonState();
}

class _HazardLightButtonState extends State<HazardLightButton> {
  int blink_tact = 0;
  Timer? timer2;

  @override
  void initState() {
    super.initState();
    timer2 = Timer.periodic(
      Duration(milliseconds: 500), (timer2) {
      var stateManager = Provider.of<StateManager>(context, listen:false);
      stateManager.toggleBlinkTact();
      }
    );
  }

  @override
  void dispose() async {
    timer2?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StateManager>(
        builder: (context, stateManager, child) {
          Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
          return GestureDetector(
            onTapDown: (_) => stateManager.toggleBothBlinkerState(),
            onTapUp: (_) => stateManager.resetHazardLightButton(),
            child: Transform.scale(
              scale: 1 - (0.2*stateManager.hazardLightButton),
              //child: Image.asset('assets/images/hazardLightButton.png', width: 60)
              child:  Icon(EK_Icons.hazardsign,
                size: 60,
                color: currentBrightness == Brightness.dark
                    ? stateManager.darkAppbarColor
                    : stateManager.appbarColor
              ),
            )
          );
        }
    );
  }
}