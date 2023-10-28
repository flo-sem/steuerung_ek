import 'package:flutter/material.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ble_info extends StatelessWidget {
  final String DEVICE_NAME = "BLE Device";
  final String SERVICE_UUID = "00001010-0000-1000-8000-00805f9b34fb";
  final String CHARACTERISTIC_UUID = "NEEDS-TO-BE-SET"; //TODO

  late ScanResult bluetoothDevice;
  Set<DeviceIdentifier> seen = {};

  bool connected = false;
  @override
  Widget build(BuildContext context) {
    // Return an empty container as this widget doesn't display anything
    return Container();
  }

  void BLE_Search() async {
    var subscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (seen.contains(r.device.remoteId) == false) {
          // DEBUG STATEMENTS
          print(
              '${r.device.remoteId}: "${r.advertisementData.localName}" found! rssi: ${r.rssi}');
          seen.add(r.device.remoteId);

          // Search for specific device
          if (r.advertisementData.localName == DEVICE_NAME) {
            // Assign device
            bluetoothDevice = r;

            // Stop scanning
            FlutterBluePlus.stopScan();

            // Connect to device
            r.device.connect();

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
    //TODO: Check if device is connected
    //Only start searching if device is connected

    List<BluetoothService> services =
        await bluetoothDevice.device.discoverServices();
    for (BluetoothService service in services) {
      if (service.uuid.toString() == SERVICE_UUID) {
        // Reads all characteristics
        var characteristics = service.characteristics;
        for (BluetoothCharacteristic c in characteristics) {
          if (c.properties.read) {
            List<int> value = await c.read();
            print(value);

            //CHECK For correct characteristic
            if (value == CHARACTERISTIC_UUID) {
              print("FOUND Characteristic $CHARACTERISTIC_UUID");
            }
          }
        }
      }
    }
  }

  void BLE_ReadCharacteristics() async {}
}
