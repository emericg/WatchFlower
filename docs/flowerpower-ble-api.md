
<img src="flowerpower.svg" width="400px" alt="Flower Power" align="right" />

## About Flower Power

* Parrot [Flower Power](https://support.parrot.com/fr/support/produits/parrot-flower-power) sensors are meant to keep your plants alive by monitoring their environment
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
* Soil temperature
* Notification LED
* IPX5

## Protocol

The device uses BLE GATT for communication.  
Sensor values are immediately available for reading, but usually require elaborate conversions.  
In order to limit connection time, the Flower Power device may disconnect from the application after a certain amount of time (around 1s) without incoming BLE request.  

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

The name advertised by the device is `Flower power AABB` (the last 4 characters are the last characters of the device's MAC address).  

##### Generic Access (UUID 00001800-0000-1000-8000-00805f9b34fb)

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
| 00002a28-0000-1000-8000-00805f9b34fb | ?      | read        | software revision string      |
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

Firmware versions 1.1.0+ have some new characteristics:

| Characteristic UUID                  | Handle | Access      | Description                   |
| ------------------------------------ | ------ | ----------- | ----------------------------- |
| 39e1fa09-84a8-11e2-afba-0002a5d5c51b | ?      | read/notify | soil moisture (calibrated)    |
| 39e1fa0a-84a8-11e2-afba-0002a5d5c51b | ?      | read/notify | air temperature (calibrated)  |
| 39e1fa0b-84a8-11e2-afba-0002a5d5c51b | ?      | read/notify | sunlight (calibrated)         |
| 39e1fa0c-84a8-11e2-afba-0002a5d5c51b | ?      | read/notify | ea (calibrated)               |
| 39e1fa0d-84a8-11e2-afba-0002a5d5c51b | ?      | read/notify | ecb (calibrated)              |
| 39e1fa0e-84a8-11e2-afba-0002a5d5c51b | ?      | read/notify | ecp (calibrated)              |

##### Upload service (UUID 39e1fb00-84a8-11e2-afba-0002a5d5c51b)

| Characteristic UUID                  | Handle | Access      | Description                   |
| ------------------------------------ | ------ | ----------- | ----------------------------- |
| -                                    | -      | -           | -                             |

##### History service (UUID 39e1fc00-84a8-11e2-afba-0002a5d5c51b)

| Characteristic UUID                  | Handle | Access      | Description                   |
| ------------------------------------ | ------ | ----------- | ----------------------------- |
| 39e1fc01-84a8-11e2-afba-0002a5d5c51b | 0x48   | read        | number of entries             |
| 39e1fc02-84a8-11e2-afba-0002a5d5c51b | 0x4c   | read        | last entry index              |
| 39e1fc03-84a8-11e2-afba-0002a5d5c51b | 0x50   | read/write  | start transfert index         |
| 39e1fc04-84a8-11e2-afba-0002a5d5c51b | 0x54   | read        | current session id            |
| 39e1fc05-84a8-11e2-afba-0002a5d5c51b | 0x58   | read        | current session start index   |
| 39e1fc06-84a8-11e2-afba-0002a5d5c51b | 0x5c   | read        | current session period        |

##### Clock service (UUID 39e1fd00-84a8-11e2-afba-0002a5d5c51b)

| Characteristic UUID                  | Handle | Access      | Description                   |
| ------------------------------------ | ------ | ----------- | ----------------------------- |
| 39e1fd01-84a8-11e2-afba-0002a5d5c51b | 0x70   | read        | current time                  |

##### Calibration service (UUID 39e1fe00-84a8-11e2-afba-0002a5d5c51b)

| Characteristic UUID                  | Handle | Access      | Description                   |
| ------------------------------------ | ------ | ----------- | ----------------------------- |
| -                                    | -      | -           | -                             |

##### OTA download service (UUID f000ffc0-0451-4000-b0000-000000000000)

#### Device name

A read request to the `0x03` handle will return n bytes of data, for example `0x466c6f77657220706f776572` corresponding to the device name.

| Position | 00 | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 |
| -------- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| Value    | 46 | 6c | 6f | 77 | 65 | 72 | 20 | 70 | 6f | 77 | 65 | 72 |

| Bytes | Type       | Value        | Description |
| ----- | ---------- | ------------ | ----------- |
| all   | ASCII text | Flower power | device name |

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

#### Blink

Just write `1` to the LED handler `0xaa` to switch it on (it will keep blinking until disconnection) or write `0` to switch it off.

#### Real time data

TODO

#### Historical data

TODO

##### Device time

TODO

###### Entry count

TODO

###### Read entry

TODO

###### Clear entries

TODO

## Advertisement data

Flower Power with firmware 1.0 doesn't seem to advertise data.  

## Reference

[1] https://developer.parrot.com/docs/FlowerPower/FlowerPower-BLE.pdf  
[2] https://github.com/Parrot-Developers/node-flower-power  
[3] https://www.fanjoe.be/?p=3520  

## License

MIT
