
<img src="hygrotemp_eink.svg" width="400px" alt="Digital Hygrometer" align="right" />

## About CGG1

* ClearGrass 'Temp and RH' [CGG1]() are hygrometers
* Has sensors to relay temperature and humidity
* Uses Bluetooth Low Energy (BLE) and has a limited range
* A CR2430 coin cell battery is used as power source

There are multiple variant of this device, sold under various names but the same FCC ID:
- ClearGrass **Temp and RH** (CGG1)  
- QingPing **Temp and RH M** (CGG1-M) (NOT COMPATIBLE ATM)  
- QingPing **Temp and RH H** HomeKit edition (CGG1-H) (NOT COMPATIBLE ATM)  

## Features

* Read real-time sensor values
* Read historical sensor values
* Temperature and humidity sensors

## Protocol

The device uses BLE GATT for communication.  
Sensor values are immediately available for reading.  

### BLE & GATT

The basic technologies behind the sensors communication are [Bluetooth Low Energy (BLE)](https://en.wikipedia.org/wiki/Bluetooth_Low_Energy) and [GATT](https://www.bluetooth.com/specifications/gatt).
They allow the devices and the app to share data in a defined manner and define the way you can discover the devices and their services.
In general you have to know about services and characteristics to talk to a BLE device.

<img src="endianness.png" width="400px" alt="Endianness" align="right" />

## Services, characteristics and handles

The name advertised by the devices (CGG1) is `ClearGrass Temp and RH`.
The name advertised by the devices (CGG1-M) is `Qingping Temp and RH M`.
The name advertised by the devices (CGG1-H) is unknown.

##### Generic access (UUID 00001800-0000-1000-8000-00805f9b34fb)

##### Generic attribute (UUID 00001801-0000-1000-8000-00805f9b34fb)

##### Device information (UUID 0000180a-0000-1000-8000-00805f9b34fb)

##### Battery service (UUID 0000180f-0000-1000-8000-00805f9b34fb)

## Advertisement data

TODO

## Reference

[1] -

## License

MIT
