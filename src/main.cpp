/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2018 Emeric Grange - All Rights Reserved
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * \date      2018
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include <QGuiApplication>
#include <QApplication>
#include <QQmlContext>
#include <QQuickView>

#include <QSystemTrayIcon>
#include <QMenu>

#include "devicemanager.h"

/* ************************************************************************** */

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QIcon appIcon(":/assets/app/icon.svg");
    app.setWindowIcon(appIcon);

    bool trayEnabled = false;

    QSystemTrayIcon *sysTray = nullptr;
    QMenu *sysTrayMenu = nullptr;
    QAction *actionShow = nullptr;
    QAction *actionSettings = nullptr;
    QAction *actionExit = nullptr;
    if (trayEnabled)
    {
        sysTrayMenu = new QMenu();
        if (sysTrayMenu)
        {
            actionShow = new QAction(QObject::tr("Show"));
            actionSettings = new QAction(QObject::tr("Settings"));
            actionExit = new QAction(QObject::tr("Exit"));
            sysTrayMenu->addAction(actionShow);
            sysTrayMenu->addAction(actionSettings);
            sysTrayMenu->addAction(actionExit);
        }

        sysTray = new QSystemTrayIcon(&app);
        if (sysTray)
        {
            QIcon trayIcon(":/assets/app/icon_tray.svg");
            sysTray->setIcon(trayIcon);
            sysTray->setContextMenu(sysTrayMenu);
            sysTray->show();
            //sysTray->showMessage("WatchFlower", QObject::tr("WatchFlower is running in the background!"));
        }
    }

    DeviceManager d;
    QQuickView *view = new QQuickView;
    view->rootContext()->setContextProperty("deviceManager", &d);
    view->setSource(QUrl("qrc:/qml/main.qml"));
    view->setResizeMode(QQuickView::SizeRootObjectToView);
    view->show();

    if (trayEnabled && sysTray && sysTrayMenu)
    {
        QObject::connect(sysTray, &QSystemTrayIcon::activated, view, &QQuickView::show);
        QObject::connect(actionShow, &QAction::triggered, view, &QQuickView::show);
        //QObject::connect(actSettings, &QAction::triggered, &app, &SystemTray::signalQuit);
        QObject::connect(actionExit, &QAction::triggered, &app, &QApplication::exit);
    }

    // Run a first scan, only if we have no saved devices
    if (d.areDevicesAvailable() == false)
    {
        d.startDeviceDiscovery();
    }

    return app.exec();
}

/* ************************************************************************** */

// TODOs

// limits editor
// settings panel
// handle nights
// graph auto min/max
// graph query limits (no +7d, no +24h)

// plant db ???

/* ************************************************************************** */

// https://github.com/barnybug/miflora
// https://github.com/open-homeautomation/miflora
// https://github.com/sandeepmistry/node-flower-power

/*
_HANDLE_READ_VERSION_BATTERY = 0x38
_HANDLE_READ_NAME = 0x03
_HANDLE_READ_SENSOR_DATA = 0x35
_HANDLE_WRITE_MODE_CHANGE = 0x33
_DATA_MODE_CHANGE = bytes([0xA0, 0x1F])

1/ connect to mac address
    use QBluetoothUuid::GenericTelephony service
2/ read _HANDLE_READ_VERSION_BATTERY(0x38)
    byte 0: battery
    bytes 2-5: firmware version
3/ if (version >= 2.6) write _DATA_MODE_CHANGE = bytes([0xA0, 0x1F]) to _HANDLE_WRITE_MODE_CHANGE(0x33)
4/ then read _HANDLE_READ_SENSOR_DATA(0x35)
   *The sensor returns 16 bytes (in little endian encoding):
   -bytes 0-1: temperature in 0.1 °C
   -byte 2: unknown
   -bytes 3-4: brightness in Lux
   -bytes 5-6: unknown
   -byte 7: conductivity in µS/cm
   -byte 8-9: brightness in Lux
   -bytes 10-15: unknown
5/ disconnect
*/

/*
$ gatttool -b C4:7C:8D:65:EB:86 -I
$ connect
$ char-write-req 0x0033 A01F
$ char-read-hnd 35
*/

/*
$ btgatt-client -d C4:7C:8D:65:EB:86
$ write-value 0x0033 0xA0 0x1F
$ read-value 0x0035
*/
