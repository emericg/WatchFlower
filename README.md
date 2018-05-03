WatchFlower
===========

[![Build Status](https://travis-ci.org/emericg/WatchFlower.svg?branch=master)](https://travis-ci.org/emericg/WatchFlower)
[![Build status](https://ci.appveyor.com/api/projects/status/fb5eelagau71jm6t?svg=true)](https://ci.appveyor.com/project/emericg/watchflower)
[![License: GPL v3](https://img.shields.io/badge/license-GPL%20v3-green.svg)](http://www.gnu.org/licenses/gpl-3.0)


## Introduction

WatchFlower is a small application to help you read and plot datas from your Xiaomi "Flower Care" devices.
It works with all versions of the device, and doesn't require GPS or other any other private datas from you.

It's still a bit early in development but it should work on all Qt platforms, meaning Linux, macOS, windows, but also android and iOS.


### Special thanks

* This repository for the inspiration and protocol RE https://github.com/open-homeautomation/miflora
* App icon is from Boston Icons theme (https://diazchris.deviantart.com/art/Boston-Icons-558741523)
* Other icons are from Faience and Adwaita icons themes (http://tiheum.deviantart.com/art/Faience-icon-theme-255099649 & https://github.com/GNOME/adwaita-icon-theme)


## Documentation

### Dependencies

You will need a C++11 capable compiler and Qt 5.7+ (version 5.10 is recommended).
WatchFlower will take advantages of sqlite if it's available on your system.


### Building WatchFlower

> $ cd WatchFlower/
> $ qmake
> $ make


## Get involved!

### Developers

You can browse the code here on GitHub, submit patches and pull requests! Your help would be greatly appreciated ;-)

### Users

You can help us finding bugs, proposing new features and more! Visit the "Issues" section in the GitHub menu to start.

## Licensing

WatchFlower is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
[Consult the licence on the FSF website](http://www.gnu.org/licenses/gpl-3.0.txt).

Emeric Grange <emeric.grange@gmail.com>
