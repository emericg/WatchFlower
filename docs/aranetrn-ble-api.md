
## About Aranet Radon

* SAF Tehnika [Aranet Radon](https://aranet.com/products/aranet-radon-plus/) are indoor radon monitors
* Relays a radon concentration, and, on the "Plus" model, temperature, humidity and atmospheric pressure
* Uses Bluetooth Low Energy (BLE) and has a limited range
* AA batteries are used as power source

Two models exist, and they are told apart by their advertised name:

* `AranetRn1` reports radon concentration and atmospheric pressure only
* `AranetRn+` also reports temperature and humidity

## Features

* Read current sensor values
* Radon concentration (Bq/m³), with 24 hours, 7 days and 30 days averages
* Temperature and humidity (`AranetRn+` only)
* Atmospheric pressure
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

Two models exist, told apart by their advertised name, followed by the serial number suffix of the device:

| Name              | Model       | Radon | Pressure | Temperature | Humidity |
| ----------------- | ----------- | ----- | -------- | ----------- | -------- |
| `AranetRn1 XXXXX` | Radon       | yes   | yes      | no          | no       |
| `AranetRn+ XXXXX` | Radon Plus  | yes   | yes      | yes         | yes      |

Both models use the same protocol. On an `AranetRn1`, the temperature and humidity fields read `0`, and must be discarded.

The device shares its service and its current readings characteristic with other Aranet models (Aranet2, Radiation).
When the name is not enough, check the device type byte, which is `3` both in the advertisement data (byte 00)
and in the current readings (`f0cd1504`, bytes 00-01).

## Advertisement data

When "Smart Home integration" is enabled, the device broadcasts manufacturer specific data with the SAF Tehnika company identifier `0x0702`.

The payload is 24 bytes:

| Bytes | Type       | Conversion   | Description                           |
| ----- | ---------- | ------------ | ------------------------------------- |
| 00    | uint8      | -            | device type, `0x03` for Aranet Radon  |
| 01    | uint8      | -            | status flags, see below               |
| 02    | uint8      | -            | firmware version, patch               |
| 03    | uint8      | -            | firmware version, minor               |
| 04    | uint8      | -            | firmware version, major               |
| 05-07 | bytes      | -            | unknown                               |
| 08-09 | uint16_le  | -            | radon concentration (Bq/m³)           |
| 10-11 | uint16_le  | / 20         | temperature (°C)                      |
| 12-13 | uint16_le  | / 10         | atmospheric pressure (hPa)            |
| 14-15 | uint16_le  | / 10         | humidity (% RH)                       |
| 16    | uint8      | -            | unknown                               |
| 17    | uint8      | -            | battery level (%)                     |
| 18    | uint8      | -            | status color                          |
| 19-20 | uint16_le  | -            | measurement interval (seconds)        |
| 21-22 | uint16_le  | -            | age of the measurement (seconds)      |
| 23    | uint8      | -            | advertisement counter                 |

Differences with the [current readings](#reading-current-values) (`f0cd1504`):

* the field order differs
* the radon concentration is 16 bits wide, instead of 32 bits
* the averages are not advertised
* the measurement interval and age are available here

The same [invalid value](#invalid-values) rules apply.

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
| f0cd1504-95da-4f4b-9ac8-aa55d312af0c | read        | 47+ bytes  | current readings                             |
| f0cd2001-95da-4f4b-9ac8-aa55d312af0c | read        | uint16_le  | total readings in memory                     |
| f0cd2002-95da-4f4b-9ac8-aa55d312af0c | read        | uint16_le  | measurement interval (seconds)               |
| f0cd2004-95da-4f4b-9ac8-aa55d312af0c | read        | uint16_le  | seconds since last measurement               |
| f0cd2005-95da-4f4b-9ac8-aa55d312af0c | read        | bytes      | history readings                             |

## Reading current values

When "Smart Home integration" is enabled, the same measurements (except the averages) are also available without connecting,
see [Advertisement data](#advertisement-data).

Read `f0cd1504`. It returns at least 47 bytes:

| Bytes | Type       | Conversion   | Description                           |
| ----- | ---------- | ------------ | ------------------------------------- |
| 00-01 | uint16_le  | -            | device type, `3` for Aranet Radon     |
| 02-03 | uint16_le  | -            | unknown                               |
| 04-05 | uint16_le  | -            | unknown                               |
| 06    | uint8      | -            | battery level (%)                     |
| 07-08 | uint16_le  | / 20         | temperature (°C), `AranetRn+` only    |
| 09-10 | uint16_le  | / 10         | atmospheric pressure (hPa)            |
| 11-12 | uint16_le  | / 10         | humidity (% RH), `AranetRn+` only     |
| 13-16 | uint32_le  | -            | radon concentration (Bq/m³)           |
| 17    | uint8      | -            | status color, see below               |
| 18-21 | uint32_le  | -            | 24 hours average, period              |
| 22-25 | uint32_le  | -            | 24 hours average, value (Bq/m³)       |
| 26-29 | uint32_le  | -            | 7 days average, period                |
| 30-33 | uint32_le  | -            | 7 days average, value (Bq/m³)         |
| 34-37 | uint32_le  | -            | 30 days average, period               |
| 38-41 | uint32_le  | -            | 30 days average, value (Bq/m³)        |
| 42-45 | uint32_le  | -            | initial progress                      |
| 46    | uint8      | -            | display type                          |

Check the device type first, the same characteristic is used by other Aranet models with a different layout.

Example, first 18 bytes:

```
03 00 xx xx xx xx 64 fe 01 c9 27 ce 01 07 00 00 00 01
```

| Field       | Raw         | Value                   |
| ----------- | ----------- | ----------------------- |
| device type | `0003`      | Aranet Radon            |
| battery     | `64`        | 100 %                   |
| temperature | `01fe`      | 510 / 20 = 25.5 °C      |
| pressure    | `27c9`      | 10185 / 10 = 1018.5 hPa |
| humidity    | `01ce`      | 462 / 10 = 46.2 %       |
| radon       | `00000007`  | 7 Bq/m³                 |
| status      | `01`        | green                   |

Unlike the other Aranet models, this characteristic does not carry a usable measurement interval or age:
the reference implementation does not decode bytes 02-05. Timestamp the reading with the current time,
or read `f0cd2004` for the age of the measurement.

An average whose value is greater than or equal to `0xFF000000` is still being computed:
its low 24 bits then hold a progress indicator instead of a concentration.

Status color:

| Value | Status  |
| ----- | ------- |
| 0     | error   |
| 1     | green   |
| 2     | yellow  |
| 3     | red     |

### Invalid values

While the sensor is warming up, or while it is in an error state, the device stores magic numbers instead of measurements.
Each value has an out-of-range flag, or a range of error codes:

| Value               | Invalid when              |
| ------------------- | ------------------------- |
| temperature         | bit 14 is set             |
| humidity            | bit 15 is set             |
| pressure            | bit 15 is set             |
| radon concentration | value is >= `0x1F00`      |

The flag bit is *not* the same for every value. When it is set, discard the reading: do not mask the bit off and use the rest of the value.

The radon concentration has three documented error codes:

| Value    | Description                          |
| -------- | ------------------------------------ |
| `0x1F00` | general error                        |
| `0x1F01` | no data                              |
| `0x1F02` | high humidity in the sensor chamber  |

## Historical values

The device stores its measurements, and the history is downloaded one parameter at a time, using the poll based "v2" protocol.

| Parameter            | Id     | Datapoint  | Conversion        |
| -------------------- | ------ | ---------- | ----------------- |
| temperature          | `0x01` | uint16_le  | / 20 (°C)         |
| atmospheric pressure | `0x03` | uint16_le  | / 10 (hPa)        |
| humidity             | `0x05` | uint16_le  | / 10 (% RH)       |
| radon concentration  | `0x0a` | uint32_le  | - (Bq/m³)         |

The same [invalid value](#invalid-values) rules apply to the history datapoints.

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
