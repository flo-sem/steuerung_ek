import 'package:provider/provider.dart';
import 'package:n_gamepad/n_gamepad.dart';
import 'package:n_gamepad/src/models/control.dart';
import 'package:steuerung_ek/state_manager.dart';
import 'package:flutter/material.dart'; // If you're using Material widgets
import 'dart:async';

class ControllerHandlers {
  final BuildContext handlerContext;

  ControllerHandlers({required this.handlerContext});
  Timer? _leftJoystickTimer;
  Timer? _rightJoystickTimer;
  Timer? _leftTriggerTimer;
  Timer? _rightTriggerTimer;

  // Define a debounce duration (e.g., 40 milliseconds)
  final Duration _debounceDuration = Duration(milliseconds: 40);

  void handleLeftJoystickEvent(JoystickEvent event) {
    _leftJoystickTimer?.cancel();
    // Start a new timer to execute the joystick handling logic after the debounce duration
    _leftJoystickTimer = Timer(_debounceDuration, () {
      // Your joystick handling logic goes here
      print('[CONTROLLER] LeftJoystick: (x: ${event.x}), (y: ${event.y})');

      double xEvent = event.x * 60;
      //double yEvent = event.y * 100;

      //setControllerInput([10, xEvent.toInt(), yEvent.toInt()]);
      var stateManager =
          Provider.of<StateManager>(handlerContext, listen: false);
      if (stateManager.usingController == 1) {
        print('[CONTROLLER][BLE] Writing steering Angle');
        stateManager.setSteeringAngle(xEvent);
      }
    });
  }

  void handleRightJoystickEvent(JoystickEvent event) {
    _rightJoystickTimer?.cancel();
    _rightJoystickTimer = Timer(_debounceDuration, () {
      print('[CONTROLLER] RightJoystick: (x: ${event.x}), (y: ${event.y})');
    });
  }

  // Handle left trigger event
  void handleLeftTriggerEvent(TriggerEvent event) {
    _leftTriggerTimer?.cancel();
    _leftTriggerTimer = Timer(_debounceDuration, () {
      print('[CONTROLLER] LeftTrigger: (z: ${event.z})');
      double zEvent = event.z * 100;
    });
  }

  // Handle right trigger event
  void handleRightTriggerEvent(TriggerEvent event) {
    _rightTriggerTimer?.cancel();
    _rightTriggerTimer = Timer(_debounceDuration, () {
      print('[CONTROLLER] RightTrigger: (z: ${event.z})');
      double zEvent = event.z * 100;
      var stateManager =
          Provider.of<StateManager>(handlerContext, listen: false);
      if (stateManager.usingController == 1) {
        print('[CONTROLLER][BLE] Writing Pedal state');
        stateManager.setPedalState(zEvent.toInt());
      }
      //setControllerInput([21, zEvent.toInt()]);
    });
  }

  // Button event handlers
  void handleButtonAPress() {
    print('[CONTROLLER] Button: (A) Pressed');
    var stateManager = Provider.of<StateManager>(handlerContext, listen: false);
    if (stateManager.usingController == 1) {
      print('[CONTROLLER][BLE] Set Horn State');
      stateManager.setHornState(1);
    }
  }

  void handleButtonARelease() {
    print('[CONTROLLER] Button: (A) Released');
    var stateManager = Provider.of<StateManager>(handlerContext, listen: false);
    if (stateManager.usingController == 1) {
      print('[CONTROLLER][BLE] Set Horn State');
      stateManager.setHornState(0);
    }
  }

  // Button event handlers
  void handleButtonBPress() {
    print('[CONTROLLER] Button: (B) Pressed');
    var stateManager = Provider.of<StateManager>(handlerContext, listen: false);
    if (stateManager.usingController == 1) {
      print('[CONTROLLER][BLE] Toggle Left Blinker State');
      stateManager.toggleBlinkerRightState();
    }
  }

  void handleButtonBRelease() {
    print('[CONTROLLER] Button: (B) Released');
  }

  // Button event handlers
  void handleButtonXPress() {
    print('[CONTROLLER] Button: (X) Pressed');
    var stateManager = Provider.of<StateManager>(handlerContext, listen: false);
    if (stateManager.usingController == 1) {
      print('[CONTROLLER][BLE] Toggle Left Blinker State');
      stateManager.toggleBlinkerLeftState();
    }
  }

  void handleButtonXRelease() {
    print('[CONTROLLER] Button: (X) Released');
  }

  // Button event handlers
  void handleButtonYPress() {
    print('[CONTROLLER] Button: (Y) Pressed');
  }

  void handleButtonYRelease() {
    print('[CONTROLLER] Button: (Y) Released');
  }
}
