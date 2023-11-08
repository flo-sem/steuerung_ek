import 'package:flutter/material.dart';


class StateManager with ChangeNotifier {
  int _speed = 0;
  int get speed => _speed;
  double _steeringAngle = 0.0;
  double get steeringAngle => _steeringAngle;
  int _pedalState = 0;
  int get pedalState => _pedalState;

  void setSteeringAngle(double value) {
    _steeringAngle = value;
    notifyListeners();
  }

  void setPedalState(int value) {
    _pedalState = value;
    notifyListeners();
  }
}