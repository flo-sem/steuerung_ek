import 'package:flutter/material.dart';


class StateManager with ChangeNotifier {

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
}

class StateBluetooth with ChangeNotifier {
  String _MainButtonText = "Suche";
  String get MainButtonText => _MainButtonText;

  var characteristics;

  void ChangeText() {
    _MainButtonText = "Verbinden";
    notifyListeners();

    Future.delayed(Duration(seconds: 5), () {
      _MainButtonText = "Suche";
      notifyListeners();
    });
  }
}