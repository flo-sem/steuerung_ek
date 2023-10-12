import 'package:flutter/material.dart';
import 'steering_wheel.dart';
import 'gas_pedal.dart';
import 'info_display.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white
      ),
      title: 'My App',
      home: const StartPage(title:'Start Menu'),
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
                  const SteeringWheel(),
                  const GasPedal(),
                  const SpeedDisplay(),
                ]
        ),
    );
  }
}