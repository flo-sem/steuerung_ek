import 'package:flutter/material.dart';
import 'ble_info.dart';

class SecondScreen extends StatelessWidget {
  SecondScreen({Key? key}) : super(key: key);

  final ble_info bluetoothProvider = ble_info();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Characteristic Value'),
      ),
      body: Center(
        // Center the content
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center the column itself
          children: <Widget>[
            StreamBuilder<List<int>>(
              stream: bluetoothProvider.charValueStream,
              builder:
                  (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return Text('Not connected to a stream...');
                  case ConnectionState.waiting:
                    return Text('Awaiting values...');
                  case ConnectionState.active:
                  case ConnectionState.done:
                    String valueAsString = snapshot.data
                            ?.map((e) => e.toRadixString(16).padLeft(2, '0'))
                            .join(':') ??
                        'No Data';
                    return Text('Value: $valueAsString');
                  default:
                    return CircularProgressIndicator();
                }
              },
            ),
            SizedBox(height: 20), // Add some spacing
            ElevatedButton(
              onPressed: () async {
                List<int> input = [
                  0x48,
                  0x65,
                  0x6c,
                  0x6c,
                  0x6f,
                  0x20,
                  0x77,
                  0x6f,
                  0x72,
                  0x6c,
                  0x64
                ];
                ble_info().BLE_WriteCharateristics(input);
              },
              child: Text('Press Me'),
            ),
          ],
        ),
      ),
    );
  }
}
