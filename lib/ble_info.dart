import 'package:flutter/material.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// Singleton class (jesus help me)
class ble_info {
  static final ble_info _instance = ble_info._internal();
  final String DEVICE_NAME = "BLE Device";
  final String SERVICE_UUID = "00001010-0000-1000-8000-00805f9b34fb";
  final String CHARACTERISTIC_UUID = "00002a00-0000-1000-8000-00805f9b34fb";

  late ScanResult bluetoothDevice;
  Set<DeviceIdentifier> seen = {};

  factory ble_info() {
    return _instance;
  }

  ble_info._internal();

  bool connected = false;
  @override
  Widget build(BuildContext context) {
    // Return an empty container as this widget doesn't display anything
    return Container();
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
            for (String uuid in r.advertisementData.serviceUuids) {
              print("[LOG] FOUND SERVICE $uuid");
            }
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
      if (true /* service.uuid.toString() == SERVICE_UUID */) {
        // Reads all characteristics
        print("[LOG] FOUND SERVICE $index with UUID: ${service.uuid}");
        index++;
        var characteristics = service.characteristics;
        if (!characteristics.isEmpty) {
          for (BluetoothCharacteristic c in characteristics) {
            if (c.properties.read) {
              List<int> value = await c.read();
              print("[LOG] FOUND CHARACTERISTIC ${c.uuid}");
              print("[LOG] with value: $value");

              //CHECK For correct characteristic
              if (value.toString() == CHARACTERISTIC_UUID) {
                print("[LOG] FOUND Characteristic $CHARACTERISTIC_UUID");
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

  void BLE_ReadCharacteristics() async {}
}
