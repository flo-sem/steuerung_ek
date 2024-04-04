import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state_manager.dart';
import 'dart:math' as math;
import 'package:steuerung_ek/ek_icons.dart';

class DistanceDisplay extends StatefulWidget {
  const DistanceDisplay({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _DistanceDisplayState();
}

class _DistanceDisplayState extends State<DistanceDisplay> {
  @override
  Widget build(BuildContext context) {
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
    return Consumer<StateManager>(builder: (context, stateManager, child) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 29.5,
                height: 80,
                child:  Image.asset(stateManager.distanceFrontLeftImage)
              ),
              Container(
                width: 21.2,
                height: 80,
                child:  Image.asset(stateManager.distanceFrontMiddleImage)
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
                    angle: - math.pi / 2,
                    child: Image.asset(stateManager.distanceLeftImage))
              ),
              Container(
                width: 80,
                height: 80,
                //child: Image.asset('assets/images/carFromTop.png')
                child: Icon(EK_Icons.cart_fill,
                    size: 50,
                    color: currentBrightness == Brightness.dark ? stateManager.darkIconColor : stateManager.iconColor
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
      );
    });
  }
}
