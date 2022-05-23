
<img src="hygrotemp_cgg1.svg" width="400px" alt="Temp and RH Monitor" align="right" />

## About CGG1

* ClearGrass / Qingping 'Temp & RH Monitor' [CGG1](https://www.qingping.co/temp-rh-monitor/overview) are hygrometers
* Has sensors to relay temperature and humidity
* Uses Bluetooth Low Energy (BLE) and has a limited range
* A CR2430 coin cell battery is used as power source

There are multiple variant of this device, sold under various names but the same product ID:
- ClearGrass **Temp and RH Monitor** (CGG1)  
- Qingping **Temp and RH M Monitor** (CGG1-M)  
- Qingping **Temp and RH H Monitor** HomeKit edition (CGG1-H) (NOT COMPATIBLE)  

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

### Data structure

Bluetooth payload data typically uses little-endian byte order.  
This means that the data is represented with the least significant byte first.  

To understand multi-byte integer representation, you can read the [endianness](https://en.wikipedia.org/wiki/Endianness) Wikipedia page.

## Services, characteristics and handles

The name advertised by the devices (CGG1) is `ClearGrass Temp and RH`.  
The name advertised by the devices (CGG1-M) is `Qingping Temp and RH M`.  
The name advertised by the devices (CGG1-H) is `unknown`.  

##### Generic access (UUID 00001800-0000-1000-8000-00805f9b34fb)

##### Generic attribute (UUID 00001801-0000-1000-8000-00805f9b34fb)

##### Device information (UUID 0000180a-0000-1000-8000-00805f9b34fb)

##### Battery service (UUID 0000180f-0000-1000-8000-00805f9b34fb)

(Only for Qingping variants)

##### Data service (UUID 22210000-554a-4546-5542-46534450464d)

| Characteristic UUID                  | Access      | Description                     |
| ------------------------------------ | ----------- | ------------------------------- |
| 00000100-0000-1000-8000-00805f9b34fb | notify      | real time data                  |

#### Communication with the device

Register to get notification on the 'real time data' characteristic.  
The device will send back 6 bytes data packets:

| Bytes | Type      | Value                 | Description                      |
| ----- | --------- | --------------------- | -------------------------------- |
| 00-01 | bytes     |                       | ?                                |
| 02-03 | int16_le  | 198 / 10 = 19.8       | temperature in °C                |
| 04-05 | int16_le  | 578 / 10 = 57.8       | humidity in % RH                 |

(Qingping variants doesn't seem to send back any data)

## Historical data

TODO

## Advertisement data

There seems to be two kind of advertisement data broadcasted.  
CGG1 broadcast `service data` with 16 bits service UUID `0xFE95` and `0xFDCD`.  

##### UUID `0xFE95` 14-16 bytes messages

Check out the [MiBeacon](mibeacon-ble-api.md) protocol page to get more information on advertisement data for this device.  

The CGG1 has 'regular' MiBeacon data.  

| Position | 00 | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 | 12 | 13 | 14 | 15 |
| -------- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| value    | 50 | 20 | 47 | 03 | 0F | XX | XX | 10 | 34 | 2d | 58 | 0d | 10 | 04 | 2B | 01 |

| Bytes | Type      | Value             | Description                          |
| ----- | --------- | ----------------- | ------------------------------------ |
| 00-01 | bytes     | 0x5020            | Frame control                        |
| 02-03 | bytes     | 0x4703            | Product ID                           |
| 04    | uint8     |                   | Frame count                          |
| 05-10 | bytes     | 58:2D:34:10:XX:XX | MAC address                          |
| 11    | byte      |                   | ?                                    |
| 12-13 | bytes     |                   | Type of mesurement (temperature)     |
| 14-15 | int16_le  |                   | temperature in °C                    |

The CGG1-M has 'fixed content' MiBeacon data. No actionable data. Encrypted?  

| Position | 00 | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 | 12 | 13 |
| -------- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| value    | 30 | 58 | 48 | 0b | 01 | XX | XX | 12 | 34 | 2d | 58 | 28 | 01 | 00 |

| Bytes | Type      | Value             | Description                          |
| ----- | --------- | ----------------- | ------------------------------------ |
| 00-01 | bytes     | 0x3058            | Frame control?                       |
| 02-03 | bytes     | 0x480b            | Product ID?                          |
| 04    | uint8     |                   | Frame count?                         |
| 05-10 | bytes     | 58:2D:34:12:XX:XX | MAC address                          |
| 11-13 | bytes     |                   | ?                                    |

##### UUID `0xFDCD` 17 bytes messages

CGG1 and CGG1-M broadcast temperature, humidity, and battery over `service data` with the `0xFDCD` 16 bits service UUID.  

Check out the [Qingping](qingping-ble-api.md) protocol page to get more information on advertisement data for this device.  

| Position | 00 | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 | 12 | 13 | 14 | 15 | 16 |
| -------- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| value    | 88 | 16 | XX | XX | 12 | 34 | 2d | 58 | 01 | 04 | 1d | 01 | d5 | 01 | 02 | 01 | 55 |

| Bytes | Type      | Value             | Description                          |
| ----- | --------- | ----------------- | ------------------------------------ |
| 00-01 | bytes     | 0x8816            | Product ID?                          |
| 02-07 | bytes     | 58:2D:34:12:XX:XX | MAC address                          |
| 08    | byte      |                   | payload type (temperature+humidity)  |
| 09    | uint8     |                   | payload size (2 bytes of data)       |
| 10-11 | int16_le  | 285 / 10 = 28.5   | temperature in °C                    |
| 12-13 | int16_le  | 469 / 10 = 46.9   | humidity in % RH                     |
| 14    | byte      |                   | payload type (battery level)         |
| 15    | uint8     |                   | payload size (1 byte of data)        |
| 16    | uint8     | 85                | battery level in %                   |

## Reference

[1] -  

## License

MIT
