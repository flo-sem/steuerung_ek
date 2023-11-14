import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// Singleton class (jesus help me)
class ble_info {
  static final ble_info _instance = ble_info._internal();
  final String DEVICE_NAME = "Blank"; //"ESP32 BLE";
  final String SERVICE_UUID =
      "00001111-0000-1000-8000-00805f9b34fb"; //"000000ff-0000-1000-8000-00805f9b34fb";
  final String READ_CHARACTERISTIC_UUID =
      "00002222-0000-1000-8000-00805f9b34fb";
  //"0000ff01-0000-1000-8000-00805f9b34fb";
  final String WRITE_CHARACTERISTIC_UUID =
      "00002222-0000-1000-8000-00805f9b34fb";
  //"00002a2b-0000-1000-8000-00805f9b34fb";

  BluetoothCharacteristic? readCharacteristic;
  BluetoothCharacteristic? writeCharacteristic;

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
        // Handle disconnection
        _handleDisconnection();
      }
      // Maybe other states?
    });
  }

  void _handleDisconnection() {
    Future.delayed(Duration(seconds: 2)); //Wait 2 seconds
    bluetoothDevice.device.connect();
    print('Device disconnected');
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
        /* print(
              '${r.device.remoteId}: "${r.advertisementData.localName}" found! rssi: ${r.rssi}');
          seen.add(r.device.remoteId); */
        // Search for specific device
        if (r.advertisementData.localName == DEVICE_NAME) {
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
    for (BluetoothService service in services) {
      print("[LOG] FOUND SERVICE $index with UUID: ${service.uuid}");
      index++;
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
              if (c.uuid.toString() == READ_CHARACTERISTIC_UUID) {
                readCharacteristic = c;
                print(
                    "[LOG]    FOUND readCharacteristic $READ_CHARACTERISTIC_UUID");
                print("[LOG]    ---> $value");
                c.read().then((value) {
                  _charValueController.add(value);
                });
                // Listen to characteristic changes
                /*c.setNotifyValue(true);
                c.lastValueStream.listen((value) {
                  _charValueController.add(value);
                });*/
              } else if (c.uuid.toString() == WRITE_CHARACTERISTIC_UUID) {
                writeCharacteristic = c;
                print(
                    "[LOG]    FOUND writeCharacteristic $READ_CHARACTERISTIC_UUID");
              }
            } /* else {
              print("[LOG] CHARACTERISTIC NOT READABLE");
            } */
          }
        } else {
          print("[LOG] NO CHARACTERISTICS FOUND");
        }
      }
    }
  }

  void BLE_WriteCharateristics(List<int> writeData) async {
    if (writeCharacteristic != null) {
      await writeCharacteristic?.write(writeData);
    }
  }

  // Backup function in case the "notifier" doesnt work
  void BLE_ReadCharacteristics() async {
    if (readCharacteristic != null) {
      readCharacteristic?.read().then((value) {
        inputBuffer = value;
      });
    }
  }
}
