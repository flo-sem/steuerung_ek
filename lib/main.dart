import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:steuerung_ek/info_battery.dart';
import 'package:steuerung_ek/state_manager.dart';
import 'steering_wheel.dart';
import 'gas_pedal.dart';
import 'info_display.dart';
import 'ble_info.dart';
import 'package:provider/provider.dart';
import 'orientation_widget.dart';
import 'state_manager.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'package:convert/convert.dart';

import 'second.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StateManager()),
        ChangeNotifierProvider(create: (_) => StateBluetooth())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'shopping cart control',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
      home: StartPage(title: 'Start Menu'),
    );
  }
}

  /*Widget build(BuildContext context) {
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
}*/

class StartPage extends StatelessWidget {
  StartPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<StateBluetooth>(context);

    return Scaffold(
        appBar: AppBar(title: const Text('Einkaufswagen Steuerung')),
        body: Stack(children: <Widget>[
          Align(
              alignment: Alignment.topRight,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const SettingsPage(title: 'SettingPage');
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
                    ElevatedButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                                return ControlPage(title: 'Control Page');
                              }));
                        },
                    child: Text('Control Page'))
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

class ControlPage extends StatefulWidget {
  ControlPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  ControlPageState createState() => ControlPageState();
}
class ControlPageState extends State<ControlPage> {
  double angle = 0;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
      Duration(seconds: 1),
          (timer) {
        //ble_info().BLE_WriteCharateristics(writeData)
            var asci = AsciiEncoder().convert(angle.round().toString());
            List<int> data = [];
            for(var i in asci) {
              int x = i.toInt();
              data.add(x);
            }
            print('[DATA_LOG]' + data.toString());
            ble_info().BLE_WriteCharateristics(data);

      },
    );
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var stateManager = Provider.of<StateManager>(context);
    angle = stateManager.steeringAngle;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('CONTROL')),
        body: OrientationWidget(
            portrait: _PortraitControl(),
            landscape: _LandscapeControl()
        )
    );
  }
}

//Adding landscape support
class _PortraitControl extends StatelessWidget {
  const _PortraitControl();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text('CONTROL')),
      body: //Stack(children: <Widget>[
      Column(

          children: [
//Top Row moving battery info to the right side of the view
            Row(
              children: [
                Spacer(),
                const Display_battery(),
                Container(
                    width: 50,
                    height: 10
                ),
              ],
            ),

            //placing the speed view in the center of the view
            Spacer(),
            const Display(),
            Spacer(),

            //wheel and pedal
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Adjust alignment as needed
              children: [
                //spacer of width 20 to align steering wheel
                Container(
                    width: 20,
                    height: 10
                ),

                //dynamic sizing
                Expanded(
                  child: const SteeringWheel(),
                ),
                Expanded(
                  child: const GasPedal(),
                ),
              ],
            ),
          ]),
    );
  }
}

class _LandscapeControl extends StatelessWidget {
  const _LandscapeControl();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text('CONTROL')),
      body: //Stack(children: <Widget>[
      Row(

        //steering wheel on the left hand side
          children: [
            Container(
                width: 20,
                height: 10
            ),

            //dynamic sizing
            Expanded(
              child: const SteeringWheel(),
            ),

            //vertical combination of battery info and speed in the row center
            Expanded(
              child:
              Column(
                children: [
                  const Display_battery(),
                  Spacer(),
                  const Display(),
                  Spacer(),
                ],
              )
            ),

            //gas pedal on the right hand side
            Expanded(
              child: const GasPedal(),
            ),
          ]),
    );
  }
}