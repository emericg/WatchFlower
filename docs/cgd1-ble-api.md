
<img src="hygrotemp_cgd1.svg" width="400px" alt="Bluetooth Alarm Clock" align="right" />

## About CGD1

* Qingping (formerly ClearGrass) 'Bluetooth Alarm Clock' [CGD1](https://www.qingping.co/bluetooth-alarm-clock/overview) are alarm clock with hygrometers
* Has onboard clock and alarm
* Has sensors to relay temperature and humidity
* Uses Bluetooth Low Energy (BLE) and has a limited range
* 2 * AAA batteries are used as power source

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

The name advertised by the devices is `Qingping Alarm Clock`.  

TODO

## Historical data

TODO

## Advertisement data

##### UUID `0xFDCD` 17 bytes messages

CGD1 broadcast temperature, humidity, and battery over `service data` with the `0xFDCD` 16 bits service UUID.  

Check out the [Qingping](qingping-ble-api.md) protocol page to get more information on advertisement data for this device.  

## Reference

[1] -  

## License

MIT
