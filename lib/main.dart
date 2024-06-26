import 'package:flutter/material.dart';
import 'package:steuerung_ek/ControllerButton.dart';
import 'package:steuerung_ek/batteryDisplay.dart';
import 'package:steuerung_ek/Horn.dart';
import 'package:steuerung_ek/BlinkerLeft.dart';
import 'package:steuerung_ek/BlinkerRight.dart';
import 'package:steuerung_ek/HazardLightButton.dart';
import 'package:steuerung_ek/distanceDisplay.dart';
import 'package:steuerung_ek/pitchDisplay.dart';
import 'package:steuerung_ek/rollDisplay.dart';
import 'package:steuerung_ek/state_manager.dart';
import 'package:steuerung_ek/temperatureDisplay.dart';
import 'package:steuerung_ek/controllerHandlers.dart';
import 'package:steuerung_ek/ek_icons.dart';
import 'steering_wheel.dart';
import 'gas_pedal.dart';
import 'speedDisplay.dart';
import 'ble_info.dart';
import 'package:provider/provider.dart';
import 'orientation_widget.dart';
import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:n_gamepad/n_gamepad.dart';
import 'package:n_gamepad/src/models/control.dart';
import 'package:flutter/services.dart';

enum ConnectionStateImage {
  disconnected,
  searching,
  connected,
}

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
  // Singleton setup (sünde)
  static final MyAppState _instance = MyAppState._internal();

  factory MyAppState() => _instance;

  MyAppState._internal();

  List<int> ControllerBuffer = [];

  List<int> readBuffer = [];

  void ControllerOutputBuffer(List<int> input) {
    ControllerBuffer = input;
    print("[Controller] : $input");
    notifyListeners();
  }

  void UpdateReadBuffer(List<int> input) {
    readBuffer = input;
    notifyListeners();
  }

  List<int> getDistance() {
    if (readBuffer.isEmpty || readBuffer.length < 11) {
      return [0, 0, 0, 0, 0, 0];
    } else {
      return [readBuffer[5], readBuffer[6], readBuffer[7], readBuffer[8], readBuffer[9], readBuffer[10]];
    }
  }

  int getPitch() {
    if (readBuffer.isEmpty || readBuffer.length < 11) {
      return 0;
    } else {
      return readBuffer[3];
    }
  }

  int getRoll() {
    if (readBuffer.isEmpty || readBuffer.length < 11) {
      return 0;
    } else {
      return readBuffer[4];
    }
  }

  int getBatteryState() {
    if (readBuffer.isEmpty || readBuffer.length < 11) {
      return 0;
    } else {
      return readBuffer[0];
    }
  }

  int getTemperature() {
    if (readBuffer.isEmpty || readBuffer.length < 11) {
      return 0;
    } else {
      return readBuffer[1];
    }
  }

  int getSpeed() {
    if (readBuffer.isEmpty || readBuffer.length < 11) {
      return 0;
    } else {
      return readBuffer[1];
    }
  }

  var MainButtonText = "Suche starten";
  var characteristics;

  void fastUpdate() {
    MainButtonText = "Verbinden";
    notifyListeners();
  }

  void ChangeTextBack() {
    MainButtonText = "Suche starten";
    notifyListeners();
  }

  void ChangeText() {
    MainButtonText = "Suche läuft";
    notifyListeners();

    Future.delayed(Duration(seconds: 5), () {
      if (statusImageURL == 'assets/images/label_BT.png') {
        MainButtonText = "Verbinden";
      } else {
        MainButtonText = "Suche starten";
      }
      notifyListeners();
    });
  }

  var statusImageURL = 'assets/images/label_noBT.png';

  void setImage(ConnectionStateImage state) {
    switch (state) {
      case ConnectionStateImage.disconnected:
        statusImageURL = 'assets/images/label_noBT.png';
        break;
      case ConnectionStateImage.searching:
        statusImageURL = 'assets/images/loading.png';
        break;
      case ConnectionStateImage.connected:
        statusImageURL = 'assets/images/label_BT.png';
        break;
    }
    notifyListeners();
  }
}

class StartPage extends StatefulWidget {
  StartPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StartPage();
}

