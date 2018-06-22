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

#include "settingsmanager.h"
#include "devicemanager.h"

/* ************************************************************************** */

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setApplicationDisplayName("WatchFlower");
    QCoreApplication::setApplicationName("WatchFlower");

    QIcon appIcon(":/assets/app/watchflower.svg");
    app.setWindowIcon(appIcon);

    SettingsManager *sm = SettingsManager::getInstance();
    bool trayEnabled = sm->getSysTray();

    DeviceManager dm;

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
            QIcon trayIcon(":/assets/app/watchflower_tray.svg");
            sysTray->setIcon(trayIcon);
            sysTray->setContextMenu(sysTrayMenu);
            sysTray->show();
            //sysTray->showMessage("WatchFlower", QObject::tr("WatchFlower is running in the background!"));
        }
    }

    QQuickView *view = new QQuickView;
    view->rootContext()->setContextProperty("deviceManager", &dm);
    view->rootContext()->setContextProperty("settingsManager", sm);
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

    // Run a first scan, but only if we have no saved devices
    if (dm.areDevicesAvailable() == false)
    {
        dm.startDeviceDiscovery();
    }

    return app.exec();
}

/* ************************************************************************** */
// TODOs

/// 0.2
// graph auto min/max
// graph stacked bar + night bars (prettier?)

// about screen
// prefered graph screen
// blinking reset button

// firmware upgrade advice
// device offline text
// bluetooth not re-enabling itself

/// 0.3
// scan menu button:
// main: rescan / refresh values
// device: refresh values

/// NEXT
// android port
// macOS port
// disable graph & limits when no database available

/// NEXT
// plant db (???)
// handle multiple bluetooth adapters (???)

/* ************************************************************************** */
// PROTOCOL

// https://github.com/barnybug/miflora
// https://github.com/open-homeautomation/miflora
// https://github.com/sandeepmistry/node-flower-power

/*
1/ Connect to device MAC address (prefix should be C4:7C:8D:xx:xx:xx)
   (use QBluetoothUuid::GenericTelephony service)
2a/ Read _HANDLE_READ_NAME(0x03) if you care
2b/ Read _HANDLE_READ_VERSION_BATTERY(0x38)
    - byte 0: battery level percentage
    - bytes 2-5: firmware version (ASCII)
3/ If (firmware version >= 2.6.6) then write _DATA_MODE_CHANGE = bytes([0xA0, 0x1F]) to _HANDLE_WRITE_MODE_CHANGE(0x33)
4/ Read _HANDLE_READ_SENSOR_DATA(0x35)
   * the sensor should return 16 bytes (values are encoded in little endian):
   - bytes 0-1: temperature in 0.1°C
   - byte 2: unknown
   - bytes 3-4: brightness in lumens
   - bytes 5-6: unknown
   - byte 7: hygrometry
   - byte 8-9: conductivity in µS/cm
   - bytes 10-15: unknown
5/ Disconnect
*/

/*
// Connect using btgatt-client
$ btgatt-client -d C4:7C:8D:xx:xx:xx
> write-value 0x0033 0xA0 0x1F
> read-value 0x0035
*/

/*
// Connect using gattool (DEPRECATED)
$ gatttool -b C4:7C:8D:xx:xx:xx -I
> connect
> char-write-req 0x0033 A01F
> char-read-hnd 35
*/
