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
      body: StreamBuilder<List<int>>(
        stream: bluetoothProvider.charValueStream,
        builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
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
              // Convert the List<int> to a string to display it
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
    );
  }
}
