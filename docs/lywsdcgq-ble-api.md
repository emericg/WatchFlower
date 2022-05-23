
<img src="hygrotemp_lywsdcgq.svg" width="400px" alt="Bluetooth Hygrometer" align="right" />

## About LYWSDCGQ

* Xiaomi MiJia 'Bluetooth Hygrometer' [LYWSDCGQ]() are hygrometers
* Has sensors to relay temperature and humidity
* Uses Bluetooth Low Energy (BLE) and has a limited range
* An AAA battery is used as power source

## Features

* Read real-time sensor values
* Read historical sensor values
* Temperature and humidity sensors

## Protocol

The device uses BLE GATT for communication.  
Sensor values are immediately available for reading.  

### BLE & GATT

The basic technologies behind the sensors communication are [Bluetooth Low Energy (BLE)](https://en.wikipedia.org/wiki/Bluetooth_Low_Energy) and [GATT](https://www.bluetooth.com/specifications/gatt).
They allow the devices and the app to share data in a defined manner and define the way you can discover the devices and their services.
In general you have to know about services and characteristics to talk to a BLE device.

<img src="endianness.png" width="400px" alt="Endianness" align="right" />

### Data structure

Bluetooth payload data typically uses little-endian byte order.  
This means that the data is represented with the least significant byte first.  

To understand multi-byte integer representation, you can read the [endianness](https://en.wikipedia.org/wiki/Endianness) Wikipedia page.

## Services, characteristics and handles

The name advertised by the devices is `MJ_HT_V1`.  

TODO

## Historical data

TODO

## Advertisement data

There seems to be two kind of advertisement data broadcasted.  
LYWSDCGQ broadcast `service data` with 16 bits service UUID `0xFE95` and `0xFFFF`.  

##### UUID `0xFE95` 16-20 bytes messages (with hygrometer data)

Check out the [MiBeacon](mibeacon-ble-api.md) protocol page to get more information on advertisement data for this device.  

##### UUID `0xFFFF` 6 bytes messages

| Position | 00 | 01 | 02 | 03 | 04 | 05 |
| -------- | -- | -- | -- | -- | -- | -- |
| Value    | e7 | b9 | f8 | 86 | 54 | 48 |

| Bytes | Type      | Value             | Description       |
| ----- | --------- | ----------------- | ----------------- |
| 00-05 | bytes     |                   | ?                 |

## Reference

[1] https://github.com/sputnikdev/eclipse-smarthome-bluetooth-binding/issues/18  

## License

MIT
