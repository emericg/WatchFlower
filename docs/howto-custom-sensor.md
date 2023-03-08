How to add a new sensor to WatchFlower
--------------------------------------


# Hardware

## DIY electronics

You can build your electronics using every kind of chip you want, as long as you have Bluetooth Low Energy support.

## Bluetooth Low Energy API

You are free to build your own API, using BLE GATT and/or BLE advertisement.  
You can also use an existing API to speed up implementation in WatchFlower.  
For instance, implementations exists for GATT [Environmental Sensing Service](ess-ble-api.md),
[MiBeacon](mibeacon-ble-api.md) advertisement, [Qingping](qingping-ble-api.md) advertisement,
and [BtHome](bthome-ble-api.md) advertisement (v1 and v2).  


# Software

## Adding support in WatchFlower

### New class

Create a new device class, for instance **DeviceNew** and put its implementation in the `src/devices/` folder.  
The class should inherit from either _DevicePlantSensor_, _DeviceThermometer_ or _DeviceEnvironmental_ class.  

### Name, type, and capabilities

There are two constructors for each device, one for device added from Bluetooth scan, then one for device saved in database.

```cpp
m_deviceType = DeviceUtils::DEVICE_THERMOMETER;
m_deviceBluetoothMode = DeviceUtils::DEVICE_BLE_ADVERTISEMENT;
m_deviceSensors += DeviceUtils::SENSOR_TEMPERATURE;
m_deviceSensors += DeviceUtils::SENSOR_HUMIDITY;
```

This is where we can specify some of the most important parameter a device can have,
like it's **type** (that will decide many things about how it is handled by the appliation and its UI)
it's **Bluetooth mode** (using GATT, advertisement, or both) and its set of **supported sensors**.  
Sensors can be set in the constructors, but can also be dynamically detected, if needed.
For instance depending on hardware variant or firmware version, some data can be available, or not.  

### Implementation

If _DeviceUtils::DEVICE_BLE_CONNECTION_ has been set, you must implement the various necessary bits.

`serviceScanDone()`  
`addLowEnergyService(const QBluetoothUuid &)`  
`serviceDetailsDiscovered_data(QLowEnergyService::ServiceState)`  

If _DeviceUtils::DEVICE_BLE_ADVERTISEMENT_ has been set 
The `parseAdvertisementData()` function must be implemented in order to handle advertisement.  

### Integration

Add your new device files to the build system, for instance _device_new.cpp_ and _device_new.h_ in `WatchFlower.pro` and `CMakeList.txt`.

Include _device_new.h_ at the top of the `DeviceManager.cpp` file.  
Add your device in the _load saved devices_ loop in the constructor.  
Add your device in the _addBleDevice()_ function.  

You can add your device firmware version in the `device_firmwares.h` file.
It will require additional logic to work with the app, in order to display the "device up to date" badge.

You can add your device to the `DeviceFilter.cpp` file, in order to have your sensor
order correctly (and grouped, if there is more than one sensor) in the app device list.
