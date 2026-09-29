
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
Sensor values are immediately available for reading, but the raw values need elaborate conversions.  
The device disconnects after about 1 second without an incoming request, so keep connections short and requests queued.  

### BLE & GATT

The basic technologies behind the sensors communication are [Bluetooth Low Energy (BLE)](https://en.wikipedia.org/wiki/Bluetooth_Low_Energy) and [GATT](https://www.bluetooth.com/specifications/gatt).
They allow the devices and the app to share data in a defined manner and define the way you can discover the devices and their services.
In general you have to know about services and characteristics to talk to a BLE device.

<img src="endianness.png" width="400px" alt="Endianness" align="right" />

### Data structure

All multi-byte values are little-endian, including the ones the Parrot documentation describes as big-endian.  
This means that the data is represented with the least significant byte first.  

To understand multi-byte integer representation, you can read the [endianness](https://en.wikipedia.org/wiki/Endianness) Wikipedia page.

### UUID notation

Every Parrot specific UUID shares the same base, only the first 4 bytes change:

```
39e1XXXX-84a8-11e2-afba-0002a5d5c51b
```

In the text below they are shortened to their first block, for example `39e1fa01`.
Standard Bluetooth UUIDs are shortened the same way, for example `2a19` for `00002a19-0000-1000-8000-00805f9b34fb`.

## Identifying the device

The name advertised by the device is `Flower power AABB`, where `AABB` are the last 4 characters of the MAC address.

The device name can be changed by the user through the `friendly name` characteristic,
so a more robust way to identify a Flower Power is to look for the live service UUID (`39e1fa00-...`) in the advertised service UUID list.

## Services and characteristics

| Service               | UUID       | Purpose                                                  |
| --------------------- | ---------- | -------------------------------------------------------- |
| Generic access        | `1800`     | device name                                              |
| Device information    | `180a`     | firmware and hardware versions                           |
| Battery               | `180f`     | battery level                                            |
| Live                  | `39e1fa00` | current sensor values, live mode, LED                    |
| Upload                | `39e1fb00` | history file transfer                                    |
| History               | `39e1fc00` | history state, where to start a transfer                 |
| Clock                 | `39e1fd00` | device time                                              |
| Plant doctor          | `39e1fd80` | firmware 2.0.3 only, only used by the Parrot Pot         |
| Calibration           | `39e1fe00` | calibration data, friendly name, color                   |
| OTA download          | `f000ffc0` | Texas Instruments firmware update                        |

Unlike most devices, the Flower Power attaches a `0x2901` user description descriptor to nearly every custom characteristic,
so a generic BLE explorer will name them for you. These names are quoted in the tables below where they help.

##### Generic Access (UUID 00001800-0000-1000-8000-00805f9b34fb)

| Characteristic UUID                  | Access      | Type       | Description                   |
| ------------------------------------ | ----------- | ---------- | ----------------------------- |
| 00002a00-0000-1000-8000-00805f9b34fb | read        | ASCII      | device name                   |

##### Device Information (UUID 0000180a-0000-1000-8000-00805f9b34fb)

| Characteristic UUID                  | Access      | Type       | Description                   |
| ------------------------------------ | ----------- | ---------- | ----------------------------- |
| 00002a23-0000-1000-8000-00805f9b34fb | read        | bytes      | system ID                     |
| 00002a25-0000-1000-8000-00805f9b34fb | read        | ASCII      | serial number                 |
| 00002a26-0000-1000-8000-00805f9b34fb | read        | ASCII      | firmware revision, see [Firmware version](#firmware-version) |
| 00002a27-0000-1000-8000-00805f9b34fb | read        | ASCII      | hardware revision (bootloader version) |
| 00002a28-0000-1000-8000-00805f9b34fb | read        | ASCII      | software revision             |
| 00002a29-0000-1000-8000-00805f9b34fb | read        | ASCII      | manufacturer name             |

##### Battery service (UUID 0000180f-0000-1000-8000-00805f9b34fb)

| Characteristic UUID                  | Access      | Type       | Description                   |
| ------------------------------------ | ----------- | ---------- | ----------------------------- |
| 00002a19-0000-1000-8000-00805f9b34fb | read        | uint8      | battery level (%)             |

##### Live service (UUID 39e1fa00-84a8-11e2-afba-0002a5d5c51b)

| Characteristic UUID                  | Access      | Type       | Description                                  |
| ------------------------------------ | ----------- | ---------- | -------------------------------------------- |
| 39e1fa01-84a8-11e2-afba-0002a5d5c51b | read/notify | uint16     | sunlight (raw)                               |
| 39e1fa02-84a8-11e2-afba-0002a5d5c51b | read/notify | uint16     | soil conductivity (raw)                      |
| 39e1fa03-84a8-11e2-afba-0002a5d5c51b | read/notify | uint16     | soil temperature (raw)                       |
| 39e1fa04-84a8-11e2-afba-0002a5d5c51b | read/notify | uint16     | air temperature (raw)                        |
| 39e1fa05-84a8-11e2-afba-0002a5d5c51b | read/notify | uint16     | soil moisture (raw)                          |
| 39e1fa06-84a8-11e2-afba-0002a5d5c51b | read/write  | uint8      | live measure period (s), see [Live mode](#live-mode) |
| 39e1fa07-84a8-11e2-afba-0002a5d5c51b | read/write  | uint8      | LED status, see [LED](#led)                  |
| 39e1fa08-84a8-11e2-afba-0002a5d5c51b | read/notify | uint32     | last move date, see [Last move](#last-move)  |
| 39e1fa09-84a8-11e2-afba-0002a5d5c51b | read/notify | float32    | soil moisture, VWC (%) (calibrated)          |
| 39e1fa0a-84a8-11e2-afba-0002a5d5c51b | read/notify | float32    | air temperature (°C) (calibrated)            |
| 39e1fa0b-84a8-11e2-afba-0002a5d5c51b | read/notify | float32    | sunlight, DLI (mol/m²/day) (calibrated)      |
| 39e1fa0c-84a8-11e2-afba-0002a5d5c51b | read/notify | float32    | ea, soil permittivity (calibrated)           |
| 39e1fa0d-84a8-11e2-afba-0002a5d5c51b | read/notify | float32    | ecb, bulk conductivity (calibrated)          |
| 39e1fa0e-84a8-11e2-afba-0002a5d5c51b | read/notify | float32    | ec porous, pore water conductivity (calibrated) |

Not every firmware exposes every characteristic, see [Firmware versions](#firmware-versions).

##### Upload service (UUID 39e1fb00-84a8-11e2-afba-0002a5d5c51b)

| Characteristic UUID                  | Access      | Type       | Description                          |
| ------------------------------------ | ----------- | ---------- | ------------------------------------ |
| 39e1fb01-84a8-11e2-afba-0002a5d5c51b | notify      | 20 bytes   | Tx buffer, history file frames       |
| 39e1fb02-84a8-11e2-afba-0002a5d5c51b | read/notify | uint8      | Tx status (device side)              |
| 39e1fb03-84a8-11e2-afba-0002a5d5c51b | read/write  | uint8      | Rx status (application side)         |
| 39e1fb04-84a8-11e2-afba-0002a5d5c51b | read/write  | ?          | upload file selector (not in the Parrot documentation) |

See [Historical data](#historical-data).

##### History service (UUID 39e1fc00-84a8-11e2-afba-0002a5d5c51b)

| Characteristic UUID                  | Access      | Type       | Description                          |
| ------------------------------------ | ----------- | ---------- | ------------------------------------ |
| 39e1fc01-84a8-11e2-afba-0002a5d5c51b | read        | uint16     | number of entries                    |
| 39e1fc02-84a8-11e2-afba-0002a5d5c51b | read        | uint32     | last entry index                     |
| 39e1fc03-84a8-11e2-afba-0002a5d5c51b | read/write  | uint32     | transfer start index                 |
| 39e1fc04-84a8-11e2-afba-0002a5d5c51b | read        | uint16     | current session id                   |
| 39e1fc05-84a8-11e2-afba-0002a5d5c51b | read        | uint32     | current session start index          |
| 39e1fc06-84a8-11e2-afba-0002a5d5c51b | read        | uint16     | current session period (s)           |

See [Historical data](#historical-data).

##### Clock service (UUID 39e1fd00-84a8-11e2-afba-0002a5d5c51b)

| Characteristic UUID                  | Access      | Type       | Description                          |
| ------------------------------------ | ----------- | ---------- | ------------------------------------ |
| 39e1fd01-84a8-11e2-afba-0002a5d5c51b | read        | uint32     | seconds since device boot            |

See [Device time](#device-time).

##### Calibration service (UUID 39e1fe00-84a8-11e2-afba-0002a5d5c51b)

| Characteristic UUID                  | Access      | Type       | Description                          |
| ------------------------------------ | ----------- | ---------- | ------------------------------------ |
| 39e1fe01-84a8-11e2-afba-0002a5d5c51b | read        | uint16[]   | calibration data                     |
| 39e1fe02-84a8-11e2-afba-0002a5d5c51b | read        | -          | force bond, a read starts the iOS pairing procedure |
| 39e1fe03-84a8-11e2-afba-0002a5d5c51b | read/write  | 19 bytes   | friendly name                        |
| 39e1fe04-84a8-11e2-afba-0002a5d5c51b | read        | uint16     | color                                |
| 39e1fe05-84a8-11e2-afba-0002a5d5c51b | read        | ?          | unknown (present in firmware 2.0.3)  |
| 39e1fe06-84a8-11e2-afba-0002a5d5c51b | read/write  | ?          | unknown (present in firmware 2.0.3)  |

A `1.0.0` device enumerated this service with no characteristic at all, most likely because they require bonding.

##### OTA download service (UUID f000ffc0-0451-4000-b000-000000000000)

| Characteristic UUID                  | Access      | Type       | Description                   |
| ------------------------------------ | ----------- | ---------- | ----------------------------- |
| f000ffc1-0451-4000-b000-000000000000 | read/write  | 8 bytes    | OAD image notify              |
| f000ffc2-0451-4000-b000-000000000000 | read/write  | 18 bytes   | OAD image block               |

The standard Texas Instruments OAD service, see [Firmware update](#firmware-update).
Like the calibration service, it showed no characteristic on a `1.0.0` device that was not bonded.

## Firmware versions

The set of characteristics depends on the firmware, and is not simply cumulative.
Always discover the services rather than assuming a characteristic exists.

| Characteristic         | 1.0.0 (device) | 1.1.0+ (Parrot documentation) | 2.0.3 (firmware image) |
| ---------------------- | -------------- | ----------------------------- | ---------------------- |
| `39e1fa01` - `39e1fa07`| yes            | yes                           | yes                    |
| `39e1fa08` last move   | yes            | yes                           | **no**                 |
| `39e1fa09` - `39e1fa0b`| no             | yes                           | yes                    |
| `39e1fa0c` - `39e1fa0e`| no             | yes                           | **no**                 |
| plant doctor service   | no             | ?                             | yes                    |

The `1.1.0` column comes from the Parrot documentation and has not been checked against hardware.
The three conductivity related calibrated values are documented, but absent from the last firmware.

### Firmware version

The firmware revision string (`2a26`) is a build string formatted as `<date>_<project>-<version>_<config>`:

```
2013-09-05_hawaii-1.0.0_hardware-config-MP
2016-09-14_hawaii-2.0.3_hardware-config-MP
```

The project name `hawaii` identifies a Flower Power, the Pot uses `hawaii2`.

The hardware revision string (`2a27`) follows the same layout and holds the bootloader version.
It is zero padded to a fixed size, strip the trailing `0x00` bytes before parsing:

```
2013-07-26_hawaiiProduction-1.2_protoDV-bootloader
```

## Reading data

### Device name

The device name (`2a00`) is plain ASCII, for example `466c6f77657220706f776572` reads `Flower power`.

### Friendly name and color

The friendly name (`39e1fe03`) is a fixed size 19 bytes buffer, zero padded, readable and writable.
Only the ASCII part up to the first null byte is meaningful. A device named `Flower power 0000` reads back as
17 ASCII characters, a null terminator, and one trailing byte:

```
466c6f77657220706f776572203030303000cc
```

The color (`39e1fe04`) is a `uint16`:

| Value | Color         | Pantone |
| ----- | ------------- | ------- |
| 1     | brown         | 7582C   |
| 2     | emerald       | 3272C   |
| 3     | lemon         | 389C    |
| 4     | gray-brown    | 7532C   |
| 5     | gray-green    | 5545C   |
| 6     | classic-green | 363C    |
| 7     | gray-blue     | 549C    |

### Battery

The battery level (`2a19`) is a single `uint8` percentage, for example `0x64` is 100 %.

### Real time data

The raw live characteristics (`39e1fa01` to `39e1fa05`) are `uint16`, converted with the formulas below.
They match the official application and the Parrot reference documentation.

When the firmware exposes them, prefer the [calibrated values](#calibrated-values), which the device has already converted.

| Measurement        | UUID       | Conversion                                                                  | Range          |
| ------------------ | ---------- | --------------------------------------------------------------------------- | -------------- |
| sunlight           | `39e1fa01` | `dli = 0.0864 * 192773.17 * raw^-1.0606619`                                 | mol/m²/day     |
| soil conductivity  | `39e1fa02` | `ec = round(raw / 1.771)`                                                   | µS/cm          |
| soil temperature   | `39e1fa03` | `t = 3.044e-8 * raw^3 - 8.038e-5 * raw^2 + 0.1149 * raw - 30.45`            | °C             |
| air temperature    | `39e1fa04` | same as soil temperature, clamped                                           | -10 - 55 °C    |
| soil moisture      | `39e1fa05` | two steps, see below, clamped                                               | 0 - 60 %       |

Soil moisture:

```
h1 = 11.4293 + (1.0698e-9 * raw^4 - 1.52538e-6 * raw^3 + 8.66976e-4 * raw^2 - 0.169422 * raw)
moisture (%) = round(100 * (4.5e-6 * h1^3 - 5.5e-4 * h1^2 + 0.0292 * h1 - 0.053))
```

Soil conductivity: the raw output ranges from `0` (no soil) to about `1771` (maximum observed).
It is usually described as a 0 - 10 mS/cm scale, while the formula above yields 0 - 1000 µS/cm (0 - 1 mS/cm).
This scaling is ad hoc either way, the calibrated `ec` values are a better source when available.

Sunlight: the native output is **not** lux, it is a photosynthetic daily light integral (DLI).
A conversion to an instantaneous illuminance is commonly done as:

```
ppfd (µmol/m²/s) = dli * 1e6 / 86400     // dli * 11.574
lux              = ppfd * 53.93          // PPF to lux, daylight spectrum
                                         // so lux = dli * 624.2
```

> **The lux conversion has never been checked against a reference.** 
> The official application doesn't work with my 'old' FlowerPower firmware...
> The same chain turned out to be wrong on the [Parrot Pot](parrotpot-ble-api.md#sunlight),
> where the calibrated sunlight is not a daily integral and not linear in illuminance.
> The two devices do not share a raw sunlight scale (the Pot's raw value *increases* with light, this formula *decreases*),
> so the Pot results cannot simply be carried over. The DLI is the value Parrot documents, and is the safer one to use.
> Measure the lux figure against a known source before relying on it.

### Calibrated values

The calibrated characteristics (`39e1fa09` to `39e1fa0e`) hold little-endian `float32` values already converted by the device.
They avoid the polynomial approximations above entirely.

| UUID       | Value                     | Unit        |
| ---------- | ------------------------- | ----------- |
| `39e1fa09` | soil moisture, VWC        | %           |
| `39e1fa0a` | air temperature           | °C          |
| `39e1fa0b` | sunlight, DLI             | mol/m²/day  |
| `39e1fa0c` | ea, soil permittivity     | ?           |
| `39e1fa0d` | ecb, bulk conductivity    | ?           |
| `39e1fa0e` | ec porous, pore water EC  | ?           |

The units of the three `ec` values have not been confirmed.

### Live mode

Reading a live characteristic returns the last measurement taken by the device on its own schedule.
To get periodic updates, write the desired period in seconds to the live measure period (`39e1fa06`). Write `0` to disable it.
The period drives both the raw and the calibrated characteristics.

The order of operations matters:

* to **enable**: subscribe to the notifications of every characteristic of interest *first*, then write the period (`1` for one measurement per second)
* to **disable**: write `0` to the period *first*, then unsubscribe

Disable live mode as soon as the values are no longer displayed, it keeps the sensor and the radio busy and drains the battery.

### LED

Write `0x01` to the LED status (`39e1fa07`) to switch the LED on, `0x00` to switch it off.
The LED is switched off automatically when the device disconnects. Do not leave it on for long, it drains the battery.

### Last move

The last move date (`39e1fa08`) is a `uint32`: the time of the last detected motion, in seconds since device boot.
See [Device time](#device-time) to convert it to an absolute timestamp.
Reading it clears the `move detected` [advertisement flag](#advertisement-data).

### Device time

The current time (`39e1fd01`) is a `uint32`: the number of seconds elapsed since the device booted.
The Flower Power has no absolute clock (unlike the [Parrot Pot](parrotpot-ble-api.md#device-time)),
so device relative timestamps (last move, history entries) are converted with a "wall time" offset stored by the application:

```
wall_time = current_unix_time - device_time
absolute_time = wall_time + device_relative_timestamp
```

## Historical data

The device continuously records measurements into an internal history file.
The history service (`39e1fc00`) tells what is available and where to start, the upload service (`39e1fb00`) transfers the file.

> **The history file format is undocumented.** Every known implementation retrieves the raw file and stops there.
> The layout of a history entry still has to be reverse engineered.

### History state

The index of the oldest available entry is:

```
first_index = last_entry_index - number_of_entries + 1
```

The session id (`39e1fc04`) changes when the device restarts (battery replacement, reboot).
A new session means the index space is no longer continuous with what was previously downloaded.

The session period (`39e1fc06`) is the logging interval. `900` (15 minutes) was read on both a Flower Power and a Parrot Pot,
and is presumably the default.

### File transfer

The two sides synchronise through a pair of state characteristics, and the file is pushed as `Tx buffer` notifications.

Tx status (`39e1fb02`), device side, notified:

| Value | State        |
| ----- | ------------ |
| 0     | idle         |
| 1     | transferring |
| 2     | waiting ack  |

Rx status (`39e1fb03`), application side, written:

| Value | State     |
| ----- | --------- |
| 0     | standby   |
| 1     | receiving |
| 2     | ack       |
| 3     | nack      |
| 4     | cancel    |
| 5     | error     |

Procedure:

1. write the desired start index to `39e1fc03`; the device may start *before* that index, never after it
2. subscribe to the `Tx status` and `Tx buffer` notifications
3. write `1` (receiving) to `Rx status`
4. the device switches to `transferring` and sends `Tx buffer` notifications
5. after 128 frames, or once the whole file has been sent, the device switches to `waiting ack`
6. check that every frame of the group has been received, then write `2` (ack), or `3` (nack) if any frame is missing
7. repeat from step 4 until all frames have been received
8. after the final group: write `2` (ack), unsubscribe from both characteristics, then write `0` (standby) to `Rx status`

### Frame format

Each `Tx buffer` notification is at most 20 bytes: a frame index followed by up to 18 bytes of payload.

Frame 0 is a header carrying the file length:

| Bytes | Type        | Description                           |
| ----- | ----------- | ------------------------------------- |
| 00-01 | uint16      | frame index, always 0                 |
| 02-05 | uint32      | file length, in bytes                 |
| 06-19 | -           | reserved                              |

All other frames:

| Bytes | Type        | Description   |
| ----- | ----------- | ------------- |
| 00-01 | uint16      | frame index   |
| 02-19 | raw         | payload       |

> The Parrot documentation says the frame index and the file length are big-endian. **They are little-endian.**

* the number of frames, header included, is `ceil(file_length / 18) + 1`
* the file is the concatenation of the payloads of frames 1 and up, truncated to the file length
* the frame index wraps back to 0 after 65535
* a frame can be sent twice, and frames can arrive out of order by up to 4 positions within a group;
  storing the payloads in a map keyed by frame index handles both cases

### Clearing entries

Unknown.

## Firmware update

The OAD service (`f000ffc0`) is a standard Texas Instruments implementation.
Firmware images are named after the [firmware revision](#firmware-version) build string,
for example `2016-09-14_hawaii-2.0.3_hardware-config-MP.bin`.

Procedure, as implemented by `node-flower-power` [4]:

1. read 8 bytes at offset 4 of the image file, this is the image header; the image size, in 16 bytes blocks, is a `uint16` at offset 2 of that header
2. read the current header from `OAD image notify` (`f000ffc1`); if it matches the file header, the device already runs this image
3. otherwise, write the file header to `OAD image notify` to start the transfer
4. read `OAD image block` (`f000ffc2`) to get the block index the device expects next
5. write 128 consecutive blocks of `[uint16 index][16 bytes of image data]` to `OAD image block`
6. repeat from step 4 until the device disconnects, which signals the end of the update

> Untested, and carries an obvious risk of bricking the device.

## Advertisement data

Flower Power with firmware 1.0 doesn't seem to advertise data.  

## Reference

[1] https://developer.parrot.com/docs/FlowerPower/FlowerPower-BLE.pdf  
[2] https://github.com/Parrot-Developers/node-flower-power  
[3] https://www.fanjoe.be/?p=3520  
[4] https://github.com/sandeepmistry/node-flower-power (upload, OAD and live mode implementations)  
[5] https://github.com/tazounet/parrot_flower_plugin (Domoticz plugin, calibrated characteristics)  
[6] toolBLEx capture of a `Flower power 834D` running `hawaii-1.0.0`, and the UUID pool of the `2016-09-14_hawaii-2.0.3_hardware-config-MP` OAD image  

## License

MIT
