import 'package:flutter/material.dart';
import 'package:steuerung_ek/ControllerButton.dart';
import 'package:steuerung_ek/batteryDisplay.dart';
import 'package:steuerung_ek/Horn.dart';
import 'package:steuerung_ek/BlinkerLeft.dart';
import 'package:steuerung_ek/BlinkerRight.dart';
import 'package:steuerung_ek/HazardLightButton.dart';
import 'package:steuerung_ek/distanceDisplay.dart';
import 'package:steuerung_ek/pitchDisplay.dart';
import 'package:steuerung_ek/state_manager.dart';
import 'package:steuerung_ek/temperatureDisplay.dart';
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

  // ble input buffer
  List<int> testBuffer = [];
  List<int> SpeedBuffer = [];
  List<int> Test1Buffer = [];
  List<int> Test2Buffer = [];
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

  void Test1InputBuffer(List<int> input) {
    Test1Buffer = input;
    notifyListeners();
  }

  void Test2InputBuffer(List<int> input) {
    Test2Buffer = input;
    notifyListeners();
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Consumer<StateManager>(builder: (context, stateManager, child) {
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
                    // ← Add this.
                    children: [
                  Image.asset(
                    MyAppState().statusImageURL,
                    height: 200,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
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
                      child: Text(appState.MainButtonText)),
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

  @override
  Widget build(BuildContext context) {
    return Consumer<StateManager>(builder: (context, stateManager, child) {
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
  double angle = 0;
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
    timer = Timer.periodic(
      Duration(seconds: 1),
      (timer) async {
        List<int> valueList = [angle.toInt(), pedal];
        print('[DATA_LOG]' + valueList.toString());
        await ble_info().BLE_WriteCharateristics(
            ble_info().wControlsCharacteristic, valueList);
        await ble_info()
            .BLE_ReadCharacteristics(ble_info().rSpeedCharacteristic);
        await ble_info()
            .BLE_ReadCharacteristics(ble_info().rTest1Characteristic);
        await ble_info()
            .BLE_ReadCharacteristics(ble_info().rTest2Characteristic);
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
      double xEvent = event.x * 100;
      double yEvent = event.y * 100;
      setControllerInput([10, xEvent.toInt(), yEvent.toInt()]);
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
      setControllerInput([21, zEvent.toInt()]);
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
    return Consumer<StateManager>(builder: (context, stateManager, child) {
      return Scaffold(
        appBar: AppBar(title: const Text('CONTROL')),
        backgroundColor: stateManager.backgroundColor,
        body: Column(children: [
          //Top Row moving battery info to the right side of the view
          Row(
            children: [
              Container(width: 20),
              const TemperatureDisplay(),
              Spacer(),
              const PitchDisplay(),
              Spacer(),
              const BatteryDisplay(),
              Container(width: 20),
            ],
          ),
          Spacer(),
          const DistanceDisplay(),
          Spacer(),
          const SpeedDisplay(),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const BlinkerLeft(),
              SizedBox(width: 50),
              const HazardLightButton(),
              Container(width: 50),
              const Horn(),
              Container(width: 50),
              const BlinkerRight(),
            ],
          ),

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
    return Consumer<StateManager>(builder: (context, stateManager, child) {
      return Scaffold(
          backgroundColor: stateManager.backgroundColor,
          body: Column(children: [
            SizedBox(height: 10),
            Row(
              children: [
                Container(width: 20),
                const TemperatureDisplay(),
                Spacer(),
                const PitchDisplay(),
                Spacer(),
                const BatteryDisplay(),
                Container(width: 20),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                const SpeedDisplay(),
                Spacer(),
                const BlinkerLeft(),
                SizedBox(width: 50),
                const HazardLightButton(),
                Container(width: 50),
                const Horn(),
                Container(width: 50),
                const BlinkerRight(),
                Spacer(),
                Spacer(),
                const ControllerButton(),
                Spacer()
              ],
            ),
            Expanded(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                width: 50,
              ),
              Container(width: 200, child: const SteeringWheel()),
              Spacer(),
              const DistanceDisplay(),
              Spacer(),
              SizedBox(
                width: 50,
              ),
              Container(
                width: 100,
                child: const GasPedal(),
              ),
              SizedBox(
                width: 100,
              )
            ]))
          ]));
    });
  }
}
