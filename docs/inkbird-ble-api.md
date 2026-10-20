
## About Inkbird hygrometers

* Inkbird hygrometers (IBS-TH, IBS-TH2, ITH-11-B, ITH-13-B, ITH-21-B), pool thermometers (IBS-P01B, IBS-P02B)
  and air quality monitor (IAM-T2)
* Has sensors to relay temperature and humidity, plus CO2 (IAM-T2)
* Uses Bluetooth Low Energy (BLE) and has a limited range

## Features

* Read real-time sensor values
* Temperature and humidity sensors (no humidity sensor on the IBS-P01B and IBS-P02B)
* CO2 sensor (IAM-T2)

## Protocol

The device broadcasts its sensor values over BLE advertisement.  
No connection is needed to read them.  

<img src="endianness.png" width="400px" alt="Endianness" align="right" />

### Data structure

The hygrometers use little-endian byte order, the IAM-T2 uses big-endian.  
This means that the data is represented with the least (little-endian) or most (big-endian) significant byte first.  

To understand multi-byte integer representation, you can read the [endianness](https://en.wikipedia.org/wiki/Endianness) Wikipedia page.

### Device name

| Model                            | Name             |
| -------------------------------- | ---------------- |
| IBS-TH                           | `sps`            |
| IBS-TH2 / IBS-P01B               | `tps`            |
| IBS-P02B                         | `IBS-P02B`       |
| ITH-11-B / ITH-13-B / ITH-21-B   | `ITH-11-B` / `ITH-13-B` / `ITH-21-B` |
| IAM-T2                           | `Ink@IAM-T2`     |

The `sps` and `tps` names are generic, the devices also advertise the `0xFFF0` service UUID.  
The IBS-TH2 and IBS-P01B share the same name, the IBS-P01B has no humidity sensor.  

## Advertisement data

The device broadcasts `manufacturer data`, but the company ID field is not a company ID:
it holds the first 2 bytes of the payload.  

##### IBS-TH, IBS-TH2, IBS-P01B: 7 bytes

| Bytes     | Type      | Conversion                    | Description                         |
| --------- | --------- | ----------------------------- | ----------------------------------- |
| company ID | int16_le | / 100                         | temperature (°C)                    |
| 00-01     | uint16_le | / 100                         | humidity (% RH), IBS-P01B: `0x0000` or `0xFFFF` |
| 02-04     | bytes     | -                             | ?                                   |
| 05        | uint8     | -                             | battery (%)                         |
| 06        | uint8     | -                             | ?                                   |

The temperature changes the company ID field with every reading.
Some Bluetooth stacks (BlueZ on Linux) keep the manufacturer data of previous advertisements,
under their old company IDs: only the new (or changed) data holds the current values.  

##### IBS-P02B, ITH-11-B, ITH-13-B, ITH-21-B: company ID `0x2449`, 16 bytes

| Bytes | Type      | Conversion                    | Description                         |
| ----- | --------- | ----------------------------- | ----------------------------------- |
| 00-03 | bytes     | -                             | ?                                   |
| 04-05 | int16_le  | / 10                          | temperature (°C)                    |
| 06-07 | uint16_le | / 10                          | humidity (% RH), 0: no humidity sensor |
| 08    | uint8     | -                             | battery (%)                         |
| 09-15 | bytes     | -                             | ?                                   |

##### IAM-T2: company ID `0x3254`, 15 bytes

| Bytes | Type      | Conversion                    | Description                         |
| ----- | --------- | ----------------------------- | ----------------------------------- |
| 00-05 | bytes     | -                             | MAC address related (starts with `00 62`) |
| 06    | uint8     | -                             | ?                                   |
| 07    | uint8     | bit 1                         | temperature unit (1: °F)            |
| 08-09 | int16_be  | / 10                          | temperature (°C or °F)              |
| 10-11 | uint16_be | / 10                          | humidity (% RH)                     |
| 12-13 | uint16_be | -                             | CO2 (ppm)                           |
| 14    | uint8     | -                             | battery (encoding unknown)          |

Corrupt advertisements happen: humidity above 100 %, battery above 100 % or CO2 above 40000 ppm are invalid.  

##### Example (IBS-TH)

Device name `sps`, company ID `0x07FC`, manufacturer data `C712 00C83D 56 06`

* temperature: 0x07FC = 2044 / 100 = 20.44 °C
* humidity: 0x12C7 = 4807 / 100 = 48.07 %
* battery: 0x56 = 86 %

## Reference

[1] https://github.com/Bluetooth-Devices/inkbird-ble  

## License

MIT
