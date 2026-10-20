
## About Qingping advertisement

The Qingping data protocol is used by devices from Qingping (formerly Cleargrass) company to advertise data over Bluetooth Low Energy.  

<img src="endianness.png" width="400px" alt="Endianness" align="right" />

## Data structure

Bluetooth payload data typically uses little-endian byte order.  
This means that the data is represented with the least significant byte first.  

To understand multi-byte integer representation, you can read the [endianness](https://en.wikipedia.org/wiki/Endianness) Wikipedia page.

## Advertisement data

Qingping data protocol usually broadcast 14-21+ bytes `service data` messages, over `0xFDCD` 16 bits service UUID.  

Multiple measurement can be sent per advertisement message.  

#### Example data

| Device       | Position | 00 | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 
| ------------ | -------- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| CGP1W        | values > | 08 | 09 | XX | XX | 40 | 34 | 2d | 58 | 01 | 04 | 08 | 01 | 87 | 02 | 07 | 02 | 4f | 27 | 02 | 01 | 5c | -  | -  | -  |
| CGP1W        |          | 08 | 09 | XX | XX | 12 | 34 | 2d | 58 | 01 | 04 | 0b | 01 | ce | 00 | 07 | 02 | ea | 26 | 02 | 01 | 5a | -  | -  | -  |
| CGD1         |          | 08 | 0c | XX | XX | 50 | 34 | 2d | 58 | 01 | 04 | 0a | 01 | 7f | 02 | 02 | 01 | 2a | -  | -  | -  | -  | -  | -  | -  |
| CGDN1        |          | 08 | 0e | XX | XX | 55 | 34 | 2d | 58 | 01 | 04 | f9 | 00 | b5 | 01 | 12 | 04 | 7d | 01 | 86 | 01 | 13 | 02 | fd | 02 |
| CGDK2        |          | 08 | 10 | XX | XX | 11 | 34 | 2d | 58 | 01 | 04 | e9 | 00 | 1d | 02 | 02 | 01 | 0b | -  | -  | -  | -  | -  | -  | -  |
| CGDK2        |          | 08 | 10 | XX | XX | 12 | 34 | 2d | 58 | 01 | 04 | 31 | 01 | c9 | 01 | 02 | 01 | 51 | -  | -  | -  | -  | -  | -  | -  |
| CGG1         |          | 80 | 07 | XX | XX | 12 | 34 | 2d | 58 | 01 | 04 | 2b | 01 | 90 | 02 | 02 | 01 | 24 | -  | -  | -  | -  | -  | -  | -  |
| CGG1-M       |          | 88 | 16 | XX | XX | 12 | 34 | 2d | 58 | 01 | 04 | 1d | 01 | d5 | 01 | 02 | 01 | 55 | -  | -  | -  | -  | -  | -  | -  |
| CGH1         |          | 08 | 04 | XX | XX | 60 | 34 | 2d | 58 | 02 | 01 | 60 | 0f | 01 | 2b | 04 | 01 | 00 | -  | -  | -  | -  | -  | -  | -  |
| CGPR1        |          | 08 | 12 | XX | XX | 60 | 34 | 2d | 58 | 02 | 01 | 53 | 0f | 01 | 18 | 09 | 04 | 00 | 00 | 00 | 00 | -  | -  | -  | -  |
| CGPR1        |          | 08 | 12 | 00 | 5e | 60 | 34 | 2d | 58 | 02 | 01 | 62 | 0f | 01 | 0b | 08 | 04 | 01 | 83 | 08 | 00 | -  | -  | -  | -  |
| CGPR1        |          | 48 | 12 | 00 | 5e | 60 | 34 | 2d | 58 | 08 | 04 | 01 | 00 | 00 | 00 | 0f | 01 | f4 | -  | -  | -  | -  | -  | -  | -  |

#### Protocol

| Bytes | Type      | Value             | Description                                                  |
| ----- | --------- | ----------------- | ------------------------------------------------------------ |
| 00    | byte      | 0x08              | Frame control (see below)                                    |
| 01    | byte      | 0x10              | Product ID (see 'product IDs' table)                         |
| 02-07 | bytes     | 58:2D:34:12:XX:XX | MAC address (reversed)                                       |

Frame control:

| Bits  | Description                                                                                  |
| ----- | -------------------------------------------------------------------------------------------- |
| 0-4   | Header length (0x08: frame control, product ID and MAC address), 0 on early CGG1 firmwares   |
| 5     | ?                                                                                            |
| 6     | Event packet (sent on a state change, ex: motion detected)                                   |
| 7     | ? (set on CGG1 and CGG1-M)                                                                   |

Then each payload element use this format: (and can be chainloaded)

| Bytes | Type      | Description                                              |
| ----- | --------- | -------------------------------------------------------- |
| 08    | byte      | payload data type (see 'type of measurement' table)      |
| 09    | uint8     | payload data size (in bytes)                             |
| 10-0x | data      | payload data                                             |

Example with a CGP1W advertisement message:

| Bytes | Type      | Value               | Description                          |
| ----- | --------- | ------------------- | ------------------------------------ |
| 00    | byte      | 0x08                | Frame control                        |
| 01    | byte      | 0x09                | Product ID (CGP1W)                   |
| 02-07 | bytes     | 58:2D:34:40:XX:XX   | MAC address                          |
| 08    | byte      | 0x01                | (1) data is 'temperature + humidity' |
| 09    | uint8     | 0x04                | (1) 4 bytes of data                  |
| 10-11 | int16_le  | 0x0108 = 26.4°      | (1) temperature (2 bytes)            |
| 12-13 | uint16_le | 0x0287 = 64.7%      | (1) humidity (2 bytes)               |
| 14    | byte      | 0x07                | (2) data is 'air pressure'           |
| 15    | uint8     | 0x02                | (2) 2 bytes of data                  |
| 16-17 | uint16_le | 0x274f = 1006.3 hPa | (2) air pressure (2 bytes)           |
| 18    | byte      | 0x02                | (3) data is 'battery level'          |
| 19    | uint8     | 0x01                | (3) 1 byte of data                   |
| 20    | uint8     | 0x5c = 92%          | (3) battery level (1 byte)           |

#### Product IDs

| Device       | Product IDs              |
| ------------ | ------------------------ |
| CGG1         | 0x01 / 0x07              |
| CGG1-M       | 0x16                     |
| CGG3         | 0x4F                     |
| CGH1         | 0x04                     |
| CGP1W        | 0x09                     |
| CGD1         | 0x0C                     |
| CGDN1        | 0x0E / 0x24              |
| CGM1         | 0x0F                     |
| CGDK2        | 0x10                     |
| CGPR1        | 0x12                     |
| CGF1W        | 0x15                     |
| CGP23W       | 0x18 / 0x26              |
| CGC1         | 0x1E                     |
| CGP22C       | 0x33 / 0x5D              |

#### Type of measurement

```
0x01 = temperature + humidity
0x02 = battery level
0x04 = door state
0x07 = air pressure
0x08 = motion + illuminance
0x09 = illuminance
0x0F = packet ID
0x11 = light
0x12 = particulate matter (2.5 + 10 µm)
0x13 = CO2
0x18 = hardware capabilities
```

#### Payload format

###### Temperature and humidity

| name        | length    | description                                        |
| ------------| --------- | -------------------------------------------------- |
| temperature | int16_le  | Temperature in °C (signed value, divide by 10)     |
| humidity    | uint16_le | Humidity percentage (divide by 10), range is 0-100 |

###### Battery level

| name       | length     | description                                        |
| ---------- | ---------- | -------------------------------------------------- |
| battery    | uint8      | Battery level in %, range is 0-100                 |

###### Door state

| name       | length     | description                                        |
| ---------- | ---------- | -------------------------------------------------- |
| door       | uint8      | 0: open, 1: closed, 2: left open (timeout)         |

###### Air pressure

| name       | length     | description                                        |
| ---------- | ---------- | -------------------------------------------------- |
| pressure   | uint16_le  | Air pressure in 0.1 hPa, divide by 10 to get hPa   |

###### Motion and illuminance

| name        | length    | description                                        |
| ----------- | --------- | -------------------------------------------------- |
| motion      | uint8     | Motion detected (0: no, 1: yes)                    |
| illuminance | uint24_le | Illuminance in lux, not valid in event packets     |

###### Illuminance

| name        | length    | description                                        |
| ----------- | --------- | -------------------------------------------------- |
| illuminance | uint32_le | Illuminance in lux                                 |

###### Packet ID

| name       | length     | description                                        |
| ---------- | ---------- | -------------------------------------------------- |
| packet_id  | uint8      | Packet counter                                     |

###### Light

| name       | length     | description                                        |
| ---------- | ---------- | -------------------------------------------------- |
| light      | uint8      | Light detected (0: no, 1: yes)                     |

###### Particulate Matter

| name        | length    | description                                        |
| ------------| --------- | -------------------------------------------------- |
| PM 2.5      | uint16_le | PM 2.5 in µg/m³                                    |
| PM 10       | uint16_le | PM 10 in µg/m³                                     |

###### CO2

| name       | length     | description                                        |
| ---------- | ---------- | -------------------------------------------------- |
| CO2        | uint16_le  | CO2 in ppm                                         |

###### Hardware capabilities

| name         | length    | description                                                     |
| ------------ | --------- | --------------------------------------------------------------- |
| capabilities | uint16_le | Static bitmap (screen type, power source, Wi-Fi...), not a measurement |

## Reference

[1] https://github.com/Bluetooth-Devices/qingping-ble  
[2] https://github.com/custom-components/ble_monitor  
[3] https://github.com/pvvx/TLB2Z  

## License

MIT
