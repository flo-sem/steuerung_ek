import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state_manager.dart';

class Display extends StatefulWidget {
  const Display({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _DisplayState();
}

class _DisplayState extends State<Display> {

  @override
  Widget build(BuildContext context) {
    return Consumer<StateManager>(
        builder: (context, stateManager, child) {
          return Stack(
            children: [
              Align(
                  //alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(stateManager.speed.toString(),
                          style: Theme
                              .of(context)
                              .textTheme
                              .displayLarge
                      ),
                      Text('km/h',
                          style: Theme
                              .of(context)
                              .textTheme
                              .headlineSmall
                      )
                    ],
                  )
              ),
            ],
          );
        });
  }
}