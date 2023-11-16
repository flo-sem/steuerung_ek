import 'package:flutter/material.dart';
import 'package:steuerung_ek/info_battery.dart';
import 'package:steuerung_ek/state_manager.dart';
import 'steering_wheel.dart';
import 'gas_pedal.dart';
import 'info_display.dart';
import 'ble_info.dart';
import 'package:provider/provider.dart';
import 'orientation_widget.dart';
import 'dart:async';

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
      home: StartPage(),
    );
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
    var stateBluetooth = Provider.of<StateBluetooth>(context);
    var stateManager = Provider.of<StateManager>(context);
    return Scaffold(
        backgroundColor: stateManager.backgroundColor,
        appBar: AppBar(title: const Text('Einkaufswagen Steuerung')),
        body: Stack(children: <Widget>[
          Align(
              alignment: Alignment.topRight,
              child: ElevatedButton(
                  onPressed: () {
                    stateManager.setSteeringAngle(0.0);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          //return ControlPage(title: 'SettingPage');
                          return const SettingsPage();
                        }));
                  },
                  child: const Text('Settings'))),
          Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      stateBluetooth.statusImageURL,
                      height: 200,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: () {
                          if (stateBluetooth.statusImageURL ==
                              "assets/images/bluetoothDisconnect.png") {
                            stateBluetooth.ChangeText();
                            print("[LOG] Button pressed");
                            ble_info().BLE_Search();
                          } else if (stateBluetooth.statusImageURL ==
                              "assets/images/bluetoothConnect.png") {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                                  return ControlPage(title: 'yeet');
                                }));
                          } else {}
                        },
                        child: Text(stateBluetooth.MainButtonText)),
                    SizedBox(height: 50),
                  ])),
          Column(children: [
            Spacer(),
            Row(children: [
              Container(width: 20, height: 10),
              Align(
                  alignment: Alignment.bottomLeft,
                  child: ElevatedButton(
                      onPressed: () {
                        stateManager.setSteeringAngle(0.0);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return ControlPage(title: '');
                            }));
                      },
                      child: const Text('C'))),
            ]),
            Container(width: 10, height: 20),
          ]),
        ]));
    }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    var stateManager = Provider.of<StateManager>(context);
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
                Row(
                  children: [
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        stateManager.setBackgroundColor(Colors.white);
                      },
                      child: Text('Weiß'),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        stateManager.setBackgroundColor(
                            const Color.fromARGB(255, 255, 55, 122));
                      },
                      child: Text('Pink'),
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
                        });
                      },
                      decoration: InputDecoration(
                        labelText: '1000 ms',
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
}

class ControlPage extends StatefulWidget {
  const ControlPage({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  ControlPageState createState() => ControlPageState();
}

//Adding landscape support
class ControlPageState extends State<ControlPage> {
  double angle = 0;
  int pedal = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
      Duration(seconds: 1),
      (timer) {
        List<int> valueList = [angle.toInt(), pedal];
        print('[DATA_LOG]' + valueList.toString());
        ble_info().BLE_WriteCharateristics(valueList);
        ble_info().BLE_ReadCharacteristics();
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var stateManager = Provider.of<StateManager>(context);
    angle = stateManager.steeringAngle;
    pedal = stateManager.pedalState;
  }

  @override
  void dispose() async {
    super.dispose();
    timer?.cancel();
    await ble_info().bluetoothDevice.device.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('CONTROL')),
        body: OrientationWidget(
            portrait: PortraitControl(), landscape: LandscapeControl()));
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
    var stateManager = Provider.of<StateManager>(context);
    return Scaffold(
      backgroundColor: stateManager.backgroundColor,
      body: Column(children: [
//Top Row moving battery info to the right side of the view
        Row(
          children: [
            Spacer(),
            const Display_battery(),
            Container(width: 50, height: 10),
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
            Container(width: 20, height: 10),

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

class LandscapeControl extends StatefulWidget {
  const LandscapeControl({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LandscapeControl();
}

class _LandscapeControl extends State<LandscapeControl> {
  @override
  Widget build(BuildContext context) {
    var stateManager = Provider.of<StateManager>(context);
    return Scaffold(
      backgroundColor: stateManager.backgroundColor,
      body: Row(

        //steering wheel on the left hand side
          children: [
            Container(width: 20, height: 10),

            //dynamic sizing
            Expanded(
              child: const SteeringWheel(),
            ),

            //vertical combination of battery info and speed in the row center
            Expanded(
                child: Column(
                  children: [
                    const Display_battery(),
                    Spacer(),
                    const Display(),
                    Spacer(),
                  ],
                )),

            //gas pedal on the right hand side
            Expanded(
              child: const GasPedal(),
            ),
          ]),
    );
  }
}
