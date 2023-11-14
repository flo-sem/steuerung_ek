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
        home: StartPage(),
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

class StartPage extends StatefulWidget {
  StartPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _StartPage();
}

class _StartPage extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Consumer<StateManager>(
        builder: (context, stateManager, child)
        {
    return Scaffold(
      backgroundColor: stateManager.backgroundColor,
        appBar: AppBar(title: const Text('Einkaufswagen Steuerung')),
        body: Stack(children: <Widget>[
          Align(
              alignment: Alignment.topRight,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          return const ControlPage(title: 'SettingPage');
                          //return const SettingsPage();
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
  );
  }
}


class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SettingsPage();
}

class _SettingsPage  extends State<SettingsPage> {

  //final String title;

  @override
  Widget build(BuildContext context) {
    return Consumer<StateManager>(
        builder: (context, stateManager, child)
    {
      return Scaffold(
          backgroundColor: stateManager.backgroundColor,
          appBar: AppBar(title: const Text('SETTINGS')),
    body: SingleChildScrollView(
    child: Column(
    children: <Widget>[

    Column(
    children: [
      Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Background Color',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Spacer()
        ],
      ),

      //Buttons for Background color customization
      Row (
        children: [
          SizedBox(width: 16),

          ElevatedButton(
            onPressed: () {
              stateManager.setBackgroundColor(Colors.blueGrey);
            },
            child: Text('Gray'),
          ),

          SizedBox(width: 16),

          ElevatedButton(
            onPressed: () {
              stateManager.setBackgroundColor(Colors.indigo);
            },
            child: Text('Blue'),
          ),
        ],
      ),

      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Row(
            children: [
              Text(
                'Min. send Interval',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer()
            ],
          ),
          //Text input for minimum ble sending interval
          TextField(
            keyboardType: TextInputType.number,
            onChanged: (newValue) {
              setState(() {
                //Update the numberValue when the text field changes
                int num = int.tryParse(newValue) ?? 20;
                //print(num);
                stateManager.setMinimumSendDelay(num);
              });
            },
            decoration: InputDecoration(
              labelText: '${stateManager.minimumSendDelay} ms',
              border: OutlineInputBorder(),
              suffixText: 'ms', // Suffix added here
            ),
          ),
        ]),
      ),
    ],
    )
    ],
    ),
    ),
    );
  }
    );
  }
}


//Adding landscape support
class ControlPage extends StatelessWidget {
  const ControlPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('CONTROL')),
        body: OrientationWidget(
            portrait: PortraitControl(),
            landscape: LandscapeControl()
        )
    );
  }
}

class PortraitControl extends StatefulWidget {
  const PortraitControl({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _PortraitControl();
}

class _PortraitControl extends State<PortraitControl> {

  @override
  Widget build(BuildContext context) {
    return Consumer<StateManager>(
        builder: (context, stateManager, child)
        {
    return Scaffold(
      backgroundColor: stateManager.backgroundColor,

      body: Column(

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
              mainAxisAlignment: MainAxisAlignment.center,
              // Adjust alignment as needed
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
  );
  }
}

class LandscapeControl extends StatefulWidget {
  const LandscapeControl({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _LandscapeControl();
}

class _LandscapeControl extends State<LandscapeControl> {

  @override
  Widget build(BuildContext context) {
    return Consumer<StateManager>(
        builder: (context, stateManager, child)
        {
    return Scaffold(
      backgroundColor: stateManager.backgroundColor,
      body: Row(

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
  );
  }
}