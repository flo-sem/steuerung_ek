import 'package:flutter/material.dart';
import 'package:steuerung_ek/info_battery.dart';
import 'package:steuerung_ek/state_manager.dart';
import 'steering_wheel.dart';
import 'gas_pedal.dart';
import 'info_display.dart';
import 'ble_info.dart';
import 'package:provider/provider.dart';
import 'state_manager.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'second.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StateManager()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  /*Widget build(BuildContext context) {
    return MaterialApp(
      title: 'shopping cart control',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
      home: StartPage(title: 'Start Menu'),
    );
  }*/

  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: StartPage(title: "Start Menu"),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var MainButtonText = "Suche";
  var characteristics;

  void ChangeText() {
    MainButtonText = "Verbinden";
    notifyListeners();

    Future.delayed(Duration(seconds: 5), () {
      MainButtonText = "Suche";
      notifyListeners();
    });
  }
}

class StartPage extends StatelessWidget {
  StartPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
        appBar: AppBar(title: const Text('Einkaufswagen Steuerung')),
        body: Stack(children: <Widget>[
          Align(
              alignment: Alignment.topRight,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const ControlPage(title: 'SettingPage');
                    }));
                  },
                  child: const Text('Settings'))),
          Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // ← Add this.
                  children: [
                Image.asset(
                  'assets/images/Wifi.png',
                  height: 200,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () {
                      if (appState.MainButtonText == "Suche") {
                        appState.ChangeText();
                        print("[LOG] Button pressed");
                        ble_info().BLE_Search();
                      } else {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return SecondScreen();
                        }));
                      }
                    },
                    child: Text(appState.MainButtonText)),
                SizedBox(height: 50),
              ]))
        ]));
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('SETTINGS')),
        body: Align(
            alignment: Alignment.topLeft,
            child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('back'))));
  }
}

class ControlPage extends StatelessWidget {
  const ControlPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CONTROL')),
      body: Stack(children: <Widget>[
        const SteeringWheel(),
        const GasPedal(),
        const Display(),
        const Display_battery(),
      ]),
    );
  }
}
