import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:steuerung_ek/state_manager.dart';
import 'package:steuerung_ek/ek_icons.dart';

// Ein StatefulWidget, das das Lenkrad darstellt
class SteeringWheel extends StatefulWidget {
  const SteeringWheel({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SteeringAngle();
}

// Der Zustand des SteeringWheel-Widgets
class _SteeringAngle extends State<SteeringWheel> {
  @override
  Widget build(BuildContext context) {
    // Ermittelt, ob der Dark Mode aktiviert ist
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
    
    return Consumer<StateManager>(builder: (context, stateManager, child) {
      return Align(
          // Zentriert das Lenkrad-Widget
          child: SizedBox(
              width: 350,
              height: 350,
              child: Stack(children: <Widget>[
                Center(
                    // Dreht das Lenkrad-Icon basierend auf dem Lenkwinkel
                    child: Transform.rotate(
                        angle: (stateManager.steeringAngle * (math.pi / 180)),
                        child: Icon(EK_Icons.steeringwheel,
                            size: 170,
                            color: currentBrightness == Brightness.dark
                                ? stateManager.darkIconColor
                                : stateManager.iconColor))),
                Center(
                    // Slider für die Lenkwinkel-Eingabe
                    child: SleekCircularSlider(
                        min: -60,
                        max: 60,
                        initialValue: 0,
                        innerWidget: (double value) {
                          return Center(
                              // Dreht das innere Widget basierend auf dem Slider-Wert
                              child: Transform.rotate(
                            angle: (value * (math.pi / 180)),
                          ));
                        },
                        appearance: CircularSliderAppearance(
                            size: 170,
                            startAngle: 210,
                            angleRange: 120,
                            customColors: CustomSliderColors(
                                trackColor: Colors.transparent,
                                progressBarColor: Colors.transparent,
                                dotColor: Colors.transparent),
                            customWidths: CustomSliderWidths(
                                progressBarWidth: 0,
                                trackWidth: 50,
                                handlerSize: 100)),
                        onChange: (double value) {
                          stateManager.setSteeringAngle(value); // Aktualisiert den Lenkwinkel
                        }))
              ])));
    });
  }
}
