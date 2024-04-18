import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'main.dart';

// Singleton class (jesus help me)
class ble_info {
  static final ble_info _instance = ble_info._internal();
  static const String DEVICE_NAME = "Blank"; //"ESP32 BLE";
  static const String SERVICE_UUID =
      "1111"; //"000000ff-0000-1000-8000-00805f9b34fb";

  static const String r_AKKU_CHARACTERISTIC_UUID = "2301";
  static const String r_SPEED_CHARACTERISTIC_UUID = "2222";
  static const String r_TEMP_CHARACTERISTIC_UUID = "2501";
  static const String r_DISTANCE_CHARACTERISTIC_UUID = "2502";
  static const String r_SLOPE_CHARACTERISTIC_UUID = "2503";

  static const String w_HORN_CHARACTERISTIC_UUID = "2601";
  static const String w_TURN_LEFT_CHARACTERISTIC_UUID = "2602";
  static const String w_TURN_RIGHT_CHARACTERISTIC_UUID = "2603";
  static const String w_CONTROLS_CHARACTERISTIC_UUID = "9999";
  static const String w_GAS_CHARACTERISTIC_UUID = "2403";

  //"00002a2b-0000-1000-8000-00805f9b34fb";

  BluetoothCharacteristic? rAkkuCharacteristic;
  BluetoothCharacteristic? rSpeedCharacteristic;
  BluetoothCharacteristic? rTempCharacteristic;
  BluetoothCharacteristic? rDistanceCharacteristic;
  BluetoothCharacteristic? rSlopeCharacteristic;

  BluetoothCharacteristic? wHornCharacteristic;
  BluetoothCharacteristic? wTurnLeftCharacteristic;
  BluetoothCharacteristic? wTurnRightCharacteristic;
  BluetoothCharacteristic? wControlsCharacteristic;
  BluetoothCharacteristic? wGasCharacteristic;

  List<int> inputBuffer = [];

  //TODO: Maybe introduce list with Characteristics, and select dem with ID
  // OR : Name the Characteristic UUID after their purpouse

  late ScanResult bluetoothDevice;
  Set<DeviceIdentifier> seen = {};

  factory ble_info() {
    return _instance;
  }

  ble_info._internal();
  //Streams for keeping up with changes in the "Read Characteristics"
  final StreamController<List<int>> _charValueController =
      StreamController<List<int>>.broadcast();

  Stream<List<int>> get charValueStream => _charValueController.stream;

