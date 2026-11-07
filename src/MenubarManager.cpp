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
 * \date      2022
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "MenubarManager.h"
#include "DeviceManager.h"

#include <QCoreApplication>
#include <QQmlEngine>
#include <QJSEngine>
#include <QDesktopServices>
#include <QKeySequence>
#include <QQuickWindow>
#include <QAction>

#if defined(Q_OS_MACOS)
#include <QMenuBar>
#include <QMenu>
#endif

/* ************************************************************************** */
/* ************************************************************************** */

MenubarManager *MenubarManager::getInstance()
{
    static MenubarManager *instance = new MenubarManager(QCoreApplication::instance());
    return instance;
}

MenubarManager *MenubarManager::create(QQmlEngine *, QJSEngine *)
{
    MenubarManager *instance = getInstance();
    QJSEngine::setObjectOwnership(instance, QJSEngine::CppOwnership);
    return instance;
}

/* ************************************************************************** */

MenubarManager::MenubarManager(QObject *parent) : QObject(parent)
{
    //
}

MenubarManager::~MenubarManager()
{
#if defined(Q_OS_MACOS)
    delete m_actionAbout;
    delete m_actionSettings;

    delete m_actionExport;
    delete m_menuFile;

    delete m_actionViewSensors;
    delete m_actionViewPlantBrowser;
    delete m_actionViewDeviceBrowser;
    delete m_menuView;

    delete m_actionSensorRefresh;
    delete m_actionSensorScan;
    delete m_menuSensors;

    delete m_actionMinimize;
    delete m_actionMaximize;
    delete m_actionFullScreen;
    delete m_actionClose;
    delete m_menuWindow;

    delete m_actionTutorial;
    delete m_actionWebsite;
    delete m_actionIssueTracker;
    delete m_actionReleaseNotes;
    delete m_menuHelp;
#endif // Q_OS_MACOS
}

/* ************************************************************************** */
/* ************************************************************************** */

void MenubarManager::setupMenubar(QQuickWindow *view)
{
#if defined(Q_OS_MACOS)
    if (!view)
    {
        qWarning() << "MenubarManager::setupMenubar() no QQuickWindow passed";
        return;
    }

    m_saved_view = view;

    QMenuBar *menuBar = new QMenuBar(nullptr);

    // Merged into macOS app menu

    m_actionAbout = new QAction(tr("About WatchFlower"));
    m_actionAbout->setMenuRole(QAction::AboutRole);
    connect(m_actionAbout, &QAction::triggered, this, &MenubarManager::about);

    m_actionSettings = new QAction(tr("Settings..."));
    m_actionSettings->setMenuRole(QAction::PreferencesRole);
    connect(m_actionSettings, &QAction::triggered, this, &MenubarManager::settings);

    // File menu

    m_actionExport = new QAction(tr("Export data..."));
    m_actionExport->setShortcut(QKeySequence(QKeySequence::Save));
    connect(m_actionExport, &QAction::triggered, this, &MenubarManager::fileExport);

    m_menuFile = new QMenu(tr("File"));
    m_menuFile->addAction(m_actionExport);
    menuBar->addMenu(m_menuFile);

    // View menu

    m_actionViewSensors = new QAction(tr("Sensor list"));
    m_actionViewPlantBrowser = new QAction(tr("Plant browser"));
    m_actionViewDeviceBrowser = new QAction(tr("Device browser"));

    const QList<QAction *> viewActions = { m_actionViewSensors,
                                           m_actionViewPlantBrowser,
                                           m_actionViewDeviceBrowser };

    m_menuView = new QMenu(tr("View"));
    for (int i = 0; i < viewActions.size(); i++)
    {
        QAction *action = viewActions.at(i);
        action->setCheckable(true);
        action->setShortcut(QKeySequence(QStringLiteral("Ctrl+%1").arg(i + 1)));
        connect(action, &QAction::triggered, this, [this, i]() { showWindow(); Q_EMIT viewClicked(i); });
        m_menuView->addAction(action);
    }
    m_menuView->addSeparator();
    // enter fullscreen will be added automatically at the end of the view menu
    menuBar->addMenu(m_menuView);

    updateViewActions();

    // Sensors menu

    m_actionSensorRefresh = new QAction(tr("Refresh sensors"));
    m_actionSensorScan = new QAction(tr("Scan for new sensors"));

    connect(m_actionSensorRefresh, &QAction::triggered, this, &MenubarManager::sensorRefresh);
    connect(m_actionSensorScan, &QAction::triggered, this, &MenubarManager::sensorScan);

    m_menuSensors = new QMenu(tr("Sensors"));
    m_menuSensors->addAction(m_actionSensorRefresh);
    m_menuSensors->addAction(m_actionSensorScan);
    menuBar->addMenu(m_menuSensors);

    // Window menu

    m_actionMinimize = new QAction(tr("Minimize"));
    m_actionMaximize = new QAction(tr("Zoom"));
    m_actionFullScreen = new QAction(tr("Enter Full Screen"));
    m_actionClose = new QAction(tr("Close window"));

    m_actionMinimize->setShortcut(QKeySequence(QStringLiteral("Ctrl+M")));
    m_actionFullScreen->setShortcut(QKeySequence(QKeySequence::FullScreen));
    m_actionClose->setShortcut(QKeySequence(QKeySequence::Close));

    connect(m_actionMinimize, &QAction::triggered, this, &MenubarManager::windowMinimize);
    connect(m_actionMaximize, &QAction::triggered, this, &MenubarManager::windowMaximize);
    connect(m_actionFullScreen, &QAction::triggered, this, &MenubarManager::windowFullScreen);
    connect(m_actionClose, &QAction::triggered, this, &MenubarManager::windowClose);

    m_menuWindow = new QMenu(tr("Window"));
    m_menuWindow->addAction(m_actionMinimize);
    m_menuWindow->addAction(m_actionMaximize);
    m_menuWindow->addSeparator();
    m_menuWindow->addAction(m_actionFullScreen);
    m_menuWindow->addSeparator();
    m_menuWindow->addAction(m_actionClose);
    menuBar->addMenu(m_menuWindow);

    connect(m_saved_view, &QWindow::visibilityChanged, this, &MenubarManager::updateWindowActions);
    updateWindowActions();

    // Help menu

    m_actionTutorial = new QAction(tr("Show the tutorial"));
    m_actionWebsite = new QAction(tr("Visit website"));
    m_actionIssueTracker = new QAction(tr("Visit issue tracker"));
    m_actionReleaseNotes = new QAction(tr("Consult release notes"));

    connect(m_actionTutorial, &QAction::triggered, this, &MenubarManager::tutorial);
    connect(m_actionWebsite, &QAction::triggered, this, &MenubarManager::website);
    connect(m_actionIssueTracker, &QAction::triggered, this, &MenubarManager::issuetracker);
    connect(m_actionReleaseNotes, &QAction::triggered, this, &MenubarManager::releasenotes);

    m_menuHelp = new QMenu(tr("Help"));
    m_menuHelp->addAction(m_actionAbout);
    m_menuHelp->addAction(m_actionSettings);
    m_menuHelp->addAction(m_actionTutorial);
    m_menuHelp->addSeparator();
    m_menuHelp->addAction(m_actionWebsite);
    m_menuHelp->addAction(m_actionIssueTracker);
    m_menuHelp->addAction(m_actionReleaseNotes);
    menuBar->addMenu(m_menuHelp);
#else
    Q_UNUSED(view)
#endif // Q_OS_MACOS
}

