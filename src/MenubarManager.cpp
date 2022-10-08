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

#include <QDesktopServices>
#include <QQuickWindow>
#include <QMenuBar>
#include <QMenu>

/* ************************************************************************** */

MenubarManager *MenubarManager::instance = nullptr;

MenubarManager *MenubarManager::getInstance()
{
    if (instance == nullptr)
    {
        instance = new MenubarManager();
    }

    return instance;
}

MenubarManager::MenubarManager()
{
    //
}

MenubarManager::~MenubarManager()
{
    delete m_actionSensorList;
    delete m_actionSensorScan;
    delete m_actionSensorRefresh;
    delete m_menuSensors;

    delete m_actionAbout;
    delete m_actionPreferences;
    delete m_actionWebsite;
    delete m_actionIssueTracker;
    delete m_actionReleaseNotes;
    delete m_actionTutorial;
    delete m_menuHelp;
}

/* ************************************************************************** */

void MenubarManager::setupMenubar(QQuickWindow *view, DeviceManager *dm)
{
    if (!view || !dm)
    {
        qWarning() << "MenubarManager::initSettings() no QQuickWindow or DeviceManager passed";
        return;
    }

    m_saved_devicemanager = dm;
    m_saved_view = view;

    QMenuBar *menuBar = new QMenuBar(nullptr);

    m_actionSensorList = new QAction(tr("Sensor list"));
    m_actionSensorScan = new QAction(tr("Scan for new sensors"));
    m_actionSensorRefresh = new QAction(tr("Refresh sensors"));

    connect(m_actionSensorList, &QAction::triggered, this, &MenubarManager::sensorList);
    connect(m_actionSensorScan, &QAction::triggered, this, &MenubarManager::sensorScan);
    connect(m_actionSensorRefresh, &QAction::triggered, this, &MenubarManager::sensorRefresh);

    m_menuSensors = new QMenu(tr("Sensors"));
    m_menuSensors->addAction(m_actionSensorList);
    m_menuSensors->addAction(m_actionSensorRefresh);
    m_menuSensors->addAction(m_actionSensorScan);
    menuBar->addMenu(m_menuSensors);

    m_actionAbout = new QAction(tr("About WatchFlower"));
    m_actionPreferences = new QAction(tr("Preferences"));
    m_actionWebsite = new QAction(tr("Visit website"));
    m_actionIssueTracker = new QAction(tr("Visit issue tracker"));
    m_actionReleaseNotes = new QAction(tr("Consult release notes"));
    m_actionTutorial = new QAction(tr("Show the tutorial"));

    connect(m_actionAbout, &QAction::triggered, this, &MenubarManager::about);
    connect(m_actionPreferences, &QAction::triggered, this, &MenubarManager::settings);
    connect(m_actionWebsite, &QAction::triggered, this, &MenubarManager::website);
    connect(m_actionIssueTracker, &QAction::triggered, this, &MenubarManager::issuetracker);
    connect(m_actionReleaseNotes, &QAction::triggered, this, &MenubarManager::releasenotes);
    connect(m_actionTutorial, &QAction::triggered, this, &MenubarManager::tutorial);

    m_menuHelp = new QMenu(tr("Help"));
    m_menuHelp->addAction(m_actionAbout);
    m_menuHelp->addAction(m_actionPreferences);
    m_menuHelp->addAction(m_actionTutorial);
    m_menuHelp->addSeparator();
    m_menuHelp->addAction(m_actionWebsite);
    m_menuHelp->addAction(m_actionIssueTracker);
    m_menuHelp->addAction(m_actionReleaseNotes);
    menuBar->addMenu(m_menuHelp);
}

/* ************************************************************************** */

void MenubarManager::sensorList()
{
    m_saved_view->show();
    m_saved_view->raise();
    Q_EMIT sensorsClicked();
}

void MenubarManager::sensorScan()
{
    m_saved_devicemanager->scanDevices_start();
}

void MenubarManager::sensorRefresh()
{
    m_saved_devicemanager->refreshDevices_start();
}

void MenubarManager::settings()
{
    m_saved_view->show();
    m_saved_view->raise();
    Q_EMIT settingsClicked();
}

void MenubarManager::about()
{
    m_saved_view->show();
    m_saved_view->raise();
    Q_EMIT aboutClicked();
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

void MenubarManager::tutorial()
{
    m_saved_view->show();
    m_saved_view->raise();
    Q_EMIT tutorialClicked();
}

/* ************************************************************************** */
