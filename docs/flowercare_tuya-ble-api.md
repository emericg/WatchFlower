
<img src="flowercare.svg" width="400px" alt="Flower Care" align="right" />

## About Flower Care

* Tuya [Flower Care](http://www.huahuacaocao.com/product) sensors are meant to keep your plants alive by monitoring their environment
* Has sensors to relay temperature, light intensity, soil moisture and soil fertility (via electrical conductivity)
* Uses Bluetooth Low Energy (BLE) and has a limited range
* A CR2032 coin cell battery is used as power source for Flower Care

Tuya **Flower Care** (HHCCJCY10)  

If you have a `pink` Flower Care, it's a Flower Care variant from Tuya.  
Otherwise, please check the page of the "regular" [Flower Care](flowercare_tuya-ble-api.md)  

## Features

* Read real-time sensor values
* Read historical sensor values
* Temperature (-10 - 60 °C ± 0.5 °C)
* Light Monitor (0 - 100000 lux ± 100 lux)
* Soil moisture
* Soil fertility
* Notification LED
* IPX5

## Protocol

The device uses BLE GATT for communication, but the sensor values are not immediately available.  

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

The name advertised by the device is `TY` for HHCCJCY10.  

TODO

## Advertisement data

Tuya Flower Care broadcast `service data` with 16 bits service UUID `0xFD50`.  

##### UUID `0xFD50` 9 bytes messages


## Reference

[0]  

## License

MIT
