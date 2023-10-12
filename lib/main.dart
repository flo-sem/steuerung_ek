import 'package:flutter/material.dart';
import 'steering_wheel.dart';

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


class GasPedal extends StatefulWidget {
  const GasPedal({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _GasPedalState();
}

class _GasPedalState extends State<GasPedal> {
  double status = 0;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget> [
        Align(
        alignment: Alignment.bottomRight,
            child: SizedBox(
                height: 240,
                width: 130,
                child: Center(
                    child: GestureDetector(
                      onTapDown: (_) => setState(() {status = 1;}),
                      onTapUp: (_) => setState(() {status = 0;}),
                      child: Transform(
                        transform: Matrix4.rotationX(0.3*status),
                        child: Image.asset('assets/images/gasPedal.png', height: 170)
                      )
                    )
                )
            )
        ),
        Align(
          alignment: Alignment.topRight,
          child: Text('$status', style: Theme.of(context).textTheme.headlineLarge,),
        )
      ],
    );
  }
}

