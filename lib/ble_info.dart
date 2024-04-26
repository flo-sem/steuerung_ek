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

  //BLE stuff idfk
  final _ble = FlutterReactiveBle();
  var _bleLogger;
  var _scanner;
  var _monitor;
  var _connector;
  var _serviceDiscoverer;

  StreamSubscription? _scanSubscription;

  // Constants
  static const String DEVICE_NAME = "TEST_ESP32"; //"ESP32-BLE";

  List<Uuid> serviceUUIDs = [
    Uuid.parse('00002300-0000-1000-8000-00805f9b34fb'),
    Uuid.parse('00002400-0000-1000-8000-00805f9b34fb'),
    Uuid.parse('00002500-0000-1000-8000-00805f9b34fb'),
    Uuid.parse('00002600-0000-1000-8000-00805f9b34fb')
  ];

  static const String rAkkuCharacteristicUuid =
      '00002301-0000-1000-8000-00805f9b34fb'; //"2301";
  static const String rSpeedCharacteristicUuid =
      '00002401-0000-1000-8000-00805f9b34fb'; //"2401";
  static const String rTemperatureCharacteristicUuid =
      '00002501-0000-1000-8000-00805f9b34fb'; //"2501";
  static const String rDistanceCharacteristicUuid =
      '00002502-0000-1000-8000-00805f9b34fb'; //"2502";
  static const String rSlopeCharacteristicUuid =
      '00002503-0000-1000-8000-00805f9b34fb'; //"2503";

  static const String wHornCharacteristicUuid =
      '00002601-0000-1000-8000-00805f9b34fb'; //"2601";
  static const String wTurnLeftCharacteristicUuid =
      '00002602-0000-1000-8000-00805f9b34fb'; //"2602";
  static const String wTurnRightCharacteristicUuid =
      '00002603-0000-1000-8000-00805f9b34fb'; //"2603";
  static const String wControlsCharacteristicUuid =
      '00002402-0000-1000-8000-00805f9b34fb'; //"2402";
  static const String wGasCharacteristicUuid =
      '00002403-0000-1000-8000-00805f9b34fb'; //"2403";

  static Map<String, QualifiedCharacteristic> readCharacteristics = {
    'akkuCharacteristic': akkuCharacteristic!,
    'speedCharacteristic': speedCharacteristic!,
    'tempCharacteristic': tempCharacteristic!,
    'distanceCharacteristic': distanceCharacteristic!,
    'slopeCharacteristic': slopeCharacteristic!
  };
  static List<int> lastAkku = [99];
  static List<int> lastSpeed = [99];
  static List<int> lastTemp = [99];
  static List<int> lastDist = [99];
  static List<int> lastSlope = [99];

  static Map<String, List<int>> lastReadValues = {
    'akkuCharacteristic': lastAkku,
    'speedCharacteristic': lastSpeed,
    'tempCharacteristic': lastTemp,
    'distanceCharacteristic': lastDist,
    'slopeCharacteristic': lastSlope
  };

  static List<int> lastHorn = [99];
  static List<int> lastLeft = [99];
  static List<int> lastRight = [99];
  static List<int> lastCtrl = [99];
  static List<int> lastGas = [99];

  static Map<String, List<int>> lastWriteValues = {
    'hornCharacteristic': lastHorn,
    'turnLeftCharacteristic': lastLeft,
    'turnRightCharacteristic': lastRight,
    'controlsCharacteristic': lastCtrl,
    'gasCharacteristic': lastGas
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
    await _ble.requestConnectionPriority(
        deviceId: _discoveredDevice!.id,
        priority: ConnectionPriority.highPerformance);
  }

  void _handleUiChanges() {}

  void _assignCharacteristics() {
    akkuCharacteristic = QualifiedCharacteristic(
        characteristicId: Uuid.parse(rAkkuCharacteristicUuid),
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
    MyAppState().ChangeTextToConnect();
  }

  // Functions for Bluetooth Low Energy
  void BLE_Search() async {
    /*_bleLogger = BleLogger(ble: _ble);
    _scanner = BleScanner(ble: _ble, logMessage: _bleLogger.addToLog);
    _monitor = BleStatusMonitor(_ble);
    _connector = BleDeviceConnector(
      ble: _ble,
      logMessage: _bleLogger.addToLog,
    );
    _serviceDiscoverer = BleDeviceInteractor(
      bleDiscoverServices: (deviceId) async {
        await _ble.discoverAllServices(deviceId);
        return _ble.getDiscoveredServices(deviceId);
      },
      logMessage: _bleLogger.addToLog,
      readRssi: _ble.readRssi,
    );*/
    _scanSubscription?.cancel();
    print("[BLELOG] Started Search!");
    _scanSubscription = _ble.scanForDevices(
      withServices: [], // Optional: UUIDs von Diensten, nach denen gescannt werden soll
      scanMode: ScanMode.lowLatency,
    ).listen((device) {
      if (device.name == DEVICE_NAME) {
        print("[BLELOG] Found ${device.name}");
        _discoveredDevice = device;
        _ble.connectToDevice(id: device.id).listen((connectionState) {
          if (connectionState.connectionState ==
              DeviceConnectionState.connected) {
            _scanSubscription?.cancel();
            print('[BLELOG]Verbunden mit ESP32');
            print('[BLELOG]${device.id}');
            _handleConnected();
            _assignCharacteristics();
            _connectImage();
            _discoverServices();
          }
        });
      }
    });
    // Stop the scan after 5 seconds
    Timer(Duration(seconds: 5), () {
      stopScan();
      print('Scan stopped after 5 seconds');
      if (MyAppState().MainButtonText != "Verbinden")
        MyAppState().ChangeTextBack();
    });
  }

  void stopScan() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  void _discoverServices() {
    _ble.getDiscoveredServices(_discoveredDevice!.id).then((services) {
      //print('[BLELOG] $services');
      int foundCharacteristics = 0;
      for (var service in services) {
        print('[BLELOG] Service: ${service.id}');
        if (serviceUUIDs.contains(service.id)) {
          print('[BLELOG] Found required service ${service.id}');
          for (var characteristic in service.characteristics) {
            print(
                '[BLELOG] Found required characteristic: ${characteristic.id}');
            ++foundCharacteristics;
          }
        }
      }
      print("[BLELOG] Found $foundCharacteristics/10 characteristics");
    }).catchError((e) {
      print('Error discovering services: $e');
    });
  }

  void _discoverAll() {
    _ble.getDiscoveredServices(_discoveredDevice!.id).then((services) {
      //print('[BLELOG] $services');
      int foundCharacteristics = 0;
      for (var service in services) {
        print('[BLELOG] Service: ${service.id}');
        for (var characteristic in service.characteristics) {
          print('[BLELOG] Found characteristic: ${characteristic.id}');
        }
      }
    }).catchError((e) {
      print('Error discovering services: $e');
    });
  }

  void BLE_Connect() async {
    _ble
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
    if (!ListEquality<int>()
        .equals(writeData, lastWriteValues[characteristicId])) {
      _ble.writeCharacteristicWithoutResponse(
          writeCharacteristics[characteristicId]!,
          value: writeData);
      lastWriteValues[characteristicId] = writeData;
      print("[BLELOG] Writing $writeData to $characteristicId");
    }

    //await _ble.writeCharacteristicWithoutResponse(writeCharacteristics[characteristicId]!, value: writeData);
    return;
  }

  Future<void> BLE_ReadCharacteristics(String characteristicId) async {
    List<int> readData =
        await _ble.readCharacteristic(readCharacteristics[characteristicId]!);
    readCharacteristicsInput[characteristicId]!(readData);
    if (!ListEquality<int>()
        .equals(readData, lastReadValues[characteristicId])) {
      lastReadValues[characteristicId] = readData;
      //print( "[BLELOG] Reading char: $characteristicId is: ${readCharacteristics[characteristicId]}");
      print("[BLELOG] Reading $readData from $characteristicId");
    }
  }
}
