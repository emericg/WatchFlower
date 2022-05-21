
<img src="hygrotemp_cgdk2.svg" width="400px" alt="Temp and RH Monitor Lite" align="right" />

## About CGDK2

* Qingping 'Temp & RH Monitor Lite' [CGDK2](https://www.qingping.co/temp-rh-monitor-lite/overview) are hygrometers
* Has sensors to relay temperature and humidity
* Uses Bluetooth Low Energy (BLE) and has a limited range
* A CR2430 coin cell battery is used as power source

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

The name advertised by the devices is `Qingping Temp RH Lite`.  

##### Generic access (UUID 00001800-0000-1000-8000-00805f9b34fb)

##### Generic attribute (UUID 00001801-0000-1000-8000-00805f9b34fb)

##### Device information (UUID 0000180a-0000-1000-8000-00805f9b34fb)

##### Data service (UUID 22210000-554a-4546-5542-46534450464d)

| Characteristic UUID                  | Handle | Access      | Description                     |
| ------------------------------------ | ------ | ----------- | ------------------------------- |
| 00000100-0000-1000-8000-00805f9b34fb | -      | notify      | real time data                  |

#### Communication with the device

Register to get notification on the 'real time data' characteristic.  
The device will send back 7 bytes data packets:  

| Bytes | Type      | Value             | Description                          |
| ----- | --------- | ----------------- | ------------------------------------ |
| 00-01 | bytes     |                   | ?                                    |
| 02    | byte      | 236               | battery voltage?                     |
| 03-04 | int16_le  | 198 / 10 = 19.8   | temperature in °C                    |
| 05-06 | int16_le  | 578 / 10 = 57.8   | humidity in % RH                     |

## Historical data

TODO

## Advertisement data

There seems to be two kind of advertisement data broadcasted.  
CGDK2 broadcast `service data` with 16 bits service UUID `0xFE95` and `0xFDCD`.  

##### UUID `0xFE95` 12 bytes messages

Looks like MiBeacon data. Fixed content, no actionable data. Encrypted?

| Position | 00 | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 |
| -------- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| value    | 30 | 58 | 6f | 06 | 02 | XX | XX | 12 | 34 | 2d | 58 | 08 |

| Bytes | Type      | Value             | Description                          |
| ----- | --------- | ----------------- | ------------------------------------ |
| 00-01 | bytes     | 0x3058            | Frame control?                       |
| 02-03 | bytes     | 0x480b            | Product ID?                          |
| 04    | uint8     |                   | Frame count?                         |
| 05-10 | bytes     | 58:2D:34:12:XX:XX | MAC address                          |
| 11    | byte      |                   | ?                                    |

##### UUID `0xFDCD` 17 bytes messages

| Position | 00 | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 | 12 | 13 | 14 | 15 | 16 |
| -------- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| value    | 08 | 10 | 2d | c7 | 12 | 34 | 2d | 58 | 01 | 04 | 31 | 01 | c9 | 01 | 02 | 01 | 51 |

| Bytes | Type      | Value             | Description                          |
| ----- | --------- | ----------------- | ------------------------------------ |
| 00-01 | bytes     | 0x0810            | Product ID?                          |
| 02-07 | bytes     | 58:2D:34:12:XX:XX | MAC address                          |
| 08-09 |           |                   | ?                                    |
| 10-11 | int16_le  | 305 / 10 = 30.5   | temperature in °C                    |
| 12-13 | int16_le  | 457 / 10 = 45.7   | humidity in % RH                     |
| 14-15 | bytes     |                   | ?                                    |
| 16    | byte      | 81                | battery level?                       |

## Reference

[1] -

## License

MIT
