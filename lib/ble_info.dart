import 'dart:async';
import 'dart:convert';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'main.dart';
import 'package:vibration/vibration.dart';
import 'package:collection/collection.dart';

class ble_info {
  //Singleton Setup
  static final _instance = ble_info._internal();
  factory ble_info() => _instance;
  ble_info._internal();

  // Constants
  static const String DEVICE_NAME = "ESP32-BLE"; //"ESP32 BLE";

  List<Uuid> serviceUUIDs = [
    Uuid.parse('2300'),
    Uuid.parse('2400'),
    Uuid.parse('2500'),
    Uuid.parse('2600')
  ];

  static const String rAkkuCharacteristicUuid = "2301";
  static const String rSpeedCharacteristicUuid = "2401";
  static const String rTemperatureCharacteristicUuid = "2501";
  static const String rDistanceCharacteristicUuid = "2502";
  static const String rSlopeCharacteristicUuid = "2503";

  static const String wHornCharacteristicUuid = "2601";
  static const String wTurnLeftCharacteristicUuid = "2602";
  static const String wTurnRightCharacteristicUuid = "2603";
  static const String wControlsCharacteristicUuid = "2402";
  static const String wGasCharacteristicUuid = "2403";

  static Map<String, QualifiedCharacteristic> readCharacteristics = {
    'akkuCharacteristic': akkuCharacteristic!,
    'speedCharacteristic': speedCharacteristic!,
    'tempCharacteristic': tempCharacteristic!,
    'distanceCharacteristic': distanceCharacteristic!,
    'slopeCharacteristic': slopeCharacteristic!
  };

  static Map<String, dynamic Function(List<int>)> readCharacteristicsInput = {
    'akkuCharacteristic': (arg) => MyAppState().AkkuInputBuffer(arg),
    'speedCharacteristic': (arg) => MyAppState().SpeedInputBuffer(arg),
    'tempCharacteristic': (arg) => MyAppState().TempInputBuffer(arg),
    'distanceCharacteristic': (arg) => MyAppState().DistanceInputBuffer(arg),
    'slopeCharacteristic': (arg) => MyAppState().SlopeInputBuffer(arg)
  };

  static Map<String, QualifiedCharacteristic> writeCharacteristics = {
    'hornCharacteristic': hornCharacteristic!,
    'turnLeftCharacteristic': turnLeftCharacteristic!,
    'turnRightCharacteristic': turnRightCharacteristic!,
    'controlsCharacteristic': controlsCharacteristic!,
    'gasCharacteristic': gasCharacteristic!
  };

  // Initializing the FLutterReactiveBle libary
  final flutterReactiveBle = FlutterReactiveBle();

  //Variables used for BLE
  DiscoveredDevice? _discoveredDevice;

  static QualifiedCharacteristic? akkuCharacteristic;
  static QualifiedCharacteristic? speedCharacteristic;
  static QualifiedCharacteristic? tempCharacteristic;
  static QualifiedCharacteristic? distanceCharacteristic;
  static QualifiedCharacteristic? slopeCharacteristic;

  static QualifiedCharacteristic? hornCharacteristic;
  static QualifiedCharacteristic? turnLeftCharacteristic;
  static QualifiedCharacteristic? turnRightCharacteristic;
  static QualifiedCharacteristic? controlsCharacteristic;
  static QualifiedCharacteristic? gasCharacteristic;

  // handler functions
  void _handleConnected() async {
    print("[BLELOG] Device connected!");
    await flutterReactiveBle.requestConnectionPriority(
        deviceId: _discoveredDevice!.id,
        priority: ConnectionPriority.highPerformance);
  }

  void _handleUiChanges() {}

