import 'dart:convert';

import 'package:flutter/material.dart';
import 'ble_info.dart';
import 'package:convert/convert.dart';

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

  Color _backgroundColor = Colors.white;
  Color get backgroundColor => _backgroundColor;

  Color _darkBackgroundColor = Colors.black;
  Color get darkBackgroundColor => _darkBackgroundColor;

  Color _appbarColor = Colors.lightBlueAccent;
  Color get appbarColor => _appbarColor;

  Color _darkAppbarColor = Colors.deepPurpleAccent ;
  Color get darkAppbarColor => _darkAppbarColor;

  Color _iconColor = Colors.black;
  Color get iconColor => _iconColor;

  Color _darkIconColor = Colors.white ;
  Color get darkIconColor => _darkIconColor;

  /* properties for ble send interval control */

  void setSteeringAngle(double value) {
    _steeringAngle = value;
    notifyListeners();
  }

  void setPedalState(int value) {
    _pedalState = value;
    notifyListeners();
  }

  void setBatteryChargingState(int value) {
    _batteryChargingState = value;
    if (value < 20) {
      _batteryImage = 'assets/images/battery0.png';
    } else if ((value >= 20) && (value < 40)) {
      _batteryImage = 'assets/images/battery1.png';
    } else if ((value >= 40) && (value < 60)) {
      _batteryImage = 'assets/images/battery2.png';
    } else if ((value >= 60) && (value < 80)) {
      _batteryImage = 'assets/images/battery3.png';
    } else {
      _batteryImage = 'assets/images/battery4.png';
    }
    notifyListeners();
  }


}
