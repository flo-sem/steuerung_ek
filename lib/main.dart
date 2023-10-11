import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'My App',
      home: StartPage(title:'Start Menu'),
    );
  }
}

class StartPage extends StatelessWidget {
  const StartPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('START')
        ),
        body: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) { return const SettingsPage(title: 'SettingPage');}
                    ));
                  },
                  child: const Text('Settings')
                )
              ),
              Center(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) { return const ControlPage(title: 'ControlPage');}
                    ));
                  },
                  child: const Text('Connect')
                )
              )
            ]
        ));
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('SETTINGS')
        ),
        body: Align(
            alignment: Alignment.topLeft,
            child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('back')
            )
        )
    );
  }
}

class ControlPage extends StatelessWidget {
  const ControlPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('CONTROL')
        ),
        body: Stack(
                children: <Widget> [
                  Align(
                    alignment: Alignment.topLeft,
                    child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('back')
                    )
                  ),
                  const SteeringWheel()
                ]
        ),
    );
  }
}

class SteeringWheel extends StatefulWidget {
  const SteeringWheel({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SteeringAngle();
}

class _SteeringAngle extends State<SteeringWheel> {
  double value = 0;
  @override
  Widget build(BuildContext context) {
      return Stack(
        children: <Widget> [
          Center(
              child: Transform.rotate(
                  angle: (value * (math.pi/180)),
                  child: Image.asset('assets/images/steeringWheel.png', scale: 0.5)
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
                      size: 235,
                      startAngle: 210,
                      angleRange: 120,
                      customColors: CustomSliderColors(
                        trackColor: Colors.black,
                        progressBarColors: null,
                        progressBarColor: Colors.black,
                        dotColor: Colors.red
                      ),
                      customWidths: CustomSliderWidths(
                        progressBarWidth: 5,
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
      );
  }
}