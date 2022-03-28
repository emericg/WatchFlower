
<img src="hygrotemp_lywsdcgq.svg" width="400px" alt="Bluetooth Hygrometer" align="right" />

## About LYWSDCGQ

* Xiaomi MiJia 'Bluetooth Hygrometer' [LYWSDCGQ]() are hygrometers
* Has sensors to relay temperature and humidity
* Uses Bluetooth Low Energy (BLE) and has a limited range
* 1 * AA battery is used as power source

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

## Services, characteristics and handles

The name advertised by the devices is `MJ_HT_V1`.

TODO

## Historical data

TODO

## Advertisement data

TODO

## Reference

[1] https://github.com/sputnikdev/eclipse-smarthome-bluetooth-binding/issues/18  

## License

MIT
