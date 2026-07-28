
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
* Light intensity
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

## Services and characteristics

The name advertised by the device is `Flower power AABB` (the last 4 characters are the last characters of the device's MAC address).  
The device name can be changed by the user through the `friendly name` characteristic, so a more robust way to identify a Flower Power is to look for the live service UUID (`39e1fa00-…`) in the advertised service UUID list.  

##### Generic Access (UUID 00001800-0000-1000-8000-00805f9b34fb)

| Characteristic UUID                  | Access      | Description                   |
| ------------------------------------ | ----------- | ----------------------------- |
| 00002a00-0000-1000-8000-00805f9b34fb | read        | device name                   |

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

| Characteristic UUID                  | Access      | Description                   |
| ------------------------------------ | ----------- | ----------------------------- |
| 00002a19-0000-1000-8000-00805f9b34fb | read        | battery level                 |

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

A read request to the `device name` characteristic will return n bytes of data, for example `0x466c6f77657220706f776572` corresponding to the device name.

| Position | 00 | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 |
| -------- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| Value    | 46 | 6c | 6f | 77 | 65 | 72 | 20 | 70 | 6f | 77 | 65 | 72 |

| Bytes | Type       | Value        | Description |
| ----- | ---------- | ------------ | ----------- |
| all   | ASCII text | Flower power | device name |

#### Battery

A read request to the `battery level` characteristic will return 1 bytes of data, for example `0x64`.

| Position | 00 |
| -------- | -- |
| Value    | 64 |

| Bytes | Type       | Value | Description        |
| ----- | ---------- | ----- | ------------------ |
| 00    | uint8      | 100   | battery level in % |

#### Last move

A read of the `last move date` characteristic (`39e1fa08` UUUID) returns 4 bytes interpreted as a little-endian `uint32`.
The value is a number of seconds, relative to the device internal clock (see [Device time](#device-time)); add the device "wall time" offset to obtain an absolute timestamp.

| Bytes | Type        | Description                              |
| ----- | ----------- | ---------------------------------------- |
| 00-03 | uint32 (LE) | seconds since device boot of last motion |

#### Blink

Write `1` to the `LED status` characteristic (`39e1fa07` UUUID) to switch the LED on, `0` to switch it off.
The LED is also automatically switched off when the device disconnects. It should not be left on for long, as it drains the battery.

#### Real time data

Each live value is read as a little-endian `uint16` raw sensor output, then converted with the formulas below.
These match the ones used by the official application and the Parrot reference documentation.

To receive continuous updates rather than one-shot reads, use the live mode, see [Live mode](#live-mode).

##### Sunlight / luminosity (`39e1fa01` UUUID)

The native output of this conversion is **not** lux, it is a photosynthetic daily light integral (DLI) in mol/m²/day:

```
dli (mol/m²/d) = 0.0864 * (192773.17 * raw^-1.0606619)
```

Converting a DLI into an instantaneous illuminance requires two steps, and is only ever an approximation since the source value is a daily integral (the result is a 24 h mean, not a real time reading):

```
ppfd (µmol/m²/s) = dli * 1e6 / 86400     // = dli * 11.574
lux              = ppfd * 53.93          // PPF to lux, daylight spectrum
```

so, for the whole chain, `lux = dli * 624.2`.

##### Soil conductivity / fertility (`39e1fa02` UUUID)

The raw output ranges from `0` (no soil) to about `1771` (max observed), which maps to 0 - 10 mS/cm.

```
conductivity (uS/cm) = round(raw / 1.771)
```

##### Soil temperature (`39e1fa03` UUUID)

```
temp (°C) = 3.044e-8 * raw^3 - 8.038e-5 * raw^2 + 0.1149 * raw - 30.45
```

##### Air temperature (`39e1fa04` UUUID)

Same polynomial as the soil temperature, clamped to the [-10 ; 55] °C range.

```
temp (°C) = 3.044e-8 * raw^3 - 8.038e-5 * raw^2 + 0.1149 * raw - 30.45
```

##### Soil moisture (`39e1fa05` UUUID)

A two-step conversion, with the final value clamped to the [0 ; 60] % range.

```
h1 = 11.4293 + (1.0698e-9 * raw^4 - 1.52538e-6 * raw^3 + 8.66976e-4 * raw^2 - 0.169422 * raw)
moisture (%) = round(100 * (4.5e-6 * h1^3 - 5.5e-4 * h1^2 + 0.0292 * h1 - 0.053))
```

#### Historical data

The device continuously records measurements into an internal history file. Retrieving it uses two services: the *history* service (`39e1fc00`) to know what is available and where to start, and the *upload* service (`39e1fb00`) to transfer the file itself.

> **The history file format itself is undocumented.** Every known implementation retrieves the raw file and stops there, none decodes the individual entries. The layout of a history record still has to be reverse engineered.

##### Device time

A read of the `current time` characteristic (clock service, `39e1fd01` UUUID) returns 4 bytes interpreted as a little-endian `uint32`: the number of seconds elapsed since the device booted.

| Bytes | Type        | Description                 |
| ----- | ----------- | --------------------------- |
| 00-03 | uint32 (LE) | seconds since device boot   |

To translate device-relative timestamps (such as the [last move](#last-move) date or history entries) into absolute time, the application stores a "wall time" offset:

```
wall_time = current_unix_time - device_time
```

###### Entry count

The history service describes the recording state:

| UUID       | Type        | Access     | Description                 |
| ---------- | ----------- | ---------- | --------------------------- |
| `39e1fc01` | uint16 (LE) | read       | number of entries           |
| `39e1fc02` | uint32 (LE) | read       | last entry index            |
| `39e1fc03` | uint32 (LE) | read/write | transfer start index        |
| `39e1fc04` | uint16 (LE) | read       | current session id          |
| `39e1fc05` | uint32 (LE) | read       | current session start index |
| `39e1fc06` | uint16 (LE) | read       | current session period      |

The index of the oldest available entry is `last entry index - number of entries + 1`.
The application writes the index it wants to start from into `transfer start index`; the device may start *before* that index, but never after it.

The `session id` changes when the device restarts (battery replacement, reboot). A change of session is a useful signal that the index space is no longer continuous with what was previously downloaded.

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
[4] https://github.com/sandeepmistry/node-flower-power (upload, OAD and live mode implementations)  
[5] https://github.com/tazounet/parrot_flower_plugin (Domoticz plugin, calibrated characteristics)  

## License

MIT
