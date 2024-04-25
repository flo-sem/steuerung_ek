import 'package:flutter/material.dart';
import 'package:steuerung_ek/state_manager.dart';
import 'package:provider/provider.dart';
import 'package:steuerung_ek/ek_icons.dart';
import 'dart:async';
import 'package:steuerung_ek/ble_info.dart';

class GasPedal extends StatefulWidget {
  const GasPedal({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _GasPedalState();
}

class _GasPedalState extends State<GasPedal> {
  Timer? sendTimer;

  @override
  void initState() {
    super.initState();
    var stateManager = Provider.of<StateManager>(context, listen: false);
    sendTimer = Timer.periodic(
        Duration(milliseconds: stateManager.sendInterval), (sendTimer) async {
      var stateManager = Provider.of<StateManager>(context, listen: false);
      await ble_info().BLE_WriteCharateristics(
          'gasCharacteristic', [stateManager.pedalState]);
    });
  }

  @override
  void dispose() {
    super.dispose();
    sendTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
    return Consumer<StateManager>(builder: (context, stateManager, child) {
      return Stack(
        children: <Widget>[
          Align(
              child: SizedBox(
                  height: 240,
                  width: 130,
                  child: Center(
                      child: GestureDetector(
                          onTapDown: (_) => stateManager.setPedalState(100),
                          onTapUp: (_) => stateManager.setPedalState(0),
                          child: Transform(
                              transform: Matrix4.rotationX(
                                  0.003 * stateManager.pedalState),
                              //child: Image.asset('assets/images/gasPedal.png', height: 170)
                              child: Icon(EK_Icons.pedal_accelerator,
                                  size: 150,
                                  color: currentBrightness == Brightness.dark
                                      ? stateManager.darkIconColor
                                      : stateManager.iconColor)))))),
        ],
      );
    });
  }
}
