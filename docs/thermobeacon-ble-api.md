
<img src="thermobeacon_round.svg" width="400px" alt="ThermoBeacon" align="right" />

## About SensorBlue ThermoBeacon

* SensorBlue [ThermoBeacon]() are hygrometers
* Has sensors to relay temperature and hygrometry
* Uses Bluetooth Low Energy (BLE) and has a limited range
* A CR2032 battery is used as power source

## Features

* Read real-time sensor values
* Read historical sensor values
* Temperature
* Hygrometry

## Protocol

The device uses BLE GATT for communication.  
Sensor values are immediately available for reading, but usually require elaborate conversions.  
In order to limit connection time, the Parrot Pot device may disconnect from the application after a certain amount of time (around 1s) without incoming BLE request.

### BLE & GATT

The basic technologies behind the sensors communication are [Bluetooth Low Energy (BLE)](https://en.wikipedia.org/wiki/Bluetooth_Low_Energy) and [GATT](https://www.bluetooth.com/specifications/gatt).
They allow the devices and the app to share data in a defined manner and define the way you can discover the devices and their services.
In general you have to know about services and characteristics to talk to a BLE device.

<img src="endianness.png" width="400px" alt="Endianness" align="right" />

### Data structure

The data is encoded in little-endian byte order.  
This means that the data is represented with the least significant byte first.

To understand multi-byte integer representation, you can read the [endianness](https://en.wikipedia.org/wiki/Endianness) Wikipedia page.

## Services, characteristics and handles

The name advertised by the devices is `ThermoBeacon`

##### Generic access (UUID 00001800-0000-1000-8000-00805f9b34fb)

| Characteristic UUID                  | Handle | Access      | Description                   |
| ------------------------------------ | ------ | ----------- | ----------------------------- |
| 00002a00-0000-1000-8000-00805f9b34fb | 0x03   | read        | device name                   |

##### Device Information (UUID 0000180a-0000-1000-8000-00805f9b34fb)

| Characteristic UUID                  | Handle | Access      | Description                   |
| ------------------------------------ | ------ | ----------- | ----------------------------- |

##### Communication service (UUID 0000ffe0-0000-1000-8000-00805f9b34fb)

| Characteristic UUID                  | Handle | Access      | Description                   |
| ------------------------------------ | ------ | ----------- | ----------------------------- |
| 0000fff3-0000-1000-8000-00805f9b34fb | 0x24   | notify      | RX                            |
| 0000fff5-0000-1000-8000-00805f9b34fb | 0x21   | write       | TX                            |

## Advertisement data

TODO

## Reference

[1] https://developer.parrot.com/docs/FlowerPower/FlowerPower-BLE.pdf  

## License

MIT
