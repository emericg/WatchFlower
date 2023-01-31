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

#include "SystrayManager.h"

#include <QApplication>
#include <QQuickWindow>
#include <QSystemTrayIcon>
#include <QMenu>

/* ************************************************************************** */

SystrayManager *SystrayManager::instance = nullptr;

SystrayManager *SystrayManager::getInstance()
{
    if (instance == nullptr)
    {
        instance = new SystrayManager();
    }

    return instance;
}

SystrayManager::SystrayManager()
{
    // Connect retry timer
    connect(&m_retryTimer, &QTimer::timeout, this, &SystrayManager::installSystray);
}

SystrayManager::~SystrayManager()
{
    delete m_actionShow;
    delete m_actionDeviceList;
    delete m_actionSettings;
    delete m_actionExit;
    m_actionShow = nullptr;
    m_actionSettings = nullptr;
    m_actionExit = nullptr;

    delete m_sysTrayIcon;
    delete m_sysTrayMenu;
    m_sysTrayIcon = nullptr;
    m_sysTrayMenu = nullptr;

    removeSystray();
}

/* ************************************************************************** */

void SystrayManager::setupSystray(QApplication *app, QQuickWindow *view)
{
    if (!app || !view)
    {
        qWarning() << "SystrayManager::setupSystray() no QApplication or QQuickWindow passed";
        return;
    }

    m_saved_app = app;
    m_saved_view = view;
}

/* ************************************************************************** */

void SystrayManager::initSystray()
{
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    return;
#endif

    if (!m_saved_app || !m_saved_view)
    {
        qWarning() << "SystrayManager::initSystray() no QApplication or QQuickWindow saved";
        return;
    }

    if (m_sysTrayMenu == nullptr)
    {
        m_sysTrayMenu = new QMenu();
        if (m_sysTrayMenu)
        {
            m_actionDeviceList = new QAction(tr("Sensor list"));
            m_actionSettings = new QAction(tr("Settings") + "        ");
            m_actionShow = new QAction(tr("Hide"));
            if (!m_saved_view ||
                m_saved_view->isVisible() == false ||
                m_saved_view->visibility() == QWindow::Hidden ||
                m_saved_view->visibility() == QWindow::Minimized)
            {
                m_actionShow->setText(tr("Show"));
            }
            m_actionExit = new QAction(tr("Quit"));

            m_sysTrayMenu->addAction(m_actionDeviceList);
            m_sysTrayMenu->addAction(m_actionSettings);
            m_sysTrayMenu->addSeparator();
            m_sysTrayMenu->addAction(m_actionShow);
            m_sysTrayMenu->addAction(m_actionExit);

            connect(m_actionShow, &QAction::triggered, this, &SystrayManager::showHideButton);
            connect(m_actionDeviceList, &QAction::triggered, this, &SystrayManager::sensorsButton);
            connect(m_actionSettings, &QAction::triggered, this, &SystrayManager::settingsButton);
            connect(m_actionExit, &QAction::triggered, m_saved_app, &QApplication::exit);
        }

#if defined(Q_OS_MACOS)
        m_sysTrayIcon = new QIcon(":/assets/logos/watchflower_tray_dark.svg");
#else
        m_sysTrayIcon = new QIcon(":/assets/logos/watchflower_tray_dark.svg");
#endif
    }
}

bool SystrayManager::installSystray()
{
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    return false;
#endif

    bool status = false;

    if (QSystemTrayIcon::isSystemTrayAvailable())
    {
        if (m_sysTray == nullptr)
        {
            initSystray();
            m_sysTray = new QSystemTrayIcon();
        }

        if (m_sysTray != nullptr && m_sysTrayMenu != nullptr && m_sysTrayIcon != nullptr)
        {
#if !defined(Q_OS_MACOS)
            connect(m_sysTray, &QSystemTrayIcon::activated, this, &SystrayManager::trayClicked);
#endif
            m_sysTray->setIcon(*m_sysTrayIcon);
            m_sysTray->setContextMenu(m_sysTrayMenu);
            m_sysTray->show();

            connect(m_sysTray, &QSystemTrayIcon::destroyed, this, &SystrayManager::aboutToBeDestroyed);
            connect(m_saved_view, &QQuickWindow::visibilityChanged, this, &SystrayManager::visibilityChanged);

            // Show greetings
            //m_sysTray->showMessage("WatchFlower", tr("WatchFlower is running in the background!"));

            status = true;
        }
        else
        {
            qWarning() << "SystrayManager::installSystray() Cannot install systray...";
        }
    }
    else
    {
        if (retryCount > 0)
        {
            m_retryTimer.setSingleShot(true);
            m_retryTimer.start(3333);
            retryCount--;
        }
        else
        {
           qWarning() << "SystrayManager::installSystray() Empty systray counter";
        }
    }

    return status;
}

void SystrayManager::REinstallSystray()
{
    // Trying to launch a new instance will manually hide then show again the tray icon...
    // This hack helps in cases where the tray icon just disappears after some time, seen a lot on Gnome desktop with TopIcons Plus.
    // A different solution to this problem is to use gnome-shell-extension-appindicator instead of TopIcons Plus.

#if defined(Q_OS_LINUX)
    if (m_sysTray)
    {
        if (m_sysTrayIcon && m_sysTrayMenu)
        {
            m_sysTray->hide();
            m_sysTray->show();
        }
        else
        {
            qWarning() << "SystrayManager::REinstallSystray() ERROR";
        }
    }
#endif // Q_OS_LINUX
}

void SystrayManager::removeSystray()
{
    if (m_sysTray)
    {
        m_retryTimer.stop();
        disconnect(m_saved_view, &QQuickWindow::visibilityChanged, this, &SystrayManager::visibilityChanged);
        disconnect(m_sysTray, &QSystemTrayIcon::activated, this, &SystrayManager::trayClicked);
        disconnect(m_sysTray, &QSystemTrayIcon::destroyed, this, &SystrayManager::aboutToBeDestroyed);

        retryCount = 6;

        delete m_sysTray;
        m_sysTray = nullptr;
    }
}

/* ************************************************************************** */

void SystrayManager::sendNotification(QString &text)
{
    if (m_sysTray && QSystemTrayIcon::isSystemTrayAvailable())
    {
        m_sysTray->showMessage("WatchFlower", text);
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

void SystrayManager::sensorsButton()
{
    m_saved_view->show();
    m_saved_view->raise();
    Q_EMIT sensorsClicked();
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
        m_actionShow->setText(tr("Hide"));
    }
    else
    {
        m_actionShow->setText(tr("Show"));
    }
}

void SystrayManager::aboutToBeDestroyed()
{
    qDebug() << "aboutToBeDestroyed()";
}

/* ************************************************************************** */
