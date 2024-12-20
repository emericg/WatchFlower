/*!
 * This file is part of WatchFlower.
 * Copyright (c) 2022 Emeric Grange - All Rights Reserved
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

#include "DatabaseManager.h"
#include "SettingsManager.h"
#include "SystrayManager.h"
#include "MenubarManager.h"
#include "NotificationManager.h"
#include "DeviceManager.h"
#include "PlantDatabase.h"
#include "PlantUtils.h"
#include "Journal.h"

#include "utils_app.h"
#include "utils_screen.h"
#include "utils_language.h"
#if defined(Q_OS_MACOS)
#include "utils_os_macos_dock.h"
#endif

#include <MobileUI>
#include <MobileSharing>
#include <SingleApplication>
#include <SunAndMoon>

#include <QtGlobal>
#include <QLibraryInfo>
#include <QVersionNumber>

#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QSurfaceFormat>

#if defined(Q_OS_ANDROID)
#include "AndroidService.h"
#include "private/qandroidextras_p.h" // for QAndroidService
#endif

/* ************************************************************************** */

int main(int argc, char *argv[])
{
    // Arguments parsing ///////////////////////////////////////////////////////

    bool start_minimized = false;
    bool refresh_only = false;
    bool background_service = false;
    for (int i = 1; i < argc; i++)
    {
        if (argv[i])
        {
            //qDebug() << "> arg >" << argv[i];

            if (QString::fromLocal8Bit(argv[i]) == "--start-minimized")
                start_minimized = true;
            if (QString::fromLocal8Bit(argv[i]) == "--service")
                background_service = true;
            if (QString::fromLocal8Bit(argv[i]) == "--refresh")
                refresh_only = true;
        }
    }

    // Background service application //////////////////////////////////////////

    // Refresh data in the background, without starting the UI, then exit
    if (refresh_only)
    {
        QCoreApplication app(argc, argv);
        app.setApplicationName("WatchFlower");
        app.setOrganizationName("WatchFlower");
        app.setOrganizationDomain("WatchFlower");

        SettingsManager *sm = SettingsManager::getInstance();
        DatabaseManager *db = DatabaseManager::getInstance();
        NotificationManager *nm = NotificationManager::getInstance();
        DeviceManager *dm = new DeviceManager();
        if (!sm || !db || !nm || !dm) return EXIT_FAILURE;

        if (dm->areDevicesAvailable())
        {
            dm->refreshDevices_listen();
        }

        return app.exec();
    }

    // Android daemon
    if (background_service)
    {
#if defined(Q_OS_ANDROID)
        QAndroidService app(argc, argv);
        app.setApplicationName("WatchFlower");
        app.setOrganizationName("WatchFlower");
        app.setOrganizationDomain("WatchFlower");

        SettingsManager *sm = SettingsManager::getInstance();
        if (sm && sm->getSysTray())
        {
            AndroidService *as = new AndroidService();
            if (!as) return EXIT_FAILURE;

            return app.exec();
        }

        return EXIT_SUCCESS;
#endif
    }

    // Hacks ///////////////////////////////////////////////////////////////////

#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
    // NVIDIA driver suspend&resume hack
    auto format = QSurfaceFormat::defaultFormat();
    format.setOption(QSurfaceFormat::ResetNotification);
    QSurfaceFormat::setDefaultFormat(format);
#endif

#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS)
    // Qt 6.6+ mouse wheel hack
    qputenv("QT_QUICK_FLICKABLE_WHEEL_DECELERATION", "2500");
#endif

    // GUI application /////////////////////////////////////////////////////////

    SingleApplication app(argc, argv, false);

    // Application name
    app.setApplicationName("WatchFlower");
    app.setApplicationDisplayName("WatchFlower");
    app.setOrganizationName("WatchFlower");
    app.setOrganizationDomain("WatchFlower");

    // Init app components
    SettingsManager *sm = SettingsManager::getInstance();
    DatabaseManager *db = DatabaseManager::getInstance();
    NotificationManager *nm = NotificationManager::getInstance();
    DeviceManager *dm = new DeviceManager;
    if (!sm || !db || !nm || !dm)
    {
        qWarning() << "Cannot init app components!";
        return EXIT_FAILURE;
    }

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    ShareUtils *utilsShare = new ShareUtils();
#else
    QIcon appIcon(":/assets/gfx/logos/watchflower.svg");
    app.setWindowIcon(appIcon);

    SystrayManager *st = SystrayManager::getInstance();
    MenubarManager *mb = MenubarManager::getInstance();
#endif

    // Sun and Moon
    SunAndMoon sam;
    if (sm->getSunAndMoon())
    {
        sam.set(sm->getLatitude(), sm->getLongitude(), QDateTime::currentDateTime());
    }

    // Plant database
    PlantDatabase *pdb = PlantDatabase::getInstance();

    // Init generic utils
    UtilsApp *utilsApp = UtilsApp::getInstance();
    UtilsScreen *utilsScreen = UtilsScreen::getInstance();
    UtilsLanguage *utilsLanguage = UtilsLanguage::getInstance();
    if (!utilsApp || !utilsScreen || !utilsLanguage)
    {
        qWarning() << "Cannot init generic utils!";
        return EXIT_FAILURE;
    }

    bool qtConnectivityPatched = false;
#if defined(QT_CONNECTIVITY_PATCHED)
    qtConnectivityPatched = true;
#endif

    // Translate the application
    utilsLanguage->loadLanguage(sm->getAppLanguage());

    MobileUI::registerQML();
    DeviceUtils::registerQML();
    JournalUtils::registerQML();
    PlantUtils::registerQML();

    QQmlApplicationEngine engine;
    engine.addImportPath(":/WatchFlower");
    engine.addImportPath(":/ComponentLibrary");

    QQmlContext *engine_context = engine.rootContext();
    engine_context->setContextProperty("deviceManager", dm);
    engine_context->setContextProperty("settingsManager", sm);
    engine_context->setContextProperty("notificationManager", nm);
    engine_context->setContextProperty("utilsApp", utilsApp);
    engine_context->setContextProperty("utilsScreen", utilsScreen);
    engine_context->setContextProperty("utilsLanguage", utilsLanguage);
    engine_context->setContextProperty("plantDatabase", pdb);
    engine_context->setContextProperty("sunAndMoon", &sam);

    engine_context->setContextProperty("startMinimized", (start_minimized || sm->getMinimized()));
    engine_context->setContextProperty("qtConnectivityPatched", qtConnectivityPatched);

    // Load the main view
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    engine_context->setContextProperty("utilsShare", utilsShare);
    engine.loadFromModule("WatchFlower", "MobileApplication");
#else
    engine_context->setContextProperty("systrayManager", st);
    engine_context->setContextProperty("menubarManager", mb);
    engine.loadFromModule("WatchFlower", "DesktopApplication");
#endif

    if (engine.rootObjects().isEmpty())
    {
        qWarning() << "Cannot init QmlApplicationEngine!";
        return EXIT_FAILURE;
    }

    // For i18n retranslate
    utilsLanguage->setQmlEngine(&engine);

#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS) // desktop section

    // QQuickWindow must be valid at this point
    QQuickWindow *window = qobject_cast<QQuickWindow *>(engine.rootObjects().value(0));

    // React to secondary instances
    QObject::connect(&app, &SingleApplication::instanceStarted, window, &QQuickWindow::show);
    QObject::connect(&app, &SingleApplication::instanceStarted, window, &QQuickWindow::raise);

    // Systray?
    st->setupSystray(window);
    if (sm->getSysTray()) st->installSystray();

    // Menu bar
    mb->setupMenubar(window, dm);

#if defined(Q_OS_MACOS)
    // macOS dock
    MacOSDockHandler *dockIconHandler = MacOSDockHandler::getInstance();
    dockIconHandler->setupDock(window);
    engine_context->setContextProperty("utilsDock", dockIconHandler);
#endif

#endif // desktop section

#if defined(Q_OS_ANDROID)
    QNativeInterface::QAndroidApplication::hideSplashScreen(333);
    if (sm->getSysTray()) AndroidService::service_start();
#endif

    return app.exec();
}

/* ************************************************************************** */
