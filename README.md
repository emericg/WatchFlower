WatchFlower
===========

[![Travis](https://img.shields.io/travis/emericg/WatchFlower.svg?style=flat-square)](https://travis-ci.org/emericg/WatchFlower)
[![AppVeyor](https://img.shields.io/appveyor/ci/emericg/WatchFlower.svg?style=flat-square)](https://ci.appveyor.com/project/emericg/watchflower)
[![License: GPL v3](https://img.shields.io/badge/license-GPL%20v3-blue.svg?style=flat-square)](http://www.gnu.org/licenses/gpl-3.0)


## Introduction

WatchFlower is an application that reads and plots datas from your Xiaomi "Flower Care", "Ropot" and "Bluetooth temperature and humidity sensor" devices.
It works with all versions of the devices, and doesn't require GPS or other any other private datas from you, unlike the official application...

It works on Linux, macOS, Windows, but also Android and iOS! Prebuilt binaries are available on the "release" page.

### Screenshots!

![GUI1](https://i.imgur.com/8pCBU8E.png)

![GUI2](https://i.imgur.com/kSpTzBd.png)


## Documentation

### Dependencies

You will need a C++11 capable compiler and Qt 5.7+ (versions 5.11+ are recommended however).
WatchFlower will take advantages of sqlite if it's available on your system.

### Building WatchFlower

> $ git clone https://github.com/emericg/WatchFlower.git  
> $ cd WatchFlower/  
> $ qmake  
> $ make  


## Licensing

WatchFlower is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.  
Read [LICENSE](LICENSE) or [consult the licence on the FSF website](http://www.gnu.org/licenses/gpl-3.0.txt) directly.

Emeric Grange <emeric.grange@gmail.com>


## Special thanks

* Mickael Heudre <mickheudre@gmail.com> for his invaluable QML expertise!
* [MiFlora](https://github.com/open-homeautomation/miflora) GitHub repository, for the *Flower care* protocol reverse engineering.
* [This thread](https://github.com/sputnikdev/eclipse-smarthome-bluetooth-binding/issues/18), for the *bluetooth temperature and humidity sensor* protocol reverse engineering.
* Graphical resources: read [assets/COPYING](assets/COPYING)

## Get involved!

### Developers

You can browse the code here on GitHub, submit patches and pull requests! Your help would be greatly appreciated ;-)

### Users

You can help us finding bugs, proposing new features and more! Visit the "Issues" section in the GitHub menu to start.
