
<img src="hygrotemp_alarm.svg" width="400px" alt="Digital Hygrometer Alarm" align="right" />

## About MHO-C303

* Miaomiaoce (MMC) 'Digital Hygrometer Alarm' [MHO-C303]() are alarm clock with hygrometers
* Has onboard clock and alarm
* Has sensors to relay temperature and humidity
* Uses Bluetooth Low Energy (BLE) and has a limited range
* 2 * AAA batteries are used as power source

## Features

TODO

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

The name advertised by the devices is `MHO-C303`.  

TODO

## Historical data

TODO

## Advertisement data

MHO-C303 broadcast `service data` with 16 bits service UUID `0xFE95` .  
Check out the [MiBeacon](mibeacon-ble-api.md) protocol page to get more information on advertisement data for this device.  

## Reference

[1] -

## License

MIT
