import 'package:flutter/material.dart';
import 'package:steuerung_ek/state_manager.dart';
import 'package:provider/provider.dart';

class GasPedal extends StatefulWidget {
  const GasPedal({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _GasPedalState();
}

class _GasPedalState extends State<GasPedal> {
  double status = 0;
  @override
  Widget build(BuildContext context) {
    return Consumer<StateManager>(
      builder: (context, stateManager, child) {
        return Stack(
          children: <Widget> [
            Align(
                child: SizedBox(
                    height: 240,
                    width: 130,
                    child: Center(
                        child: GestureDetector(
                            onTapDown: (_) => stateManager.setPedalState(1),
                            onTapUp: (_) => stateManager.setPedalState(0),
                            child: Transform(
                                transform: Matrix4.rotationX(0.3*stateManager.pedalState),
                                child: Image.asset('assets/images/gasPedal.png', height: 170)
                            )
                        )
                    )
                )
            ),
          ],
        );
      }
    );
  }
}