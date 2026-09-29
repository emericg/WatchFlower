
## About Aranet2

* SAF Tehnika [Aranet2](https://aranet.com/products/aranet2/) are indoor temperature and humidity monitors
* Has sensors to relay temperature and humidity
* Uses Bluetooth Low Energy (BLE) and has a limited range
* AA battery is used as power source

## Features

* Read current sensor values
* Temperature and humidity
* Battery level
* Configurable measurement interval
* Historical values stored on the device

## Protocol

The device uses BLE GATT for communication.  
Sensor values are immediately available for reading, and only need a simple scaling.  

The sensor characteristics are only readable once the device has been paired,
unless the "Smart Home integration" setting has been enabled on the device itself.
The same setting enables the [advertisement data](#advertisement-data), which carries the measurements without any connection.

### BLE & GATT

The basic technologies behind the sensors communication are [Bluetooth Low Energy (BLE)](https://en.wikipedia.org/wiki/Bluetooth_Low_Energy) and [GATT](https://www.bluetooth.com/specifications/gatt).
They allow the devices and the app to share data in a defined manner and define the way you can discover the devices and their services.
In general you have to know about services and characteristics to talk to a BLE device.

### Data structure

The data is encoded in little-endian byte order.  
This means that the data is represented with the least significant byte first.  

To understand multi-byte integer representation, you can read the [endianness](https://en.wikipedia.org/wiki/Endianness) Wikipedia page.

## Identifying the device

The advertised name is `Aranet2 XXXXX`, `Aranet2` followed by the serial number suffix of the device.

The device shares its service and its current readings characteristic with other Aranet models (Radiation, Radon).
When the name is not enough, check the device type byte:

| Source                                        | Aranet2 device type |
| --------------------------------------------- | ------------------- |
| advertisement data, byte 00                   | `0x01`              |
| current readings (`f0cd1504`), bytes 00-01    | `2`                 |

Note that the two values differ.

## Advertisement data

When "Smart Home integration" is enabled, the device broadcasts manufacturer specific data with the SAF Tehnika company identifier `0x0702`.

The payload is 24 bytes:

| Bytes | Type       | Conversion   | Description                     |
| ----- | ---------- | ------------ | ------------------------------- |
| 00    | uint8      | -            | device type, `0x01` for Aranet2 |
| 01    | uint8      | -            | status flags, see below         |
| 02    | uint8      | -            | firmware version, patch         |
| 03    | uint8      | -            | firmware version, minor         |
| 04    | uint8      | -            | firmware version, major         |
| 05-07 | bytes      | -            | unknown                         |
| 08-09 | uint16_le  | -            | unknown                         |
| 10-11 | uint16_le  | / 20         | temperature (°C)                |
| 12-13 | uint16_le  | -            | unknown                         |
| 14-15 | uint16_le  | / 10         | humidity (% RH)                 |
| 16    | uint8      | -            | unknown                         |
| 17    | uint8      | -            | battery level (%)               |
| 18    | uint8      | -            | threshold status (as in `f0cd1504`) |
| 19-20 | uint16_le  | -            | measurement interval (seconds)  |
| 21-22 | uint16_le  | -            | age of the measurement (seconds)|
| 23    | uint8      | -            | advertisement counter           |

The field order differs from the [current readings](#reading-current-values) (`f0cd1504`), and so does the device type value.
The same [invalid value](#invalid-values) flags apply.

Status flags:

| Bit   | Description                                              |
| ----- | -------------------------------------------------------- |
| 0     | device is disconnected                                   |
| 2-3   | calibration state (0 not active, 1 end request, 2 in progress, 3 error) |
| 4     | DFU (firmware update) active                             |
| 5     | smart home integration enabled                           |

If bit 5 is not set, the advertisement carries no measurement, and stops after the version bytes.

## Services and characteristics

| Service               | UUID                                   | Purpose                                  |
| --------------------- | -------------------------------------- | ---------------------------------------- |
| Generic access        | `1800`                                 | device name                              |
| Device information    | `180a`                                 | model, serial number, versions           |
| Battery               | `180f`                                 | battery level                            |
| Aranet                | `fce0` or `f0cd1400`                   | measurements, history, commands          |

##### Generic access (UUID 00001800-0000-1000-8000-00805f9b34fb)

| Characteristic UUID                  | Access      | Type       | Description                     |
| ------------------------------------ | ----------- | ---------- | ------------------------------- |
| 00002a00-0000-1000-8000-00805f9b34fb | read        | ASCII      | device name                     |

##### Device information (UUID 0000180a-0000-1000-8000-00805f9b34fb)

| Characteristic UUID                  | Access      | Type       | Description                     |
| ------------------------------------ | ----------- | ---------- | ------------------------------- |
| 00002a24-0000-1000-8000-00805f9b34fb | read        | ASCII      | model number                    |
| 00002a25-0000-1000-8000-00805f9b34fb | read        | ASCII      | serial number                   |
| 00002a26-0000-1000-8000-00805f9b34fb | read        | ASCII      | firmware revision (current)     |
| 00002a27-0000-1000-8000-00805f9b34fb | read        | ASCII      | hardware revision               |
| 00002a28-0000-1000-8000-00805f9b34fb | read        | ASCII      | software revision (factory)     |
| 00002a29-0000-1000-8000-00805f9b34fb | read        | ASCII      | manufacturer name               |

##### Battery service (UUID 0000180f-0000-1000-8000-00805f9b34fb)

| Characteristic UUID                  | Access      | Type       | Description                     |
| ------------------------------------ | ----------- | ---------- | ------------------------------- |
| 00002a19-0000-1000-8000-00805f9b34fb | read        | uint8      | battery level (%)               |

##### Aranet service (UUID 0000fce0-0000-1000-8000-00805f9b34fb)

Recent firmwares identify the service by the 16 bits UUID `0xfce0`.
Older firmwares expose it as `f0cd1400-95da-4f4b-9ac8-aa55d312af0c` instead, with the same characteristics, so look for either UUID.

| Characteristic UUID                  | Access      | Type       | Description                                  |
| ------------------------------------ | ----------- | ---------- | -------------------------------------------- |
| f0cd1401-95da-4f4b-9ac8-aa55d312af0c | read        | bytes      | sensor settings state                        |
| f0cd1402-95da-4f4b-9ac8-aa55d312af0c | write       | bytes      | commands, see [Commands](#commands)          |
| f0cd1504-95da-4f4b-9ac8-aa55d312af0c | read        | 12 bytes   | current readings                             |
| f0cd2001-95da-4f4b-9ac8-aa55d312af0c | read        | uint16_le  | total readings in memory                     |
| f0cd2002-95da-4f4b-9ac8-aa55d312af0c | read        | uint16_le  | measurement interval (seconds)               |
| f0cd2004-95da-4f4b-9ac8-aa55d312af0c | read        | uint16_le  | seconds since last measurement               |
| f0cd2005-95da-4f4b-9ac8-aa55d312af0c | read        | bytes      | history readings                             |

## Reading current values

When "Smart Home integration" is enabled, the same measurements are also available without connecting,
see [Advertisement data](#advertisement-data).

Read `f0cd1504`. It returns 12 bytes:

| Bytes | Type       | Conversion   | Description                     |
| ----- | ---------- | ------------ | ------------------------------- |
| 00-01 | uint16_le  | -            | device type, `2` for Aranet2    |
| 02-03 | uint16_le  | -            | measurement interval (seconds)  |
| 04-05 | uint16_le  | -            | age of the measurement (seconds)|
| 06    | uint8      | -            | battery level (%)               |
| 07-08 | uint16_le  | / 20         | temperature (°C)                |
| 09-10 | uint16_le  | / 10         | humidity (% RH)                 |
| 11    | uint8      | -            | threshold status, see below     |

Check the device type first, the same characteristic is used by other Aranet models with a different layout.

Example:

```
02 00 78 00 52 00 3b 99 01 0a 02 00
```

| Field       | Raw     | Value              |
| ----------- | ------- | ------------------ |
| device type | `0002`  | Aranet2            |
| interval    | `0078`  | 120 s              |
| age         | `0052`  | 82 s               |
| battery     | `3b`    | 59 %               |
| temperature | `0199`  | 409 / 20 = 20.5 °C |
| humidity    | `020a`  | 522 / 10 = 52.2 %  |
| status      | `00`    | both off           |

The measurement was taken `age` seconds ago, so its timestamp is `now - age`.
If `age` is greater than `interval`, the two are out of sync: use the current time instead.

The threshold status byte holds two 2-bit fields:

| Bits  | Description                     |
| ----- | ------------------------------- |
| 0-1   | humidity status                 |
| 2-3   | temperature status              |

| Value | Status                          |
| ----- | ------------------------------- |
| 0     | off                             |
| 1     | under threshold                 |
| 2     | over threshold                  |
| 3     | dash (no value)                 |

### Invalid values

While the sensor is warming up, or while it is in an error state, the device stores magic numbers instead of measurements.
Each value has an out-of-range flag bit:

| Value       | Invalid when   |
| ----------- | -------------- |
| temperature | bit 14 is set  |
| humidity    | bit 15 is set  |

The flag bit is *not* the same for every value. When it is set, discard the reading: do not mask the bit off and use the rest of the value.

## Historical values

The device stores its measurements, and the history is downloaded one parameter at a time, using the poll based "v2" protocol.

| Parameter   | Id     | Datapoint  | Conversion |
| ----------- | ------ | ---------- | ---------- |
| temperature | `0x01` | uint16_le  | / 20       |
| humidity    | `0x05` | uint16_le  | / 10       |

Indices start at 1, and the number of stored readings is given by `f0cd2001`.
Datapoint `i` was measured at:

```
timestamp(i) = now - age - (total_readings - i) * interval
```

with `age` from `f0cd2004` and `interval` from `f0cd2002`.

Procedure:

1. write `61 PP II II` to `f0cd1402`: `PP` is the parameter id, `II II` the first index to read (uint16_le, `01 00` for everything)
2. read `f0cd2005`
3. decode the 10 bytes header, followed by `count` datapoints
4. repeat from step 2 until the last datapoint index reaches the total number of readings

Response header:

| Bytes | Type       | Description                      |
| ----- | ---------- | -------------------------------- |
| 00    | uint8      | parameter id                     |
| 01-02 | uint16_le  | measurement interval (seconds)   |
| 03-04 | uint16_le  | total readings                   |
| 05-06 | uint16_le  | age of the last measurement (seconds) |
| 07-08 | uint16_le  | index of the first datapoint     |
| 09    | uint8      | datapoint count in this packet   |

## Commands

Commands are written to the `f0cd1402` characteristic.

| Command                        | Bytes           | Arguments                                              |
| ------------------------------ | --------------- | ------------------------------------------------------ |
| set measurement interval       | `90 XX`         | `XX` in minutes: `01`, `02`, `05` or `0a`              |
| toggle smart home integration  | `91 XX`         | `XX`: `00` disabled, `01` enabled                      |
| set bluetooth range            | `92 XX`         | `XX`: `00` standard, `01` extended                     |
| history request                | `61 PP II II`   | parameter, first index, see [Historical values](#historical-values) |

## Reference

[1] - https://github.com/Anrijs/Aranet4-Python

## License

MIT