/* ************************************************************************** */

void MenubarManager::updateViewActions()
{
    if (m_actionViewSensors) m_actionViewSensors->setChecked(m_currentView == 0);
    if (m_actionViewPlantBrowser) m_actionViewPlantBrowser->setChecked(m_currentView == 1);
    if (m_actionViewDeviceBrowser) m_actionViewDeviceBrowser->setChecked(m_currentView == 2);
}

void MenubarManager::setCurrentView(int screen)
{
    m_currentView = screen;
    updateViewActions();
}

void MenubarManager::updateWindowActions()
{
    if (!m_saved_view) return;

    const QWindow::Visibility v = m_saved_view->visibility();

    // Remember the last state (Windowed or Maximized) so we can restore it when leaving full screen
    if (v != QWindow::FullScreen && v != QWindow::Minimized && v != QWindow::Hidden)
    {
        m_previousVisibility = v;
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void MenubarManager::about()
{
    showWindow();
    Q_EMIT aboutClicked();
}

void MenubarManager::settings()
{
    showWindow();
    Q_EMIT settingsClicked();
}

/* ************************************************************************** */

void MenubarManager::fileExport()
{
    showWindow();
    Q_EMIT exportClicked();
}

/* ************************************************************************** */

void MenubarManager::sensorRefresh()
{
    DeviceManager::getInstance()->refreshDevices_start();
}

void MenubarManager::sensorScan()
{
    DeviceManager::getInstance()->scanDevices_start();
}

/* ************************************************************************** */

void MenubarManager::windowMinimize()
{
    if (m_saved_view) m_saved_view->setVisibility(QWindow::Minimized);
}

void MenubarManager::windowMaximize()
{
    if (!m_saved_view) return;

    // Toggle, matching the behavior of the macOS "Zoom" action
    if (m_saved_view->visibility() == QWindow::Maximized)
    {
        m_saved_view->setVisibility(QWindow::Windowed);
    }
    else
    {
        m_saved_view->setVisibility(QWindow::Maximized);
    }
}

void MenubarManager::windowFullScreen()
{
    if (!m_saved_view) return;

    if (m_saved_view->visibility() == QWindow::FullScreen)
    {
        // Restore the pre-fullscreen state
        m_saved_view->setVisibility(m_previousVisibility);
    }
    else
    {
        m_saved_view->setVisibility(QWindow::FullScreen);
    }
}

void MenubarManager::showWindow()
{
    if (!m_saved_view) return;

    // Only show() if the window is actually hidden/minimized
    if (!m_saved_view->isVisible() || m_saved_view->visibility() == QWindow::Minimized)
    {
        m_saved_view->show();
    }
    m_saved_view->raise();
    m_saved_view->requestActivate();
}

void MenubarManager::windowClose()
{
    if (m_saved_view) m_saved_view->close();
}

/* ************************************************************************** */

void MenubarManager::tutorial()
{
    showWindow();
    Q_EMIT tutorialClicked();
}

void MenubarManager::website()
{
    QDesktopServices::openUrl(QUrl("https://emeric.io/WatchFlower"));
}

void MenubarManager::issuetracker()
{
    QDesktopServices::openUrl(QUrl("https://github.com/emericg/WatchFlower/issues"));
}

void MenubarManager::releasenotes()
{
    QDesktopServices::openUrl(QUrl("https://github.com/emericg/WatchFlower/releases"));
}

/* ************************************************************************** */
/* ************************************************************************** */
