# ![WatchFlower](assets/android/res/drawable-xhdpi/splashicon.png)

[![GitHub release](https://img.shields.io/github/release/emericg/WatchFlower.svg?style=flat-square)](https://github.com/emericg/WatchFlower/releases)
[![GitHub action](https://img.shields.io/github/actions/workflow/status/emericg/WatchFlower/builds_desktop.yml?style=flat-square)](https://github.com/emericg/WatchFlower/actions)
[![GitHub issues](https://img.shields.io/github/issues/emericg/WatchFlower.svg?style=flat-square)](https://github.com/emericg/WatchFlower/issues)
[![GitHub contributors](https://img.shields.io/github/contributors/emericg/WatchFlower.svg?style=flat-square)](https://github.com/emericg/WatchFlower/graphs/contributors)
[![License: GPL v3](https://img.shields.io/badge/license-GPL%20v3-brightgreen.svg?style=flat-square)](http://www.gnu.org/licenses/gpl-3.0)

WatchFlower is a **plant monitoring application** that reads and plots data from compatible Bluetooth sensors like Xiaomi "Flower Care" and "RoPot" or Parrot "Flower Power" and "Parrot Pot", as well as many Bluetooth thermometers!
It works with international and Chinese Xiaomi devices, doesn't require an account creation, your GPS location, nor any other personal data from you!

Works on Linux, macOS, Windows, but also Android and iOS! Desktop binaries are available on the "release" page, mobile applications are on the app stores.  
Virtually all phones and laptops have Bluetooth "Low Energy", but you will need to make sure your desktop computer has a Bluetooth card or dongle (and for Windows, a working driver too).  

> Available in Chinese (traditional and simplified), Danish, Dutch, English, French, Frisian, German, Norwegian (Bokmål and Nynorsk), Russian and Spanish!

> Application developed by [Emeric Grange](https://emeric.io/). Visual design by [Chris Díaz](https://dribbble.com/chrisdiaz).

### Features

* Support many different plant sensors and thermometers
* Support a couple of environmental and air quality sensors
* Plant database with over 3400 plants
* Name your plants and set your own limits for optimal care
* Background updates and notifications (excluding iOS)
* Synchronize sensors history (FlowerCare, RoPot and ThermoBeacon ONLY for now)
* Configurable update intervals
* Clickable two-week graphs
* Monthly/weekly/daily data histograms
* 90 days CSV data export
* Scalable UI: 4.6" to 34" screens, landscape or portrait


![GUI_MOBILE1](https://i.imgur.com/VdzHdqH.png)


## Supported devices

WatchFlower has been built to be compatible with as many Bluetooth sensors as possible.  
Various new Bluetooth devices and sensors can be added to WatchFlower. If you have one in mind, you can contact us and we'll see what can be done!  

Checkout out the [device page](docs/README.md) to get more informations about the devices currently support, and get a peek at their Bluetooth APIs.  
You can also create your own sensors and use them with WatchFlower! Checkout this [guide](docs/howto-custom-sensor.md) to learn more about the process.  

> WatchFlower is NOT associated with Xiaomi, Parrot, or any device manufacturer.

Please note that most Chinese devices have many names, usually no official manufacturer, sometimes a couple of variants potentially sold as the same base model. We do our best to identify them as clearly as we can. You can use the affiliate links below to be sure of what you are buying.

| Flower Care |  Flower Care Max | RoPot | Flower Power | Parrot Pot | HiGrow |
| :---------: | :--------------: | :---: | :----------: | :--------: | :----: |
| ![FlowerCare](docs/flowercare.svg) | ![FlowerCare Max](docs/flowercaremax.svg) | ![RoPot](docs/ropot.svg) | ![FlowerPower](docs/flowerpower.svg) | ![ParrotPot](docs/parrotpot.svg) | ![HiGrow](docs/higrow.svg) |
| HHCCJCY01 | HHCCJCY09 <br> GCLS002 | HHCCPOT002 | RKXHAWAII | 2AG61POT | |
| Xiaomi / VegTrug / ...<br>(International and Chinese versions) | Xiaomi and VegTrug variants | Xiaomi and VegTrug variants | | (monitoring only) | (with custom firmware) |
| [shop](https://www.banggood.com/custlink/DKKDVksMWv) | | | | | [firmware](https://github.com/emericg/esp32-environmental-sensors/tree/master/HiGrow) |

| Xiaomi MiJia Bluetooth Hygrometer (LCD) | ClearGrass Temp & RH Monitor (EInk) | Qingping Temp & RH Monitor Lite (LCD) |
| :-----------------------------: | :----------------------------------: | :-------------------------: |
| ![LYWSDCGQ](docs/hygrotemp_lywsdcgq.svg) | ![CGG1](docs/hygrotemp_cgg1.svg) | ![CGDK2](docs/hygrotemp_cgdk2.svg) |
| LYWSDCGQ | CGG1 | CGDK2 |
| [shop](https://www.banggood.com/custlink/3KDK5qQqvj) | [shop](https://www.banggood.com/custlink/KvKGHkAMDT) | |

| Miaomiaoce Thermo-Hygrometer 2 (LCD) | Miaomiaoce Thermo-Hygrometer 2 (EInk) | Miaomiaoce Thermo-Hygrometer (EInk) |
| :----------------------------------: | :---------------------------------: | :---------------------------------: |
| ![LYWSD03MMC](docs/hygrotemp_lywsd03mmc.svg) | ![MHO-C401](docs/hygrotemp_mhoc401.svg) | ![XMWSDJO4MMC](docs/hygrotemp_xmwsdjo4mmc.svg) |
| LYWSD03MMC | MHO-C401 | XMWSDJO4MMC |
| [shop](https://www.banggood.com/custlink/vG33kIGiqv) / [shop](https://www.banggood.com/custlink/Kv3DuJio9Q) | [shop](https://www.banggood.com/custlink/GGGdWczfB6) | [shop](https://www.banggood.com/custlink/3DmR2A33n6) |

| Miaomiaoce Digital Hygrometer Clock (EInk) | Miaomiaoce Digital Hygrometer Alarm (EInk) | Qingping Bluetooth Alarm Clock (LCD) | Qingping Temp & RH Barometer Pro S (LCD) |
| :----------------------------------------: | :----------------------------------------: | :----------------------------------: | :--------------------------------------: |
| ![HygroTempClock](docs/hygrotemp_clock.svg) | ![HygroTempAlarm](docs/hygrotemp_alarm.svg) | ![CGD1](docs/hygrotemp_cgd1.svg) | ![CGP1W](docs/hygrotemp_cgp1w.svg) |
| LYWSD02 | MHO-C303 | CGD1 | CGP1W |
| [shop](https://www.banggood.com/custlink/v3GmHzAQ9k) | [shop](https://www.banggood.com/custlink/3DvyFIBoC7) | | | |

| ThermoBeacon (round keychain) | ThermoBeacon (diamond keychain) | ThermoBeacon (LCD) |
| :---------------------------: | :-----------------------------: | :----------------: |
| ![ThermoBeacon](docs/thermobeacon_round.svg) | ![ThermoBeacon](docs/thermobeacon_diamond.svg) | ![ThermoBeacon](docs/thermobeacon_square.svg) |
| 2ACD3-WS02<br>2ACD3-WS07 |  2ACD3-WS02 | 2ACD3-WS08<br>KEU-WA59D |
| | | [shop](https://www.banggood.com/custlink/DKKYiqcRij) |

| Air Box WP6003 | Honeywell HCHO detector | Qingping Air Monitor Lite |
| :------------: | :---------------------: | :-----------------------: |
| ![WP6003](docs/wp6003.svg) | ![JQJCY01YM](docs/jqjcy01ym.svg) | ![CGDN1](docs/cgdn1.svg) |
| | JQJCY01YM | CGDN1 |
| [shop](https://www.banggood.com/custlink/mK3yOI9teA) | |

| ESP32 Air Quality Monitor | ESP32 Weather Station | ESP32 Geiger Counter |
| :-----------------------: | :-------------------: | :------------------: |
| ![Air Monitor](docs/lungs-solid.svg) | ![Weather Station](docs/cloud-sun-solid.svg) | ![Geiger Counter](docs/radiation-alt-solid.svg) |
| [build](https://github.com/emericg/esp32-environmental-sensors/tree/master/AirQualityMonitor) | [build](https://github.com/emericg/esp32-environmental-sensors/tree/master/WeatherStation) | [build](https://github.com/emericg/esp32-environmental-sensors/tree/master/GeigerCounter) |


## Screenshots

![GUI_MOBILE2](https://i.imgur.com/e1bXFXM.png)
![GUI_MOBILE3](https://i.imgur.com/UiirNMw.png)
![GUI_DESKTOP1](https://i.imgur.com/1F666UF.png)
![GUI_DESKTOP2](https://i.imgur.com/XBoM36H.png)


## Documentation

#### Dependencies

You will need a C++17 compiler and Qt 6.3+ with the following 'additional librairies':  
- Qt 5 Compatibility Module
- Qt Connectivity
- Qt Charts

For Android builds, you'll need the appropriates JDK (11) SDK (23+) and NDK (23+). You can customize Android build environment using the `assets/android/gradle.properties` file.  
For Windows builds, you'll need the MSVC 2019+ compiler. Bluetooth won't work with MinGW.  
For macOS and iOS builds, you'll need Xcode 12+ installed.  

#### Building WatchFlower

```bash
$ git clone https://github.com/emericg/WatchFlower.git
$ cd WatchFlower/
$ qmake6
$ make
```

#### Using WatchFlower

##### Android

The Android operating system requires applications to ask for device location permission in order to scan for nearby Bluetooth Low Energy sensors. Android 10+ will ask for _ACCESS_FINE_LOCATION_, while Android 6+ will only ask for _ACCESS_COARSE_LOCATION_.  
This is a mandatory requirement. The application is neither using nor storing your location. Sorry for the inconvenience.  

You can learn more on Android developer [website](https://developer.android.com/guide/topics/connectivity/bluetooth/permissions#declare-android11-or-lower).  

Some devices also require the GPS to be turned on while scanning for new sensors. This requirement is not documented and there is not much that can be done about it.  

##### Android background updates and notifications

Using the 'background updates' feature requires the _ACCESS_BACKGROUND_LOCATION_ additional permission, for the same reasons just mentioned above. Note that you can actually deny that permission, but then the background updates will be **much** less efficient.  

It's also very important to note that Android phones will try very hard to both prevent the app from starting in the background, then kill every application running in the background, making it hard for this feature to work properly.  
Depending on your phone model and manufacturer, you **will** have to manually **enable** `auto launch` and manually **disable** various `battery saving` features.  

> Fortunately, there is a very good website with per device steps to help you do that: https://dontkillmyapp.com/

##### iOS

The application will ask you for permission to use Bluetooth. You can learn more on Apple [website](https://support.apple.com/HT210578).

##### macOS

Starting with macOS 11, the application will ask you for permission to use Bluetooth. You can learn more on Apple [developer website](https://developer.apple.com/documentation/bundleresources/information_property_list/nsbluetoothalwaysusagedescription).

##### Linux ('live mode' and 'historical data')

While reading Flower Care and RoPot historical entry count, the sensors usually freeze for up to a second, and the Linux kernel consider that to be a connection timeout.  
To be able to get the historical data working on Linux, you'll need to increase the "supervision timeout" value (while root):

```bash
# echo 100 > /sys/kernel/debug/bluetooth/hci0/supervision_timeout
```

You could also give WatchFlower binary the _net_raw_ and _net_admin_ capabilities, so that it could be allowed to changes the supervision timeout on its own. But at the moment that's not fully implemented.

```bash
# setcap 'cap_net_raw,cap_net_admin+eip' watchflower
```


## Special thanks

* Chris Díaz <christiandiaz.design@gmail.com> for his extensive work on the application design and logo!
* Mickael Heudre <mickheudre@gmail.com> for his invaluable QML expertise!
* Everyone who gave time to [help translate](i18n/README.md#special-thanks) this application!

#### Third party projects used by WatchFlower

* [Qt6](https://www.qt.io) ([LGPL v3](https://www.gnu.org/licenses/lgpl-3.0.txt))
* [MobileUI](src/thirdparty/MobileUI/README.md) ([MIT](https://opensource.org/licenses/MIT))
* [MobileSharing](src/thirdparty/MobileSharing/README.md) ([MIT](https://opensource.org/licenses/MIT))
* [SingleApplication](https://github.com/itay-grudev/SingleApplication) ([MIT](https://opensource.org/licenses/MIT))
* RC4 code from Christophe Devine ([GPL v2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.txt))
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
