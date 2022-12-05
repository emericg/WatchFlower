
## About MiBeacon advertisement

The MiBeacon protocol is used by various Xiaomi devices (and various affiliated manufacturers) to advertise data over Bluetooth Low Energy.  

<img src="endianness.png" width="400px" alt="Endianness" align="right" />

## Data structure

Bluetooth payload data typically uses little-endian byte order.  
This means that the data is represented with the least significant byte first.  

To understand multi-byte integer representation, you can read the [endianness](https://en.wikipedia.org/wiki/Endianness) Wikipedia page.

## Advertisement data

MiBeacon protocol usually broadcast 12-20 bytes `service data` messages, over `0xFE95` 16 bits service UUID.  

There seems to be at least three (slightly) different versions of the protocol.  

Only one measurement is sent per advertisement message.  

#### Example data

| Device       | Position | 00 | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 | 12 | 13 | 14 | 15 | 16 |
| ------------ | -------- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| HHCCJCY01    | values > | 71 | 20 | 98 | 00 | 71 | XX | XX | 66 | 8d | 7c | c4 | 0d | 08 | 10 | 01 | 1f | -  |
| HHCCPOT002   |          | 71 | 20 | 5d | 01 | 83 | XX | XX | 6d | 8d | 7c | c4 | 0d | 08 | 10 | 01 | 03 | -  |
| HHCCPOT002   |          | 71 | 20 | 5d | 01 | 83 | XX | XX | 6d | 8d | 7c | c4 | 0d | 09 | 10 | 02 | 01 | 01 |
| LYWSD02      |          | 70 | 20 | 5b | 04 | fc | XX | XX | 83 | c8 | 59 | 3f | 09 | 04 | 10 | 02 | 19 | 01 |
| MHO-C303     |          | 70 | 20 | d3 | 06 | 20 | XX | XX | 11 | 45 | 76 | e7 | 09 | 0a | 10 | 01 | 00 | -  |

| Device       | Position | 00 | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 |
| ------------ | -------- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| JQJCY01YM    | values > | 51 | 20 | df | 02 | 3e | XX | XX | 01 | 43 | 57 | 48 | 04 | 10 | 02 | c4 | 00 | -  | -  |
| CGG1         |          | 50 | 30 | 47 | 03 | 41 | XX | XX | 10 | 34 | 2d | 58 | 04 | 10 | 02 | 12 | 01 | -  | -  |
| CGG1         |          | 50 | 30 | 47 | 03 | 83 | XX | XX | 10 | 34 | 2d | 58 | 0d | 10 | 04 | 10 | 01 | 7e | 02 |
| LYWSDCGQ     |          | 50 | 20 | aa | 01 | 37 | XX | XX | 33 | 34 | 2d | 58 | 0d | 10 | 04 | 04 | 01 | 66 | 02 |
| LYWSDCGQ     |          | 50 | 20 | aa | 01 | ca | XX | XX | d0 | a8 | 65 | 4c | 0d | 10 | 04 | 18 | 01 | 24 | 02 |

| Device       | Position | 00 | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 | 12 | 13 |
| ------------ | -------- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| HHCCJCY01    | values > | 31 | 02 | 98 | 00 | A0 | XX | XX | 62 | 8d | 7c | c4 | 0d | -  | -  |
| CGG1-M       |          | 30 | 58 | 48 | 0b | 01 | XX | XX | 12 | 34 | 2d | 58 | 28 | 01 | 00 |
| CGDK2        |          | 30 | 58 | 6f | 06 | 02 | XX | XX | 12 | 34 | 2d | 58 | 08 | -  | -  |

#### Frame control (first 2 bytes)

| bits   | Type      | Description                          |
| ------ | --------- | ------------------------------------ |
| 0x8000 | flag      |                                      |
| 0x4000 | flag      | data is present flag                 |
| 0x2000 | flag      | capability byte present flag         |
| 0x1000 | flag      |                                      |
| 0x0800 | flag      | encrypted data flag                  |


#### Protocol (version 0x70?)

| Bytes | Type      | Value             | Description                          |
| ----- | --------- | ----------------- | ------------------------------------ |
| 00-01 | bytes     | 0x7120            | Frame control                        |
| 02-03 | bytes     | 0x9800            | Product ID                           |
| 04    | uint8     |                   | Frame count                          |
| 05-10 | bytes     | C4:7C:8D:66:XX:XX | MAC address                          |
| 11    | byte      |                   | capability byte?                     |
| 12-13 | bytes     |                   | Type of measurement                  |
| 14+   | data      |                   | Payload                              |

#### Protocol (version 0x50?)

| Bytes | Type      | Value             | Description                          |
| ----- | --------- | ----------------- | ------------------------------------ |
| 00-01 | bytes     | 0x5120            | Frame control                        |
| 02-03 | bytes     | 0x4703            | Product ID                           |
| 04    | uint8     |                   | Frame count                          |
| 05-10 | bytes     | 58:2D:34:10:XX:XX | MAC address                          |
| 11-12 | bytes     |                   | Type of measurement                  |
| 13+   | data      |                   | Payload                              |

#### Protocol (version 0x30?)

| Bytes | Type      | Value             | Description                          |
| ----- | --------- | ----------------- | ------------------------------------ |
| 00-01 | bytes     | 0x3102            | Frame control                        |
| 02-03 | bytes     | 0x9800            | Product ID                           |
| 04    | uint8     |                   | Frame count                          |
| 05-10 | bytes     | 58:2D:34:10:XX:XX | MAC address                          |
| 11+   | bytes     |                   | Usually no payload                   |

#### Product IDs

| Device       | Product ID   |
| ------------ | ------------ |
| HHCCJCY01    | 0x9800       |
| HHCCJCY09    | 0xBC03       |
| HHCCPOT002   | 0x5D01       |
| -            |              |
| LYWSDCGQ     | 0xAA01       |
| CGG1         | 0x4703       |
| CGG1-M       | 0x480B       |
| LYWSD02      | 0x5B04       |
| CGDK2        | 0x6F06       |
| MHO-C303     | 0xD306       |
| -            |              |
| JQJCY01YM    | 0xDF02       |
| -            |              |
| YLKG01YL     | 0x0315       |
| YLKG07YL     | 0xB603       |
| YLAI003      | 0xBF07       |

#### Type of measurement

```
0x0210 = sleep state
0x0310 = RSSI
0x0410 = temperature
0x0610 = humidity
0x0710 = luminosity
0x0810 = soil moisture
0x0910 = soil conductivity
0x0a10 = battery level
0x0d10 = temperature + humidity
0x0e10 = lock state
0x0f10 = door state
0x1010 = formaldehyde (hcho)
0x1110 = bind state
0x1210 = switch state
0x1310 = consumables remaining
0x1410 = water immersion state
0x1510 = smoke state
0x1610 = gas state
```

#### Payload format

###### Sleep state

| name     | length   | description                                            |
| -------- | -------- | ------------------------------------------------------ |
| state    | 1 byte   | no sleep (0x00), asleep (0x01)                         |

###### RSSI

| name     | length   | description                                            |
| -------- | -------- | ------------------------------------------------------ |
| RSSI     | 1 byte   | Signal strength in dB                                  |

###### Temperature

| name        | length    | description                                        |
| ----------- | --------- | -------------------------------------------------- |
| temperature | int16_le  | Temperature in °C (signed value, divide by 10)     |

###### Humidity

| name       | length     | description                                        |
| ---------- | ---------- | -------------------------------------------------- |
| humidity   | uint16_le  | Humidity percentage (divide by 10), range is 0-100 |

###### Temperature and humidity

| name        | length    | description                                        |
| ------------| --------- | -------------------------------------------------- |
| temperature | int16_le  | Temperature in °C (signed value, divide by 10)     |
| humidity    | uint16_le | Humidity percentage (divide by 10), range is 0-100 |

###### Luminosity

| name       | length     | description                                        |
| ---------- | ---------- | -------------------------------------------------- |
| luminosity | uint24_le  | Luminosity in lux, range is 0-120000               |

###### Soil moisture

| name           | length    | description                                     |
| -------------- | --------- | ----------------------------------------------- |
| soil moisture  | uint8     | Soil moisture in %, range is 0-100              |

###### Soil electrical conducivity

| name       | length     | description                                        |
| ---------- | ---------- | -------------------------------------------------- |
| soil EC    | uint16_le  | Soil EC in µs/cm, range is 0-5000                  |

###### Battery level

| name       | length     | description                                        |
| ---------- | ---------- | -------------------------------------------------- |
| battery    | uint8      | Battery level in %, range is 0-100                 |

###### Lock state

| name     | length   | description                                            |
| -------- | -------- | ------------------------------------------------------ |
| state    | 1 byte   | Bitfield                                               |

Bitfield:

    bit 0: Square tongue state (1: popped; 0: retracted)
    bit 1: dumb state (1: eject; 0: retract)
    bit 2: Diagonal status (1: ejected; 0: retracted)
    bit 3: Child lock status (1: on; 0: off)

All normal combined states:

    0x00: unlocked state (all latches retracted)
    0x04: The lock tongue pops out (the oblique tongue pops out)
    0x05: Locking + tongue popping out (square tongue, oblique tongue popping out)
    0x06: Anti-lock + lock tongue pops out (lazy tongue, oblique tongue pops out)
    0x07: All lock tongues pop up (square tongue, flat tongue, oblique tongue pops up)

###### Door state

| name     | length   | description                                            |
| -------- | -------- | ------------------------------------------------------ |
| state    | 1 byte   | Open door (0x00), close door (0x01), exception (0xFF)  |

###### Formaldehyde (HCHO)

| name     | length     | description                                          |
| -------- | ---------- | ---------------------------------------------------- |
| HCHO     | uint16_le  | Formaldehyde in mg/m3 (divide by 100)                |

###### Bind state

| name     | length   | description                                            |
| -------- | -------- | ------------------------------------------------------ |
| state    | 1 byte   | Unbound (0x00), Bound (0x01)                           |

###### Switch state

| name     | length   | description                                            |
| -------- | -------- | ------------------------------------------------------ |
| state    | 1 byte   | Off (0x00), On (0x01)                                  |

###### Consumables remaining

| name      | length   | description                                           |
| --------- | -------- | ----------------------------------------------------- |
| remaining | 1 byte   | Consumables remaining in %, range is 0-100            |

###### Water immersion

| name     | length   | description                                            |
| -------- | -------- | ------------------------------------------------------ |
| state    | 1 byte   | Submerged (0x01), Not submerged (0x00)                 |

###### Smoke state

| name     | length   | description                                            |
| -------- | -------- | ------------------------------------------------------ |
| state    | 1 byte   | Normal (0x00), Fire alarm (0x01), Equipment failure (0x02) |

###### Gas state

| name     | length   | description                                            |
| -------- | -------- | ------------------------------------------------------ |
| state    | 1 byte   | There is a leak (0x01), no leak (0x00)                 |

## Reference

[1] https://iot.mi.com/new/doc/embedded-development/ble/object-definition  
[2] https://home-is-where-you-hang-your-hack.github.io/ble_monitor/MiBeacon_protocol  

## License

MIT