class _StartPage extends State<StartPage> {
  @override
  void initState() {
    super.initState();
    FlutterBluePlus.setLogLevel(LogLevel.none, color: false);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
    var appState = context.watch<MyAppState>();
    return Consumer<StateManager>(builder: (context, stateManager, child) {
      return Scaffold(
          backgroundColor: currentBrightness == Brightness.dark
              ? stateManager.darkBackgroundColor
              : stateManager.backgroundColor,
          appBar: AppBar(
            title: const Center(
              child: Text('Einkaufswagen Steuerung'),
            ),
            foregroundColor: currentBrightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            backgroundColor: currentBrightness == Brightness.dark
                ? stateManager.darkBackgroundColor
                : stateManager.backgroundColor,
          ),
          body: Stack(children: <Widget>[
            Align(
                alignment: Alignment.topRight,
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Column(children: [
                    SizedBox(
                      height: 20,
                    ),
                    OutlinedButton(
                        onPressed: () {
                          stateManager.setSteeringAngle(0.0);
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            //return ControlPage(title: 'SettingPage');
                            return const SettingsPage();
                          }));
                        },
                        style: OutlinedButton.styleFrom(
                            foregroundColor:
                                currentBrightness == Brightness.dark
                                    ? Colors.white
                                    : stateManager.appbarColor,
                            fixedSize: Size(110, 50),
                            side: BorderSide(
                                width: 2,
                                style: BorderStyle.solid,
                                color: currentBrightness == Brightness.dark
                                    ? stateManager.darkAppbarColor
                                    : stateManager.appbarColor)),
                        child: const Text(
                          'Settings',
                          textScaleFactor: 1.1,
                        ))
                  ]),
                  SizedBox(
                    width: 10,
                  )
                ])),
            Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // ← Add this.
                    children: [
                  /*
                      Image.asset(
                      MyAppState().statusImageURL,
                      height: 200,
                    ),
                    */
                  Icon(
                      appState.statusImageURL == "assets/images/label_noBT.png"
                          ? EK_Icons.bluetooth_disabled
                          : EK_Icons.bluetooth_connected,
                      size: 150,
                      color: currentBrightness == Brightness.dark
                          ? stateManager.darkIconColor
                          : stateManager.iconColor),
                  SizedBox(height: 20),
                  OutlinedButton(
                      onPressed: () {
                        if (appState.statusImageURL ==
                            "assets/images/label_noBT.png") {
                          appState.ChangeText();
                          print("[LOG] Button pressed");
                          ble_info().BLE_Search();
                        } else if (appState.statusImageURL ==
                            "assets/images/label_BT.png") {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return ControlPage(title: 'yeet');
                          }));
                        } else {}
                      },
                      style: OutlinedButton.styleFrom(
                          foregroundColor: currentBrightness == Brightness.dark
                              ? Colors.white
                              : stateManager.appbarColor,
                          fixedSize: Size(150, 50),
                          side: BorderSide(
                              width: 2,
                              style: BorderStyle.solid,
                              color: currentBrightness == Brightness.dark
                                  ? stateManager.darkAppbarColor
                                  : stateManager.appbarColor)),
                      child: Text(
                        appState.MainButtonText,
                        textScaleFactor: 1.1,
                      )),
                  SizedBox(height: 50),
                ])),
            Column(children: [
              Spacer(),
              Row(children: [
                Container(width: 20, height: 10),
                Align(
                    alignment: Alignment.bottomLeft,
                    child: OutlinedButton(
                        onPressed: () {
                          stateManager.resetAll();
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return ControlPage(title: '');
                          }));
                        },
                        style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                                width: 2,
                                style: BorderStyle.solid,
                                color: currentBrightness == Brightness.dark
                                    ? stateManager.darkAppbarColor
                                    : stateManager.appbarColor)),
                        child: const Text('C'))),
              ]),
              Container(width: 10, height: 20),
            ]),
          ]));
    });
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  //final String title;
  Color profile1dark = Colors.deepPurpleAccent;
  Color profile2dark = Color.fromARGB(255, 252, 53, 3);
  Color profile1light = Colors.lightBlueAccent;
  Color profile2light = Color.fromARGB(255, 252, 132, 2);

  @override
  Widget build(BuildContext context) {
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
    return Consumer<StateManager>(builder: (context, stateManager, child) {
      return Scaffold(
        backgroundColor: currentBrightness == Brightness.dark
            ? stateManager.darkBackgroundColor
            : stateManager.backgroundColor,
        appBar: AppBar(
            title: const Text('SETTINGS'),
            foregroundColor: currentBrightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            backgroundColor: currentBrightness == Brightness.dark
                ? stateManager.darkBackgroundColor
                : stateManager.backgroundColor),
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
                            color: currentBrightness == Brightness.dark
                                ? stateManager.darkTextColor
                                : stateManager.textColor,
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
                      OutlinedButton(
                        onPressed: () {
                          stateManager.backgroundColor = Colors.white;
                          stateManager.darkBackgroundColor = Colors.black;
                          stateManager.appbarColor = profile1light;
                          stateManager.darkAppbarColor = profile1dark;
                          stateManager.iconColor = Colors.black;
                          stateManager.darkIconColor = Colors.white;
                          stateManager.textColor = Colors.black;
                          stateManager.darkTextColor = Colors.white70;
                        },
                        style: OutlinedButton.styleFrom(
                            foregroundColor:
                                currentBrightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                            fixedSize: Size(150, 50),
                            side: BorderSide(
                                width: 3,
                                style: BorderStyle.solid,
                                color: currentBrightness == Brightness.dark
                                    ? profile1dark
                                    : profile1light)),
                        child: Text('Color Profile 1'),
                      ),
                      SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: () {
                          stateManager.backgroundColor = Colors.white;
                          stateManager.darkBackgroundColor = Colors.black;
                          stateManager.appbarColor = profile2light;
                          stateManager.darkAppbarColor = profile2dark;
                          stateManager.iconColor = Colors.black;
                          stateManager.darkIconColor = Colors.white;
                          stateManager.textColor = Colors.black;
                          stateManager.darkTextColor = Colors.white70;
                        },
                        style: OutlinedButton.styleFrom(
                            foregroundColor:
                                currentBrightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                            fixedSize: Size(150, 50),
                            side: BorderSide(
                                width: 3,
                                style: BorderStyle.solid,
                                color: currentBrightness == Brightness.dark
                                    ? profile2dark
                                    : profile2light)),
                        child: Text('Color Profile 2'),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(children: [
                      Row(
                        children: [
                          Text(
                            'Read/Write Interval',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: currentBrightness == Brightness.dark
                                  ? stateManager.darkTextColor
                                  : stateManager.textColor,
                            ),
                          ),
                          Spacer(),
                          Text('${stateManager.readWriteInterval} ms',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: currentBrightness == Brightness.dark
                                    ? stateManager.darkTextColor
                                    : stateManager.textColor,
                              )),
                        ],
                      ),
                      Slider(
                        min: 50,
                        max: 500,
                        divisions: 9,
                        activeColor: currentBrightness == Brightness.dark
                            ? stateManager.darkAppbarColor
                            : stateManager.appbarColor,
                        value: stateManager.readWriteInterval.toDouble(),
                        onChanged: (double value) {
                          stateManager.setReadWriteInterval(value.toInt());
                        },
                      ),
                    ]),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    });
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
  int angle = 0;
  int pedal = 0;
  Timer? timer;
  final leftJoystick = JoystickHandler.left;
  final rightJoystick = JoystickHandler.right;
  String _text = '';
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp
    ]);
    var ControllerHandler = ControllerHandlers(handlerContext: context);
    var stateManager = Provider.of<StateManager>(context, listen: false);
    timer = Timer.periodic(Duration(milliseconds: stateManager.readWriteInterval),
        (timer) async {
      var stateManager = Provider.of<StateManager>(context, listen: false);
      //updating Values
      stateManager.setBatteryChargingState(MyAppState().getBatteryState());
      stateManager.setSpeed(MyAppState().getSpeed());
      stateManager.setPitch(MyAppState().getPitch());
      stateManager.setRoll(MyAppState().getRoll());
      stateManager.setTemperature(MyAppState().getTemperature());
      stateManager.setDistance(MyAppState().getDistance());

      //prepering write List
      int steeringAngle = stateManager.steeringAngle;
      int pedalState = stateManager.pedalState;
      int indicatorLeft = stateManager.blinkerLeftState;
      int indicatorRight = stateManager.blinkerRightState;
      int horn = stateManager.hornState;
      List<int> writeData = [steeringAngle, pedalState, indicatorLeft, indicatorRight, horn];
      
      ble_info().BLE_ReadCharacteristics();
      ble_info().BLE_WriteCharateristics(writeData);

    });

    leftJoystick.assignMotionEvent(ControllerHandler
        .handleLeftJoystickEvent); // Listen for left joystick events
    rightJoystick.assignMotionEvent(ControllerHandler
        .handleRightJoystickEvent); // Listen for right joystick events

    // Listen for left trigger events
    TriggerHandler.left
        .assignMotionEvent(ControllerHandler.handleLeftTriggerEvent);

    // Listen for right trigger events
    TriggerHandler.right
        .assignMotionEvent(ControllerHandler.handleRightTriggerEvent);

    /*******************
     *  Button Events  *
     *******************/

    // Assign button listeners with event handlers
    Gamepad.instance.assignButtonListener(
      Button.a,
      onPress: ControllerHandler.handleButtonAPress,
      onRelease: ControllerHandler.handleButtonARelease,
    );

    Gamepad.instance.assignButtonListener(
      Button.b,
      onPress: ControllerHandler.handleButtonBPress,
      onRelease: ControllerHandler.handleButtonBRelease,
    );

    Gamepad.instance.assignButtonListener(
      Button.x,
      onPress: ControllerHandler.handleButtonXPress,
      onRelease: ControllerHandler.handleButtonXRelease,
    );

    Gamepad.instance.assignButtonListener(
      Button.y,
      onPress: ControllerHandler.handleButtonYPress,
      onRelease: ControllerHandler.handleButtonYRelease,
    );

    // Assign D-pad listener
    Gamepad.instance.assignDpadListener(
        onEvent: (event) => setState(() => _text = '$event'));
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    //var appState = context.watch<MyAppState>();
    timer?.cancel();
    super.dispose();
    await ble_info().bluetoothDevice?.disconnect();
    //appState.ChangeText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: OrientationWidget(
            portrait: PortraitControl(text: _text),
            landscape: LandscapeControl()));
  }
}

