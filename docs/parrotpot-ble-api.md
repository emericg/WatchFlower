
<img src="parrotpot.svg" width="400px" alt="Parrot Pot" align="right" />

## About Parrot Pot

* [Parrot Pot](https://support.parrot.com/fr/support/produits/parrot-pot) are meant to keep your plants alive by monitoring their environment
* Has sensors to relay temperature, light intensity, soil temperature, soil moisture and fertility (via electrical conductivity)
* Uses Bluetooth Low Energy (BLE) and has a limited range
* An AAA battery is used as power source

## Features

* Read real-time sensor values
* Read historical sensor values
* Temperature
* Light Monitor
* Soil moisture
* Soil fertility
* Water tank
* Notification LED
* IPX5

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

The name advertised by the device is `Parrot pot AABB` (the last 4 characters are the last characters of the device's MAC address)

##### Generic access (UUID 00001800-0000-1000-8000-00805f9b34fb)

| Characteristic UUID                  | Handle | Access      | Description                   |
| ------------------------------------ | ------ | ----------- | ----------------------------- |
| 00002a00-0000-1000-8000-00805f9b34fb | 0x03   | read        | device name                   |

##### Device Information (UUID 0000180a-0000-1000-8000-00805f9b34fb)

| Characteristic UUID                  | Handle | Access      | Description                   |
| ------------------------------------ | ------ | ----------- | ----------------------------- |
| 00002a23-0000-1000-8000-00805f9b34fb | 0x12   | read        | system ID                     |
| 00002a25-0000-1000-8000-00805f9b34fb | 0x16   | read        | serial number string          |
| 00002a26-0000-1000-8000-00805f9b34fb | 0x17   | read        | firmware revision string      |
| 00002a27-0000-1000-8000-00805f9b34fb | 0x1a   | read        | hardware revision string      |
| 00002a28-0000-1000-8000-00805f9b34fb | 0x?    | read        | software revision string      |
| 00002a29-0000-1000-8000-00805f9b34fb | 0x1e   | read        | manufacturer name string      |

##### Battery service (UUID 0000180f-0000-1000-8000-00805f9b34fb)

| Characteristic UUID                  | Handle | Access      | Description                   |
| ------------------------------------ | ------ | ----------- | ----------------------------- |
| 00002a19-0000-1000-8000-00805f9b34fb | 0x44   | read        | battery level                 |

##### Live service (UUID 39e1fa00-84a8-11e2-afba-0002a5d5c51b)

| Characteristic UUID                  | Handle | Access      | Description                   |
| ------------------------------------ | ------ | ----------- | ----------------------------- |
| 39e1fa01-84a8-11e2-afba-0002a5d5c51b | 0x25   | read/notify | sunlight                      |
| 39e1fa02-84a8-11e2-afba-0002a5d5c51b | 0x29   | read/notify | soil conductivity             |
| 39e1fa03-84a8-11e2-afba-0002a5d5c51b | 0x2d   | read/notify | soil temp                     |
| 39e1fa04-84a8-11e2-afba-0002a5d5c51b | 0x31   | read/notify | air temperature               |
| 39e1fa05-84a8-11e2-afba-0002a5d5c51b | 0x35   | read/notify | soil moisture                 |
| 39e1fa06-84a8-11e2-afba-0002a5d5c51b | 0x39   | read/write  | live measure period           |
| 39e1fa07-84a8-11e2-afba-0002a5d5c51b | 0x3c   | read/write  | LED status                    |
| 39e1fa08-84a8-11e2-afba-0002a5d5c51b | 0x3f   | read/notify | last move date                |

##### History service (UUID 39e1fc00-84a8-11e2-afba-0002a5d5c51b)

| Characteristic UUID                  | Handle | Access     | Description                    |
| ------------------------------------ | ------ | ---------- | ------------------------------ |
| 39e1fc01-84a8-11e2-afba-0002a5d5c51b | 0x?    | read       | ?                              |
| 39e1fc02-84a8-11e2-afba-0002a5d5c51b | 0x?    | read       | ?                              |
| 39e1fc03-84a8-11e2-afba-0002a5d5c51b | 0x?    | read/write | ?                              |
| 39e1fc04-84a8-11e2-afba-0002a5d5c51b | 0x?    | read       | ?                              |
| 39e1fc05-84a8-11e2-afba-0002a5d5c51b | 0x?    | read       | ?                              |
| 39e1fc06-84a8-11e2-afba-0002a5d5c51b | 0x?    | read       | ?                              |
| 39e1fc06-84a8-11e2-afba-0002a5d5c51b | 0x?    | read       | ?                              |

##### Clock service (UUID 39e1fd00-84a8-11e2-afba-0002a5d5c51b)

| Characteristic UUID                  | Handle | Access     | Description                    |
| ------------------------------------ | ------ | ---------- | ------------------------------ |
| 39e1fd01-84a8-11e2-afba-0002a5d5c51b | 0x70   | read       | current time                   |
| 39e1fd02-84a8-11e2-afba-0002a5d5c51b | 0x70   | read/write | ?                              |

#### Device name

A read request to the `0x03` handle will return n bytes of data, for example `0x506172726f7420706f74` corresponding to the device name.

| Position | 00 | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 |
| -------- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| Value    | 50 | 61 | 72 | 72 | 6f | 74 | 20 | 70 | 6f | 74 |

| Bytes | Type       | Value        | Description |
| ----- | ---------- | ------------ | ----------- |
| all   | ASCII text | Parrot pot   | device name |

#### Battery

A read request to the `0x33` handle will return 1 bytes of data, for example `0x64`.

| Position | 00 |
| -------- | -- |
| Value    | 64 |

| Bytes | Type       | Value | Description        |
| ----- | ---------- | ----- | ------------------ |
| 00    | uint8      | 100   | battery level in % |

#### Last move

TODO

#### Real time data

TODO

#### Historical data

TODO

##### Device time

TODO

##### Entry count

TODO

##### Read entry

TODO

##### Clear entries

TODO

## Advertisement data

TODO

## Reference

[1] https://developer.parrot.com/docs/FlowerPower/FlowerPower-BLE.pdf  

## License

MIT
