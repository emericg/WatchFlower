
## About Aranet Radiation

* SAF Tehnika [Aranet Radiation](https://aranet.com/products/aranet-radiation/) are ionizing radiation monitors
* Relays a radiation dose rate, and a cumulated radiation dose over a given duration
* Uses Bluetooth Low Energy (BLE) and has a limited range
* AA batteries are used as power source

## Features

* Read current sensor values
* Radiation dose rate (nSv/h)
* Cumulated radiation dose (nSv) and its integration duration
* Battery level
* Configurable measurement interval
* Historical values stored on the device

## Protocol

The device uses BLE GATT for communication.  
Sensor values are immediately available for reading.  

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

The advertised name is `Aranet☢ XXXXX`: `Aranet`, the radioactivity sign (U+2622), then the serial number suffix of the device.
Compare names as UTF-8 (or UTF-16) strings, not as ASCII.

The device shares its service and its current readings characteristic with other Aranet models (Aranet2, Radon).
When the name is not enough, check the device type byte:

| Source                                        | Aranet Radiation device type |
| --------------------------------------------- | ---------------------------- |
| advertisement data, byte 00                   | `0x02`                       |
| current readings (`f0cd1504`), bytes 00-01    | `4`                          |

Note that the two values differ.

## Advertisement data

When "Smart Home integration" is enabled, the device broadcasts manufacturer specific data with the SAF Tehnika company identifier `0x0702`.

The payload is 24 bytes:

| Bytes | Type       | Description                              |
| ----- | ---------- | ---------------------------------------- |
| 00    | uint8      | device type, `0x02` for Aranet Radiation |
| 01    | uint8      | status flags, see below                  |
| 02    | uint8      | firmware version, patch                  |
| 03    | uint8      | firmware version, minor                  |
| 04    | uint8      | firmware version, major                  |
| 05    | uint8      | unknown                                  |
| 06-09 | uint32_le  | radiation dose total (nSv)               |
| 10-13 | uint32_le  | total dose duration (seconds)            |
| 14-15 | uint16_le  | radiation dose rate (nSv/h), see below   |
| 16    | uint8      | unknown                                  |
| 17    | uint8      | battery level (%)                        |
| 18    | uint8      | unknown, status?                         |
| 19-20 | uint16_le  | measurement interval (seconds)           |
| 21-22 | uint16_le  | age of the measurement (seconds)         |
| 23    | uint8      | advertisement counter                    |

Differences with the [current readings](#reading-current-values) (`f0cd1504`):

* the field order differs, and so does the device type value
* the dose total and duration are 32 bits wide, instead of 64 bits
* the dose rate is 16 bits wide, instead of 32 bits

> The unit of the advertised dose rate is uncertain. The reference implementation reads it as plain nSv/h,
> while its own documentation describes it as scaled by 10, as in the history.
> Compare it with the `f0cd1504` value before relying on it.

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
| 00002a00-0000-1000-8000-00805f9b34fb | read        | UTF-8      | device name                     |

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
| f0cd1504-95da-4f4b-9ac8-aa55d312af0c | read        | 28+ bytes  | current readings                             |
| f0cd2001-95da-4f4b-9ac8-aa55d312af0c | read        | uint16_le  | total readings in memory                     |
| f0cd2002-95da-4f4b-9ac8-aa55d312af0c | read        | uint16_le  | measurement interval (seconds)               |
| f0cd2004-95da-4f4b-9ac8-aa55d312af0c | read        | uint16_le  | seconds since last measurement               |
| f0cd2005-95da-4f4b-9ac8-aa55d312af0c | read        | bytes      | history readings                             |

## Reading current values

When "Smart Home integration" is enabled, the same measurements are also available without connecting,
see [Advertisement data](#advertisement-data).

Read `f0cd1504`. It returns at least 28 bytes:

| Bytes | Type       | Description                           |
| ----- | ---------- | ------------------------------------- |
| 00-01 | uint16_le  | device type, `4` for Aranet Radiation |
| 02-03 | uint16_le  | measurement interval (seconds)        |
| 04-05 | uint16_le  | age of the measurement (seconds)      |
| 06    | uint8      | battery level (%)                     |
| 07-10 | uint32_le  | radiation dose rate (nSv/h)           |
| 11-18 | uint64_le  | radiation dose total (nSv)            |
| 19-26 | uint64_le  | total dose duration (seconds)         |
| 27    | uint8      | status                                |

Check the device type first, the same characteristic is used by other Aranet models with a different layout.

Example:

```
04 00 2c 01 58 00 63 82 00 00 00 d0 33 00 00 00 00 00 00 6c 60 06 00 00 00 00 00 00
```

| Field          | Raw          | Value                       |
| -------------- | ------------ | --------------------------- |
| device type    | `0004`       | Aranet Radiation            |
| interval       | `012c`       | 300 s                       |
| age            | `0058`       | 88 s                        |
| battery        | `63`         | 99 %                        |
| dose rate      | `00000082`   | 130 nSv/h (0.13 µSv/h)      |
| dose total     | `33d0`       | 13264 nSv (13.3 µSv)        |
| dose duration  | `0006606c`   | 417900 s (4 days 20 h)      |
| status         | `00`         | -                           |

The measurement was taken `age` seconds ago, so its timestamp is `now - age`.
If `age` is greater than `interval`, the two are out of sync: use the current time instead.

The average dose rate over the integration period is `dose total / dose duration * 3600` (nSv/h).

## Historical values

The device stores its measurements, and the history is downloaded one parameter at a time, using the poll based "v2" protocol.

| Parameter               | Id     | Datapoint                     | Unit       |
| ----------------------- | ------ | ----------------------------- | ---------- |
| radiation dose          | `0x07` | uint16_le + 1 padding byte    | nSv        |
| radiation dose rate     | `0x08` | uint16_le + 1 padding byte    | 10 nSv/h   |
| radiation dose integral | `0x09` | uint64_le                     | nSv        |

The dose rate is stored in units of 10 nSv/h in the history, multiply by 10 to get nSv/h.

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

### Invalid values

While the sensor is warming up, or while it is in an error state, the device stores magic numbers in the history instead of measurements.
Each value has an out-of-range flag bit:

| Value                   | Invalid when   |
| ----------------------- | -------------- |
| radiation dose          | bit 15 is set  |
| radiation dose rate     | bit 15 is set  |
| radiation dose integral | bit 63 is set  |

When the flag bit is set, discard the datapoint: do not mask the bit off and use the rest of the value.

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
