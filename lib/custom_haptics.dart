import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'dart:async';
import 'dart:io';

/* TODO: Set appropriate interval for vibration */

// can be replaced with
// Vibration.vibrate(duration: 100);

class CustomHaptics {
  void objectDetected() {
    //Vibration.vibrate(duration: 20, amplitude: 50);
  }

  void objectClose() {
    //Vibration.vibrate(duration: 40, amplitude: 100);
  }

  void objectCloser() {
    //Vibration.vibrate(duration: 60, amplitude: 200);
  }

  void buttonTapped() {
    HapticFeedback.selectionClick();
  }
}
