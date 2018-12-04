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

#include "systraymanager.h"

#include <QApplication>
#include <QSystemTrayIcon>
#include <QMenu>

#include <QQuickWindow>

/* ************************************************************************** */

SystrayManager *SystrayManager::instance = nullptr;

SystrayManager *SystrayManager::getInstance()
{
    if (instance == nullptr)
    {
        instance = new SystrayManager();
        return instance;
    }
    else
    {
        return instance;
    }
}

SystrayManager::SystrayManager()
{
    // Connect retry timer
    connect(&m_retryTimer, &QTimer::timeout, this, &SystrayManager::installSystray);
}

SystrayManager::~SystrayManager()
{
    delete m_actionShow;
    delete m_actionSettings;
    delete m_actionExit;
    delete m_sysTrayMenu;
    m_actionShow = nullptr;
    m_actionSettings = nullptr;
    m_actionExit = nullptr;
    m_sysTrayMenu = nullptr;

    removeSystray();
}

/* ************************************************************************** */

void SystrayManager::initSystray(QApplication *app, QQuickWindow *view)
{
    if (m_sysTrayMenu == nullptr)
    {
        m_saved_app = app;
        m_saved_view = view;

        m_sysTrayMenu = new QMenu();
        if (m_sysTrayMenu)
        {
            m_actionShow = new QAction(QObject::tr("Show"));
            if (m_saved_view->isVisible())
                m_actionShow->setText(QObject::tr("Hide"));
            m_actionSettings = new QAction(QObject::tr("Settings"));
            m_actionExit = new QAction(QObject::tr("Exit"));
            m_sysTrayMenu->addAction(m_actionShow);
            m_sysTrayMenu->addAction(m_actionSettings);
            m_sysTrayMenu->addAction(m_actionExit);

            QObject::connect(m_actionShow, &QAction::triggered, this, &SystrayManager::showHideButton);
            QObject::connect(m_actionSettings, &QAction::triggered, this, &SystrayManager::settingsButton);
            QObject::connect(m_actionExit, &QAction::triggered, m_saved_app, &QApplication::exit);
        }
    }
}

bool SystrayManager::installSystray()
{
    bool status = false;

    if (QSystemTrayIcon::isSystemTrayAvailable())
    {
        if (m_sysTray == nullptr && m_sysTrayMenu != nullptr)
        {
            m_sysTray = new QSystemTrayIcon();
            if (m_sysTray)
            {
#ifdef TARGET_OS_OSX
                QIcon trayIcon(":/assets/desktop/watchflower_tray_light.svg");
#else
                QIcon trayIcon(":/assets/desktop/watchflower_tray_dark.svg");
                QObject::connect(m_sysTray, &QSystemTrayIcon::activated, this, &SystrayManager::trayClicked);
#endif
                m_sysTray->setIcon(trayIcon);
                m_sysTray->setContextMenu(m_sysTrayMenu);
                m_sysTray->show();

                QObject::connect(m_sysTray, &QSystemTrayIcon::destroyed, this, &SystrayManager::aboutToBeDestroyed);
                QObject::connect(m_saved_view, &QQuickWindow::visibilityChanged, this, &SystrayManager::visibilityChanged);

                // Show greetings
                //m_sysTray->showMessage("WatchFlower", QObject::tr("WatchFlower is running in the background!"));

                status = true;
            }
        }
    }
    else
    {
        if (retryCount > 0)
        {
            m_retryTimer.setSingleShot(true);
            m_retryTimer.start(5000);
            retryCount--;
        }
    }

    return status;
}

void SystrayManager::removeSystray()
{
    if (m_sysTray)
    {
        m_retryTimer.stop();
        QObject::disconnect(m_saved_view, &QQuickWindow::visibilityChanged, this, &SystrayManager::visibilityChanged);
        QObject::disconnect(m_sysTray, &QSystemTrayIcon::activated, this, &SystrayManager::trayClicked);
        QObject::disconnect(m_sysTray, &QSystemTrayIcon::destroyed, this, &SystrayManager::aboutToBeDestroyed);
        delete m_sysTray;
        m_sysTray = nullptr;
    }
}

/* ************************************************************************** */

void SystrayManager::sendNotification(QString &text)
{
    if (QSystemTrayIcon::isSystemTrayAvailable())
    {
        if (m_sysTray)
        {
            m_sysTray->showMessage("WatchFlower", text);
        }
    }
}

/* ************************************************************************** */

void SystrayManager::trayClicked(QSystemTrayIcon::ActivationReason r)
{
    // Context, DoubleClick, Trigger, MiddleClick

    if (r == QSystemTrayIcon::Context)
    {
        // do nothing
    }
    else
    {
        showHideButton();
    }
}

void SystrayManager::showHideButton()
{
    if (m_saved_view->isVisible())
    {
        m_saved_view->hide();
    }
    else
    {
        m_saved_view->show();
        m_saved_view->raise();
    }
}

void SystrayManager::settingsButton()
{
    m_saved_view->show();
    m_saved_view->raise();
    Q_EMIT settingsClicked();
}

/* ************************************************************************** */

void SystrayManager::visibilityChanged()
{
    if (m_saved_view->isVisible())
    {
        m_actionShow->setText(QObject::tr("Hide"));
    }
    else
    {
        m_actionShow->setText(QObject::tr("Show"));
    }
}

void SystrayManager::aboutToBeDestroyed()
{
    m_sysTray = nullptr;
}

/* ************************************************************************** */
