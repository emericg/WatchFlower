
<img src="bparasite.svg" width="400px" alt="b-parasite" align="right" />

## About b-parasite

* [b-parasite](https://github.com/rbaron/b-parasite) sensors are meant to keep your plants alive by monitoring their environment
* Has sensors to relay temperature, humidity, light intensity, soil moisture
* Uses Bluetooth Low Energy (BLE) and has a limited range
* A CR2032 coin cell battery is used as power source for Flower Care

## Features

* Read real-time sensor values
* Temperature
* Humidity
* Light intensity
* Soil moisture

## Protocol

The device uses BLE advertisement (only) for communication, depending on the firmware used.  

## Advertisement data

The name advertised by the device is `unknown`.  

b-parasite can broadcast advertisement data, depending on the firmware used.

Check out the [BtHome](bthome-ble-api.md) protocol page to get more information on advertisement data for this device.  

## Reference

[1] https://github.com/rbaron/b-parasite  
[2] https://github.com/rbaron/b-parasite/tree/main/code/nrf-connect/samples/ble  

## License

MIT
