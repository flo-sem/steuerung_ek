import 'package:flutter/material.dart';

class SpeedDisplay extends StatefulWidget {
  const SpeedDisplay({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SpeedState();
}

class _SpeedState extends State<SpeedDisplay> {
  double speed = 0;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget> [
            Text('$speed',
                style: Theme.of(context).textTheme.displayLarge
            ),
            Text('km/h',
                style: Theme.of(context).textTheme.headlineSmall
            )
          ],
        )
    );
  }
}