  void _assignCharacteristics() {
    akkuCharacteristic = QualifiedCharacteristic(
        characteristicId: Uuid.parse(rAkkuCharacteristicUuid!),
        serviceId: serviceUUIDs[0],
        deviceId: _discoveredDevice!.id);
    speedCharacteristic = QualifiedCharacteristic(
        characteristicId: Uuid.parse(rSpeedCharacteristicUuid),
        serviceId: serviceUUIDs[1],
        deviceId: _discoveredDevice!.id);
    tempCharacteristic = QualifiedCharacteristic(
        characteristicId: Uuid.parse(rTemperatureCharacteristicUuid),
        serviceId: serviceUUIDs[2],
        deviceId: _discoveredDevice!.id);
    distanceCharacteristic = QualifiedCharacteristic(
        characteristicId: Uuid.parse(rDistanceCharacteristicUuid),
        serviceId: serviceUUIDs[2],
        deviceId: _discoveredDevice!.id);
    slopeCharacteristic = QualifiedCharacteristic(
        characteristicId: Uuid.parse(rSlopeCharacteristicUuid),
        serviceId: serviceUUIDs[2],
        deviceId: _discoveredDevice!.id);

    hornCharacteristic = QualifiedCharacteristic(
        characteristicId: Uuid.parse(wHornCharacteristicUuid),
        serviceId: serviceUUIDs[3],
        deviceId: _discoveredDevice!.id);
    turnLeftCharacteristic = QualifiedCharacteristic(
        characteristicId: Uuid.parse(wTurnLeftCharacteristicUuid),
        serviceId: serviceUUIDs[3],
        deviceId: _discoveredDevice!.id);
    turnRightCharacteristic = QualifiedCharacteristic(
        characteristicId: Uuid.parse(wTurnRightCharacteristicUuid),
        serviceId: serviceUUIDs[3],
        deviceId: _discoveredDevice!.id);
    controlsCharacteristic = QualifiedCharacteristic(
        characteristicId: Uuid.parse(wControlsCharacteristicUuid),
        serviceId: serviceUUIDs[1],
        deviceId: _discoveredDevice!.id);
    gasCharacteristic = QualifiedCharacteristic(
        characteristicId: Uuid.parse(wGasCharacteristicUuid),
        serviceId: serviceUUIDs[1],
        deviceId: _discoveredDevice!.id);
  }

  void _handleDisconnected() {
    print("[BLELOG] Device disconnected!");
  }

  void _connectImage() {
    MyAppState().setImage(ConnectionStateImage.connected);
  }

  // Functions for Bluetooth Low Energy
  void BLE_Search() async {
    print("[BLELOG] Started Search!");
    flutterReactiveBle.scanForDevices(
        withServices: [] /*serviceUUIDs*/,
        scanMode: ScanMode.lowLatency).listen((device) {
      //code for handling results
      print("[BLELOG] Found device: ${device.name}");
      if (device.name == "Blank") {
        _discoveredDevice = device;
        BLE_Connect();
      }
    }, onError: (dynamic error) {
      print("[BLELOG] Device Search failed!");
      print("[BLELOG] $error");
      MyAppState().statusImageURL = "assets/images/label_noBT.png";
    });
  }

  void BLE_Connect() async {
    flutterReactiveBle
        .connectToAdvertisingDevice(
      id: _discoveredDevice!.id,
      withServices: serviceUUIDs,
      prescanDuration: const Duration(seconds: 5),
      connectionTimeout: const Duration(seconds: 2),
    )
        .listen((connectionState) {
      // Handle connection state updates
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        _handleConnected();
        _assignCharacteristics();
        _connectImage();
      }
      if (connectionState.connectionState == DeviceConnectionState.disconnected)
        _handleDisconnected();
    }, onError: (dynamic error) {
      // Handle a possible error
      print("[BLELOG] Device connection failed!");
      print("[BLELOG] $error");
    });
  }

  Future<void> BLE_WriteCharateristics(
      String characteristicId, List<int> writeData) async {
    flutterReactiveBle.writeCharacteristicWithoutResponse(
        writeCharacteristics[characteristicId]!,
        value: writeData);
    //await flutterReactiveBle.writeCharacteristicWithoutResponse(writeCharacteristics[characteristicId]!, value: writeData);
    return;
  }

  Future<void> BLE_ReadCharacteristics(String characteristicId) async {
    List<int> readData = await flutterReactiveBle
        .readCharacteristic(readCharacteristics[characteristicId]!);
    readCharacteristicsInput[characteristicId]!(readData);
  }
}
