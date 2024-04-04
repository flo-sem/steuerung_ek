import 'package:flutter/material.dart';
import 'package:steuerung_ek/state_manager.dart';
import 'package:provider/provider.dart';
import 'package:steuerung_ek/ek_icons.dart';

class Horn extends StatefulWidget {
  const Horn({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _HornState();
}

class _HornState extends State<Horn> {
  @override
  Widget build(BuildContext context) {
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
    return Consumer<StateManager>(
        builder: (context, stateManager, child) {
          return GestureDetector(
              onTapDown: (_) => stateManager.setDistance([1000, 2000, 3000, 1500, 7000, 840]),
              onTapUp: (_) => stateManager.setDistance([4000, 4000, 4000, 4000, 4000, 4000]),
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