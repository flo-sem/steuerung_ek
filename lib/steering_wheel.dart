import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import 'package:steuerung_ek/variables.dart';

class SteeringWheel extends StatefulWidget {
  const SteeringWheel({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SteeringAngle();
}

class _SteeringAngle extends State<SteeringWheel> {

  @override
  Widget build(BuildContext context) {
    return Consumer<StateManager>(
      builder: (context, stateManager, child) {
        return Align(
            alignment: Alignment.bottomLeft,
            child: SizedBox(
                width: 300,
                height: 350,
                child: Stack(
                    children: <Widget> [
                      Center(
                          child: Transform.rotate(
                              angle: (stateManager.steeringAngle * (math.pi/180)),
                              child: Image.asset('assets/images/steeringWheel.png', width: 270,)
                          )
                      ),
                      Center(
                          child: SleekCircularSlider(
                              min: -60,
                              max: 60,
                              initialValue: 0,
                              innerWidget: (double value) {
                                return Center(
                                    child: Transform.rotate(
                                        angle: (value * (math.pi/180)),
                                        child: const FaIcon(FontAwesomeIcons.circle, size:50)
                                    )
                                );
                              },
                              appearance: CircularSliderAppearance(
                                  size: 220,
                                  startAngle: 210,
                                  angleRange: 120,
                                  customColors: CustomSliderColors(
                                      trackColor: Colors.transparent,
                                      progressBarColors: null,
                                      progressBarColor: Colors.transparent,
                                      dotColor: Colors.transparent
                                  ),
                                  customWidths: CustomSliderWidths(
                                      progressBarWidth: 0,
                                      trackWidth: 50,
                                      handlerSize: 100
                                  )
                              ),
                              onChange: (double value) {
                                setState(() {
                                  stateManager.setSteeringAngle(value);
                                });
                              }
                          )
                      )
                    ]
                )
            )
        );
      }
    );
  }
}