  // Call this method after connecting to a device to listen for disconnections
  void listenToConnectionChanges() {
    bluetoothDevice.device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        MyAppState().setImage(ConnectionStateImage.disconnected);
        MyAppState().ChangeTextBack();
        _handleDisconnection();
      }
      if (state == BluetoothConnectionState.connected) {
        _connectImage();
      }
      // Maybe other states?
    });
  }

  void _handleDisconnection() {
    //Future.delayed(Duration(seconds: 2)); //Wait 2 seconds
    //bluetoothDevice.device.connect();
    print('Device disconnected');
  }

  void _connectImage() {
    MyAppState().setImage(ConnectionStateImage.connected);
  }

  var subscription;
  void BLE_Search() async {
    // Maybe this is causing issues?
    await FlutterBluePlus.stopScan();
    subscription?.cancel();
    // Start scanning
    await FlutterBluePlus.startScan(timeout: Duration(seconds: 5));

    print("[LOG] STARTED SEARCHING");
    subscription = FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        // DEBUG STATEMENTS
        // Search for specific device
        if (r.advertisementData.advName == DEVICE_NAME) {
          // Assign device
          bluetoothDevice = r;
          print("[LOG] FOUND DEVICE $DEVICE_NAME");
          /*for (String uuid in r.advertisementData.serviceUuids) {
              print("[LOG] FOUND SERVICE $uuid");
            }*/
          // Stop scanning
          FlutterBluePlus.stopScan();
          // Cancel subscription
          subscription.cancel();
          //change Image faster
          _connectImage();
          MyAppState().fastUpdate();
          // Connect to device
          await r.device.connect();
          //Listen to connection changes
          listenToConnectionChanges();
          // Discover services
          BLE_discoverServices();
        }
      }
    });
    // Start scanning
    // Set up a timer to stop scanning after 5 seconds
    Timer(Duration(seconds: 5), () {
      if (!subscription.isPaused) {
        print("[LOG] SCAN TIMEOUT");
        FlutterBluePlus.stopScan();
        subscription.cancel();
      }
    });
  }

  //Should ONLY be called, when a device is connected!!!
  void BLE_discoverServices() async {
    print("[LOG] STARTED DISCOVERING SERVICES");
    //TODO: Check if device is connected
    //Only start searching if device is connected
    List<BluetoothService> services =
        await bluetoothDevice.device.discoverServices();
    int index = 1;
    int found = 0;
    for (BluetoothService service in services) {
      print("[LOG] FOUND SERVICE $index with UUID: ${service.uuid}");
      index++;
      //print("[LOG] Comparing ${service.uuid.toString()} and ${SERVICE_UUID}");
      if (service.uuid.toString() == SERVICE_UUID) {
        // Reads all characteristics
        print("[LOG] ${service.uuid} IS THE CORRECT SERVICE!!");
        var characteristics = service.characteristics;
        if (!characteristics.isEmpty) {
          for (BluetoothCharacteristic c in characteristics) {
            if (c.properties.read) {
              List<int>? value;
              try {
                value = await c.read();
              } catch (e) {
                print("[ERROR]: $e");
              }
              print("[LOG] FOUND CHARACTERISTIC ${c.uuid}");
              //print("[LOG] with value: $value");

              //CHECK For correct characteristic
              switch (c.uuid.toString()) {
                /* READ CHARACTERISTICS */
                case r_SPEED_CHARACTERISTIC_UUID:
                  rSpeedCharacteristic = c;
                  found++;
                case r_AKKU_CHARACTERISTIC_UUID:
                  rAkkuCharacteristic = c;
                  found++;
                  break;
                case r_TEMP_CHARACTERISTIC_UUID:
                  rTempCharacteristic = c;
                  found++;
                  break;
                case r_DISTANCE_CHARACTERISTIC_UUID:
                  rDistanceCharacteristic = c;
                  found++;
                  break;
                case r_SLOPE_CHARACTERISTIC_UUID:
                  rSlopeCharacteristic = c;
                  found++;
                  break;

                /* WRITE CHARACTERISTICS */
                case w_CONTROLS_CHARACTERISTIC_UUID:
                  wControlsCharacteristic = c;
                  found++;
                  break;
                case w_HORN_CHARACTERISTIC_UUID:
                  wHornCharacteristic = c;
                  found++;
                  break;
                case w_TURN_LEFT_CHARACTERISTIC_UUID:
                  wTurnLeftCharacteristic = c;
                  found++;
                  break;
                case w_TURN_RIGHT_CHARACTERISTIC_UUID:
                  wTurnRightCharacteristic = c;
                  found++;
                  ;
                  break;
                case w_GAS_CHARACTERISTIC_UUID:
                  wGasCharacteristic = c;
                  found++;
                  break;
              }
            }
          }
          print("[LOG] FOUND $found out of 10 Characteristics");
        } else {
          print("[LOG] NO CHARACTERISTICS FOUND");
        }
      }
    }
  }

  Future<void> BLE_WriteCharateristics(
      BluetoothCharacteristic? writeCharacteristic, List<int> writeData) async {
    print("[LOG] WRITING CHARACTERISTICS");
    print("[LOG] ----> ${writeData.toString()}");
    if (writeCharacteristic != null) {
      await writeCharacteristic.write(writeData);
    }
  }

  Future<void> BLE_ReadCharacteristics(
      BluetoothCharacteristic? readCharacteristic) async {
    if (readCharacteristic == null) {
      print("[ERROR] readCharacteristic is null");
      return;
    }

    print("[LOG] READING CHARACTERISTICS");
    try {
      await readCharacteristic.read().then((value) {
        switch (readCharacteristic.uuid.toString()) {
          case (r_SPEED_CHARACTERISTIC_UUID):
            MyAppState().SpeedInputBuffer(value);
            print("[LOG] Speed: ${value.toString()}");
            break;
          case r_AKKU_CHARACTERISTIC_UUID:
            MyAppState().AkkuInputBuffer(value);
            print("[LOG] Akku: ${value.toString()}");
            break;
          case r_TEMP_CHARACTERISTIC_UUID:
            MyAppState().TempInputBuffer(value);
            print("[LOG] Temp: ${value.toString()}");
            break;
          case r_DISTANCE_CHARACTERISTIC_UUID:
            MyAppState().DistanceInputBuffer(value);
            print("[LOG] Distance: ${value.toString()}");
            break;
          case r_SLOPE_CHARACTERISTIC_UUID:
            MyAppState().SlopeInputBuffer(value);
            print("[LOG] Slope: ${value.toString()}");
            break;
          default:
            print("[ERROR] NO VALID Characteristic selected");
        }
      });
    } catch (e) {
      print("[ERROR] Exception while reading characteristics: $e");
    }
  }
}
