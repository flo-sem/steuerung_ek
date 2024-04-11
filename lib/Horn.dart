import 'package:flutter/material.dart';
import 'package:steuerung_ek/state_manager.dart';
import 'package:provider/provider.dart';

class Horn extends StatefulWidget {
  const Horn({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _HornState();
}

class _HornState extends State<Horn> {
  @override
  Widget build(BuildContext context) {
    return Consumer<StateManager>(
        builder: (context, stateManager, child) {
          return GestureDetector(
              onTapDown: (_) => stateManager.setHornState(1),
              onTapUp: (_) => stateManager.setHornState(0),
              child: Transform.scale(
                scale: 1 - (0.2*stateManager.hornState),
                child: Image.asset('assets/images/horn.png', width: 60)
              )
          );
        }
    );
  }
}