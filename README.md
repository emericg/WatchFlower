# ![WatchFlower](assets/android/res/drawable-xhdpi/splashicon.png)

[![Travis](https://img.shields.io/travis/emericg/WatchFlower.svg?style=flat-square&logo=travis)](https://travis-ci.org/emericg/WatchFlower)
[![AppVeyor](https://img.shields.io/appveyor/ci/emericg/WatchFlower.svg?style=flat-square&logo=appveyor)](https://ci.appveyor.com/project/emericg/watchflower)
[![License: GPL v3](https://img.shields.io/badge/license-GPL%20v3-blue.svg?style=flat-square)](http://www.gnu.org/licenses/gpl-3.0)


WatchFlower is a plant monitoring application that reads and plots data from your Xiaomi MiJia "Flower Care" and "Ropot" sensors. WatchFlower also works great with a couple of Bluetooth thermometers!
It works with international and Chinese Xiaomi devices, doesn't require an account creation, your GPS location, nor any other personal data from you!

Works on Linux, macOS, Windows, but also Android and iOS! Desktop binaries are available on the "release" page, mobile applications are on the app stores.  
Virtually all phones have Bluetooth "Low Energy", but you will need to make sure your computer has BLE capabilities (and for Windows, a working driver too).  
Available in Danish, Dutch, English, French, German, Spanish and Russian!  

Application developed by [Emeric Grange](https://emeric.io/).
Visual design by [Chris Díaz](https://dribbble.com/chrisdiaz).

### Features

* Support plant sensors and thermometers
* Name your plants and set your own limits for optimal care
* Background updates & notifications (desktop only)
* Configurable update intervals
* Clickable two-week graphs
* Monthly/weekly/daily data histograms
* CSV data export
* Scalable UI: 4.6" to 34" screens, landscape or portrait

TODOs:

* Read offline sensors history
* Continuous measurements (BLE advertising support)
* Background updates & notifications (Android, maybe iOS)

### Supported devices

WatchFlower has been built to be easily extensible, and compatible with as many Bluetooth sensors as possible.  
Various Bluetooth devices and sensors can be added to WatchFlower. If you have one in mind, you can contact us and we'll see what can be done!

| Flower Care | RoPot | Parrot Flower Power | Parrot Pot | HiGrow |
| :---------: | :---: | :-----------------: | :--------: | :----: |
| ![FlowerCare](doc/flowercare.svg) | ![RoPot](doc/ropot.svg) | ![FlowerPower](doc/flowerpower.svg) | ![ParrotPot](doc/parrotpot.svg) | ![HiGrow](doc/higrow.svg) |
| HHCCJCY01<br>Xiaomi and VegTrug variants<br>(International and Chinese versions) | HHCCPOT002<br>Xiaomi and VegTrug variants |  | (monitoring only) | (with custom firmware) |
| [shop](https://www.banggood.com/custlink/DKKDVksMWv) | | | | [build](https://github.com/emericg/esp32-environmental-sensors/tree/master/HiGrow) |

| Xiaomi Digital Hygrometer (LCD) | ClearGrass Digital Hygrometer (EInk) | Xiaomi Smart Hygrometer Clock | Xiaomi Digital Hygrometer 2 (LCD) | MMC Digital Hygrometer 2 (EInk) |
| :-----------------------------: | :----------------------------------: | :---------------------------: | :------------------------: | :------------------------------------: |
| ![HygroTemp](doc/hygrotemp_lcd.svg) | ![HygroTemp](doc/hygrotemp_eink.svg) | ![HygroTempClock](doc/hygrotemp_clock.svg) | ![HygroTemp2](doc/hygrotemp_square_lcd.svg) | ![HygroTemp2](doc/hygrotemp_square_eink.svg) |
| LYWSDCGQ | CGG1 | LYWSD02<br>MHO-C303 | LYWSD03MMC | MHO-C401 |
| [shop](https://www.banggood.com/custlink/3KDK5qQqvj) | [shop](https://www.banggood.com/custlink/KvKGHkAMDT) | [shop](https://www.banggood.com/custlink/v3GmHzAQ9k) | [shop](https://www.banggood.com/custlink/vG33kIGiqv) / [shop](https://www.banggood.com/custlink/Kv3DuJio9Q) | [shop](https://www.banggood.com/custlink/GGGdWczfB6) |

### Screenshots

![GUI_MOBILE1](https://i.imgur.com/VdzHdqH.png)
![GUI_MOBILE2](https://i.imgur.com/e1bXFXM.png)

![GUI_MOBILE3](https://i.imgur.com/UiirNMw.png)

![GUI_DESKTOP1](https://i.imgur.com/1cAIta8.png)
![GUI_DESKTOP2](https://i.imgur.com/joJB4pB.png)


## Documentation

### Dependencies

You will need a C++11 compiler and Qt 5.12+ (with Qt Charts).  
For Android builds, the appropriates SDK and NDK.

### Building WatchFlower

> $ git clone https://github.com/emericg/WatchFlower.git  
> $ cd WatchFlower/  
> $ qmake  
> $ make  


## Special thanks

* Chris Díaz <christiandiaz.design@gmail.com> for his extensive work on the application design and logo!
* Mickael Heudre <mickheudre@gmail.com> for his invaluable QML expertise!
* Everyone who gave time to [help translate](i18n/README.md) this application!


## Get involved!

### Developers

You can browse the code on the GitHub page, submit patches and pull requests! Your help would be greatly appreciated ;-)

### Users

You can help us find and report bugs, suggest new features, help with translation, documentation and more! Visit the Issues section of the GitHub page to start!


## License

WatchFlower is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.  
Read the [LICENSE](LICENSE) file or [consult the license on the FSF website](https://www.gnu.org/licenses/gpl-3.0.txt) directly.

Emeric Grange <emeric.grange@gmail.com>

### Third party projects used by WatchFlower

* Qt [website](https://www.qt.io) ([LGPL 3](https://www.gnu.org/licenses/lgpl-3.0.txt))
* StatusBar [website](https://github.com/jpnurmi/statusbar) ([MIT](https://opensource.org/licenses/MIT))
* SingleApplication [website](https://github.com/itay-grudev/SingleApplication) ([MIT](https://opensource.org/licenses/MIT))
* Graphical resources: please read [assets/COPYING](assets/COPYING)
