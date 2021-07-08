# ![WatchFlower](assets/android/res/drawable-xhdpi/splashicon.png)

[![GitHub release](https://img.shields.io/github/release/emericg/WatchFlower.svg?style=flat-square)](https://github.com/emericg/WatchFlower/releases)
[![GitHub action](https://img.shields.io/github/workflow/status/emericg/WatchFlower/CI%20builds.svg?style=flat-square)](https://github.com/emericg/WatchFlower/actions)
[![GitHub issues](https://img.shields.io/github/issues/emericg/WatchFlower.svg?style=flat-square)](https://github.com/emericg/WatchFlower/issues)
[![GitHub contributors](https://img.shields.io/github/contributors/emericg/WatchFlower.svg?style=flat-square)](https://github.com/emericg/WatchFlower/graphs/contributors)
[![License: GPL v3](https://img.shields.io/badge/license-GPL%20v3-brightgreen.svg?style=flat-square)](http://www.gnu.org/licenses/gpl-3.0)

WatchFlower is a **plant monitoring application** that reads and plots data from compatible Bluetooth sensors like Xiaomi MiJia "Flower Care" and "RoPot" or Parrot "Flower Power" and "Parrot Pot", as well as many Bluetooth thermometers!
It works with international and Chinese Xiaomi devices, doesn't require an account creation, your GPS location, nor any other personal data from you!

Works on Linux, macOS, Windows, but also Android and iOS! Desktop binaries are available on the "release" page, mobile applications are on the app stores.  
Virtually all phones and laptops have Bluetooth "Low Energy", but you will need to make sure your desktop computer has a Bluetooth card or dongle (and for Windows, a working driver too).  

> Available in Chinese (traditional and simplified), Danish, Dutch, English, French, Frisian, German, Norwegian (Bokmål and Nynorsk), Russian and Spanish!

> Application developed by [Emeric Grange](https://emeric.io/). Visual design by [Chris Díaz](https://dribbble.com/chrisdiaz).

### Features

* Support many plant sensors and thermometers
* Name your plants and set your own limits for optimal care
* Background updates & notifications (desktop ONLY for now)
* Synchronize sensors history (FlowerCare ONLY for now)
* Configurable update intervals
* Clickable two-week graphs
* Monthly/weekly/daily data histograms
* 90 days CSV data export
* Scalable UI: 4.6" to 34" screens, landscape or portrait

### TODOs

* Background updates & notifications for Android and iOS


![GUI_MOBILE1](https://i.imgur.com/VdzHdqH.png)


## Supported devices

WatchFlower has been built to be compatible with as many Bluetooth sensors as possible.  
Various new Bluetooth devices and sensors can be added to WatchFlower. If you have one in mind, you can contact us and we'll see what can be done!  

Checkout out this [page](docs/README.md) to get more informations about the devices currently support, and get a peek at their Bluetooth APIs.  
You can also create your own sensors and use them with WatchFlower! Checkout this [guide](docs/howtwo-custom-sensor.md) to learn more about the process.  

Please note that most Chinese devices have many names, usually no official manufacturer, sometimes a couple of variants potentially sold as the same base model. We do our best to identify them as clearly as we can. You can use the affiliate links below to be sure of what you are buying.

| Flower Care | RoPot | Flower Power | Parrot Pot | HiGrow |
| :---------: | :---: | :----------: | :--------: | :----: |
| ![FlowerCare](docs/flowercare.svg) | ![RoPot](docs/ropot.svg) | ![FlowerPower](docs/flowerpower.svg) | ![ParrotPot](docs/parrotpot.svg) | ![HiGrow](docs/higrow.svg) |
| HHCCJCY01<br>GCLS002 | HHCCPOT002 | RKXHAWAII | 2AG61POT | |
| Xiaomi / VegTrug / WANFEI<br>(International and Chinese versions) | Xiaomi and VegTrug variants | | (monitoring only) | (with custom firmware) |
| [shop](https://www.banggood.com/custlink/DKKDVksMWv) | | | | [firmware](https://github.com/emericg/esp32-environmental-sensors/tree/master/HiGrow) |

| Xiaomi Digital Hygrometer (LCD) | ClearGrass Digital Hygrometer (EInk) | QingPing Temp RH Lite (LCD) |
| :-----------------------------: | :----------------------------------: | :-------------------------: |
| ![HygroTemp](docs/hygrotemp_lcd.svg) | ![HygroTemp](docs/hygrotemp_cgg1.svg) | ![HygroTemp](docs/hygrotemp_cgdk2.svg) |
| LYWSDCGQ | CGG1 | CGDK2 |
| [shop](https://www.banggood.com/custlink/3KDK5qQqvj) | [shop](https://www.banggood.com/custlink/KvKGHkAMDT) | |

| Xiaomi Smart Hygrometer Clock | Xiaomi Digital Hygrometer 2 (LCD) | Miaomiaoce Digital Hygrometer 2 (EInk) |
| :---------------------------: | :-------------------------------: | :------------------------------------: |
| ![HygroTempClock](docs/hygrotemp_clock.svg) | ![HygroTemp2](docs/hygrotemp_square_lcd.svg) | ![HygroTemp2](docs/hygrotemp_square_eink.svg) |
| LYWSD02<br>MHO-C303 | LYWSD03MMC | MHO-C401 |
| [shop](https://www.banggood.com/custlink/v3GmHzAQ9k) / [shop](https://www.banggood.com/custlink/3DvyFIBoC7) | [shop](https://www.banggood.com/custlink/vG33kIGiqv) / [shop](https://www.banggood.com/custlink/Kv3DuJio9Q) | [shop](https://www.banggood.com/custlink/GGGdWczfB6) |

| ThermoBeacon (keychain) | ThermoBeacon (LCD) |
| :---------------------: | :----------------: |
| ![ThermoBeacon](docs/thermobeacon_round.svg) | ![ThermoBeacon](docs/thermobeacon_square.svg) |
| 2ACD3-WS02<br>2ACD3-WS07 | 2ACD3-WS08<br>KEU-WA59D |
| | [shop](https://www.banggood.com/custlink/DKKYiqcRij) |

| Air Box WP6003 |
| :------------: |
| ![WP6003](docs/wp6003.svg) |
| |
| [shop](https://www.banggood.com/custlink/mK3yOI9teA) |

| ESP32 Air Quality Monitor | ESP32 Weather Station | ESP32 Geiger Counter |
| :-----------------------: | :-------------------: | :------------------: |
| ![Air Monitor](docs/lungs-solid.svg) | ![Weather Station](docs/cloud-sun-solid.svg) | ![Geiger Counter](docs/radiation-alt-solid.svg) |
| [build](https://github.com/emericg/esp32-environmental-sensors/tree/master/AirQualityMonitor) | [build](https://github.com/emericg/esp32-environmental-sensors/tree/master/WeatherStation) | [build](https://github.com/emericg/esp32-environmental-sensors/tree/master/GeigerCounter) |


## Screenshots

![GUI_MOBILE2](https://i.imgur.com/e1bXFXM.png)
![GUI_MOBILE3](https://i.imgur.com/UiirNMw.png)
![GUI_DESKTOP1](https://i.imgur.com/1cAIta8.png)
![GUI_DESKTOP2](https://i.imgur.com/joJB4pB.png)


## Documentation

#### Dependencies

You will need a C++11 compiler and Qt 5.12+ (with Qt Charts). Qt 6+ won't be supported for a while.  
For Android builds, you'll need the appropriates SDK and NDK (21+).

#### Building WatchFlower

```bash
$ git clone https://github.com/emericg/WatchFlower.git
$ cd WatchFlower/
$ qmake
$ make
```

#### Using FlowerCare 'live mode' and 'historical data'

##### macOS and iOS

Due to a (bad) combination of factors, these platform need a patched version of Qt in order to work with FlowerCare live mode and history data.  
The apps published on the app stores are using such patched version, but if you are building it yourself you can get these patches [here](https://github.com/emericg/qtconnectivity).
Without it, these two features will just be disabled.

##### Linux

While reading FlowerCare historical entry count, the sensors usually freeze for up to a second, and the Linux kernel consider that to be a connection timeout.  
To be able to get the historical data working on Linux, you'll need to increase the "supervision timeout" value (while root):

```bash
# echo 100 > /sys/kernel/debug/bluetooth/hci0/supervision_timeout
```

You could also give WatchFlower binary the net_raw and net_admin capabilities, so that it could be allowed to changes the supervision timeout on its own. But at the moment that's not fully implemented.

```bash
# setcap 'cap_net_raw,cap_net_admin+eip' watchflower
```


## Special thanks

* Chris Díaz <christiandiaz.design@gmail.com> for his extensive work on the application design and logo!
* Mickael Heudre <mickheudre@gmail.com> for his invaluable QML expertise!
* Everyone who gave time to [help translate](i18n/README.md#special-thanks) this application!

#### Third party projects used by WatchFlower

* [Qt](https://www.qt.io) ([LGPL 3](https://www.gnu.org/licenses/lgpl-3.0.txt))
* [StatusBar](https://github.com/jpnurmi/statusbar) ([MIT](https://opensource.org/licenses/MIT))
* [SingleApplication](https://github.com/itay-grudev/SingleApplication) ([MIT](https://opensource.org/licenses/MIT))
* Graphical resources: [assets/COPYING](assets/COPYING)


## Get involved!

#### Developers

You can browse the code on the GitHub page, submit patches and pull requests! Your help would be greatly appreciated ;-)

#### Users

You can help us find and report bugs, suggest new features, help with translation, documentation and more! Visit the Issues section of the GitHub page to start!


## License

WatchFlower is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.  
Read the [LICENSE](LICENSE) file or [consult the license on the FSF website](https://www.gnu.org/licenses/gpl-3.0.txt) directly.

> Emeric Grange <emeric.grange@gmail.com>
