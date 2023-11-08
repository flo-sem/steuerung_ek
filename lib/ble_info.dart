import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// Singleton class (jesus help me)
class ble_info {
  static final ble_info _instance = ble_info._internal();
  final String DEVICE_NAME = "Time";
  final String SERVICE_UUID = "00001805-0000-1000-8000-00805f9b34fb";
  final String CHARACTERISTIC_UUID = "00002a2b-0000-1000-8000-00805f9b34fb";

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
    bluetoothDevice.device?.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        // Handle disconnection
        _handleDisconnection();
      }
      // You can handle other states like connecting, connected, and disconnecting similarly
    });
  }

  void _handleDisconnection() {
    // Implement your reconnection strategy here
    // For example, you can try reconnecting or update the UI to show the device is disconnected
    print('Device disconnected');
    // You can call `connectToDevice` again with some delay if you want to reconnect
  }

  void BLE_Search() async {
    print("[LOG] STARTED SEARCHING");
    var subscription = FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        if (seen.contains(r.device.remoteId) == false) {
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

            // Connect to device
            await r.device.connect();

            // Discover services
            BLE_discoverServices();
          }
        }
      }
    });
    // Start scanning
    await FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
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
      //print("[LOG] FOUND SERVICE $index with UUID: ${service.uuid}");
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
              //print("[LOG] FOUND CHARACTERISTIC ${c.uuid}");
              //print("[LOG] with value: $value");

              //CHECK For correct characteristic
              if (c.uuid.toString() == CHARACTERISTIC_UUID) {
                print("[LOG]    FOUND Characteristic $CHARACTERISTIC_UUID");
                print("[LOG]    ---> $value");
                c.read().then((value) {
                  _charValueController.add(value);
                });
                // Listen to characteristic changes
                c.setNotifyValue(true);
                c.lastValueStream.listen((value) {
                  _charValueController.add(value);
                });
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

  void BLE_ReadCharacteristics() async {
    BluetoothCharacteristic characteristic;
  }
}
