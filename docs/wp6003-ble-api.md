
<img src="wp6003.svg" width="400px" alt="Air Box WP6003" align="right" />

## About WP6003

* VSON technology [WP6003](http://www.vson.com.cn/English/Product/3614894931.html) are air quality sensors
* Has sensors to relay temperature, TVOC, HCHO and eCO2
* Uses Bluetooth Low Energy (BLE) and has a limited range
* 5V USB is used as power source

## Features

* Read real-time sensor values
* Read historical sensor values
* Temperature
* TVOC and HCHO mesurements
* CO2 estimation

## Protocol

The device uses BLE GATT for communication.  
Sensor values are immediately available for reading.  

### BLE & GATT

The basic technologies behind the sensors communication are [Bluetooth Low Energy (BLE)](https://en.wikipedia.org/wiki/Bluetooth_Low_Energy) and [GATT](https://www.bluetooth.com/specifications/gatt).
They allow the devices and the app to share data in a defined manner and define the way you can discover the devices and their services.
In general you have to know about services and characteristics to talk to a BLE device.

<img src="endianness.png" width="400px" alt="Endianness" align="right" />

### Data structure

The data is encoded in big-endian byte order.  
This means that the data is represented with the most significant byte first.  

To understand multi-byte integer representation, you can read the [endianness](https://en.wikipedia.org/wiki/Endianness) Wikipedia page.

## Services, characteristics and handles

The name advertised by the devices is `WP6003#XXXXXXXXXXXX`, WP6003# followed by the MAC address of the device.  

##### Generic access (UUID 00001800-0000-1000-8000-00805f9b34fb)

| Characteristic UUID                  | Access      | Description                     |
| ------------------------------------ | ----------- | ------------------------------- |
| 00002a00-0000-1000-8000-00805f9b34fb | read,write  | device name                     |
| 00002a01-0000-1000-8000-00805f9b34fb | read,write  | appearance                      |
| 00002a02-0000-1000-8000-00805f9b34fb | read        | privacy flag                    |
| 00002a04-0000-1000-8000-00805f9b34fb | read        | connection parameters           |

##### Generic attribute (UUID 00001801-0000-1000-8000-00805f9b34fb)

##### Communication service (UUID 0000fff0-0000-1000-8000-00805f9b34fb)

| Characteristic UUID                  | Access        | Description                   |
| ------------------------------------ | ------------- | ----------------------------- |
| 0000fff1-0000-1000-8000-00805f9b34fb | write no resp | TX                            |
| 0000fff4-0000-1000-8000-00805f9b34fb | read,notify   | RX                            |

#### Communication with the device

First of all you need to register to get notification on the RX characteristic.

##### Set device time

Writing 7 bytes (`0xaaYYMMDDhhmmss`) to the TX handle will set the device time.  

| Bytes | Type      | Value             | Description           |
| ----- | --------- | ----------------- | --------------------- |
| 00    | bytes     | 0xaa              | command               |
| 01    | bytes     | 20                | year % 100            |
| 02    | bytes     | 01                | month                 |
| 03    | bytes     | 01                | day                   |
| 04    | bytes     | 12                | hour                  |
| 05    | bytes     | 30                | minute                |
| 06    | bytes     | 00                | second                |

##### Read entries

Writing 1 byte (`0xab`) to the TX handle will make the device send back a data packet on RX.  

The response is as follow:

| Bytes | Type      | Value             | Description           |
| ----- | --------- | ----------------- | --------------------- |
| 00    | bytes     | 0x0a              | command               |
| 01    | bytes     | 20                | year % 100            |
| 02    | bytes     | 01                | month                 |
| 03    | bytes     | 01                | day                   |
| 04    | bytes     | 12                | hour                  |
| 05    | bytes     | 30                | minute                |
| 06-07 | int16_be  | 221 (221/10=22.1°)| temperature (°C)      |
| 06-07 | uint16_be |                   | VOC (µg/m3)           |
| 06-07 | uint16_be |                   | HCHO (µg/m3)          |
| 06-07 | uint16_be | 560               | eCO2 (PPM)            |

The sensor needs a couple of minutes to warm up and send valid data (VOC and HCHO will read 16383 in the mean time) and about an hour to provide accurate and stable readings.

## Advertisement data

There seems to be no advertisement data broadcasted.  

## Reference

[1] -

## License

MIT
