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

#include <QApplication>
#include <QGuiApplication>
#include <QSystemTrayIcon>
#include <QMenu>

#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>

#include <singleapplication.h>

#include "settingsmanager.h"
#include "systraymanager.h"
#include "devicemanager.h"

/* ************************************************************************** */

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    QApplication app(argc, argv);
#else
    SingleApplication app(argc, argv);
    app.setApplicationName("WatchFlower");
    app.setApplicationDisplayName("WatchFlower");

    QIcon appIcon(":/assets/desktop/watchflower.svg");
    app.setWindowIcon(appIcon);
#endif

    SettingsManager *sm = SettingsManager::getInstance();

    SystrayManager *st = SystrayManager::getInstance();

    DeviceManager *dm = new DeviceManager;

    // Run a first scan, but only if we have no saved devices
    if (dm->areDevicesAvailable() == false)
    {
        dm->startDeviceDiscovery();
    }

    QQmlApplicationEngine engine;
    QQmlContext *engine_context = engine.rootContext();
    engine_context->setContextProperty("deviceManager", dm);
    engine_context->setContextProperty("settingsManager", sm);
    engine_context->setContextProperty("systrayManager", st);
    engine.load(QUrl(QStringLiteral("qrc:/qml/MainScreen.qml")));
    if (engine.rootObjects().isEmpty())
        return EXIT_FAILURE;

    QQuickWindow *window = qobject_cast<QQuickWindow *>(engine.rootObjects().value(0));

    if (st && sm && sm->getSysTray())
    {
        st->initSystray(&app, window);
        st->installSystray();
    }

#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS)
    QObject::connect(&app, &SingleApplication::instanceStarted, window, &QQuickWindow::show);
    QObject::connect(&app, &SingleApplication::instanceStarted, window, &QQuickWindow::raise);
#endif
#if defined(Q_OS_MACOS)
    QObject::connect(&app, &SingleApplication::dockClicked, window, &QQuickWindow::show);
    QObject::connect(&app, &SingleApplication::dockClicked, window, &QQuickWindow::raise);
#endif

    return app.exec();
}

/* ************************************************************************** */
// TODOs

/// 0.5
// save states
// save geometry
// monthly graphs
// always load <12h old datas at loading

// BLE device update timeout
// bluetooth not re-enabling itself

/// NEXT
// better mobile UI: sidemenu, notifs, ...
// background daemon for mobile?
// iOS port

/// NEXT next
// plants img
// plants db (???)
// handle multiple bluetooth adapters (???)

/* ************************************************************************** */
// PROTOCOL // Flower care

// https://github.com/barnybug/miflora
// https://github.com/open-homeautomation/miflora
// https://github.com/sandeepmistry/node-flower-power

/*
1/ Connect to device MAC address (prefix should be C4:7C:8D:xx:xx:xx)
2/ Use QBluetoothUuid::GenericTelephony service
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
5/ Disconnect (or let the device disconnect you after a couple of seconds)
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

/* ************************************************************************** */
// PROTOCOL // Bluetooth temperature and humidity sensor

// https://github.com/sputnikdev/eclipse-smarthome-bluetooth-binding/issues/18

/*
// Connect using btgatt-client
btgatt-client -d 4C:65:A8:D0:6D:C8
register-notify 0x000e // temp and humidity
read-value 0x0018 // battery
*/
