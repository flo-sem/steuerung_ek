import 'package:flutter/material.dart';
import 'ble_info.dart';
import 'state_manager.dart';
import 'package:provider/provider.dart';
import 'main.dart';

class SecondScreen extends StatefulWidget {
  const SecondScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SecondScreen();
}

class _SecondScreen extends State<SecondScreen> {
  @override
  Widget build(BuildContext context) {
    var stateBluetooth = Provider.of<StateBluetooth>(context);
    var stateManager = Provider.of<StateManager>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Characteristic Value'),
      ),
      backgroundColor: stateManager.backgroundColor,
      body: Center(
        // Center the content
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center, // Center the column itself
          children: <Widget>[
            StreamBuilder<List<int>>(
              stream: ble_info().charValueStream,
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
              onPressed: () {
                List<int> input = [
                  0x48
                  /*0x65,
                    0x6c,
                    0x6c,
                    0x6f,
                    0x20,
                    0x77,
                    0x6f,
                    0x72,
                    0x6c,
                    0x64**/
                ];
                ble_info().BLE_WriteCharateristics(input);
              },
              child: Text('Send HelloWorld'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
                onPressed: () {
                  ble_info().BLE_ReadCharacteristics();
                },
                child: Text("Request Data")),
            SizedBox(height: 10),
            Text("recieved: ${stateBluetooth.testBuffer.toString()}")
          ],
        ),
      ),
    );
  }
}
