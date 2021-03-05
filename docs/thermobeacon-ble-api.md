
<img src="thermobeacon_square.svg" width="256px" alt="ThermoBeacon" align="right" />
<img src="thermobeacon_round.svg" width="256px" alt="ThermoBeacon" align="right" />

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

The name advertised by the devices is `ThermoBeacon`, for both keychain and LCD devices.

##### Generic access (UUID 00001800-0000-1000-8000-00805f9b34fb)

| Characteristic UUID                  | Handle | Access      | Description                     |
| ------------------------------------ | ------ | ----------- | ------------------------------- |
| 00002a00-0000-1000-8000-00805f9b34fb | 0x03   | read        | device name                     |

##### Device Information (UUID 0000180a-0000-1000-8000-00805f9b34fb)

| Characteristic UUID                  | Handle | Access      | Description                     |
| ------------------------------------ | ------ | ----------- | ------------------------------- |
| -                                    | -      | -           | -                               |

##### Communication service (UUID 0000ffe0-0000-1000-8000-00805f9b34fb)

| Characteristic UUID                  | Handle | Access      | Description                     |
| ------------------------------------ | ------ | ----------- | ------------------------------- |
| 0000fff3-0000-1000-8000-00805f9b34fb | 0x24   | notify      | RX                              |
| 0000fff5-0000-1000-8000-00805f9b34fb | 0x21   | write       | TX                              |

#### Communication with the device

TODO

## Advertisement data

There seems to be two kind of advertisement message broadcasted.  
One with 20 bytes of seemingly fixed content, and one of 18 bytes with hygrometer data.

##### 20 bytes message

| Position | 00 | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 |
| -------- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| Value    | 00 | 00 | d7 | 2a | 00 | 00 | XX | XX | 8e | 01 | 3d | 7a | 1f | 00 | 4e | 01 | 0a | 80 | 06 | 00 |

| Bytes | Type      | Value             | Description       |
| ----- | --------- | ----------------- | ----------------- |
| 00-01 | bytes     |                   | padding bytes?    |
| 02-07 | bytes     | 91:20:00:00:XX:XX | mac address       |
| 08-19 | bytes     |                   | unknown content   |

##### 18 bytes message

| Position | 00 | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 |
| -------- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| Value    | 00 | 00 | d7 | 2a | 00 | 00 | XX | XX | bd | 0b | 68 | 01 | 8c | 02 | 1c | be | 59 | 00 |

| Bytes | Type      | Raw value         | Value                 | Description           |
| ----- | --------- | ----------------- | --------------------- | --------------------- |
| 00-01 | bytes     |                   |                       | padding bytes?        |
| 02-07 | bytes     |                   | 91:20:00:00:XX:XX     | mac address           |
| 08-09 | Int16     | 3005              | 3005/1000 = 3.005V    | battery voltage?      |
| 10-11 | Int16     | 360               | 360/16 = 22.5°        | temperature (°C)      |
| 12-13 | Int16     | 652               | 652/16 = 40.75%       | humidity (%RH)        |
| 14-17 | Int32     | 5881372           | 5881372/256 = 22974   | device time (s)       |

## Reference

[1] https://github.com/rnlgreen/thermobeacon  

## License

MIT
