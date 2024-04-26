import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:steuerung_ek/custom_haptics.dart';
import 'package:steuerung_ek/main.dart';
import 'ble_info.dart';
import 'package:convert/convert.dart';
import 'package:steuerung_ek/ek_icons.dart';

class StateManager with ChangeNotifier {
  ble_info bluetoothProvider = ble_info();
  CustomHaptics haptics = CustomHaptics();

  Color _backgroundColor = Colors.white;
  Color get backgroundColor => _backgroundColor;
  void set backgroundColor(Color color) {
    _backgroundColor = color;
    notifyListeners();
  }

  Color _darkBackgroundColor = Colors.black;
  Color get darkBackgroundColor => _darkBackgroundColor;
  void set darkBackgroundColor(Color color) {
    _darkBackgroundColor = color;
    notifyListeners();
  }

  Color _appbarColor = Colors.lightBlueAccent;
  Color get appbarColor => _appbarColor;
  void set appbarColor(Color color) {
    _appbarColor = color;
    notifyListeners();
  }

  Color _darkAppbarColor = Colors.deepPurpleAccent;
  Color get darkAppbarColor => _darkAppbarColor;
  void set darkAppbarColor(Color color) {
    _darkAppbarColor = color;
    notifyListeners();
  }

  Color _iconColor = Colors.black;
  Color get iconColor => _iconColor;
  void set iconColor(Color color) {
    _iconColor = color;
    notifyListeners();
  }

  Color _darkIconColor = Colors.white;
  Color get darkIconColor => _darkIconColor;
  void set darkIconColor(Color color) {
    _darkIconColor = color;
    notifyListeners();
  }

  Color _textColor = Colors.black;
  Color get textColor => _textColor;
  void set textColor(Color color) {
    _textColor = color;
    notifyListeners();
  }

  Color _darkTextColor = Colors.white70;
  Color get darkTextColor => _darkTextColor;
  void set darkTextColor(Color color) {
    _darkTextColor = color;
    notifyListeners();
  }

  int _readWriteInterval = 100;
  int get readWriteInterval => _readWriteInterval;


  int _usingController = 0;
  int get usingController => _usingController;
  void set usingController(int controller) {
    _usingController = controller;
    notifyListeners();
  }

  int _speed = 0;
  int get speed => _speed;

  int _temperature = 0;
  int get temperature => _temperature;

  int _pitch = 0;
  int get pitch => _pitch;

  int _roll = 0;
  int get roll => _roll;

  //Used in Characteristic
  int _steeringAngle = 0;
  int get steeringAngle => _steeringAngle;

  int _hornState = 0;
  int get hornState => _hornState;

  int _blinkTact = 0;
  int get blinkTact => _blinkTact;

  //Used in characteristic
  int _blinkerRightState = 0;
  int get blinkerRightState => _blinkerRightState;

  //Used in characteristic
  int _blinkerLeftState = 0;
  int get blinkerLeftState => _blinkerLeftState;

  int _hazardLightState = 0;
  int get hazardLightState => _hazardLightState;

  int _hazardLightButton = 0;
  int get hazardLightButton => _hazardLightButton;

  //Used in characteristic
  int _pedalState = 0;
  int get pedalState => _pedalState;

  int _batteryChargingState = 100;
  int get batteryChargingState => _batteryChargingState;

  String _batteryImage = 'assets/images/battery4.png';
  String get batteryImage => _batteryImage;

  IconData _batteryIcon = EK_Icons.battery_100percent;
  IconData get batteryIcon => _batteryIcon;

  int _distanceFrontLeft = 0;
  int get distanceFrontLeft => _distanceFrontLeft;

  int _distanceFrontMiddle = 0;
  int get distanceFrontMiddle => _distanceFrontMiddle;

  int _distanceFrontRight = 0;
  int get distanceFrontRight => _distanceFrontRight;

  int _distanceLeft = 0;
  int get distanceLeft => _distanceLeft;

