

# Plant sensors

| Flower Care                       | HHCCJCY01                         |
| ----------------------------------| ----------------------------------|
| Battery                           | 1 x AAA                           |
| Thermometer                       | -15 → 50 °C (± 0.5 °C)            |
| Soil moisture                     | 0 → 100%                          |
| Light sensor                      | 0 → 100k lux (± 100 lux)          |
| IP Code                           | IPX5                              |
| BLE API                           | [link](flowercare-ble-api.md)     |

| RoPot                             | HHCCPOT002                        |
| --------------------------------- | --------------------------------- |
| Battery                           | LiPo (embeded)                    |
| Thermometer                       | -15 → 50 °C (± 0.5 °C)            |
| Soil moisture                     | 0 → 100%                          |
| IP Code                           | IPX6                              |
| BLE API                           | [link](ropot-ble-api.md)          |

| Parrot Flower Power               | RKXHAWAII                         |
| --------------------------------- | --------------------------------- |
| Battery                           | 1 x AAA                           |
| Thermometer                       | -10 → 55 °C                       |
| Soil moisture                     | 0 → 50%                           |
| Light sensor                      | 0 → 1000 μmole.m-2.s-1            |
| IP Code                           | IPX5                              |
| BLE API                           | [link](flowerpower-ble-api.md)    |

| Parrot Pot                        | 2AG61POT                          |
| --------------------------------- | --------------------------------- |
| Battery                           | 4 x AA                            |
| Water tank                        | 2.2 l                             |
| Thermometer                       | -10 → 55 °C                       |
| Soil moisture                     | 0 → 50%                           |
| Light sensor                      | 0 → 1000 μmole.m-2.s-1            |
| IP Code                           | IPX5                              |
| BLE API                           | [link](parrotpot-ble-api.md)      |

| HiGrow                            | N/A                               |
| --------------------------------- | --------------------------------- |
| Battery                           | 1 x 18650 or 1 * LiPo             |
| Thermometer                       |                                   |
| Hygrometer                        |                                   |
| Soil moisture                     |                                   |
| Light sensor                      |                                   |
| BLE API                           | [link](higrow-ble-api.md)         |


# Thermometers

| Digital Hygrometer LCD            | LYWSDCGQ/01ZM                     |
| --------------------------------- | --------------------------------- |
| Screen                            | LCD                               |
| Battery                           | 1 x AAA                           |
| Thermometer                       | -9.9 ~ 60 °C                      |
| Hygrometer                        | 0 ~ 99.9% RH                      |

| Digital Hygrometer EInk           | LYWSD02                           |
| --------------------------------- | --------------------------------- |
| Screen                            | EInk                              |
| Battery                           | 1 x CR2430                        |
| Thermometer                       | 0 ~ 50 °C                         |
| Hygrometer                        | 0 ~ 99.9% RH                      |

| Digital Hygrometer Clock          | LYWSD02MMC                        |
| --------------------------------- | --------------------------------- |
| Screen                            | EInk                              |
| Battery                           | 2 x CR2032                        |
| Thermometer                       | 0 ~ 60 °C                         |
| Hygrometer                        | 0 ~ 99% RH                        |

| Digital Hygrometer 2 LCD          | LYWSD03MMC                        |
| --------------------------------- | --------------------------------- |
| Screen                            | LCD                               |
| Battery                           | 1 x CR2032                        |
| Thermometer                       | -9.9 ~ 60 °C (± 0.1 °C)           |
| Hygrometer                        | 0 ~ 99% RH (± 1% RH)              |

| Digital Hygrometer Alarm          | MHO-C303                          |
| --------------------------------- | --------------------------------- |
| Screen                            | EInk                              |
| Battery                           | 2 x AAA                           |
| Thermometer                       | 0 ~ 60 °C                         |
| Hygrometer                        | 0 ~ 99% RH                        |

| Digital Hygrometer 2 EInk         | MHO-C401                          |
| --------------------------------- | --------------------------------- |
| Screen                            | EInk                              |
| Battery                           | 1 x CR2032                        |
| Thermometer                       | 0 ~ 60 °C (± 0.3 °C)              |
| Hygrometer                        | 0 ~ 99% RH (± 3 %RH)              |

| Hygrometer                        | 2ACD3-WS08 and KEU-WA59D          |
| --------------------------------- | --------------------------------- |
| Screen                            | LCD                               |
| Battery                           | 1 x CR2477                        |
| Thermometer                       | -20 ~ 65 °C (± 0.5 °C)            |
| Hygrometer                        | 0 ~ 99% RH (± 5 %RH)              |
| BLE API                           | [link](thermobeacon-ble-api.md)   |

| Keychain Hygrometer               | 2ACD3-WS02 and 2ACD3-WS07         |
| --------------------------------- | --------------------------------- |
| Screen                            | N/A                               |
| Battery                           | 1 x CR2032 or CR2477              |
| Thermometer                       | -20 ~ 65 °C (± 0.5 °C)            |
| Hygrometer                        | 0 ~ 99% RH (± 5 %RH)              |
| BLE API                           | [link](thermobeacon-ble-api.md)   |


# Environmental sensors

* Generic implementation for Bluetooth Low Energy "[Environmental Sensing Service](ess-ble-api.md)"

* ESP32 based Geiger Counter & Air Quality Monitor. Check out the APIs documentations directly [on their repository](https://github.com/emericg/esp32-environmental-sensors).

* Make your [own sensor](howto-custom-sensor.md)!
