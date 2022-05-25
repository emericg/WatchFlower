
<img src="hygrotemp_cgp1w.svg" width="400px" alt="Qingping Temp RH Barometer Pro S" align="right" />

## About CGP1W

* Qingping 'Temp & RH Barometer Pro S' [CGP1W](https://www.qingping.co/temp-rh-barometer/overview) are alarm clock with hygrometers and pressure sensor
* Has onboard clock and alarm
* Has sensors to relay temperature, humidity and air pressure
* Uses Bluetooth Low Energy (BLE) and has a limited range
* An internal 18650 battery is used as power source

## Features

* Read real-time sensor values
* Read historical sensor values
* Temperature temperature, humidity and air pressure sensors

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

The name advertised by the devices is `Qingping Temp RH Barometer`.  

TODO

## Historical data

TODO

## Advertisement data

##### UUID `0xFDCD` 21 bytes messages

CGP1W broadcast temperature, humidity, air pressure and battery over `service data` with the `0xFDCD` 16 bits service UUID.  

Check out the [Qingping](qingping-ble-api.md) protocol page to get more information on advertisement data for this device.  

## Reference

[1] -  

## License

MIT
