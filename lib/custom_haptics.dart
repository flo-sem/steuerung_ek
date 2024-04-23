import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'dart:async';
import 'dart:io';

/* TODO: Set appropriate interval for vibration */

// can be replaced with
// Vibration.vibrate(duration: 100);

class CustomHaptics {
  void objectDetected() {
    for (int i = 1; i <= 3; i++) {
      Future.delayed(Duration(milliseconds: 300 * i), () {
        // Code to be executed after the delay
        //HapticFeedback.lightImpact();
        print("objectDetected");
      });
    }
  }

  void objectClose() {
    for (int i = 1; i <= 5; i++) {
      Future.delayed(Duration(milliseconds: 150 * i), () {
        // Code to be executed after the delay
        //HapticFeedback.mediumImpact();
        print("objectClose");
      });
    }
  }

  void objectCloser() {
    for (int i = 1; i <= 7; i++) {
      Future.delayed(Duration(milliseconds: 100 * i), () {
        // Code to be executed after the delay
        //HapticFeedback.heavyImpact();
        print("objectCloser");
      });
    }
  }

  void buttonTapped() {
    HapticFeedback.selectionClick();
  }
}
