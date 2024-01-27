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

#ifndef SYSTRAY_MANAGER_H
#define SYSTRAY_MANAGER_H
/* ************************************************************************** */

#include <QtGlobal>
#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS)

#include <QObject>
#include <QSystemTrayIcon>
#include <QTimer>

class QMenu;
class QAction;
class QApplication;
class QQuickWindow;

/* ************************************************************************** */

/*!
 * \brief The SystrayManager class
 */
class SystrayManager: public QObject
{
    Q_OBJECT

    QApplication *m_saved_app = nullptr;
    QQuickWindow *m_saved_window = nullptr;

    QSystemTrayIcon *m_sysTray = nullptr;
    QIcon *m_sysTrayIcon = nullptr;
    QMenu *m_sysTrayMenu = nullptr;
    QAction *m_actionShow = nullptr;
    QAction *m_actionDeviceList = nullptr;
    QAction *m_actionSettings = nullptr;
    QAction *m_actionExit = nullptr;

    QTimer m_retryTimer;
    int retryCount = 6;

    static SystrayManager *instance;

    SystrayManager();
    ~SystrayManager();

    void initSystray();

signals:
    void showClicked();
    void hideClicked();
    void sensorsClicked();
    void settingsClicked();
    void quitClicked();

public:
    static SystrayManager *getInstance();
    void setupSystray(QQuickWindow *window);

public slots:
    bool installSystray();
    void REinstallSystray();
    void removeSystray();
    void sendNotification(const QString &text);

private slots:
    void trayClicked(const QSystemTrayIcon::ActivationReason r);
    void showHideButton();
    void sensorsButton();
    void settingsButton();

    void visibilityChanged();
    void aboutToBeDestroyed();
};

/* ************************************************************************** */
#endif // !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS)
#endif // SYSTRAY_MANAGER_H
