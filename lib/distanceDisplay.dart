import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state_manager.dart';
import 'dart:math' as math;
import 'main.dart';
import 'dart:async';
import 'package:steuerung_ek/ek_icons.dart';

// Ein StatefulWidget, das die Distanzanzeige darstellt
class DistanceDisplay extends StatefulWidget {
  const DistanceDisplay({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DistanceDisplayState();
}

// Der Zustand des DistanceDisplay-Widgets
class _DistanceDisplayState extends State<DistanceDisplay> {
  @override
  Widget build(BuildContext context) {
    // Ermittelt ob der Darkmode aktiviert ist 
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;

    return Consumer<StateManager>(builder: (context, stateManager, child) {
      return ColorFiltered(
        colorFilter: ColorFilter.matrix([
          -1,  0,  0, 0, currentBrightness == Brightness.dark ? 255 : 0, // Rot
          0, -1,  0, 0, currentBrightness == Brightness.dark ? 255 : 0, // Grün
          0,  0, -1, 0, currentBrightness == Brightness.dark ? 255 : 0, // Blau
          0,  0,  0, 1, 0  // Alpha
        ]),
        //Platziert die Verschiedenen Elemente des DistanceDisplay
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 29.5,
                  height: 80,
                  child: Image.asset(stateManager.distanceFrontLeftImage)
                ),
                Container(
                  width: 21.2,
                  height: 80,
                  child: Image.asset(stateManager.distanceFrontMiddleImage)
                ),
                SizedBox(
                  width: 29.5,
                  height: 80,
                  child: Image.asset(stateManager.distanceFrontRightImage)
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  child: Transform.rotate(
                    angle: -math.pi / 2,
                    child: Image.asset(stateManager.distanceLeftImage))
                ),
                Container(
                  width: 80,
                  height: 80,
                  child: Icon(EK_Icons.cart,
                    size: 50,
                    color: currentBrightness == Brightness.light 
                      ? stateManager.darkIconColor 
                      : stateManager.iconColor
                  )
                ),
                Container(
                  width: 80,
                  height: 80,
                  child: Transform.rotate(
                    angle: math.pi / 2,
                    child: Image.asset(stateManager.distanceRightImage))
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                ),
                Container(
                  width: 80,
                  height: 80,
                  child: Transform.rotate(
                    angle: math.pi,
                    child: Image.asset(stateManager.distanceBackImage))
                ),
                SizedBox(
                  width: 80,
                  height: 80,
                )
              ],
            )
          ],
        ),
      );
    });
  }
}
