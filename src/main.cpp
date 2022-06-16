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
#include "NotificationManager.h"
#include "DeviceManager.h"
#include "PlantDatabase.h"
#include "Journal.h"

#include "utils_app.h"
#include "utils_screen.h"
#include "utils_language.h"
#include "utils_os_macosdock.h"

#include <MobileUI>
#include <MobileSharing>
#include <SingleApplication>

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

    // GUI application /////////////////////////////////////////////////////////

#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
    // NVIDIA suspend&resume hack
    auto format = QSurfaceFormat::defaultFormat();
    format.setOption(QSurfaceFormat::ResetNotification);
    QSurfaceFormat::setDefaultFormat(format);
#endif

    SingleApplication app(argc, argv);

    // Application name
    app.setApplicationName("WatchFlower");
    app.setApplicationDisplayName("WatchFlower");
    app.setOrganizationName("WatchFlower");
    app.setOrganizationDomain("WatchFlower");

#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS)
    // Application icon
    QIcon appIcon(":/assets/logos/watchflower.svg");
    app.setWindowIcon(appIcon);
#endif

    // Init components
    SettingsManager *sm = SettingsManager::getInstance();
    SystrayManager *st = SystrayManager::getInstance();
    NotificationManager *nm = NotificationManager::getInstance();
    DeviceManager *dm = new DeviceManager;
    if (!sm || !st || !nm || !dm)
    {
        qWarning() << "Cannot init WatchFlower components!";
        return EXIT_FAILURE;
    }

    // Plant database
    PlantDatabase *pdb = PlantDatabase::getInstance();

    // Init generic utils
    UtilsApp *utilsApp = UtilsApp::getInstance();
    UtilsScreen *utilsScreen = UtilsScreen::getInstance(&app);
    UtilsLanguage *utilsLanguage = UtilsLanguage::getInstance();
    if (!utilsScreen || !utilsApp || !utilsLanguage)
    {
        qWarning() << "Cannot init WatchFlower utils!";
        return EXIT_FAILURE;
    }

    // Translate the application
    utilsLanguage->loadLanguage(sm->getAppLanguage());

    // ThemeEngine
    qmlRegisterSingletonType(QUrl("qrc:/qml/ThemeEngine.qml"), "ThemeEngine", 1, 0, "Theme");

    MobileUI::registerQML();
    DeviceUtils::registerQML();
    JournalUtils::registerQML();

    // Then we start the UI
    QQmlApplicationEngine engine;
    QQmlContext *engine_context = engine.rootContext();

    engine_context->setContextProperty("deviceManager", dm);
    engine_context->setContextProperty("settingsManager", sm);
    engine_context->setContextProperty("systrayManager", st);
    engine_context->setContextProperty("plantDatabase", pdb);
    engine_context->setContextProperty("utilsApp", utilsApp);
    engine_context->setContextProperty("utilsLanguage", utilsLanguage);
    engine_context->setContextProperty("utilsScreen", utilsScreen);
    engine_context->setContextProperty("startMinimized", (start_minimized || sm->getMinimized()));

    // Load the main view
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(FORCE_MOBILE_UI)
    ShareUtils *utilsShare = new ShareUtils();
    engine_context->setContextProperty("utilsShare", utilsShare);
    engine.load(QUrl(QStringLiteral("qrc:/qml/MobileApplication.qml")));
#else
    engine.load(QUrl(QStringLiteral("qrc:/qml/DesktopApplication.qml")));
#endif
    if (engine.rootObjects().isEmpty())
    {
        qWarning() << "Cannot init QmlApplicationEngine!";
        return EXIT_FAILURE;
    }

    // For i18n retranslate
    utilsLanguage->setQmlEngine(&engine);

    // Notch handling // QQuickWindow must be valid at this point
    QQuickWindow *window = qobject_cast<QQuickWindow *>(engine.rootObjects().value(0));
    engine_context->setContextProperty("quickWindow", window);

#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS) // desktop section

    // Set systray?
    st->initSettings(&app, window);
    if (sm->getSysTray()) st->installSystray();

#if defined(Q_OS_LINUX)
    // GNOME hack for the mysterious disappearences of the tray icon with TopIcon Plus
    // gnome-shell-extension-appindicator is recommanded instead of TopIcon Plus
    //QObject::connect(&app, &SingleApplication::instanceStarted, st, &SystrayManager::REinstallSystray);
#endif

#if defined(Q_OS_MACOS)
    MacOSDockHandler *dockIconHandler = MacOSDockHandler::getInstance();
    QObject::connect(dockIconHandler, &MacOSDockHandler::dockIconClicked, window, &QQuickWindow::show);
    QObject::connect(dockIconHandler, &MacOSDockHandler::dockIconClicked, window, &QQuickWindow::raise);
#endif

#endif // desktop section

#if defined(Q_OS_ANDROID)
    QNativeInterface::QAndroidApplication::hideSplashScreen(333);
    if (sm->getSysTray()) AndroidService::service_start();
#endif

    return app.exec();
}

/* ************************************************************************** */
