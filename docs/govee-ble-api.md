
## About Govee hygrometers

* Govee hygrometers and air quality monitors
* Has sensors to relay temperature and humidity, plus PM2.5 (H5106) or CO2 (H5140)
* Uses Bluetooth Low Energy (BLE) and has a limited range

## Features

* Read real-time sensor values
* Temperature and humidity sensors
* PM2.5 (H5106) and CO2 (H5140) sensors

## Protocol

The device broadcasts its sensor values over BLE advertisement.  
No connection is needed to read them.  

<img src="endianness.png" width="400px" alt="Endianness" align="right" />

### Data structure

Most Govee payloads use big-endian byte order, the older models (H5074, H5051, H5052, H5071, H5179) use little-endian.  
This means that the data is represented with the most (big-endian) or least (little-endian) significant byte first.  

To understand multi-byte integer representation, you can read the [endianness](https://en.wikipedia.org/wiki/Endianness) Wikipedia page.

### Device name

The model is only reliably identified by the advertised device name, for example:

* `GVH5102_C1B9`, `GVH5075_2762`: `GVH` + model number + last 2 bytes of the MAC address
* `Govee_H5179_3CD5`, `Govee_H5052_E81B`: `Govee_H` + model number + last 2 bytes of the MAC address
* `GV5140303A`, `GV51085242`, `GV5179_6319`: `GV` + model number + last 2 bytes of the MAC address
* `B51782BC8`: H5178

GV5179 (`GV5179` prefix) and H5179 (`Govee_H5179` prefix) are different devices, with different payloads.

## Advertisement data

The device broadcasts `manufacturer data`, but the company identifier field is not a Govee company identifier:
`0xEC88` and `0x8801` are not registered, `0x0001` is registered to Nokia.  

Some firmwares glue an iBeacon frame at the end of the manufacturer data (25 bytes, `4C 00 02 15` then `INTELLI_ROCKS_HW`...),
it must be removed first. The same iBeacon frame is often also advertised on its own, with the Apple company identifier `0x004C`.  

##### Packed temperature and humidity (3 bytes)

Most models pack the temperature and the humidity into a single 24-bit big-endian value:

* bit 23: temperature sign
* temperature (°C) = int((value & 0x7FFFFF) / 1000) / 10, negative if bit 23 is set
* humidity (% RH) = ((value & 0x7FFFFF) % 1000) / 10

The packed value is usually followed by a byte holding the battery level (bits 6-0, %) and a sensor error flag (bit 7).

##### H5072, H5075, H5129: company ID `0xEC88`, 6 bytes

| Bytes | Type      | Conversion                    | Description                         |
| ----- | --------- | ----------------------------- | ----------------------------------- |
| 00    | uint8     | -                             | `0x00`                              |
| 01-03 | uint24_be | see above                     | packed temperature (°C) and humidity (% RH) |
| 04    | uint8     | bits 6-0                      | battery (%)                         |
|       |           | bit 7                         | sensor error                        |
| 05    | uint8     | -                             | ?                                   |

##### H5074 (7 bytes), H5051, H5052, H5071 (9 bytes): company ID `0xEC88`

| Bytes | Type      | Conversion                    | Description                         |
| ----- | --------- | ----------------------------- | ----------------------------------- |
| 00    | uint8     | -                             | `0x00`                              |
| 01-02 | int16_le  | / 100                         | temperature (°C)                    |
| 03-04 | uint16_le | / 100                         | humidity (% RH)                     |
| 05    | uint8     | -                             | battery (%)                         |
| 06-08 | bytes     | -                             | ?                                   |

##### H5100 to H5105, H5108, H5110, H5174, H5177, GV5179: company ID `0x0001`, 6 or 8 bytes

| Bytes | Type      | Conversion                    | Description                         |
| ----- | --------- | ----------------------------- | ----------------------------------- |
| 00-01 | bytes     | -                             | `0x01 0x01`                         |
| 02-04 | uint24_be | see above                     | packed temperature (°C) and humidity (% RH) |
| 05    | uint8     | bits 6-0                      | battery (%)                         |
|       |           | bit 7                         | sensor error                        |
| 06-07 | bytes     | -                             | `0x00 0x00` (8 bytes payloads only) |

##### H5178: company ID `0x0001`, 9 bytes

The H5178 main unit relays its own values and the values of its remote sensor, in alternate advertisements.

| Bytes | Type      | Conversion                    | Description                         |
| ----- | --------- | ----------------------------- | ----------------------------------- |
| 00-01 | bytes     | -                             | `0x01 0x01`                         |
| 02    | uint8     | -                             | sensor (0: main unit, 1: remote sensor) |
| 03-05 | uint24_be | see above                     | packed temperature (°C) and humidity (% RH) |
| 06    | uint8     | bits 6-0                      | battery (%)                         |
|       |           | bit 7                         | sensor error                        |
| 07-08 | bytes     | -                             | ?                                   |

WatchFlower only uses the main unit values.

##### H5112: company ID `0x0001`, 8 bytes

The H5112 relays the values of its two probes, in alternate advertisements.

| Bytes | Type      | Conversion                    | Description                         |
| ----- | --------- | ----------------------------- | ----------------------------------- |
| 00-01 | bytes     | -                             | `0x01 0x01`                         |
| 02-04 | uint24_be | see above                     | packed temperature (°C) and humidity (% RH, probe 1 only) |
| 05    | uint8     | bits 6-0                      | battery (%)                         |
|       |           | bit 7                         | sensor error                        |
| 06    | uint8     | -                             | ?                                   |
| 07    | uint8     | -                             | probe (`0x41`: probe 1, `0x82`: probe 2) |

WatchFlower only uses the probe 1 values.

##### H5179: company ID `0x8801`, 9 bytes

| Bytes | Type      | Conversion                    | Description                         |
| ----- | --------- | ----------------------------- | ----------------------------------- |
| 00-03 | bytes     | -                             | `0xEC 0x00 0x01 0x01`               |
| 04-05 | int16_le  | / 100                         | temperature (°C)                    |
| 06-07 | uint16_le | / 100                         | humidity (% RH)                     |
| 08    | uint8     | -                             | battery (%)                         |

##### H5106 (PM2.5): company ID `0x0001`, 6 bytes

| Bytes | Type      | Conversion                    | Description                         |
| ----- | --------- | ----------------------------- | ----------------------------------- |
| 00-01 | bytes     | -                             | `0x01 0x01`                         |
| 02-05 | uint32_be | see below                     | packed temperature (°C), humidity (% RH) and PM2.5 (µg/m³) |

* bit 31: temperature sign
* temperature (°C) = int((value & 0x7FFFFFFF) / 1000000) / 10, negative if bit 31 is set
* humidity (% RH) = int(((value & 0x7FFFFFFF) % 1000000) / 1000) / 10
* PM2.5 (µg/m³) = (value & 0x7FFFFFFF) % 1000

##### H5140 (CO2): company ID `0x0001`, 8 bytes

| Bytes | Type      | Conversion                    | Description                         |
| ----- | --------- | ----------------------------- | ----------------------------------- |
| 00-01 | bytes     | -                             | `0x01 0x01`                         |
| 02-04 | uint24_be | see above                     | packed temperature (°C) and humidity (% RH) |
| 05-06 | uint16_be | -                             | CO2 (ppm)                           |
| 07    | uint8     | -                             | sensor error (0: no error)          |

##### Example (H5102)

Device name `GVH5102_C1B9`, company ID `0x0001`, manufacturer data `0101 03BEEA 32`

* packed value: 0x03BEEA = 245482
* temperature: int(245482 / 1000) / 10 = 24.5 °C
* humidity: (245482 % 1000) / 10 = 48.2 %
* battery: 0x32 & 0x7F = 50 %, no sensor error (bit 7 not set)

Temperatures outside of -40 → 100 °C, and values flagged with the sensor error bit, are invalid.

## Reference

[1] https://github.com/Bluetooth-Devices/govee-ble  
[2] https://github.com/custom-components/ble_monitor  

## License

MIT
