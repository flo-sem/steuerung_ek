import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'main.dart';
import 'package:vibration/vibration.dart';
import 'package:collection/collection.dart';

// Singleton class (jesus help me)
class ble_info {
  static final ble_info _instance = ble_info._internal();
  static const String DEVICE_NAME = "ESP32-BLE"; //"ESP32 BLE";
  static const String SERVICE_UUID1 = "2300";
  static const String SERVICE_UUID2 = "2400";
  static const String SERVICE_UUID3 = "2500";
  static const String SERVICE_UUID4 = "2600";

  static const String r_AKKU_CHARACTERISTIC_UUID = "2301";
  static const String r_SPEED_CHARACTERISTIC_UUID = "2401";
  static const String r_TEMP_CHARACTERISTIC_UUID = "2501";
  static const String r_DISTANCE_CHARACTERISTIC_UUID = "2502";
  static const String r_SLOPE_CHARACTERISTIC_UUID = "2503";

  static const String w_HORN_CHARACTERISTIC_UUID = "2601";
  static const String w_TURN_LEFT_CHARACTERISTIC_UUID = "2602";
  static const String w_TURN_RIGHT_CHARACTERISTIC_UUID = "2603";
  static const String w_CONTROLS_CHARACTERISTIC_UUID = "2402";
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
  int characteristicsFound = 0;

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

          // Connect to device
          int connectError = 0;
          try {
            await r.device.connect();
          } catch (e) {
            connectError = 1;
            print("[ERROR] on Device connect: $e");
            subscription?.cancel();
            MyAppState().statusImageURL = "assets/images/label_noBT.png";
          }
          if (connectError == 0) {
            Vibration.vibrate(duration: 50, amplitude: 100);
            //change Image faster
            _connectImage();
            MyAppState().fastUpdate();
            //Listen to connection changes
            listenToConnectionChanges();
            // Discover services
            BLE_discoverServices();
          }
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

  bool isCorrectService(BluetoothService service) {
    return [SERVICE_UUID1, SERVICE_UUID2, SERVICE_UUID3, SERVICE_UUID4]
        .any((uuid) => service.uuid.toString() == uuid);
  }

  void assignCharacteristic(BluetoothCharacteristic c) {
    switch (c.uuid.toString()) {
      /* READ CHARACTERISTICS */
      case r_SPEED_CHARACTERISTIC_UUID:
        rSpeedCharacteristic = c;
        characteristicsFound++;
        break;
      case r_AKKU_CHARACTERISTIC_UUID:
        rAkkuCharacteristic = c;
        characteristicsFound++;
        break;
      case r_TEMP_CHARACTERISTIC_UUID:
        rTempCharacteristic = c;
        characteristicsFound++;
        break;
      case r_DISTANCE_CHARACTERISTIC_UUID:
        rDistanceCharacteristic = c;
        characteristicsFound++;
        break;
      case r_SLOPE_CHARACTERISTIC_UUID:
        rSlopeCharacteristic = c;
        characteristicsFound++;
        break;

      /* WRITE CHARACTERISTICS */
      case w_CONTROLS_CHARACTERISTIC_UUID:
        wControlsCharacteristic = c;
        characteristicsFound++;
        break;
      case w_HORN_CHARACTERISTIC_UUID:
        wHornCharacteristic = c;
        characteristicsFound++;
        break;
      case w_TURN_LEFT_CHARACTERISTIC_UUID:
        wTurnLeftCharacteristic = c;
        characteristicsFound++;
        break;
      case w_TURN_RIGHT_CHARACTERISTIC_UUID:
        wTurnRightCharacteristic = c;
        characteristicsFound++;
        break;
      case w_GAS_CHARACTERISTIC_UUID:
        wGasCharacteristic = c;
        characteristicsFound++;
        break;
    }
  }

  //Should ONLY be called, when a device is connected!!!
  void BLE_discoverServices() async {
    print("[LOG] STARTED DISCOVERING SERVICES");
    //TODO: Check if device is connected
    //Only start searching if device is connected
    characteristicsFound = 0;

    List<BluetoothService> services =
        await bluetoothDevice.device.discoverServices();
    int index = 1;

    for (BluetoothService service in services) {
      print("[LOG] FOUND SERVICE $index with UUID: ${service.uuid}");
      index++;
      //print("[LOG] Comparing ${service.uuid.toString()} and ${SERVICE_UUID}");
      if (isCorrectService(service)) {
        // Reads all characteristics
        print("[LOG] ${service.uuid} IS THE CORRECT SERVICE!!");
        var characteristics = service.characteristics;

        if (!characteristics.isEmpty) {
          for (BluetoothCharacteristic characteristic in characteristics) {
            if (characteristic.properties.read) {
              try {
                await characteristic.read();
              } catch (e) {
                print("[ERROR]: $e");
              }
            }
            print("[LOG] FOUND CHARACTERISTIC ${characteristic.uuid}");

            //CHECK For correct characteristic
            assignCharacteristic(characteristic);
          }
          print("[LOG] FOUND $characteristicsFound out of 10 Characteristics");
        } else {
          print("[LOG] NO CHARACTERISTICS FOUND");
        }
      }
    }
  }

