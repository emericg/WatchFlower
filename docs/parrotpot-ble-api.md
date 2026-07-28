
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

## Services and characteristics

The name advertised by the device is `Parrot pot AABB` (the last 4 characters are the last characters of the device's MAC address).  
The device name can be changed by the user, so a more robust way to identify a Parrot Pot is to look for the live service UUID (`39e1fa00-…`) in the advertised service UUID list. Note that this matches the [Flower Power](flowerpower-ble-api.md) too; the watering service (`39e1f900-…`) is what distinguishes a Pot.  

The Parrot Pot shares most of its BLE interface with the Flower Power: the live, upload, history, clock, plant doctor and calibration services are the same, and are documented in more detail in [flowerpower-ble-api.md](flowerpower-ble-api.md). The watering service is specific to the Pot, as are a handful of extra characteristics in the shared services (`39e1fa0f` to `39e1fa11`, `39e1fc07`, `39e1fd02`, `39e1fd87` to `39e1fd89`).  

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
| 39e1fa0b-84a8-11e2-afba-0002a5d5c51b | read/notify | sunlight / DLI (calibrated)   |
| 39e1fa0f-84a8-11e2-afba-0002a5d5c51b | read/notify | ?                             |

The calibrated characteristics hold little-endian `float32` values, unlike the raw `uint16` of `39e1fa01` to `39e1fa05`.
On Flower Power, `39e1fa0c`, `39e1fa0d` and `39e1fa0e` are documented as the calibrated `ea`, `ecb` and `ec porous` soil conductivity values; they are likely present here too but have not been observed. The `39e1fa0f`, `39e1fa10` and `39e1fa11` characteristics above have no known equivalent on the Flower Power.

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

The watering service is entirely undocumented by Parrot: it appears neither in the official Flower Power BLE specification, nor in `node-flower-power`, nor in any of the other known reverse engineering projects, all of which target the Flower Power sensor only. What is known above comes from [2].

WatchFlower triggers a manual watering by writing `0x0800` to `39e1f906`; the meaning of that value is unknown. Nothing is known about the automatic watering modes ("plant sitter" and similar in the official application), their schedules or their thresholds. Sniffing the official application, or an HCI snoop log from a real device, is the only way forward here.

##### OTA download service (UUID f000ffc0-0451-4000-b0000-000000000000)

See [Firmware update](flowerpower-ble-api.md#firmware-update) in the Flower Power documentation.

#### Device name

A read request to the `device name` characteristic will return n bytes of data, for example `0x506172726f7420706f74` corresponding to the device name.

| Position | 00 | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 |
| -------- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| Value    | 50 | 61 | 72 | 72 | 6f | 74 | 20 | 70 | 6f | 74 |

| Bytes | Type       | Value        | Description |
| ----- | ---------- | ------------ | ----------- |
| all   | ASCII text | Parrot pot   | device name |

#### Battery

A read request to the `battery level` characteristic will return 1 bytes of data, for example `0x64`.

| Position | 00 |
| -------- | -- |
| Value    | 64 |

| Bytes | Type       | Value | Description        |
| ----- | ---------- | ----- | ------------------ |
| 00    | uint8      | 100   | battery level in % |

#### Firmware and hardware revision

The `firmware revision string` (`00002a26`) is a build string formatted as `<date>_<project>-<version>_<config>`, not a bare version number. The version is extracted by splitting on `_`, taking the second field, then splitting on `-` and taking the second field. See [flowerpower-ble-api.md](flowerpower-ble-api.md#firmware-and-hardware-revision).

#### Blink

Write `1` to the `LED status` characteristic (`39e1fa07`) to switch the LED on, `0` to switch it off.
The LED is also automatically switched off when the device disconnects.

#### Real time data

The raw characteristics (`39e1fa01` to `39e1fa05`) use the same conversions as the [Flower Power](flowerpower-ble-api.md#real-time-data), but the Pot is better read through the calibrated `float32` characteristics, which the device has already converted.

Two Pot specific notes on the soil conductivity: the raw `39e1fa02` output does not have the same range as on the Flower Power (no soil reads about `2036`, and the maximum observed is about `1747`, so the scale is *inverted* compared to the sensor), and the calibrated `ec` characteristics are a better source anyway.

##### Sunlight / luminosity

The calibrated sunlight characteristic (`39e1fa0b`) is a daily light integral (DLI) in mol/m²/day, not an illuminance. Converting to lux:

```
ppfd (µmol/m²/s) = dli * 1e6 / 86400     // = dli * 11.574
lux              = ppfd * 53.93          // PPF to lux, daylight spectrum
```

so `lux = dli * 624.2`.

#### Water tank

The `39e1f907` characteristic holds the water tank level as a percentage (`uint8`). WatchFlower converts it to a volume using a tank capacity of 2.2 L.

#### Historical data

Identical to the Flower Power: the history service describes what is available, and the file itself is transferred through the upload service. See [Historical data](flowerpower-ble-api.md#historical-data) for the full procedure.

The layout of an individual history entry is still unknown, on this device as on the Flower Power.

##### Device time

A read of the `current time` characteristic (`39e1fd01`) returns a little-endian `uint32`: the number of seconds elapsed since the device booted. To translate device-relative timestamps into absolute time, store a "wall time" offset:

```
wall_time = current_unix_time - device_time
```

##### Entry count

See [Entry count](flowerpower-ble-api.md#entry-count).

##### Read entry

See [Read entry](flowerpower-ble-api.md#read-entry).

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

Note that this differs from the [Flower Power](flowerpower-ble-api.md#advertisement-data), which advertises a single flags byte with no company identifier at all. Whether the Pot also exposes the `unread entries` / `move detected` / `starting` flags, and where, has not been established.

## Reference

[1] https://developer.parrot.com/docs/FlowerPower/FlowerPower-BLE.pdf  
[2] https://github.com/grover/homebridge-flower-sensor  
[3] https://github.com/sandeepmistry/node-flower-power (upload, OAD and live mode implementations)  
[4] https://github.com/tazounet/parrot_flower_plugin (Domoticz plugin, calibrated characteristics)  

## License

MIT