  int _distanceRight = 0;
  int get distanceRight => _distanceRight;

  int _distanceBack = 0;
  int get distanceBack => _distanceBack;

  String _distanceFrontLeftImage = 'assets/images/distanceLongFrontLeft.png';
  String get distanceFrontLeftImage => _distanceFrontLeftImage;

  String _distanceFrontMiddleImage =
      'assets/images/distanceLongFrontMiddle.png';
  String get distanceFrontMiddleImage => _distanceFrontMiddleImage;

  String _distanceFrontRightImage = 'assets/images/distanceLongFrontRight.png';
  String get distanceFrontRightImage => _distanceFrontRightImage;

  String _distanceLeftImage = 'assets/images/distanceLong.png';
  String get distanceLeftImage => _distanceLeftImage;

  String _distanceRightImage = 'assets/images/distanceLong.png';
  String get distanceRightImage => _distanceRightImage;

  String _distanceBackImage = 'assets/images/distanceLong.png';
  String get distanceBackImage => _distanceBackImage;

  int _controllerConnectionState = 0;
  int get controllerConnectionState => _controllerConnectionState;

  int _controllerButtonState = 0;
  int get controllerButtonState => _controllerButtonState;

  void resetAll() {
    _steeringAngle = 0;
    _blinkerLeftState = 0;
    _blinkerRightState = 0;
  }

  void setReadWriteInterval(int value) {
    _readWriteInterval = value;
    notifyListeners();
  }

  void setSteeringAngle(double value) {
    _steeringAngle = value.toInt();
    notifyListeners();
  }

  void setSpeed(int value) {
    _speed = value;
    notifyListeners();
  }

  void setTemperature(int value) {
    _temperature = value;
    notifyListeners();
  }

  void setPitch(int value) {
    _pitch = value;
    notifyListeners();
  }

  void setRoll(int value) {
    _roll = value;
    notifyListeners();
  }

  void setHornState(int value) {
    _hornState = value;
    notifyListeners();
  }

  void toggleBlinkTact() {
    if (_blinkTact == 0) {
      _blinkTact = 1;
    } else {
      _blinkTact = 0;
    }
    notifyListeners();
  }

  void toggleBlinkerRightState() {
    if (_hazardLightState == 0 && _blinkerLeftState == 0) {
      if (_blinkerRightState == 0) {
        _blinkerRightState = 1;
      } else {
        _blinkerRightState = 0;
      }
      notifyListeners();
    }
  }

  void toggleBlinkerLeftState() {
    if (_hazardLightState == 0 && _blinkerRightState == 0) {
      if (_blinkerLeftState == 0) {
        _blinkerLeftState = 1;
      } else {
        _blinkerLeftState = 0;
      }
      notifyListeners();
    }
  }

  void toggleBothBlinkerState() {
    if (_hazardLightState == 0) {
      _hazardLightState = 1;
      _blinkerLeftState = 1;
      _blinkerRightState = 1;
    } else {
      _hazardLightState = 0;
      _blinkerLeftState = 0;
      _blinkerRightState = 0;
    }
    _hazardLightButton = 1;
    notifyListeners();
  }