class PortraitControl extends StatefulWidget {
  PortraitControl({Key? key, required this.text}) : super(key: key);
  String text;

  @override
  State<StatefulWidget> createState() => _PortraitControl();
}

class _PortraitControl extends State<PortraitControl> {
  @override
  Widget build(BuildContext context) {
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
    return Consumer<StateManager>(builder: (context, stateManager, child) {
      return Scaffold(
        appBar: AppBar(
            title: const Text('CONTROL'),
            foregroundColor: currentBrightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            backgroundColor: currentBrightness == Brightness.dark
                ? stateManager.darkBackgroundColor
                : stateManager.backgroundColor),
        backgroundColor: currentBrightness == Brightness.dark
            ? stateManager.darkBackgroundColor
            : stateManager.backgroundColor,
        body: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          //Top Row moving battery info to the right side of the view
          Container(height: 10),
          Row(
            children: [
              Container(width: 20),
              const TemperatureDisplay(),
              Spacer(),
              const RollDisplay(),
              Container(width: 20),
              const PitchDisplay(),
              Spacer(),
              const BatteryDisplay(),
              Container(width: 50),
            ],
          ),
          const DistanceDisplay(),
          const SpeedDisplay(),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const BlinkerLeft(),
              const HazardLightButton(),
              const Horn(),
              const BlinkerRight(),
            ],
          ),
          SizedBox(height: 40),
          //wheel and pedal
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            // Adjust alignment as needed
            children: [
              Container(
                width: 160, // Adjust the width as neededd
                height: 160,
                child: SteeringWheel(),
              ),
              SizedBox(width: 10), // Add spacing
              Container(
                width: 160, // Adjust the width as needed
                height: 160,
                child: GasPedal(),
              ),
            ],
          ),
        ]),
      );
    });
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
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
    return Consumer<StateManager>(builder: (context, stateManager, child) {
      return Scaffold(
          backgroundColor: currentBrightness == Brightness.dark
              ? stateManager.darkBackgroundColor
              : stateManager.backgroundColor,
          body: Column(children: [
            SizedBox(height: 10),
            Row(
              children: [
                Container(width: 20),
                const TemperatureDisplay(),
                Spacer(),
                const RollDisplay(),
                Container(width: 20),
                const PitchDisplay(),
                Spacer(),
                const BatteryDisplay(),
                Container(width: 50),
              ],
            ),
            Container(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SpeedDisplay(),
                const BlinkerLeft(),
                const HazardLightButton(),
                const Horn(),
                const BlinkerRight(),
                const ControllerButton(),
              ],
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: 180, height: 180, child: const SteeringWheel()),
                  //These nested wid  get are necessary, because the "DistanceDisplay" will
                  //be messed up when resizing through a container.
                  SizedBox(
                    // Wrap DistanceDisplay with SizedBox to adjust its size
                    width: 200, // Set the desired width
                    height: 200, // Set the desired height
                    child: AspectRatio(
                        aspectRatio: 1.0,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: const DistanceDisplay(),
                        )),
                  ),
                  Container(
                    width: 180,
                    height: 180,
                    child: const GasPedal(),
                  ),
                ])
          ]));
    });
  }
}
