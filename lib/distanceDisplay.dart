import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state_manager.dart';
import 'dart:math' as math;

class DistanceDisplay extends StatefulWidget {
  const DistanceDisplay({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _DistanceDisplayState();
}

class _DistanceDisplayState extends State<DistanceDisplay> {
  @override
  Widget build(BuildContext context) {
    return Consumer<StateManager>(builder: (context, stateManager, child) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
                child: Image.asset(stateManager.distanceFrontImage),
              ),
              SizedBox(
                width: 80,
                height: 80,
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
                    angle: - math.pi / 2,
                    child: Image.asset(stateManager.distanceLeftImage))
              ),
              Container(
                width: 80,
                height: 80,
                child: Image.asset('assets/images/carFromTop.png')
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
      );
    });
  }
}
