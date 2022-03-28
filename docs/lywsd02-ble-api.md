
<img src="hygrotemp_clock.svg" width="400px" alt="Digital Hygrometer Clock" align="right" />

## About LYWSD02

* Miaomiaoce (MMC) 'Digital Hygrometer Clock' [LYWSD02]() are clocks with hygrometers
* Has onboard clock
* Has sensors to relay temperature and humidity
* Uses Bluetooth Low Energy (BLE) and has a limited range
* 2 * CR2032 coin cell batteries are used as power source

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

## Services, characteristics and handles

The name advertised by the devices is `LYWSD02`.

TODO

## Historical data

TODO

## Advertisement data

TODO

## Reference

[1] TODO

## License

MIT
