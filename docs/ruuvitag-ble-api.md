
## About RuuviTag

* Ruuvi Innovations [RuuviTag](https://ruuvi.com/ruuvitag/) are open source environmental sensors
* Has sensors to relay temperature, humidity, air pressure and acceleration
* Uses Bluetooth Low Energy (BLE) and has a limited range
* A CR2477 battery is used as power source

## Features

* Read real-time sensor values
* Temperature, humidity and air pressure sensors
* Accelerometer and movement counter

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
The first byte is the data format. RuuviTag use format 5 (RAWv2), older firmwares use format 3 (RAWv1).  

Ruuvi Air devices use the same company identifier and name, with formats 6 and E1.  

##### Data format 5 (RAWv2), 24 bytes

| Bytes | Type      | Conversion                    | Description                         |
| ----- | --------- | ----------------------------- | ----------------------------------- |
| 00    | uint8     | -                             | data format (`0x05`)                |
| 01-02 | int16_be  | x 0.005                       | temperature (°C)                    |
| 03-04 | uint16_be | x 0.0025                      | humidity (% RH)                     |
| 05-06 | uint16_be | + 50000                       | air pressure (Pa)                   |
| 07-08 | int16_be  | -                             | acceleration X (mG)                 |
| 09-10 | int16_be  | -                             | acceleration Y (mG)                 |
| 11-12 | int16_be  | -                             | acceleration Z (mG)                 |
| 13-14 | uint16_be | bits 15-5: + 1600             | battery voltage (mV)                |
|       |           | bits 4-0: x 2 - 40            | TX power (dBm)                      |
| 15    | uint8     | -                             | movement counter                    |
| 16-17 | uint16_be | -                             | measurement sequence number         |
| 18-23 | bytes     | -                             | MAC address                         |

Invalid values are the smallest signed value (`0x8000`), or the largest unsigned value (all bits set).

##### Data format 3 (RAWv1), 14 bytes

| Bytes | Type      | Conversion                    | Description                         |
| ----- | --------- | ----------------------------- | ----------------------------------- |
| 00    | uint8     | -                             | data format (`0x03`)                |
| 01    | uint8     | x 0.5                         | humidity (% RH)                     |
| 02    | uint8     | bit 7 sign, bits 6-0 value    | temperature, integer part (°C)      |
| 03    | uint8     | / 100                         | temperature fraction (°C)           |
| 04-05 | uint16_be | + 50000                       | air pressure (Pa)                   |
| 06-07 | int16_be  | -                             | acceleration X (mG)                 |
| 08-09 | int16_be  | -                             | acceleration Y (mG)                 |
| 10-11 | int16_be  | -                             | acceleration Z (mG)                 |
| 12-13 | uint16_be | -                             | battery voltage (mV)                |

The temperature is not two's complement: `0x8145` is -1.69 °C.

##### Example (format 5)

`05 12FC 5394 C37C 0004 FFFC 040C AC36 42 00CD CBB8334C884F`

* temperature: 0x12FC = 4860 x 0.005 = 24.3 °C
* humidity: 0x5394 = 21396 x 0.0025 = 53.49 %
* pressure: 0xC37C = 50044 + 50000 = 100044 Pa
* battery voltage: 0xAC36 >> 5 = 1377 + 1600 = 2977 mV
* TX power: 0xAC36 & 0x1F = 22 x 2 - 40 = 4 dBm

## Services and characteristics

The name advertised by the devices is `Ruuvi XXXX`, XXXX being the last 2 bytes of the MAC address.  
It is sent in the scan response, along with the Nordic UART Service UUID.  

Reading historical values through the Nordic UART Service is not implemented.

## Reference

[1] https://docs.ruuvi.com/communication/bluetooth-advertisements/data-format-5-rawv2  
[2] https://docs.ruuvi.com/communication/bluetooth-advertisements/data-format-3-rawv1  
[3] https://docs.ruuvi.com/communication/bluetooth-connection  

## License

MIT