  void resetHazardLightButton() {
    _hazardLightButton = 0;
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
      _batteryIcon = EK_Icons.battery_0percent;
    } else if ((value >= 20) && (value < 40)) {
      _batteryImage = 'assets/images/battery1.png';
      _batteryIcon = EK_Icons.battery_25percent;
    } else if ((value >= 40) && (value < 60)) {
      _batteryImage = 'assets/images/battery2.png';
      _batteryIcon = EK_Icons.battery_50percent;
    } else if ((value >= 60) && (value < 80)) {
      _batteryImage = 'assets/images/battery3.png';
      _batteryIcon = EK_Icons.battery_75percent;
    } else {
      _batteryImage = 'assets/images/battery4.png';
      _batteryIcon = EK_Icons.battery_100percent;
    }
    notifyListeners();
  }

  void setDistance(List<int> distanceList) {
    setFrontLeftDistance(distanceList[0]);
    setFrontMiddleDistance(distanceList[1]);
    setFrontRightDistance(distanceList[2]);
    setRightDistance(distanceList[3]);
    setBackDistance(distanceList[4]);
    setLeftDistance(distanceList[5]);

    hapticOnObjectDetection(distanceList);
  }

  void hapticOnObjectDetection(List<int> distanceList) {
    int minimum = distanceList[0];
    for (int i = 1; i < distanceList.length; i++) {
      if (distanceList[i] < minimum) {
        minimum = distanceList[i];
      }
    }
    if (minimum <= 1000) {
      haptics.objectCloser();
    } else if (minimum <= 3000) {
      haptics.objectDetected();
    } else {
      return;
    }
  }

  void setFrontLeftDistance(int value) {
    _distanceFrontLeft = value;
    _distanceFrontLeftImage = _getDistanceFrontLeftImage();
    notifyListeners();
  }

  void setFrontMiddleDistance(int value) {
    _distanceFrontMiddle = value;
    _distanceFrontMiddleImage = _getDistanceFrontMiddleImage();
    notifyListeners();
  }

  void setFrontRightDistance(int value) {
    _distanceFrontRight = value;
    _distanceFrontRightImage = _getDistanceFrontRightImage();
    notifyListeners();
  }

  void setLeftDistance(int value) {
    _distanceLeft = value;
    _distanceLeftImage = _getDistanceImage(_distanceLeft);
    notifyListeners();
  }

  void setRightDistance(int value) {
    _distanceRight = value;
    _distanceRightImage = _getDistanceImage(_distanceRight);
    notifyListeners();
  }

  void setBackDistance(int value) {
    _distanceBack = value;
    _distanceBackImage = _getDistanceImage(_distanceBack);
    notifyListeners();
  }

  String _getDistanceFrontLeftImage() {
    String ret = 'assets/images/distanceShortFrontLeft.png';

    if (_distanceFrontLeft > 150) {
      ret = 'assets/images/distanceLongFrontLeft.png';
    } else if (_distanceFrontLeft <= 150 && _distanceFrontLeft > 75) {
      ret = 'assets/images/distanceMediumFrontLeft.png';
    }

    return ret;
  }

  String _getDistanceFrontMiddleImage() {
    String ret = 'assets/images/distanceShortFrontMiddle.png';

    if (_distanceFrontMiddle > 150) {
      ret = 'assets/images/distanceLongFrontMiddle.png';
    } else if (_distanceFrontMiddle <= 150 && _distanceFrontMiddle > 75) {
      ret = 'assets/images/distanceMediumFrontMiddle.png';
    }

    return ret;
  }

  String _getDistanceFrontRightImage() {
    String ret = 'assets/images/distanceShortFrontRight.png';

    if (_distanceFrontRight > 150) {
      ret = 'assets/images/distanceLongFrontRight.png';
    } else if (_distanceFrontRight <= 150 && _distanceFrontRight > 75) {
      ret = 'assets/images/distanceMediumFrontRight.png';
    }

    return ret;
  }

  String _getDistanceImage(int distance) {
    String ret = 'assets/images/distanceShort.png';

    if (distance > 150) {
      ret = 'assets/images/distanceLong.png';
    } else if (distance <= 150 && distance > 75) {
      ret = 'assets/images/distanceMedium.png';
    }

    return ret;
  }

  void toggleControllerConnectionState() {
    if (_controllerConnectionState == 0) {
      _controllerConnectionState = 1;
    } else {
      _controllerConnectionState = 0;
    }
    _controllerButtonState = 1;
    notifyListeners();
  }

  void resetControllerButtonState() {
    _controllerButtonState = 0;
    notifyListeners();
  }
}
