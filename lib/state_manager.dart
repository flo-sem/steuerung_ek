import 'dart:convert';

import 'package:flutter/material.dart';
import 'ble_info.dart';
import 'package:convert/convert.dart';

class StateManager with ChangeNotifier {
  ble_info bluetoothProvider = ble_info();

  int _speed = 0;
  int get speed => _speed;

  double _temperature = 0;
  double get temperature => _temperature;

  double _pitch = 0;
  double get pitch => _pitch;

  double _steeringAngle = 0.0;
  double get steeringAngle => _steeringAngle;

  int _hornState = 0;
  int get hornState => _hornState;

  int _blinkTact = 0;
  int get blinkTact => _blinkTact;

  int _blinkerRightState = 0;
  int get blinkerRightState => _blinkerRightState;

  int _blinkerLeftState = 0;
  int get blinkerLeftState => _blinkerLeftState;

  int _hazardLightState = 0;
  int get hazardLightState => _hazardLightState;

  int _hazardLightButton = 0;
  int get hazardLightButton => _hazardLightButton;

  int _pedalState = 0;
  int get pedalState => _pedalState;

  int _batteryChargingState = 100;
  int get batteryChargingState => _batteryChargingState;

  String _batteryImage = 'assets/images/battery4.png';
  String get batteryImage => _batteryImage;

  Color _backgroundColor = Colors.white;
  Color get backgroundColor => _backgroundColor;

  double _distanceFront = 0;
  double get distanceFront => _distanceFront;

  double _distanceLeft = 0;
  double get distanceLeft => _distanceLeft;

  double _distanceRight = 0;
  double get distanceRight => _distanceRight;

  double _distanceBack = 0;
  double get distanceBack => _distanceBack;

  String _distanceFrontImage = 'assets/images/distanceLong.png';
  String get distanceFrontImage => _distanceFrontImage;

  String _distanceLeftImage = 'assets/images/distanceLong.png';
  String get distanceLeftImage => _distanceLeftImage;

  String _distanceRightImage = 'assets/images/distanceLong.png';
  String get distanceRightImage => _distanceRightImage;

  String _distanceBackImage = 'assets/images/distanceLong.png';
  String get distanceBackImage => _distanceBackImage;

  void setSteeringAngle(double value) {
    _steeringAngle = value;
    notifyListeners();
  }

  void setHornState(int value) {
    _hornState = value;
    notifyListeners();
  }

  void toggleBlinkTact()
  {
    if(_blinkTact == 0)
    {
      _blinkTact = 1;
    }
    else
    {
      _blinkTact = 0;
    }
    notifyListeners();
  }

  void toggleBlinkerRightState()
  {
    if(_hazardLightState == 0 && _blinkerLeftState == 0) {
      if(_blinkerRightState == 0)
        {
          _blinkerRightState = 1;
        }
      else
        {
          _blinkerRightState = 0;
        }
      notifyListeners();
    }
  }

  void toggleBlinkerLeftState()
  {
    if(_hazardLightState == 0 && _blinkerRightState == 0) {
      if(_blinkerLeftState == 0)
      {
        _blinkerLeftState = 1;
      }
      else
      {
        _blinkerLeftState = 0;
      }
      notifyListeners();
    }
  }

  void toggleBothBlinkerState()
  {
    if(_hazardLightState == 0)
      {
        _hazardLightState = 1;
        _blinkerLeftState = 1;
        _blinkerRightState = 1;
      }
    else
      {
        _hazardLightState = 0;
        _blinkerLeftState = 0;
        _blinkerRightState = 0;
      }
    _hazardLightButton = 1;
    notifyListeners();
  }

  void resetHazardLightButton()
  {
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

  void setFrontDistance(double value)
  {
    _distanceFront = value;
    _distanceFrontImage = _getDistanceImage(_distanceFront);
    notifyListeners();
  }

  void setLeftDistance(double value)
  {
    _distanceLeft = value;
    _distanceLeftImage = _getDistanceImage(_distanceLeft);
    notifyListeners();
  }

  void setRightDistance(double value)
  {
    _distanceRight = value;
    _distanceRightImage = _getDistanceImage(_distanceRight);
    notifyListeners();
  }

  void setBackDistance(double value)
  {
    _distanceBack = value;
    _distanceBackImage = _getDistanceImage(_distanceBack);
    notifyListeners();
  }

  String _getDistanceImage (double distance)
  {
    String ret = 'assets/images/distanceShort.png';

    if(distance > 3000)
    {
      ret = 'assets/images/distanceLong.png';
    }
    else if(_distanceFront <= 3000 && _distanceFront > 1000)
    {
      ret = 'assets/images/distanceMedium.png';
    }

    return ret;
  }

  void setBackgroundColor(Color value) {
    _backgroundColor = value;
    notifyListeners();
  }
}
