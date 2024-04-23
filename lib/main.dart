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
import 'package:steuerung_ek/custom_haptics.dart';
import 'package:steuerung_ek/ek_icons.dart';
import 'steering_wheel.dart';
import 'gas_pedal.dart';
import 'speedDisplay.dart';
import 'ble_info.dart';
import 'package:provider/provider.dart';
import 'orientation_widget.dart';
import 'dart:async';
import 'package:convert/convert.dart';
import 'state_manager.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:n_gamepad/n_gamepad.dart';
import 'package:n_gamepad/src/models/control.dart';
import 'package:flutter/services.dart';
import 'second.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

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

  //ble output buffer

  /* GAMEPAD LEGEND 
    # First int
    0 : Button A
    1 : Button B
    2 : Button X
    3 : Button Y
    10: Left Joystick
    11: Right Joystick
    20: Left Trigger
    21: Right Trigger
    # Second int
    Buttons:
    0 : Released
    1 : Pressed
    Joysticks:
    X - Axis
    Triggers:
    Z - Axis
    # Third int
    Joysticks:
    Y - Axis
  */
  List<int> ControllerBuffer = [];

  // ble input buffer
  List<int> testBuffer = [];

  List<int> SpeedBuffer = [];
  List<int> AkkuBuffer = [];
  List<int> TempBuffer = [];
  List<int> DistanceBuffer = [];
  List<int> SlopeBuffer = [];

  void ControllerOutputBuffer(List<int> input) {
    ControllerBuffer = input;
    print("[Controller] : $input");
    notifyListeners();
  }

  void UpdateInputBuffer(List<int> input) {
    testBuffer = input;
    notifyListeners();
  }

  void SpeedInputBuffer(List<int> input) {
    SpeedBuffer = input;
    notifyListeners();
  }

  void AkkuInputBuffer(List<int> input) {
    AkkuBuffer = input;
    notifyListeners();
  }

  void TempInputBuffer(List<int> input) {
    TempBuffer = input;
    notifyListeners();
  }

  void DistanceInputBuffer(List<int> input) {
    DistanceBuffer = input;
    notifyListeners();
  }

  void SlopeInputBuffer(List<int> input) {
    SlopeBuffer = input;
    notifyListeners();
  }

  List<int> getDistance() {
    if (DistanceBuffer.isEmpty) {
      return [0, 0, 0, 0, 0, 0];
    } else {
      return DistanceBuffer;
    }
  }

  int getPitch() {
    if (SlopeBuffer.isEmpty) {
      return 0;
    } else {
      return SlopeBuffer[0];
    }
  }

  int getBatteryState() {
    if (AkkuBuffer.isEmpty) {
      return 0;
    } else {
      return AkkuBuffer[0];
    }
  }

  int getTemperature() {
    if (TempBuffer.isEmpty) {
      return 20;
    } else {
      return TempBuffer[0];
    }
  }

  int getSpeed() {
    if (SpeedBuffer.isEmpty) {
      return 0;
    } else {
      return SpeedBuffer[0];
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
                            'Send Interval',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: currentBrightness == Brightness.dark
                                  ? stateManager.darkTextColor
                                  : stateManager.textColor,
                            ),
                          ),
                          Spacer(),
                          Text('${stateManager.sendInterval} ms',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: currentBrightness == Brightness.dark
                                    ? stateManager.darkTextColor
                                    : stateManager.textColor,
                              )),
                        ],
                      ),
                      Slider(
                        min: 100,
                        max: 1000,
                        divisions: 18,
                        activeColor: currentBrightness == Brightness.dark
                            ? stateManager.darkAppbarColor
                            : stateManager.appbarColor,
                        value: stateManager.sendInterval.toDouble(),
                        onChanged: (double value) {
                          stateManager.setSendInterval(value.toInt());
                        },
                      ),
                      Row(
                        children: [
                          Text(
                            'Receive Interval',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: currentBrightness == Brightness.dark
                                  ? stateManager.darkTextColor
                                  : stateManager.textColor,
                            ),
                          ),
                          Spacer(),
                          Text('${stateManager.receiveInterval} ms',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: currentBrightness == Brightness.dark
                                    ? stateManager.darkTextColor
                                    : stateManager.textColor,
                              )),
                        ],
                      ),
                      Slider(
                        min: 100,
                        max: 1000,
                        divisions: 18,
                        activeColor: currentBrightness == Brightness.dark
                            ? stateManager.darkAppbarColor
                            : stateManager.appbarColor,
                        value: stateManager.receiveInterval.toDouble(),
                        onChanged: (double value) {
                          stateManager.setReceiveInterval(value.toInt());
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
    var stateManager = Provider.of<StateManager>(context, listen: false);
    timer = Timer.periodic(
      Duration(milliseconds: stateManager.sendInterval),
      (timer) async {
        await ble_info()
            .BLE_ReadCharacteristics(ble_info().rSpeedCharacteristic);
        await ble_info()
            .BLE_ReadCharacteristics(ble_info().rAkkuCharacteristic);
        await ble_info()
            .BLE_ReadCharacteristics(ble_info().rTempCharacteristic);
        await ble_info()
            .BLE_ReadCharacteristics(ble_info().rDistanceCharacteristic);
        await ble_info()
            .BLE_ReadCharacteristics(ble_info().rSlopeCharacteristic);
      },
    );

    leftJoystick.assignMotionEvent(
        handleLeftJoystickEvent); // Listen for left joystick events
    rightJoystick.assignMotionEvent(
        handleRightJoystickEvent); // Listen for right joystick events

    // Listen for left trigger events
    TriggerHandler.left.assignMotionEvent(handleLeftTriggerEvent);

    // Listen for right trigger events
    TriggerHandler.right.assignMotionEvent(handleRightTriggerEvent);

    /*******************
     *  Button Events  *
     *******************/

    // Assign button listeners with event handlers
    Gamepad.instance.assignButtonListener(
      Button.a,
      onPress: handleButtonAPress,
      onRelease: handleButtonARelease,
    );

    Gamepad.instance.assignButtonListener(
      Button.b,
      onPress: handleButtonBPress,
      onRelease: handleButtonBRelease,
    );

    Gamepad.instance.assignButtonListener(
      Button.x,
      onPress: handleButtonXPress,
      onRelease: handleButtonXRelease,
    );

    Gamepad.instance.assignButtonListener(
      Button.y,
      onPress: handleButtonYPress,
      onRelease: handleButtonYRelease,
    );

    // Assign D-pad listener
    Gamepad.instance.assignDpadListener(
        onEvent: (event) => setState(() => _text = '$event'));
  }

  // Define a debounce duration (e.g., 40 milliseconds)
  final Duration _debounceDuration = Duration(milliseconds: 40);
  Timer? _leftJoystickTimer;
  Timer? _rightJoystickTimer;
  Timer? _leftTriggerTimer;
  Timer? _rightTriggerTimer;

  /* GAMEPAD LEGEND 
    # First int
    0 : Button A
    1 : Button B
    2 : Button X
    3 : Button Y
    10: Left Joystick
    11: Right Joystick
    20: Left Trigger
    21: Right Trigger
    # Second int
    Buttons:
    0 : Released
    1 : Pressed
    Joysticks:
    X - Axis
    Triggers:
    Z - Axis
    # Third int
    Joysticks:
    Y - Axis
  */

  void setControllerInput(List<int> input) {
    MyAppState().ControllerOutputBuffer(input);
  }

  void handleLeftJoystickEvent(JoystickEvent event) {
    _leftJoystickTimer?.cancel();
    // Start a new timer to execute the joystick handling logic after the debounce duration
    _leftJoystickTimer = Timer(_debounceDuration, () {
      // Your joystick handling logic goes here
      setState(() {
        print('[CONTROLLER] LeftJoystick: (x: ${event.x}), (y: ${event.y})');
        _text = 'LeftJoystick: (x: ${event.x}), (y: ${event.y})';
        // Write to Bluetooth Characteristic here
      });
      double xEvent = event.x * 60;
      //double yEvent = event.y * 100;

      //setControllerInput([10, xEvent.toInt(), yEvent.toInt()]);
      var stateManager = Provider.of<StateManager>(context, listen: false);
      if (stateManager.usingController == 1) {
        stateManager.setSteeringAngle(xEvent);
      }
    });
  }

  void handleRightJoystickEvent(JoystickEvent event) {
    _rightJoystickTimer?.cancel();
    _rightJoystickTimer = Timer(_debounceDuration, () {
      setState(() {
        print('[CONTROLLER] RightJoystick: (x: ${event.x}), (y: ${event.y})');
      });
      double xEvent = event.x * 100;
      double yEvent = event.y * 100;
      setControllerInput([11, xEvent.toInt(), yEvent.toInt()]);
    });
  }

  // Handle left trigger event
  void handleLeftTriggerEvent(TriggerEvent event) {
    _leftTriggerTimer?.cancel();
    _leftTriggerTimer = Timer(_debounceDuration, () {
      setState(() {
        print('[CONTROLLER] LeftTrigger: (z: ${event.z})');
      });
      double zEvent = event.z * 100;
      setControllerInput([20, zEvent.toInt()]);
    });
  }

  // Handle right trigger event
  void handleRightTriggerEvent(TriggerEvent event) {
    _rightTriggerTimer?.cancel();
    _rightTriggerTimer = Timer(_debounceDuration, () {
      setState(() {
        print('[CONTROLLER] RightTrigger: (z: ${event.z})');
      });
      double zEvent = event.z * 100;
      var stateManager = Provider.of<StateManager>(context, listen: false);
      if (stateManager.usingController == 1) {
        stateManager.setPedalState(zEvent.toInt());
      }
      //setControllerInput([21, zEvent.toInt()]);
    });
  }

  // Button event handlers
  void handleButtonAPress() {
    setState(() {
      print('[CONTROLLER] Button: (A) Pressed');
    });
    setControllerInput([0, 1]);
  }

  void handleButtonARelease() {
    setState(() {
      print('[CONTROLLER] Button: (A) Released');
    });
    setControllerInput([0, 0]);
  }

  // Button event handlers
  void handleButtonBPress() {
    setState(() {
      print('[CONTROLLER] Button: (B) Pressed');
    });
    setControllerInput([1, 1]);
  }

  void handleButtonBRelease() {
    setState(() {
      print('[CONTROLLER] Button: (B) Released');
    });
    setControllerInput([1, 0]);
  }

  // Button event handlers
  void handleButtonXPress() {
    setState(() {
      print('[CONTROLLER] Button: (X) Pressed');
    });
    setControllerInput([2, 1]);
  }

  void handleButtonXRelease() {
    setState(() {
      print('[CONTROLLER] Button: (X) Released');
    });
    setControllerInput([2, 0]);
  }

  // Button event handlers
  void handleButtonYPress() {
    setState(() {
      print('[CONTROLLER] Button: (Y) Pressed');
    });
    setControllerInput([3, 1]);
  }

  void handleButtonYRelease() {
    setState(() {
      print('[CONTROLLER] Button: (Y) Released');
    });
    setControllerInput([3, 0]);
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
    await ble_info().bluetoothDevice.device.disconnect();
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
                width: 160, // Adjust the width as needed
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
