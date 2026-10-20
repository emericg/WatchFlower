
## About Ruuvi Air

* Ruuvi Innovations [Ruuvi Air](https://ruuvi.com/air/) are indoor air quality monitors
* Has sensors to relay temperature, humidity, air pressure, CO2, particulate matter, VOC, NOx and luminosity
* Uses Bluetooth Low Energy (BLE) and has a limited range
* Powered over USB

## Features

* Read real-time sensor values
* Temperature, humidity and air pressure sensors
* CO2, PM1.0 / PM2.5 / PM4.0 / PM10, VOC and NOx index sensors
* Luminosity sensor

## Protocol

The device broadcasts its sensor values over BLE advertisement.  
No connection is needed to read them.  

<img src="endianness.png" width="400px" alt="Endianness" align="right" />

### Data structure

Unlike most Bluetooth payloads, Ruuvi payloads use big-endian byte order.  
This means that the data is represented with the most significant byte first.  

To understand multi-byte integer representation, you can read the [endianness](https://en.wikipedia.org/wiki/Endianness) Wikipedia page.

## Advertisement data

The device broadcasts `manufacturer data` with the Ruuvi Innovations company identifier `0x0499`.  
The first byte is the data format:

* format E1, 40 bytes, sent using Bluetooth 5 extended advertising
* format 6, 20 bytes, a reduced version for Bluetooth 4 scanners

A scanner receiving both should discard the format 6 packets.  
RuuviTag devices use the same company identifier and name, with formats 3 and 5 (see [RuuviTag](ruuvitag-ble-api.md)).  

Invalid values are the smallest signed value (`0x8000`), or the largest unsigned value (all bits set).

##### Data format E1, 40 bytes

| Bytes | Type      | Conversion                    | Description                         |
| ----- | --------- | ----------------------------- | ----------------------------------- |
| 00    | uint8     | -                             | data format (`0xE1`)                |
| 01-02 | int16_be  | x 0.005                       | temperature (°C)                    |
| 03-04 | uint16_be | x 0.0025                      | humidity (% RH)                     |
| 05-06 | uint16_be | + 50000                       | air pressure (Pa)                   |
| 07-08 | uint16_be | x 0.1                         | PM1.0 (µg/m³)                       |
| 09-10 | uint16_be | x 0.1                         | PM2.5 (µg/m³)                       |
| 11-12 | uint16_be | x 0.1                         | PM4.0 (µg/m³)                       |
| 13-14 | uint16_be | x 0.1                         | PM10 (µg/m³)                        |
| 15-16 | uint16_be | -                             | CO2 (ppm)                           |
| 17    | uint8     | see below                     | VOC index, bits 8-1                 |
| 18    | uint8     | see below                     | NOx index, bits 8-1                 |
| 19-21 | uint24_be | x 0.01                        | luminosity (lux)                    |
| 22-24 | bytes     | -                             | reserved                            |
| 25-27 | uint24_be | -                             | measurement sequence number         |
| 28    | uint8     | -                             | flags                               |
| 29-33 | bytes     | -                             | reserved                            |
| 34-39 | bytes     | -                             | MAC address                         |

##### Data format 6, 20 bytes

| Bytes | Type      | Conversion                    | Description                         |
| ----- | --------- | ----------------------------- | ----------------------------------- |
| 00    | uint8     | -                             | data format (`0x06`)                |
| 01-02 | int16_be  | x 0.005                       | temperature (°C)                    |
| 03-04 | uint16_be | x 0.0025                      | humidity (% RH)                     |
| 05-06 | uint16_be | + 50000                       | air pressure (Pa)                   |
| 07-08 | uint16_be | x 0.1                         | PM2.5 (µg/m³)                       |
| 09-10 | uint16_be | -                             | CO2 (ppm)                           |
| 11    | uint8     | see below                     | VOC index, bits 8-1                 |
| 12    | uint8     | see below                     | NOx index, bits 8-1                 |
| 13    | uint8     | logarithmic, see below        | luminosity (lux)                    |
| 14    | uint8     | -                             | reserved                            |
| 15    | uint8     | -                             | measurement sequence number         |
| 16    | uint8     | -                             | flags                               |
| 17-19 | bytes     | -                             | MAC address, lowest 3 bytes         |

##### Flags

| Bit   | Description                                              |
| ----- | -------------------------------------------------------- |
| 0     | calibration in progress, sensor data not fully accurate  |
| 6     | VOC index, bit 0                                         |
| 7     | NOx index, bit 0                                         |

The VOC and NOx indexes are 9 bits values: `VOC = (VOC_byte << 1) | ((flags >> 6) & 0x01)`.  
They are unitless (Sensirion indexes, 100 being the average for VOC, 1 for NOx), 511 is invalid.

##### Logarithmic luminosity (format 6)

`lux = exp(code x ln(65536) / 254) - 1`, code 255 is invalid.

## Services and characteristics

The name advertised by the devices is `Ruuvi XXXX`, XXXX being the last 2 bytes of the MAC address.  

WatchFlower does not save the VOC and NOx indexes, as its VOC values are concentrations.

## Reference

[1] https://docs.ruuvi.com/communication/bluetooth-advertisements/data-format-e1  
[2] https://docs.ruuvi.com/communication/bluetooth-advertisements/data-format-6  

## License

MIT
