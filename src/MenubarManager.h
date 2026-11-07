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

#ifndef MENUBAR_MANAGER_H
#define MENUBAR_MANAGER_H
/* ************************************************************************** */

#include <QtQml/qqmlregistration.h>

#include <QObject>
#include <QWindow>

class QJSEngine;
class QQmlEngine;

class QMenu;
class QAction;
class QQuickWindow;

/* ************************************************************************** */

/*!
 * \brief The MenubarManager class
 */
class MenubarManager: public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    QQuickWindow *m_saved_view = nullptr;

    QAction *m_actionAbout = nullptr;
    QAction *m_actionSettings = nullptr;

    QMenu *m_menuFile = nullptr;
    QAction *m_actionExport = nullptr;

    QMenu *m_menuView = nullptr;
    QAction *m_actionViewSensors = nullptr;
    QAction *m_actionViewPlantBrowser = nullptr;
    QAction *m_actionViewDeviceBrowser = nullptr;

    int m_currentView = -1; //!< UI screen currently shown, for the View menu checkmark

    QMenu *m_menuSensors = nullptr;
    QAction *m_actionSensorRefresh = nullptr;
    QAction *m_actionSensorScan = nullptr;

    QMenu *m_menuWindow = nullptr;
    QAction *m_actionMinimize = nullptr;
    QAction *m_actionMaximize = nullptr;
    QAction *m_actionFullScreen = nullptr;
    QAction *m_actionClose = nullptr;

    QWindow::Visibility m_previousVisibility = QWindow::Windowed; //!< state to restore when leaving full screen

    QMenu *m_menuHelp = nullptr;
    QAction *m_actionTutorial = nullptr;
    QAction *m_actionWebsite = nullptr;
    QAction *m_actionIssueTracker = nullptr;
    QAction *m_actionReleaseNotes = nullptr;

    void showWindow();

    // Singleton
    explicit MenubarManager(QObject *parent = nullptr);
    ~MenubarManager();

signals:
    void settingsClicked();
    void aboutClicked();
    void tutorialClicked();
    void exportClicked();
    void viewClicked(int screen);

public:
    static MenubarManager *getInstance();
    static MenubarManager *create(QQmlEngine *, QJSEngine *);

    /*!
     * \brief Create the macOS menu bar.
     * \param view: the application main window, target of the Window menu actions.
     */
    void setupMenubar(QQuickWindow *view);

    /*!
     * \brief Set the screen currently shown, to update the View menu checkmark.
     * \param screen: screen index, as emitted by viewClicked(), or -1 for none.
     */
    Q_INVOKABLE void setCurrentView(int screen);

private slots:
    void updateViewActions();
    void updateWindowActions();
    void about();
    void settings();
    void fileExport();

    void sensorRefresh();
    void sensorScan();

    void windowMinimize();
    void windowMaximize();
    void windowFullScreen();
    void windowClose();

    void tutorial();
    void website();
    void issuetracker();
    void releasenotes();
};

/* ************************************************************************** */
#endif // MENUBAR_MANAGER_H
