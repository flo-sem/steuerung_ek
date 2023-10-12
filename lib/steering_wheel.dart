import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;

class SteeringWheel extends StatefulWidget {
  const SteeringWheel({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SteeringAngle();
}

class _SteeringAngle extends State<SteeringWheel> {
  double value = 0;
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.bottomLeft,
        child: SizedBox(
            width: 300,
            height: 350,
            child: Stack(
                children: <Widget> [
                  Center(
                      child: Transform.rotate(
                          angle: (value * (math.pi/180)),
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
                                  progressBarColor: Colors.white,
                                  dotColor: Colors.transparent
                              ),
                              customWidths: CustomSliderWidths(
                                  progressBarWidth: 0,
                                  trackWidth: 5,
                                  handlerSize: 10
                              )
                          ),
                          onChange: (double value) {
                            setState(() {
                              this.value = value;
                            });
                          }
                      )
                  )
                ]
            )
        )
    );
  }
}