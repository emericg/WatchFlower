
## About MiBeacon advertisement

The MiBeacon protocol is used by various Xiaomi devices (and various affiliated manufacturers) to advertise data over Bluetooth Low Energy.  

<img src="endianness.png" width="400px" alt="Endianness" align="right" />

## Data structure

Bluetooth payload data typically uses little-endian byte order.  
This means that the data is represented with the least significant byte first.  

To understand multi-byte integer representation, you can read the [endianness](https://en.wikipedia.org/wiki/Endianness) Wikipedia page.

## Advertisement data

MiBeacon protocol usually broadcast 12-20 bytes `service data` messages, over `0xFE95` 16 bits service UUID.  

Only one measurement is sent per advertisement message. Allegedly it supports multiple measurement per message, but it remains to be confirmed.  

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

#### Protocol

| Bytes | Type      | Value             | Description                          |
| ----- | --------- | ----------------- | ------------------------------------ |
| 00-01 | uint16_le | 0x2051            | Frame control                        |
| 02-03 | uint16_le | 0x0098            | Product ID                           |
| 04    | uint8     |                   | Frame count                          |
| 05-10 | bytes     | C4:7C:8D:66:XX:XX | MAC address (if MAC is set)          |
| 11    | uint8     |                   | Capability (if Capability is set)    |
| 12-13 | uint16_le |                   | I/O (if I/O from Capability is set)  |
| 14-15 | uint16_le | 0x1004            | Type of measurement                  |
| 16+   | bytes     |                   | Payload                              |

#### Frame control field

| Bit     | Name               | Description                                                    |
| ------- | ------------------ | -------------------------------------------------------------- |
| 0       | Reserved           | ?                                                              |
| 1       | Reserved           | ?                                                              |
| 2       | Reserved           | ?                                                              |
| 3       | Encrypted          | 0: Data is not encrypted; 1: Data is encrypted                 |
| 4       | MAC Include        | 0: Does not include the MAC address; 1: Includes a fixed MAC address (the MAC address is included for iOS to recognize this device and connect) |
| 5       | Capability Include | 0: Does not include Capability byte; 1: Includes Capability byte. Before the device is bound, this bit is forced to 1 |
| 6       | Object Include     | 0: Does not contain Object; 1: Contains Object(s)              |
| 7       | Mesh               | 0: Does not include Mesh; 1: includes Mesh. For standard BLE access products and high security level access, this item is mandatory to 0. This item is mandatory for Mesh access to 1. For more information about Mesh access, please refer to Mesh related documents |
| 8       | Registered         | 0: The device is not bound; 1: The device is registered and bound. This item is used to indicate whether the device is reset |
| 9       | Solicited          | 0: No operation; 1: Request APP to register and bind. It is only valid when the user confirms the pairing by selecting the device on the developer platform, otherwise set to 0. The original name of this item was bindingCfm, and it was renamed to solicited "actively request, solicit" APP for registration and binding |
| 10 ~ 11 | Auth Mode          | 0: Old version certification; 1: Safety certification; 2: Standard certification; 3: Reserved |
| 12 ~ 15 | version            | Version number                                                 |

#### Product IDs

| Device       | Product ID   |
| ------------ | ------------ |
| HHCCJCY01    | 0x0098       |
| HHCCJCY09    | 0x03BC       |
| HHCCPOT002   | 0x015D       |
| -            |              |
| LYWSDCGQ     | 0x01AA       |
| CGG1         | 0x0347       |
| CGG1-M       | 0x0B48       |
| LYWSD02      | 0x045B       |
| LYWSD02MMC   | 0x16E4/0x2542|
| LYWSD03MMC   | 0x055B       |
| CGDK2        | 0x066F       |
| MHO-C303     | 0x06D3       |
| -            |              |
| JQJCY01YM    | 0x02DF       |

#### Capability field

| Bit   | Name        | Description                                                |
| ----- | ----------- | ---------------------------------------------------------- |
| 0     | Connectable | ?                                                          |
| 1     | Centralized | ?                                                          |
| 2     | Encryptable | ?                                                          |
| 3 ~ 4 | BondAbility | 0: No binding, 1: Front binding, 2: Back binding, 3: Combo |
| 5     | I/O         | 1: Contains the I/O Capability field                       |
| 6 ~ 7 | Reserved    |                                                            |

#### IO Capability field

| Bit  | Type   | Description                      |
| ---- | ------ | -------------------------------- |
| 0    | Input  | The device can enter 6 digits    |
| 1    | Input  | The device can enter 6 letters   |
| 2    | Input  | Device can read NFC tag          |
| 3    | Input  | The device can recognize QR Code |
| 4    | Output | The device can output 6 digits   |
| 5    | Output | The device can output 6 letters  |
| 6    | Output | Device can generate NFC tag      |
| 7    | Output | The device can generate QR Code  |
| 8-15 |        | Reserved                         |

#### Payload format

###### BLE Object format

| Field           | Length | Description         |
| --------------- | ------ | ------------------- |
| Object ID       | 2      | Type of measurement |
| Object Data Len | 1      | Data length         |
| Object Data     | N      | Data                |

###### BLE Object data

| Object ID | Property              | Data type | Factor | Example | Result | Unit  |
| --------- | --------------------- | --------- | ------ | ------- | ------ | ----- |
| 0x0410    | temperature           | int16_le  | 0.1    |         |        | °C    |
| 0x0610    | humidity              | uint16_le | 0.1    |         |        | % RH  |
| 0x0710    | luminosity            | uint24_le | 1      |         |        | lux   |
| 0x0810    | soil moisture         | uint8     | 1      |         |        | %     |
| 0x0910    | soil conductivity     | uint16_le | 1      |         |        | µS/cm |
| 0x0a10    | battery level         | uint8     | 1      |         |        | %     |
| 0x0d10    | temperature + humidity| int16_le + uint16_le | 0.1 + 0.1 | | | °C + % RH |
| 0x1010    | formaldehyde (hcho)   | uint16_le | 0.1    |         |        | µg/m³ |

| Object ID | Property          | Data type | Description                                                |
| --------- | ----------------- | --------- | ---------------------------------------------------------- |
| 0x0210    | sleep state       | uint8     | No sleep (0x00), Asleep (0x01)                             |
| 0x0310    | RSSI              | uint8     | Signal strength (in dB)                                    |
| 0x0e10    | lock state        | uint8     | Lock state (bitfield)                                      |
| 0x0f10    | door state        | uint8     | Open door (0x00), Close door (0x01), Exception (0xFF)      |
| 0x1110    | bind state        | uint8     | Unbound (0x00), Bound (0x01)                               |
| 0x1210    | switch state      | uint8     | Off (0x00), On (0x01)                                      |
| 0x1310    | consumables remaining | uint8 | Consumables remaining in %, range is 0-100                 |
| 0x1410    | water immersion state | uint8 | Submerged (0x01), Not submerged (0x00)                     |
| 0x1510    | smoke state       | uint8     | Normal (0x00), Fire alarm (0x01), Equipment failure (0x02) |
| 0x1610    | gas state         | uint8     | Leak (0x01), No leak (0x00)                                |

## Other

###### Product IDs

```
0x0C3C = CGC1
0x0576 = CGD1
0x066F = CGDK2
0x0347 = CGG1
0x0B48 = CGG1-ENCRYPTED
0x03D6 = CGH1
0x0A83 = CGPR1
0x03BC = GCLS002
0x0098 = HHCCJCY01
0x015D = HHCCPOT002
0x02DF = JQJCY01YM
0x0997 = JTYJGD03MI
0x1568 = K9B-1BTN
0x1569 = K9B-2BTN
0x0DFD = K9B-3BTN
0x1C10 = K9BB-1BTN
0x1889 = MS1BB(MI)
0x2AEB = HS1BB(MI)
0x01AA = LYWSDCGQ
0x045B = LYWSD02
0x16e4 = LYWSD02MMC
0x2542 = LYWSD02MMC
0x055B = LYWSD03MMC
0x098B = MCCGQ02HL
0x06d3 = MHO-C303
0x0387 = MHO-C401
0x07F6 = MJYD02YL
0x04E9 = MJZNMSQ01YD
0x2832 = MJWSD05MMC
0x00DB = MMC-T201-1
0x0391 = MMC-W505
0x03DD = MUE4094RT
0x0489 = M1S-T500
0x0A8D = RTCGQ02LM
0x0863 = SJWS01LM
0x045C = V-SK152
0x040A = WX08ZM
0x04E1 = XMMF01JQD
0x1203 = XMWSDJ04MMC
0x1949 = XMWXKG01YL
0x2387 = XMWXKG01LM
0x098C = XMZNMST02YD
0x0784 = XMZNMS04LM
0x0E39 = XMZNMS08LM
0x07BF = YLAI003
0x0153 = YLYK01YL
0x068E = YLYK01YL-FANCL
0x04E6 = YLYK01YL-VENFAN
0x03BF = YLYB01YL-BHFRC
0x03B6 = YLKG07YL/YLKG08YL
0x0083 = YM-K1501
0x0113 = YM-K1501EU
0x069E = ZNMS16LM
0x069F = ZNMS17LM
0x0380 = DSL-C08
0x0DE7 = SU001-T
0x20DB = MJZNZ018H
0x18E3 = ZX1
```

###### Type of measurement

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

## Reference

[1] https://iot.mi.com/new/doc/embedded-development/ble/object-definition  
[2] https://home-is-where-you-hang-your-hack.github.io/ble_monitor/MiBeacon_protocol  
[3] https://github.com/pvvx/ATC_MiThermometer/blob/master/InfoMijiaBLE/Mijia%20BLE%20MiBeacon%20protocol%20v5.md  
[4] https://github.com/pvvx/ATC_MiThermometer/blob/master/InfoMijiaBLE/Mijia%20BLE%20Object%20Definition.md  

## License

MIT
