# ![WatchFlower](assets/android/res/drawable-xhdpi/splashicon.png)

[![Travis](https://img.shields.io/travis/emericg/WatchFlower.svg?style=flat-square&logo=travis)](https://travis-ci.org/emericg/WatchFlower)
[![AppVeyor](https://img.shields.io/appveyor/ci/emericg/WatchFlower.svg?style=flat-square&logo=appveyor)](https://ci.appveyor.com/project/emericg/watchflower)
[![License: GPL v3](https://img.shields.io/badge/license-GPL%20v3-blue.svg?style=flat-square)](http://www.gnu.org/licenses/gpl-3.0)


WatchFlower is a plant monitoring application that reads and plots data from your Xiaomi MiJia "Flower Care" and "Ropot" sensors. WatchFlower also works great with a couple of Bluetooth thermometers!
It works with international and Chinese Xiaomi devices, doesn't require an account creation, your GPS location, nor any other personal data from you!

Works on Linux, macOS, Windows, but also Android and iOS! Desktop binaries are available on the "release" page, mobile applications are on the app stores.  
Virtually all phones have Bluetooth "Low Energy", but you will need to make sure your computer has BLE capabilities (and for Windows, a working driver too).  
Available in English, French and Spanish.  

Application developped by [Emeric Grange](https://emeric.io/).
Visual design by [Chris Díaz](https://dribbble.com/chrisdiaz).

### Features

* Support "plant sensors" and thermometers
* Clickable two-week graphs
* Monthly/weekly/daily data histograms
* Set your own limits for plants care
* Configurable update intervals
* Background updates & notifications (desktop only)
* Scalable UI: 4.6" to 34" screens, landscape or portrait

TODOs:

- Continuous measurements
- Read offline sensors history
- Android: background updates & notifications
- Add more compatible sensors!

### Supported devices

| Flower Care | Ropot | Hygro & Temp sensor | Digital Hygrometer Clock |
| ----------- | ----- | ------------------- | ------------------------ |
| ![FlowerCare](assets/devices/flowercare.svg) | ![Ropot](assets/devices/ropot.svg) | ![HygroTemp](assets/devices/hygrotemp.svg) | ![HygroTempClock](assets/devices/hygrotemp-clock.svg) |
| (International and Chinese versions) | | (MiJia LCD and ClearGrass EInk) | |
| [shop](https://www.banggood.com/custlink/DKKDVksMWv) | | [shop](https://www.banggood.com/custlink/3KDK5qQqvj) / [shop](https://www.banggood.com/custlink/KvKGHkAMDT) | [shop](https://www.banggood.com/custlink/v3GmHzAQ9k) |

Various Bluetooth devices and sensors can be added to WatchFlower. If you have one in mind, you can contact us and we'll see what can be done!

### Screenshots

![GUI_DESKTOP1](https://i.imgur.com/1cAIta8.png)
![GUI_DESKTOP2](https://i.imgur.com/joJB4pB.png)

![GUI_MOBILE1](https://i.imgur.com/VdzHdqH.png)
![GUI_MOBILE2](https://i.imgur.com/e1bXFXM.png)

![GUI_MOBILE3](https://i.imgur.com/UiirNMw.png)


## Documentation

### Dependencies

You will need a C++11 compiler and Qt 5.10 (Qt 5.12+ is recommended however) with Qt Charts.

### Building WatchFlower

> $ git clone https://github.com/emericg/WatchFlower.git  
> $ cd WatchFlower/  
> $ qmake  
> $ make  


## Special thanks

* Chris Díaz <christiandiaz.design@gmail.com> for his extensive work on the application design and logo!
* Mickael Heudre <mickheudre@gmail.com> for his invaluable QML expertise!
* [MiFlora](https://github.com/open-homeautomation/miflora) GitHub repository, for the *Flower care* protocol reverse engineering.
* [This thread](https://github.com/sputnikdev/eclipse-smarthome-bluetooth-binding/issues/18), for the *bluetooth temperature and humidity sensor* protocol reverse engineering.


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
* SingleApplication [website](https://github.com/itay-grudev/SingleApplication) ([MIT](https://opensource.org/licenses/MIT))
* StatusBar [website](https://github.com/jpnurmi/statusbar) ([MIT](https://opensource.org/licenses/MIT))
* Graphical resources: please read [assets/COPYING](assets/COPYING)
