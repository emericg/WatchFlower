
<img src="cgdn1.svg" width="400px" alt="Air Detector Lite" align="right" />

## About CGDN1

* Qingping 'Air Monitor Lite' [CGDN1](https://www.qingping.co/air-monitor-lite/overview)
* Has sensors to relay temperature, humidity, CO2 and PM 2.5/10
* Uses Bluetooth Low Energy (BLE) and has a limited range
* A 18650 battery is used as internal power source

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

The name advertised by the devices is `Qingping Air Monitor Lite`.  

TODO

## Historical data

TODO

## Advertisement data

CGDN1 broadcast sensor values over `service data` with the `0xFDCD` 16 bits service UUID.  

Check out the [Qingping](qingping-ble-api.md) protocol page to get more information on advertisement data for this device.  

## Reference

[1] -

## License

MIT
