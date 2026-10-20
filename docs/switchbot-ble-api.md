
## About SwitchBot hygrometers

* SwitchBot (Woan Technology) Meter, Meter Plus, Meter Pro, Meter Pro CO2, Indoor/Outdoor Thermo-Hygrometer and Weather Station
* Has sensors to relay temperature and humidity, plus CO2 (Meter Pro CO2)
* Uses Bluetooth Low Energy (BLE) and has a limited range

## Features

* Read real-time sensor values
* Temperature and humidity sensors
* CO2 sensor (Meter Pro CO2)

## Protocol

The device broadcasts its sensor values over BLE advertisement.  
No connection is needed to read them.  

<img src="endianness.png" width="400px" alt="Endianness" align="right" />

### Data structure

The CO2 value uses big-endian byte order.  
This means that the data is represented with the most significant byte first.  

To understand multi-byte integer representation, you can read the [endianness](https://en.wikipedia.org/wiki/Endianness) Wikipedia page.

### Device name

| Model                            | Name             |
| -------------------------------- | ---------------- |
| Meter                            | `WoSensorTH`     |
| Meter Plus                       | `WoSensorTHPlus` |
| Meter Pro                        | `WoSensorTHP`    |
| Meter Pro CO2                    | `WoSensorTHPc`   |
| Indoor/Outdoor Thermo-Hygrometer | `WoIOSensorTH`   |

The model is more reliably identified by the model identifier of the service data (see below).

## Advertisement data

The device broadcasts two parts, usually in the same advertisement:

* `service data`, with the `0xFD3D` 16 bits service UUID (older devices use `0x0D00`)
* `manufacturer data`, with the Woan Technology company identifier `0x0969`

Newer models put their values in the manufacturer data, and their battery level in the service data:
both parts are needed.

##### Service data

| Bytes | Type      | Conversion                    | Description                         |
| ----- | --------- | ----------------------------- | ----------------------------------- |
| 00    | uint8     | bits 6-0                      | model identifier                    |
|       |           | bit 7                         | encrypted                           |
| 01    | uint8     | -                             | ?                                   |
| 02    | uint8     | bits 6-0                      | battery (%)                         |
| 03-05 | bytes     | see below                     | temperature and humidity (older models) |

Model identifiers (the two values only differ by bit 5):

| Model                            | Identifier                        |
| -------------------------------- | --------------------------------- |
| Meter                            | `T` (`0x54`) / `t` (`0x74`)       |
| Meter Plus                       | `i` (`0x69`) / `I` (`0x49`)       |
| Meter Pro                        | `4` (`0x34`) / `0x14`             |
| Meter Pro CO2                    | `5` (`0x35`) / `0x15`             |
| Indoor/Outdoor Thermo-Hygrometer | `w` (`0x77`) / `W` (`0x57`)       |
| Weather Station                  | `00 10 53 B0` / `01 10 53 B0`, at the end of the service data (last 4 bytes, or the 4 bytes before the last one) |

##### Manufacturer data

| Bytes | Type      | Conversion                    | Description                         |
| ----- | --------- | ----------------------------- | ----------------------------------- |
| 00-05 | bytes     | -                             | MAC address                         |
| 06    | uint8     | -                             | sequence number                     |
| 07    | uint8     | bits 6-0                      | battery (%, Weather Station only)   |
|       |           | bit 7                         | charging (Weather Station only)     |
| 08-10 | bytes     | see below                     | temperature and humidity            |
| 11-12 | bytes     | -                             | ?                                   |
| 13-14 | uint16_be | -                             | CO2 (ppm, Meter Pro CO2 only, values above 9999 are invalid) |

When the manufacturer data is shorter than 11 bytes, the temperature and humidity come from the service data.

##### Temperature and humidity (3 bytes)

| Bytes | Type      | Conversion                    | Description                         |
| ----- | --------- | ----------------------------- | ----------------------------------- |
| 00    | uint8     | bits 3-0, x 0.1               | temperature, decimal part (°C)      |
| 01    | uint8     | bits 6-0                      | temperature, integer part (°C)      |
|       |           | bit 7                         | temperature sign (1: positive)      |
| 02    | uint8     | bits 6-0                      | humidity (% RH)                     |
|       |           | bit 7                         | °F display                          |

A temperature and a humidity both at 0 means no measurement.

##### Example (Meter, service data only)

Service data `54 00 E4 07 99 2A`

* model: 0x54 & 0x7F = `T`, Meter, not encrypted
* battery: 0xE4 & 0x7F = 100 %
* temperature: 0x99 & 0x7F = 25, + (0x07 & 0x0F) x 0.1 = 25.7 °C, positive (bit 7 of 0x99 set)
* humidity: 0x2A & 0x7F = 42 %, °C display (bit 7 of 0x2A not set)

## Reference

[1] https://github.com/sblibs/pySwitchbot  
[2] https://github.com/OpenWonderLabs/SwitchBotAPI-BLE  

## License

MIT
