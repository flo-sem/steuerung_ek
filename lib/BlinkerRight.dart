import 'package:flutter/material.dart';
import 'package:steuerung_ek/state_manager.dart';
import 'package:provider/provider.dart';
import 'package:steuerung_ek/ek_icons.dart';
import 'dart:async';
import 'package:steuerung_ek/ble_info.dart';

class BlinkerRight extends StatefulWidget {
  const BlinkerRight({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _BlinkerRightState();
}

class _BlinkerRightState extends State<BlinkerRight> {
  Timer? sendTimer;
  @override
  void initState() {
    super.initState();
    var stateManager = Provider.of<StateManager>(context, listen: false);
    sendTimer = Timer.periodic(Duration(milliseconds: stateManager.sendInterval), (sendTimer) async {
      var stateManager = Provider.of<StateManager>(context, listen: false);
      await ble_info().BLE_WriteCharateristics(ble_info().wTurnRightCharacteristic, [stateManager.blinkerRightState]);
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