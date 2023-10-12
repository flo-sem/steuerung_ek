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
    return Center(
        child: Text('$speed km/h', style: Theme.of(context).textTheme.displayMedium)
    );
  }
}