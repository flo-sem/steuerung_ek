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

  Color _backgroundColor = Colors.white;
  Color get backgroundColor => _backgroundColor;


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

  void setBackgroundColor(Color value) {
    _backgroundColor = value;
    notifyListeners();
  }
}

enum ConnectionStateImage {
  disconnected,
  searching,
  connected,
}

class StateBluetooth with ChangeNotifier {

  List<int> _testBuffer = [];
  List<int> get testBuffer => _testBuffer;

  String _MainButtonText = "Suche starten";
  String get MainButtonText => _MainButtonText;

  String _statusImageURL = 'assets/images/label_noBT.png';
  String get statusImageURL => _statusImageURL;

  var characteristics;

  void UpdateInputBuffer(List<int> input) {
    _testBuffer = input;
    notifyListeners();
  }

  void fastUpdate() {
    _MainButtonText = "Verbinden";
    notifyListeners();
  }

  void ChangeTextBack() {
    _MainButtonText = "Suche starten";
    notifyListeners();
  }

  void ChangeText() {
    _MainButtonText = "Suche läuft";
    notifyListeners();

    Future.delayed(Duration(seconds: 5), () {
      if (statusImageURL == 'assets/images/label_BT.png') {
        _MainButtonText = "Verbinden";
      } else {
        _MainButtonText = "Suche starten";
      }
      notifyListeners();
    });
  }

  void setImage(ConnectionStateImage state) {
    switch (state) {
      case ConnectionStateImage.disconnected:
        _statusImageURL = 'assets/images/label_noBT.png';
        break;
      case ConnectionStateImage.searching:
        _statusImageURL = 'assets/images/loading.png';
        break;
      case ConnectionStateImage.connected:
        _statusImageURL = 'assets/images/label_BT.png';
        break;
    }
    notifyListeners();
  }
}
