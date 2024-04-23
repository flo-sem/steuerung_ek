import 'package:flutter/material.dart';
import 'package:steuerung_ek/state_manager.dart';
import 'package:provider/provider.dart';
import 'package:steuerung_ek/ek_icons.dart';
import 'dart:async';
import 'package:steuerung_ek/ble_info.dart';

class Horn extends StatefulWidget {
  const Horn({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _HornState();
}

class _HornState extends State<Horn> {
  Timer? sendTimer;
  @override
  void initState() {
    super.initState();
    var stateManager = Provider.of<StateManager>(context, listen: false);
    sendTimer = Timer.periodic(Duration(milliseconds: stateManager.sendInterval), (sendTimer) async {
      var stateManager = Provider.of<StateManager>(context, listen: false);
      await ble_info().BLE_WriteCharateristics(ble_info().wHornCharacteristic, [stateManager.hornState]);
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
              onTapDown: (_) => stateManager.setHornState(1),
              onTapUp: (_) => stateManager.setHornState(0),
              child: Transform.scale(
                scale: 1 - (0.2*stateManager.hornState),
                //child: Image.asset('assets/images/horn.png', width: 60)
                child: Icon(EK_Icons.horn,
                    size: 60,
                    color: currentBrightness == Brightness.dark ? stateManager.darkIconColor : stateManager.iconColor
                )
              )
          );
        }
    );
  }
}