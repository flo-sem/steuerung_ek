/*********
  Rui Santos
  Complete instructions at https://RandomNerdTutorials.com/esp32-ble-server-client/
  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files.
  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
*********/

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <Wire.h>
#include <stdlib.h>

//Alle ReadValues initialisieren
uint8_t chargingState = 0x10; // 16
uint8_t temperature = 0x10;
uint8_t speed = 0x10;
uint8_t pitch = 0x10;
uint8_t roll = 0x10;
uint8_t distanceFrontLeft = 0x70; //112 -> zwei  Balken Abstand
uint8_t distanceFrontMiddle = 0x70;
uint8_t distanceFrontRight = 0x70;
uint8_t distanceLeft = 0x70;
uint8_t distanceRight = 0x70;
uint8_t distanceBack = 0x70;

#define bleServerName "TEST_ESP32"

//#define readCharacteristicOn //Define um ReadCharacteristic zu erstellen

unsigned long lastTime = 0;
unsigned long interval = 1000; //in ms to the next loop

bool deviceConnected = false;

#define SERVICE_UUID1 "2300"

/*Reihenfolge WriteCharacteristic:
  [0] steeringAngle
  [1] pedalState
  [2] leftIndicator
  [3] rightIndicator
  [4] horn                            */

BLECharacteristic WriteCharacteristic("2301", BLECharacteristic::PROPERTY_WRITE);

#ifdef readCharacteristicOn

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

  BLECharacteristic ReadCharacteristic("2302", BLECharacteristic::PROPERTY_READ);
#endif


//Setup callbacks onConnect and onDisconnect
class MyServerCallbacks: public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    printf("connected\n");
    deviceConnected = true;
  };
  void onDisconnect(BLEServer* pServer) {
    printf("disconnected\n");
    deviceConnected = false;
    pServer->getAdvertising()->start();
    printf("Not connected yet...\n");
  }
};

void setup() {

  // Create the BLE Device
  BLEDevice::init(bleServerName);

  // Create the BLE Server
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Create the BLE Service
  BLEService *service = pServer->createService(SERVICE_UUID1);

  // Create BLE Characteristics
  service->addCharacteristic(&WriteCharacteristic);

  #ifdef readCharacteristicOn
    service->addCharacteristic(&ReadCharacteristic);
  #endif
  
  // Start the service
  service->start();

  // Start advertising
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID1);
  pServer->getAdvertising()->start();

  #ifdef readCharacteristicOn
    printf("Read Characteristic is On");
  #endif

  printf("Not connected yet...\n");
}

void loop() {
  if (deviceConnected) {
    if ((millis() - lastTime) > interval) {

      uint8_t readData[11] = {chargingState, temperature, speed, pitch, roll, distanceFrontLeft, distanceFrontMiddle, distanceFrontRight, distanceLeft, distanceRight, distanceBack};

      #ifdef readCharacteristicOn
        ReadCharacteristic.setValue(readData, 11);
      #endif

      uint8_t* writeData = WriteCharacteristic.getData();
      printf("steer:%d ", writeData[0]);
      printf("pedal:%d ", writeData[1]);
      printf("left:%d ", writeData[2]);
      printf("right:%d ", writeData[3]);
      printf("horn:%d\n", writeData[4]);
      
      lastTime = millis();
    }
  }
}
