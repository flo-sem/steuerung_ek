import 'package:flutter/material.dart';
import 'ble_info.dart';


class StateManager with ChangeNotifier {
  ble_info bluetoothProvider = ble_info();

  int _speed = 0;
  int get speed => _speed;

  double _steeringAngle = 0.0;
  double get steeringAngle => _steeringAngle;

  int _pedalState = 0;
  int get pedalState => _pedalState;

  int _batteryChargingState = 100;
  int get batteryChargingState => _batteryChargingState;

  String _batteryImage = 'assets/images/battery4.png';
  String get batteryImage => _batteryImage;

  Color _backgroundColor = Colors.blueGrey ;
  Color get backgroundColor => _backgroundColor;


  /* properties for ble send interval control */

//last time the steering angle was sent to ble device
  DateTime lastSteerMs = DateTime.now();

  //false if minimum sending interval was not reached
  bool lastSteerWasSent = false;

  DateTime lastGasMs = DateTime.now();
  bool lastGasWasSent = false;

  //allowed minimal interval between sending to ble device
  int minimumSendDelay = 20;


  bool minimumSendDelayReached(DateTime lastTimestamp) {
    DateTime time = DateTime.now();
    int interval = time.difference(lastTimestamp).inMilliseconds;

    return interval >= minimumSendDelay;
  }

  void setMinimumSendDelay(int value) {
    minimumSendDelay = value;
    //print("Send delay set to $minimumSendDelay");
  }

  void setSteeringAngle(double value) {
    _steeringAngle = value;
    notifyListeners();

    //is interval reached?
    bool canSend = minimumSendDelayReached(lastSteerMs);
    if (canSend) {

      //Send here

     //print("sending allowed");
      //print(DateTime.now().difference(lastSteerMs).inMilliseconds);
      lastSteerWasSent = true;
      lastSteerMs = DateTime.now();
    } else {
      lastSteerWasSent = false;
     //print("no send");

      //send the last value of a change in steering angle
      Future.delayed(Duration(milliseconds: minimumSendDelay), () {
        if (!lastSteerWasSent) {
          lastSteerWasSent = true;
          lastSteerMs = DateTime.now();

          //send here

          //print("sent last");
          //print(DateTime.now().difference(lastSteerMs).inMilliseconds);
        }
      });
    }
  }

  void setPedalState(int value) {
    _pedalState = value;
    notifyListeners();

    bool canSend = minimumSendDelayReached(lastGasMs);
    if (canSend) {

      //Send here

      //print("sending allowed");
      //print(DateTime.now().difference(lastSteerMs).inMilliseconds);
      lastGasWasSent = true;
      lastGasMs = DateTime.now();
    } else {
      lastGasWasSent = false;
      //print("no send");

      Future.delayed(Duration(milliseconds: minimumSendDelay), () {
        if (!lastGasWasSent) {
          lastGasWasSent = true;
          lastGasMs = DateTime.now();

          //send here

          //print("sent last");
          //print(DateTime.now().difference(lastSteerMs).inMilliseconds);
        }
      });
    }
  }

  void setBatteryChargingState(int value) {
    _batteryChargingState = value;
    if(value < 20) {
      _batteryImage = 'assets/images/battery0.png';
    }
    else if((value >= 20) && (value < 40)) {
      _batteryImage = 'assets/images/battery1.png';
    }
    else if((value >= 40) && (value < 60)) {
      _batteryImage = 'assets/images/battery2.png';
    }
    else if((value >= 60) && (value < 80)) {
      _batteryImage = 'assets/images/battery3.png';
    }
    else {
      _batteryImage = 'assets/images/battery4.png';
  }
    notifyListeners();
  }

  void setBackgroundColor(Color value) {
    _backgroundColor = value;
    notifyListeners();
  }
}