
<img src="parrotpot.svg" width="400px" alt="Parrot Pot" align="right" />

## About Parrot Pot

* [Parrot Pot](https://support.parrot.com/fr/support/produits/parrot-pot) are meant to keep your plants alive by monitoring their environment
* Has sensors to relay temperature, light intensity, soil temperature, soil moisture and fertility (via electrical conductivity)
* Uses Bluetooth Low Energy (BLE) and has a limited range
* 4 * AA batteries are used as power source

## Features

* Read real-time sensor values
* Read historical sensor values
* Temperature
* Light intensity
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

Bluetooth payload data typically uses little-endian byte order.  
This means that the data is represented with the least significant byte first.  

To understand multi-byte integer representation, you can read the [endianness](https://en.wikipedia.org/wiki/Endianness) Wikipedia page.

## Services, characteristics and handles

The name advertised by the device is `Parrot pot AABB` (the last 4 characters are the last characters of the device's MAC address).  

##### Generic access (UUID 00001800-0000-1000-8000-00805f9b34fb)

| Characteristic UUID                  | Access      | Description                   |
| ------------------------------------ | ----------- | ----------------------------- |
| 00002a00-0000-1000-8000-00805f9b34fb | read        | device name                   |

##### Device Information (UUID 0000180a-0000-1000-8000-00805f9b34fb)

| Characteristic UUID                  | Access      | Description                   |
| ------------------------------------ | ----------- | ----------------------------- |
| 00002a23-0000-1000-8000-00805f9b34fb | read        | system ID                     |
| 00002a25-0000-1000-8000-00805f9b34fb | read        | serial number string          |
| 00002a26-0000-1000-8000-00805f9b34fb | read        | firmware revision string      |
| 00002a27-0000-1000-8000-00805f9b34fb | read        | hardware revision string      |
| 00002a28-0000-1000-8000-00805f9b34fb | read        | software revision string      |
| 00002a29-0000-1000-8000-00805f9b34fb | read        | manufacturer name string      |

##### Battery service (UUID 0000180f-0000-1000-8000-00805f9b34fb)

| Characteristic UUID                  | Access      | Description                   |
| ------------------------------------ | ----------- | ----------------------------- |
| 00002a19-0000-1000-8000-00805f9b34fb | read        | battery level                 |

##### Live service (UUID 39e1fa00-84a8-11e2-afba-0002a5d5c51b)

| Characteristic UUID                  | Access      | Description                   |
| ------------------------------------ | ----------- | ----------------------------- |
| 39e1fa01-84a8-11e2-afba-0002a5d5c51b | read/notify | sunlight                      |
| 39e1fa02-84a8-11e2-afba-0002a5d5c51b | read/notify | soil conductivity             |
| 39e1fa03-84a8-11e2-afba-0002a5d5c51b | read/notify | soil temp                     |
| 39e1fa04-84a8-11e2-afba-0002a5d5c51b | read/notify | air temperature               |
| 39e1fa05-84a8-11e2-afba-0002a5d5c51b | read/notify | soil moisture                 |
| 39e1fa06-84a8-11e2-afba-0002a5d5c51b | read/write  | live measure period           |
| 39e1fa07-84a8-11e2-afba-0002a5d5c51b | read/write  | LED status                    |
| 39e1fa09-84a8-11e2-afba-0002a5d5c51b | read/notify | soil moisture (calibrated)    |
| 39e1fa10-84a8-11e2-afba-0002a5d5c51b | read/notify | ?                             |
| 39e1fa11-84a8-11e2-afba-0002a5d5c51b | read/notify | ?                             |
| 39e1fa0a-84a8-11e2-afba-0002a5d5c51b | read/notify | air temperature (calibrated)  |
| 39e1fa0b-84a8-11e2-afba-0002a5d5c51b | read/notify | sunlight (calibrated)         |
| 39e1fa0f-84a8-11e2-afba-0002a5d5c51b | read/notify | ?                             |

##### Upload service (UUID 39e1fb00-84a8-11e2-afba-0002a5d5c51b)

| Characteristic UUID                  | Access      | Description                   |
| ------------------------------------ | ----------- | ----------------------------- |
| -                                    | -           | -                             |

##### History service (UUID 39e1fc00-84a8-11e2-afba-0002a5d5c51b)

| Characteristic UUID                  | Access     | Description                    |
| ------------------------------------ | ---------- | ------------------------------ |
| 39e1fc01-84a8-11e2-afba-0002a5d5c51b | read       | ?                              |
| 39e1fc02-84a8-11e2-afba-0002a5d5c51b | read       | ?                              |
| 39e1fc03-84a8-11e2-afba-0002a5d5c51b | read/write | ?                              |
| 39e1fc04-84a8-11e2-afba-0002a5d5c51b | read       | ?                              |
| 39e1fc05-84a8-11e2-afba-0002a5d5c51b | read       | ?                              |
| 39e1fc06-84a8-11e2-afba-0002a5d5c51b | read       | ?                              |
| 39e1fc07-84a8-11e2-afba-0002a5d5c51b | read       | ?                              |

##### Clock service (UUID 39e1fd00-84a8-11e2-afba-0002a5d5c51b)

| Characteristic UUID                  | Access     | Description                    |
| ------------------------------------ | ---------- | ------------------------------ |
| 39e1fd01-84a8-11e2-afba-0002a5d5c51b | read       | current time                   |
| 39e1fd02-84a8-11e2-afba-0002a5d5c51b | read/write | ?                              |

##### Calibration service (UUID 39e1fe00-84a8-11e2-afba-0002a5d5c51b)

| Characteristic UUID                  | Access      | Description                   |
| ------------------------------------ | ----------- | ----------------------------- |
| -                                    | -           | -                             |

##### Watering service (UUID 39e1f900-84a8-11e2-afba-0002a5d5c51b)

| Characteristic UUID                  | Access      | Description                   |
| ------------------------------------ | ----------- | ----------------------------- |
| 39e1f901-84a8-11e2-afba-0002a5d5c51b | read/write  | -                             |
| 39e1f902-84a8-11e2-afba-0002a5d5c51b | read/write  | -                             |
| 39e1f903-84a8-11e2-afba-0002a5d5c51b | read/write  | -                             |
| 39e1f904-84a8-11e2-afba-0002a5d5c51b | read/write  | -                             |
| 39e1f905-84a8-11e2-afba-0002a5d5c51b | read/write  | -                             |
| 39e1f906-84a8-11e2-afba-0002a5d5c51b | write       | manual watering trigger       |
| 39e1f907-84a8-11e2-afba-0002a5d5c51b | read/notify | water tank level (%)          |
| 39e1f908-84a8-11e2-afba-0002a5d5c51b | read/write  | -                             |
| 39e1f910-84a8-11e2-afba-0002a5d5c51b | read/write  | -                             |
| 39e1f911-84a8-11e2-afba-0002a5d5c51b | read/write  | -                             |
| 39e1f912-84a8-11e2-afba-0002a5d5c51b | read/write  | watering status               |
| 39e1f913-84a8-11e2-afba-0002a5d5c51b | read/notify | -                             |
| 39e1f90a-84a8-11e2-afba-0002a5d5c51b | read/write  | -                             |
| 39e1f90b-84a8-11e2-afba-0002a5d5c51b | read/write  | -                             |
| 39e1f90c-84a8-11e2-afba-0002a5d5c51b | read/write  | -                             |
| 39e1f90d-84a8-11e2-afba-0002a5d5c51b | read/write  | watering mode                 |
| 39e1f90e-84a8-11e2-afba-0002a5d5c51b | read/write  | -                             |
| 39e1f90f-84a8-11e2-afba-0002a5d5c51b | read/write  | -                             |

##### OTA download service (UUID f000ffc0-0451-4000-b0000-000000000000)

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

#### Blink

Just write `1` to the LED handler `0xaa` to switch it on (it will keep blinking until disconnection) or write `0` to switch it off.

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

Parrot Pot broadcast `manufacturer data` with company identifier `0x0043`.  

##### 3 bytes message

| Position | 00 | 01 | 02 |
| -------- | -- | -- | -- |
| Value    | 01 | 23 | 01 |

| Bytes | Type      | Value             | Description       |
| ----- | --------- | ----------------- | ----------------- |
| 00    | byte      | 0x01              | ?                 |
| 01    | byte      | 0x23              | ?                 |
| 02    | byte      | 0x01              | ?                 |

## Reference

[1] https://developer.parrot.com/docs/FlowerPower/FlowerPower-BLE.pdf  
[2] https://github.com/grover/homebridge-flower-sensor  

## License

MIT
