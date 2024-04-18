import 'package:flutter/material.dart';
import 'package:steuerung_ek/state_manager.dart';
import 'package:provider/provider.dart';
import 'package:steuerung_ek/ek_icons.dart';
import 'dart:async';


class BlinkerLeft extends StatefulWidget {
  const BlinkerLeft({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _BlinkerLeftState();
}

class _BlinkerLeftState extends State<BlinkerLeft> {
  Timer? sendTimer;
  @override
  void initState() {
    super.initState();
    sendTimer = Timer.periodic(Duration(seconds: 1), (sendTimer) async {
      var stateManager = Provider.of<StateManager>(context, listen: false);
      //await ble_info().BLE_WriteCharateristics(ble_info().wBlinkerLeftCharacteristic, [stateManager.blinkerLeftState]);
    });
  }

  @override
  void dispose()
  {
    super.dispose();
    sendTimer?.cancel();
  }

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