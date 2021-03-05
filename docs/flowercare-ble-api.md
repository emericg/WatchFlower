
<img src="flowercare.svg" width="400px" alt="Flower Care" align="right" />

## About Flower Care

* Xiaomi [Flower Care (MiFlora)](http://www.huahuacaocao.com/product) sensors are meant to keep your plants alive by monitoring their environment
* Has sensors to relay temperature, light intensity, soil moisture and soil fertility (via electrical conductivity)
* Uses Bluetooth Low Energy (BLE) and has a limited range
* A CR2032 coin cell battery is used as power source

Xiaomi MiJia **Flower Care** / VegTrug **Grow Care Home** (HHCCJCY01)  
VegTrug **Grow Care Garden** (GCLS002)  

## Features

* Read real-time sensor values
* Read historical sensor values
* Temperature (-10 - 60 °C ± 0.5 °C)
* Light Monitor (0 - 100000 lux ± 100 lux)
* Soil moisture
* Soil fertility
* Notification LED
* IPX5

## Protocol

The device uses BLE GATT for communication, but the sensor values are not immediately available.  
When the official application connects to the device, it performs an elaborate initialization, required only to keep the connection opened for more than a few seconds.  
Sensor values are available for reading only after sending a *change mode* request detailed below.

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

The name advertised by the device is `Flower care`.

##### Generic access (UUID 00001800-0000-1000-8000-00805f9b34fb)

| Characteristic UUID                  | Handle | Access      | Description                         |
| ------------------------------------ | ------ | ----------- | ----------------------------------- |
| 00002a00-0000-1000-8000-00805f9b34fb | 0x03   | read        | device name                         |

##### Root service (UUID 0000fe95-0000-1000-8000-00805f9b34fb)

| Characteristic UUID                  | Handle | Access      | Description                         |
| ------------------------------------ | ------ | ----------- | ----------------------------------- |
| -                                    | -      | -           | used for device discovery           |

##### Data service (UUID 00001204-0000-1000-8000-00805f9b34fb)

| Characteristic UUID                  | Handle | Access      | Description                         |
| ------------------------------------ | ------ | ----------- | ----------------------------------- |
| 00001a00-0000-1000-8000-00805f9b34fb | 0x33   | write       | device mode change (send command)   |
| 00001a01-0000-1000-8000-00805f9b34fb | 0x35   | read        | real-time sensor values             |
| 00001a02-0000-1000-8000-00805f9b34fb | 0x38   | read        | firmware version and battery level  |

##### History service (UUID 00001206-0000-1000-8000-00805f9b34fb)

| Characteristic UUID                  | Handle | Access      | Description                         |
| ------------------------------------ | ------ | ----------- | ----------------------------------- |
| 00001a10-0000-1000-8000-00805f9b34fb | 0x3e   | r/w/notify  | device mode change (send command)   |
| 00001a11-0000-1000-8000-00805f9b34fb | 0x3c   | read        | historical sensor values            |
| 00001a12-0000-1000-8000-00805f9b34fb | 0x41   | read        | device time                         |

#### Device name

A read request to the `0x03` handle will return n bytes of data, for example `0x466c6f7765722063617265` corresponding to the device name.

| Position | 00 | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 |
| -------- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| Value    | 46 | 6c | 6f | 77 | 65 | 72 | 20 | 63 | 61 | 72 | 65 |

| Bytes | Type       | Value       | Description |
| ----- | ---------- | ----------- | ----------- |
| all   | ASCII text | Flower Care | device name |

#### Firmware and battery

A read request to the `0x38` handle will return 7 bytes of data, for example `0x6328332e312e39`.

| Position | 00 | 01 | 02 | 03 | 04 | 05 | 06 |
| -------- | -- | -- | -- | -- | -- | -- | -- |
| Value    | 63 | 28 | 33 | 2e | 31 | 2e | 39 |

| Bytes | Type       | Value | Description        |
| ----- | ---------- | ----- | ------------------ |
| 00    | uint8      | 99    | battery level in % |
| 02-06 | ASCII text | 3.1.8 | firmware version   |

The second byte (`0x28`) seems to be a separator. In older firmware versions it always read `0x13`.  
Both are control characters in the ASCII table.

#### Blink

Writing 2 bytes (`0xfdff`) to the mode change handle (`0x33`) will make the device blink the top LED once.

#### Real-time data

In order to read the sensor values you need to change its mode.  
This can be done by writing 2 bytes (`0xa01f`) to the mode change handle (`0x33`).  
After writing them you can read the actual sensor values from the data handle (`0x35`).  

A read request will return 16 bytes of data, for example `0xea0000ab00000015b200023c00fb349b`.

| Position | 00 | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 | 12 | 13 | 14 | 15 |
| -------- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| Value    | ea | 00 | 00 | ab | 00 | 00 | 00 | 15 | b2 | 00 | 02 | 3c | 00 | fb | 34 | 9b |

| Bytes | Type       | Value | Description           |
| ----- | ---------- | ----- | --------------------- |
| 00-01 | uint16     | 234   | temperature in 0.1 °C |
| 02    | ?          | ?     | ?                     |
| 03-06 | uint32     | 171   | brightness in lux     |
| 07    | uint8      | 21    | moisture in %         |
| 08-09 | uint16     | 178   | conductivity in µS/cm |
| 10-15 | ?          | ?     | ?                     |

#### Historical data

The device stores historical data when not connected that can be later synchronized.  
As with reading real-time sensor information, we need to change the device mode by writing 3 bytes (`0xa00000`) to the history control handle (`0x3e`).  

##### Device time

A read request to the `0x41` handle will return 4 bytes of data, for example `0x09ef2000`.

| Position | 00 | 01 | 02 | 03 |
| -------- | -- | -- | -- | -- |
| Value    | 09 | ef | 20 | 00 |

| Bytes | Type       | Value   | Description                       |
| ----- | ---------- | ------- | --------------------------------- |
| 00-03 | uint32     | 2158345 | seconds since device epoch (boot) |

Considering the device's epoch as second 0, the value obtained is a delta from now from which we can determine the actual time.  
We use this method while determining the datetime of historical entries.  

##### Entry count

The next step is to get information about the stored history by reading from the history data handle (`0x3c`).  
This will return 16 bytes of data, for example `0x2b007b04ba130800c815080000000000`.  

| Position | 00 | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 | 12 | 13 | 14 | 15 |
| -------- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| Value    | 2b | 00 | 7b | 04 | ba | 13 | 08 | 00 | c8 | 15 | 08 | 00 | 00 | 00 | 00 | 00 |

| Bytes | Type       | Value | Description                         |
| ----- | ---------- | ----- | ----------------------------------- |
| 00-01 | uint16     | 43    | number of stored historical records |
| 02-15 | ?          | ?     | ?                                   |

##### Read entry

Next we need to read each historical entry individually.  
To do so we need to calculate it's address, write it to the history control handle (`0x3e`) and then read the entry from the history data handle (`0x3c`).  

The address for each individual entry is computed by adding two bytes representing the entry index to `0xa1`.  
Entry `0`'s address will be `0xa10000`, entry `1`'s address `0xa10100`, entry `16`'s address `0xa11000`, and so on...  

After writing the address of the entry to be read, be can do so by requesting the payload from the history read handle (`0x3c`).  
This will return 16 bytes of data, for example `0x70e72000eb00005a00000015b3000000`.  

| Position | 00 | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 | 12 | 13 | 14 | 15 |
| -------- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| Value    | 70 | e7 | 20 | 00 | eb | 00 | 00 | 5a | 00 | 00 | 00 | 15 | b3 | 00 | 00 | 00 |

| Bytes | Type       | Value   | Description                                  |
| ----- | ---------- | ------- | -------------------------------------------- |
| 00-03 | uint32     | 2156400 | timestamp, seconds since device epoch (boot) |
| 04-05 | uint16     | 235     | temperature in 0.1 °C                        |
| 06    | ?          | ?       | ?                                            |
| 07-10 | uint32     | 90      | brightness in lux                            |
| 11    | uint8      | 21      | moisture in %                                |
| 12-13 | uint16     | 179     | conductivity in µS/cm                        |
| 14-15 |            | ?       | ?                                            |

##### Clear entries

Once all entries have been read, they can be wiped from the device by marking the process as `successful`.  
This can be achieved by writing 3 bytes (`0xa20000`) to the history control handle (`0x3e`).  

## Advertisement data

TODO

## Reference

[1] https://github.com/vrachieru/xiaomi-flower-care-api  
[2] https://github.com/ChrisScheffler/miflora/wiki/The-Basics  
[3] https://wiki.hackerspace.pl/projects:xiaomi-flora  

## License

MIT
