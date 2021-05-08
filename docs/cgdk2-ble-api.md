
<img src="hygrotemp_cgdk2.svg" width="400px" alt="Digital Hygrometer" align="right" />

## About CGDK2

* QinPing 'Temp RH Lite' [CGDK2]() are hygrometers
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

| Bytes | Type      | Value                 | Description           |
| ----- | --------- | --------------------- | --------------------- |
| 00-01 | bytes     |                       | unknown?              |
| 02    | byte      | 236                   | battery voltage?      |
| 03-04 | Int16     | 198 / 10 = 19.8       | temperature °C        |
| 05-06 | Int16     | 578 / 10 = 57.8       | humidity %RH          |

## Historical data

TODO

## Advertisement data

TODO

## Reference

[1] -

## License

MIT
