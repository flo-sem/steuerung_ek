import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:steuerung_ek/rollDisplay.dart';
import 'state_manager.dart';
import 'package:steuerung_ek/ControllerButton.dart';
import 'package:steuerung_ek/batteryDisplay.dart';
import 'package:steuerung_ek/Horn.dart';
import 'package:steuerung_ek/BlinkerLeft.dart';
import 'package:steuerung_ek/BlinkerRight.dart';
import 'package:steuerung_ek/HazardLightButton.dart';
import 'package:steuerung_ek/distanceDisplay.dart';
import 'package:steuerung_ek/pitchDisplay.dart';
import 'package:steuerung_ek/state_manager.dart';
import 'package:steuerung_ek/temperatureDisplay.dart';
import 'steering_wheel.dart';
import 'gas_pedal.dart';
import 'speedDisplay.dart';
import 'package:flutter/services.dart';

class ControllerDisplay extends StatefulWidget {
  const ControllerDisplay({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _ControllerDisplay();
}

class _ControllerDisplay extends State<ControllerDisplay> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
    return Consumer<StateManager>(builder: (context, stateManager, child) {
      return Scaffold(
          backgroundColor: currentBrightness == Brightness.dark
              ? stateManager.darkBackgroundColor
              : stateManager.backgroundColor,
          body: Column(
            children: [
              SizedBox(height: 10),
              Row(
                children: [
                  Container(width: 20),
                  const TemperatureDisplay(),
                  Spacer(),
                  const RollDisplay(),
                  Container(width: 20),
                  const PitchDisplay(),
                  Spacer(),
                  const BatteryDisplay(),
                  Container(width: 50),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 20),
                  const BlinkerLeft(),
                  Spacer(),
                  const HazardLightButton(),
                  Spacer(),
                  const BlinkerRight(),
                  Spacer(),
                  const ControllerButton(),
                  Container(width: 67)
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  Spacer(),
                  const SpeedDisplay(),
                  Spacer(),
                  Spacer(),
                  SizedBox(
                    // Wrap DistanceDisplay with SizedBox to adjust its size
                    width: 200, // Set the desired width
                    height: 200, // Set the desired height
                    child: AspectRatio(
                        aspectRatio: 1.0,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: const DistanceDisplay(),
                        )),
                  ),
                  Spacer(),
                ],
              )
            ],
          ));
    });
  }

  @override
  void dispose() {
    // Resetting the screen orientation preferences when leaving View B
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}
