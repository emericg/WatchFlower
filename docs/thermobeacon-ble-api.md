
## About SensorBlue ThermoBeacon

* SensorBlue [ThermoBeacon]() are hygrometers
* Uses Bluetooth Low Energy (BLE) and has a limited range
* A CR2477 battery is used as power source

<img src="thermobeacon_square.svg" width="220px" alt="ThermoBeacon (LCD)" align="right" />
<img src="thermobeacon_round.svg" width="220px" alt="ThermoBeacon (Keychain round)" align="right" />
<img src="thermobeacon_diamond.svg" width="220px" alt="ThermoBeacon (Keychain diamond)" align="right" />

## Variants

* LCD
* Keychain round
* Keychain diamond

## Features

* Read real-time sensor values
* Read historical sensor values
* Temperature
* Hygrometry

## Protocol

The device uses BLE GATT for communication.  
Sensor values are broadcasted, history values are available for reading.  

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

##### Blink

Writing 5 bytes (`0x0400000000`) to the TX handle will make the device blink the onboard LED for a couple of seconds, so you can visualize where it is.

#### Historical data

First of all you need to register to get notification on the RX characteristic.

##### Entry count

Writing 5 bytes (`0x0100000000`) to the TX handle will make the device send back the entry count on RX (Int16).  
The entries (temperature + humidity) are saved every 10 minutes by the sensors. 

##### Device time

The device uptime can be found in the advertisement data. However even without it, it can be approximated at ±10m, because we now know the number of entries and that they are saved each 10m, so device time (in s) = entry count * 600.

##### Read entries

Writing 5 bytes (`0x07XXXX0000`) to the TX handle will make the device send back 3 pair of entries (starting at index XXXX) on RX.  
The index in an 2 bytes integer, little-endian, from 0 to entry count, 0 being the oldest record, entry count the most recent.

The response is as follow:

| Bytes | Type      | Raw value         | Value             | Description           |
| ----- | --------- | ----------------- | ----------------- | --------------------- |
| 00-05 | bytes     | 0x07XXXX0000      |                   | command + idx         |
| 06-07 | int16_le  | 360               | 360/16 = 22.5°    | temperature °C (1)    |
| 08-09 | int16_le  |                   |                   | temperature (2)       |
| 10-11 | int16_le  |                   |                   | temperature (3)       |
| 12-13 | int16_le  | 652               | 652/16 = 40.75%   | humidity %RH (1)      |
| 14-15 | int16_le  |                   |                   | humidity (2)          |
| 16-17 | int16_le  |                   |                   | humidity (3)          |

##### Clear entries

Writing 5 bytes (`0x0200000000`) to the TX handle will clear sensor history and reboot the device.
The onboard LED will also slowly blink three time.

## Advertisement data

There seems to be two kind of advertisement data broadcasted.  
They are `manufacturer data` with company identifier `0x0010`.  

##### 20 bytes message (with seemingly fixed content)

| Position | 00 | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 |
| -------- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| Value    | 00 | 00 | d7 | 2a | 00 | 00 | XX | XX | 8e | 01 | 3d | 7a | 1f | 00 | 4e | 01 | 0a | 80 | 06 | 00 |

| Bytes | Type      | Value             | Description       |
| ----- | --------- | ----------------- | ----------------- |
| 00-01 | bytes     |                   | padding bytes?    |
| 02-07 | bytes     | 91:20:00:00:XX:XX | mac address       |
| 08-19 | bytes     |                   | unknown content   |

##### 18 bytes message (with hygrometer data)

| Position | 00 | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 |
| -------- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| Value    | 00 | 00 | d7 | 2a | 00 | 00 | XX | XX | bd | 0b | 68 | 01 | 8c | 02 | 1c | be | 59 | 00 |

| Bytes | Type      | Raw value         | Value                 | Description           |
| ----- | --------- | ----------------- | --------------------- | --------------------- |
| 00-01 | bytes     |                   |                       | padding bytes?        |
| 02-07 | bytes     |                   | 91:20:00:00:XX:XX     | mac address           |
| 08-09 | int16_le  | 3005              | 3005/1000 = 3.005V    | battery voltage       |
| 10-11 | int16_le  | 360               | 360/16 = 22.5°        | temperature (°C)      |
| 12-13 | int16_le  | 652               | 652/16 = 40.75%       | humidity (%RH)        |
| 14-17 | int32_le  | 5881372           | 5881372/256 = 22974   | device time (s)       |

## Reference

[1] https://github.com/rnlgreen/thermobeacon  

## License

MIT
