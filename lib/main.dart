import 'package:flutter/material.dart';
import 'steering_wheel.dart';
import 'gas_pedal.dart';
import 'info_display.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'shopping cart control',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
      home: StartPage(title: 'Start Menu'),
    );
  }
}

class StartPage extends StatelessWidget {
  StartPage({Key? key, required this.title}) : super(key: key);

  void ConnectThisFucker() async {
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      print(state);
      if (state == BluetoothAdapterState.on) {
        Set<DeviceIdentifier> seen = {};
        var subscription = FlutterBluePlus.scanResults.listen(
          (results) {
            for (ScanResult r in results) {
              if (seen.contains(r.device.remoteId) == false) {
                print(
                    '${r.device.remoteId}: "${r.advertisementData.localName}" found! rssi: ${r.rssi}');
                seen.add(r.device.remoteId);
              }
            }
          },
        );

        // Start scanning
        //await FlutterBluePlus.startScan();
      } else {
        // show an error to the user, etc
      }
    });
  }

  final String title; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Einkaufswagen Steuerung')),
        body: Stack(children: <Widget>[
          Align(
              alignment: Alignment.topRight,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const SettingsPage(title: 'SettingPage');
                    }));
                  },
                  child: const Text('Settings'))),
          Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // ← Add this.
                  children: [
                Image.asset(
                  'assets/images/Wifi.png',
                  height: 200,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () async {
                      Set<DeviceIdentifier> seen = {};
                      await FlutterBluePlus.startScan(
                          timeout: Duration(seconds: 10));
                      print("START");
                      FlutterBluePlus.scanResults.listen((results) {
                        for (ScanResult r in results) {
                          /*if (!(r.advertisementData.serviceUuids.isEmpty)) {
                            print("Service UUID available");
                            print(r);
                          }*/
                          if (seen.contains(r.device.remoteId) == false &&
                              r.advertisementData.localName != "") {
                            print(
                                '${r.device.remoteId}: "${r.advertisementData.localName}" found! rssi: ${r.rssi}');
                            seen.add(r.device.remoteId);
                          }

                          if (r.advertisementData.localName == "BLE Device") {
                            print("###############");
                            print(r.advertisementData.serviceUuids);
                            print(r.device);
                            print(r.advertisementData.toString());
                            print("###############");

                            FlutterBluePlus.stopScan();
                          }
                        }
                      });
                    },
                    child: const Text('Connect')),
                SizedBox(height: 50),
              ]))
        ]));
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('SETTINGS')),
        body: Align(
            alignment: Alignment.topLeft,
            child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('back'))));
  }
}

class ControlPage extends StatelessWidget {
  const ControlPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CONTROL')),
      body: Stack(children: <Widget>[
        Align(
            alignment: Alignment.topLeft,
            child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('back'))),
        const SteeringWheel(),
        const GasPedal(),
        const SpeedDisplay(),
      ]),
    );
  }
}
