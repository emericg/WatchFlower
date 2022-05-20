
<img src="hygrotemp_lywsd03mmc.svg" width="400px" alt="Thermo-Hygrometer 2" align="right" />

## About

* Miaomiaoce (MMC) 'Thermo-Hygrometer' [LYWSDO3MMC]() are hygrometers
* Has sensors to relay temperature and humidity
* Uses Bluetooth Low Energy (BLE) and has a limited range
* A CR2032 coin cell battery is used as power source

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

The name advertised by the devices is `LYWSD03MMC`.  

TODO

## Historical data

TODO

## Advertisement data

LYWSDO3MMC broadcast `service data` with 16 bits service UUID `0xFE95`.  
These data are encrypted and thus not easily exploitable.  

| Position | 00 | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 |
| -------- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| Value    | 30 | 58 | 5b | 05 | 5d | b2 | 68 | c5 | 38 | c1 | a4 | 08 |

| Bytes | Type      | Value             | Description                          |
| ----- | --------- | ----------------- | ------------------------------------ |
| 00-04 | bytes     |                   | -                                    |
| 05-10 | bytes     | A4:C1:38:C5:68:B2 | MAC address                          |
| 11    | bytes     |                   | -                                    |

## Reference

[1] TODO

## License

MIT
