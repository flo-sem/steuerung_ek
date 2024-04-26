import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'main.dart';
import 'package:vibration/vibration.dart';

// Singleton class (jesus help me)
class ble_info {
  /*Reihenfolge WriteCharacteristic:
  [0] chargingState
  [1] temperature
  [2] speed
  [3] pitch
  [4] roll
  [5] distanceFrontLeft
  [6] distanceFrontMiddle
  [7] distanceFrontRight
  [8] distanceLeft
  [9] distanceRight
  [10] distanceBack                    */

  /*Reihenfolge WriteCharacteristic:
  [0] steeringAngle
  [1] pedalState
  [2] leftIndicator
  [3] rightIndicator
  [4] horn                            */

  // Singleton Setup
  static final ble_info _instance = ble_info._internal();
  factory ble_info() {
    return _instance;
  }
  ble_info._internal();

  // Configuration Paramters for the BLE Serverr
  static const String DEVICE_NAME = "TEST_ESP32"; //"ESP32 BLE";
  static const String ServiceUUID = "2300";

  static const String writeCharacteristicUuid = "2301";
  static const String readCharacteristicUuid = "2302";

  //Variables for the different BLE Objects
  BluetoothDevice? bluetoothDevice;
  var subscription;

  BluetoothCharacteristic? readCharacteristic;
  BluetoothCharacteristic? writeCharacteristic;

  int characteristicsFound = 0;

  /**********************
   *     FUNCTIONS      *
   **********************/

  // Initialising the connection
  void BLE_Search() async {
    // Maybe this is causing issues?
    await FlutterBluePlus.stopScan();
    subscription?.cancel();
    // Start scanning
    await FlutterBluePlus.startScan(
        withNames: const [DEVICE_NAME], timeout: const Duration(seconds: 5));

    subscription = FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        if (r.advertisementData.advName == DEVICE_NAME) {
          print("[LOG] FOUND DEVICE $DEVICE_NAME");
          FlutterBluePlus.stopScan(); // Stop scanning
          bluetoothDevice = r.device; // Assign device
          try {
            await bluetoothDevice?.connect(); // Connect to the device
            Vibration.vibrate(duration: 50, amplitude: 100);
            MyAppState().setImage(ConnectionStateImage.connected);
            MyAppState().fastUpdate();
            // Listen to connection state changes
            subscription = bluetoothDevice?.connectionState
                .listen((BluetoothConnectionState state) async {
              if (state == BluetoothConnectionState.disconnected) {
                print("${bluetoothDevice?.disconnectReason}");
                // Implement reconnection strategy here
              }
            });
            // Discover services
            BLE_discoverServices();
          } catch (e) {
            print("[ERROR] on Device connect: $e");
            subscription?.cancel();
            MyAppState().statusImageURL = "assets/images/label_noBT.png";
          }
        }
      }
    });
  }

  void BLE_discoverServices() async {
    characteristicsFound = 0;

    List<BluetoothService> services = await bluetoothDevice!.discoverServices();

    for (BluetoothService service in services) {
      if (service.uuid.toString() == ServiceUUID) {
        // Reads all characteristics
        var characteristics = service.characteristics;

        if (!characteristics.isEmpty) {
          for (BluetoothCharacteristic characteristic in characteristics) {
            _assignCharacteristic(characteristic);
          }
          print("[LOG] FOUND $characteristicsFound/2 Characteristics");
        }
      }
    }
  }


  // Read / Write to characteristic
  Future<void> BLE_WriteCharateristics(List<int> writeData) async {
    if (writeCharacteristic != null) {
      try {
        await writeCharacteristic!.write(writeData);
      } catch (e) {
        print("[ERROR] on Write to Characteristic: $e");
      }
    }
  }

  Future<void> BLE_ReadCharacteristics() async {
    if (readCharacteristic != null) {
      try {
        await readCharacteristic!.read().then((value) {
          MyAppState().readBuffer = value;
        });
      } catch (e) {
        print("[ERROR] Exception while reading characteristics: $e");
      }
    }
  }

  //Helper functions
  void _assignCharacteristic(BluetoothCharacteristic c) {
    switch (c.uuid.toString()) {
      /* READ CHARACTERISTICS */
      case writeCharacteristicUuid:
        writeCharacteristic = c;
        characteristicsFound++;
        break;
      case readCharacteristicUuid:
        readCharacteristic = c;
        characteristicsFound++;
        break;
    }
  }
}
