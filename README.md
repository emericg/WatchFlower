# ![WatchFlower](assets/android/res/drawable-xhdpi/splashicon.png)

[![Travis](https://img.shields.io/travis/emericg/WatchFlower.svg?style=flat-square&logo=travis)](https://travis-ci.org/emericg/WatchFlower)
[![AppVeyor](https://img.shields.io/appveyor/ci/emericg/WatchFlower.svg?style=flat-square&logo=appveyor)](https://ci.appveyor.com/project/emericg/watchflower)
[![License: GPL v3](https://img.shields.io/badge/license-GPL%20v3-blue.svg?style=flat-square)](http://www.gnu.org/licenses/gpl-3.0)


WatchFlower is a plant monitoring application that reads and plots datas from your Xiaomi / MiJia "Flower Care", "Ropot" and "Bluetooth temperature and humidity sensor" devices.
It works with international and chinese devices, doesn't require an account creation, your GPS location, nor any other personnal datas from you.

It works on Linux, macOS, Windows, but also Android and iOS! Prebuilt binaries are available on the "release" page.

### Compatible devices

| MiJia "Flower Care" | Ropot | BLE Hygro & Temp |
| ------------------- | ----- | ---------------- |
| ![FlowerCare](assets/devices/flowercare.svg) | ![Ropot](assets/devices/ropot.svg) | ![HygroTemp](assets/devices/hygrotemp.svg) |

Many Bluetooth devices could be added to WatchFlower. If you have a device in mind, you can contact us and we'll see what can be done! 

### Desktop screenshots

![GUI_DESKTOP](https://i.imgur.com/SYuxbCa.png)

### Mobile screenshots

![GUI_MOBILE](https://i.imgur.com/nXotThA.png)


## Documentation

### Dependencies

You will need a C++11 compiler and Qt 5.9 (Qt 5.12+ is recommended however) with Qt Charts.

### Building WatchFlower

> $ git clone https://github.com/emericg/WatchFlower.git  
> $ cd WatchFlower/  
> $ qmake  
> $ make  


## Special thanks

* Christian Díaz <christiandiaz.design@gmail.com> for his extensive work on the application design and logo!
* Mickael Heudre <mickheudre@gmail.com> for his invaluable QML expertise!
* [MiFlora](https://github.com/open-homeautomation/miflora) GitHub repository, for the *Flower care* protocol reverse engineering.
* [This thread](https://github.com/sputnikdev/eclipse-smarthome-bluetooth-binding/issues/18), for the *bluetooth temperature and humidity sensor* protocol reverse engineering.
* Graphical resources details in [assets/COPYING](assets/COPYING)


## Get involved!

### Developers

You can browse the code on the GitHub page, submit patches and pull requests! Your help would be greatly appreciated ;-)

### Users

You can help us find and report bugs, propose new features, help with the documentation and more! Visit the Issues section of the GitHub page to start!


## License

WatchFlower is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.  
Read the [LICENSE](LICENSE) file or [consult the licence on the FSF website](https://www.gnu.org/licenses/gpl-3.0.txt) directly.

Emeric Grange <emeric.grange@gmail.com>