  List<int> lastHorn = [99];
  List<int> lastLeft = [99];
  List<int> lastRight = [99];
  List<int> lastControls = [99];
  List<int> lastGas = [99];

  void printOnChangeWrite(String charUUID, List<int> writeData) {
    bool change = false;
    switch (charUUID) {
      case w_HORN_CHARACTERISTIC_UUID:
        if (!ListEquality<int>().equals(lastHorn, writeData)) {
          lastHorn = writeData;
          change = true;
        }
        break;
      case w_TURN_LEFT_CHARACTERISTIC_UUID:
        if (!ListEquality<int>().equals(lastLeft, writeData)) {
          lastLeft = writeData;
          change = true;
        }
        break;
      case w_TURN_RIGHT_CHARACTERISTIC_UUID:
        if (!ListEquality<int>().equals(lastRight, writeData)) {
          lastRight = writeData;
          change = true;
        }
        break;
      case w_CONTROLS_CHARACTERISTIC_UUID:
        if (!ListEquality<int>().equals(lastControls, writeData)) {
          lastControls = writeData;
          change = true;
        }
        break;
      case w_GAS_CHARACTERISTIC_UUID:
        if (!ListEquality<int>().equals(lastGas, writeData)) {
          lastGas = writeData;
          change = true;
        }
        break;
      default:
        print("[ERROR] NO VALID Characteristic selected");
    }
    if (change) {
      print("## WRITING DATA");
      print("[LOG][DATA] WRITING ${lastHorn} to HORN");
      print("[LOG][DATA] WRITING ${lastLeft} to TURN LEFT");
      print("[LOG][DATA] WRITING ${lastRight} to TURN RIGHT");
      print("[LOG][DATA] WRITING ${lastControls} to TURN CONTROLS");
      print("[LOG][DATA] WRITING ${lastGas} to TURN GAS");
    }
  }

  Future<void> BLE_WriteCharateristics(
      BluetoothCharacteristic? writeCharacteristic, List<int> writeData) async {
    if (writeCharacteristic != null) {
      printOnChangeWrite(writeCharacteristic.uuid.toString(), writeData);
      try {
        await writeCharacteristic.write(writeData);
      } catch (e) {
        print("[ERROR] on Write to Characteristic: $e");
      }
    }
  }

  List<int> lastSpeed = [99];
  List<int> lastAkku = [99];
  List<int> lastTemp = [99];
  List<int> lastDistance = [99];
  List<int> lastSlope = [99];

  void printOnChangeRead(String charUUID, List<int> readData) {
    bool change = false;
    switch (charUUID) {
      case r_SPEED_CHARACTERISTIC_UUID:
        MyAppState().SpeedInputBuffer(readData);
        if (!ListEquality<int>().equals(lastSpeed, readData)) {
          lastSpeed = readData;
          change = true;
        }
        break;
      case r_AKKU_CHARACTERISTIC_UUID:
        MyAppState().AkkuInputBuffer(readData);
        if (!ListEquality<int>().equals(lastAkku, readData)) {
          lastAkku = readData;
          change = true;
        }
        break;
      case r_TEMP_CHARACTERISTIC_UUID:
        MyAppState().TempInputBuffer(readData);
        if (!ListEquality<int>().equals(lastTemp, readData)) {
          lastTemp = readData;
          change = true;
        }
        break;
      case r_DISTANCE_CHARACTERISTIC_UUID:
        MyAppState().DistanceInputBuffer(readData);
        if (!ListEquality<int>().equals(lastDistance, readData)) {
          lastDistance = readData;
          change = true;
        }
        break;
      case r_SLOPE_CHARACTERISTIC_UUID:
        MyAppState().SlopeInputBuffer(readData);
        if (!ListEquality<int>().equals(lastSlope, readData)) {
          lastSlope = readData;
          change = true;
        }
        break;
      default:
        print("[ERROR] NO VALID Characteristic selected");
    }
    if (change) {
      print("## READING DATA");
      print("[LOG][DATA] READING ${lastSpeed} from SPEED");
      print("[LOG][DATA] READING ${lastAkku} from AKKU");
      print("[LOG][DATA] READING ${lastTemp} from TEMP");
      print("[LOG][DATA] READING ${lastDistance} from DISTANCE");
      print("[LOG][DATA] READING ${lastSlope} from SLOPE");
    }
  }

  Future<void> BLE_ReadCharacteristics(
      BluetoothCharacteristic? readCharacteristic) async {
    if (readCharacteristic == null) {
      print("[ERROR] readCharacteristic is null");
      return;
    }
    try {
      await readCharacteristic.read().then((value) {
        printOnChangeRead(readCharacteristic.uuid.toString(), value);
      });
    } catch (e) {
      print("[ERROR] Exception while reading characteristics: $e");
    }
  }
}
