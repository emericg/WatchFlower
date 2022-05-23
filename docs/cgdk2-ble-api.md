
<img src="hygrotemp_cgdk2.svg" width="400px" alt="Temp and RH Monitor Lite" align="right" />

## About CGDK2

* Qingping 'Temp & RH Monitor Lite' [CGDK2](https://www.qingping.co/temp-rh-monitor-lite/overview) are hygrometers
* Has sensors to relay temperature and humidity
* Uses Bluetooth Low Energy (BLE) and has a limited range
* A CR2430 coin cell battery is used as power source

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

The name advertised by the devices is `Qingping Temp RH Lite`.  

##### Generic access (UUID 00001800-0000-1000-8000-00805f9b34fb)

##### Generic attribute (UUID 00001801-0000-1000-8000-00805f9b34fb)

##### Device information (UUID 0000180a-0000-1000-8000-00805f9b34fb)

##### Data service (UUID 22210000-554a-4546-5542-46534450464d)

| Characteristic UUID                  | Handle | Access      | Description                     |
| ------------------------------------ | ------ | ----------- | ------------------------------- |
| 00000100-0000-1000-8000-00805f9b34fb | -      | notify      | real time data                  |

#### Communication with the device

Register to get notification on the 'real time data' characteristic.  
The device will send back 7 bytes data packets:  

| Bytes | Type      | Value             | Description                          |
| ----- | --------- | ----------------- | ------------------------------------ |
| 00-01 | bytes     |                   | ?                                    |
| 02    | byte      | 236               | battery voltage?                     |
| 03-04 | int16_le  | 198 / 10 = 19.8   | temperature in °C                    |
| 05-06 | int16_le  | 578 / 10 = 57.8   | humidity in % RH                     |

## Historical data

TODO

## Advertisement data

There seems to be two kind of advertisement data broadcasted.  
CGDK2 broadcast `service data` with 16 bits service UUID `0xFE95` and `0xFDCD`.  

##### UUID `0xFE95` 12 bytes messages

The CGDK2 has 'fixed content' MiBeacon data. No actionable data. Encrypted?  

Check out the [MiBeacon](mibeacon-ble-api.md) protocol page to get more information on advertisement data for this device.  

##### UUID `0xFDCD` 17 bytes messages

CGDK2 broadcast temperature, humidity, and battery over `service data` with the `0xFDCD` 16 bits service UUID.  

Check out the [Qingping](qingping-ble-api.md) protocol page to get more information on advertisement data for this device.  

## Reference

[1] -  

## License

MIT
